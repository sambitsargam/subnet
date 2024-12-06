import os
import pytest
from flaky import flaky
import bittensor as bt
from bitsec.utils.data import create_challenge, PredictionResponse
from typing import Tuple

SPEND_MONEY = os.environ.get("SPEND_MONEY", False)
if SPEND_MONEY:
    bt.logging.set_debug()

@flaky(max_runs=7)
def test_create_challenge_non_vulnerable():
    if not SPEND_MONEY:
        return

    """Test creating a non-vulnerable challenge."""
    code, expected_response = create_challenge(vulnerable=False)
    
    # Basic type checks
    assert isinstance(code, str), f"Expected str, got {type(code)}"
    assert isinstance(expected_response, PredictionResponse), f"Expected PredictionResponse, got {type(expected_response)}"
    
    # Code should not be empty
    assert len(code) > 0, f"Expected code to not be empty, got '{code}'"
    
    # Response should match expectations for non-vulnerable code
    assert not expected_response.prediction, f"Expected response should be non-vulnerable, got {expected_response}. Code: {code}"  # True means vulnerable
    assert len(expected_response.vulnerabilities) == 0, f"Expected response should have no vulnerabilities, got {expected_response}. Code: {code}"

@flaky(max_runs=7)
def test_create_challenge_vulnerable():
    """Test creating a vulnerable challenge."""
    if not SPEND_MONEY:
        return

    code, expected_response = create_challenge(vulnerable=True)
    
    # Basic type checks
    assert isinstance(code, str), f"Expected str, got {type(code)}"
    assert isinstance(expected_response, PredictionResponse), f"Expected PredictionResponse, got {type(expected_response)}"
    
    # Code should not be empty
    assert len(code) > 0, f"Expected code to not be empty, got '{code}'"
    
    # Response should match expectations for vulnerable code
    assert expected_response.prediction, f"Expected response should be vulnerable, got {expected_response}. Code: {code}"  # True means vulnerable
    assert len(expected_response.vulnerabilities) > 0, f"Expected response should have vulnerabilities, got {expected_response}. Code: {code}"

@flaky(max_runs=7)
def test_create_challenge_return_type():
    """Test that create_challenge returns the correct type."""
    if not SPEND_MONEY:
        return
    
    result = create_challenge(vulnerable=False)
    assert isinstance(result, tuple), f"Expected tuple, got {type(result)}"
    assert len(result) == 2, f"Expected tuple of length 2, got {len(result)}"
    assert isinstance(result[0], str), f"Expected str, got {type(result[0])}"  # code
    assert isinstance(result[1], PredictionResponse), f"Expected PredictionResponse, got {type(result[1])}"  # response

@flaky(max_runs=7)
def test_create_challenge_different_outputs():
    """Test that create_challenge generates different challenges."""
    if not SPEND_MONEY:
        return
    
    result1 = create_challenge(vulnerable=False)
    result2 = create_challenge(vulnerable=False)

    # Save some money by retrying until different code samples are generated
    i = 0
    while result1[0] == result2[0]:
        bt.logging.info(f"test_create_challenge_different_outputs: Generated same code sample {i} times in a row. Retrying...")
        i += 1
        if i > 10:
            raise ValueError("Failed to generate different code samples")
        result2 = create_challenge(vulnerable=False)
    
    # Two different calls should return different code samples
    assert result1[0] != result2[0], f"Code samples should be different\nR1: {result1[0]}\nR2: {result2[0]}"
    
    # But they should maintain the same vulnerability status
    assert not result2[1].prediction, f"Expected R2 response should not be vulnerable: {result2[1]}"
    assert not result1[1].prediction, f"Expected R1 response should not be vulnerable: {result1[1]}"

@flaky(max_runs=7)
def test_create_challenge_code_syntax():
    """Test that generated code has basic Solidity syntax."""
    if not SPEND_MONEY:
        return
    
    code, _ = create_challenge(vulnerable=False)
    
    # Check for basic Solidity syntax
    assert code.startswith("// SPDX-License-Identifier: MIT"), f"Expected code to start with '// SPDX-License-Identifier: MIT', got '{code}'"
    assert "pragma solidity" in code, f"Expected code to contain 'pragma solidity', got '{code}'"
    assert "contract" in code, f"Expected code to contain 'contract', got '{code}'"
    
    # Check for common Solidity keywords
    assert "function" in code, f"Expected code to contain 'function', got '{code}'"
    assert "public" in code or "private" in code or "internal" in code, f"Expected code to contain 'public', 'private', or 'internal', got '{code}'"
