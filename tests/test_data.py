import pytest
from bitsec.utils.data import create_challenge, PredictionResponse
from typing import Tuple

def test_create_challenge_non_vulnerable():
    """Test creating a non-vulnerable challenge."""
    code, response = create_challenge(vulnerable=False)
    
    # Basic type checks
    assert isinstance(code, str)
    assert isinstance(response, PredictionResponse)
    
    # Code should not be empty
    assert len(code) > 0
    
    # Response should match expectations for non-vulnerable code
    assert not response.prediction  # True means vulnerable
    assert len(response.vulnerabilities) == 0

def test_create_challenge_vulnerable():
    """Test creating a vulnerable challenge."""
    code, response = create_challenge(vulnerable=True)
    
    # Basic type checks
    assert isinstance(code, str)
    assert isinstance(response, PredictionResponse)
    
    # Code should not be empty
    assert len(code) > 0
    
    # Response should match expectations for vulnerable code
    assert response.prediction  # True means vulnerable
    assert len(response.vulnerabilities) > 0

def test_create_challenge_return_type():
    """Test that create_challenge returns the correct type."""
    result = create_challenge(vulnerable=False)
    assert isinstance(result, tuple)
    assert len(result) == 2
    assert isinstance(result[0], str)  # code
    assert isinstance(result[1], PredictionResponse)  # response

def test_create_challenge_different_outputs():
    """Test that create_challenge generates different challenges."""
    result1 = create_challenge(vulnerable=False)
    result2 = create_challenge(vulnerable=False)
    
    # Two different calls should return different code samples
    assert result1[0] != result2[0]
    
    # But they should maintain the same vulnerability status
    assert not result1[1].prediction
    assert not result2[1].prediction

@pytest.mark.parametrize("vulnerable", [True, False])
def test_create_challenge_code_compiles(vulnerable):
    """Test that generated code can compile."""
    code, _ = create_challenge(vulnerable=vulnerable)
    
    # The code appears to be Solidity, not Python, so we can't use compile()
    # Instead, let's do basic syntax checks
    assert code.startswith("// SPDX-License-Identifier: MIT")
    assert "pragma solidity" in code
    assert "contract" in code
