import os
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
import bittensor as bt
import numpy as np
from fastapi import Request
import json

from neurons.validator_proxy import ValidatorProxy
from bitsec.protocol import PredictionResponse, Vulnerability, VulnerabilityByMiner, LineRange
from bitsec.base.vulnerability_category import VulnerabilityCategory

@pytest.fixture
def mock_validator() -> MagicMock:
    """
    Create a mock validator with necessary attributes.
    
    Returns:
        MagicMock: A mock validator object.
    """
    validator = MagicMock()
    validator.wallet = MagicMock()
    validator.metagraph = MagicMock()
    validator.metagraph.uids = np.array([0, 1, 2])
    validator.metagraph.R = np.array([0.1, 0.2, 0.3])
    validator.metagraph.I = np.array([0.4, 0.5, 0.6])
    validator.metagraph.E = np.array([0.7, 0.8, 0.9])
    validator.metagraph.axons = {0: MagicMock(), 1: MagicMock(), 2: MagicMock()}
    validator.last_responding_miner_uids = [1, 2]
    validator.config = MagicMock()
    validator.config.neuron.full_path = "/tmp"
    validator.config.neuron.sample_size = 2
    validator.config.proxy.port = None
    return validator

@pytest.fixture
def mock_request() -> MagicMock:
    """
    Create a mock request object.
    
    Returns:
        MagicMock: A mock request object.
    """
    request = MagicMock()
    request.json = AsyncMock(return_value={"code": "contract Test {}"})
    return request

@pytest.fixture
def mock_prediction_responses() -> list[PredictionResponse]:
    """
    Create mock prediction responses.
    
    Returns:
        list[PredictionResponse]: A list of mock prediction responses.
    """
    vuln = Vulnerability(
        category=VulnerabilityCategory.ARITHMETIC_OVERFLOW_AND_UNDERFLOW,
        line_ranges=[LineRange(start=1, end=9)],
        description="Can lead to loss of funds",
        vulnerable_code="",
        code_to_exploit="",
        rewritten_code_to_fix_vulnerability=""
    )
    
    return [
        PredictionResponse(prediction=True, vulnerabilities=[vuln]),
        PredictionResponse(prediction=True, vulnerabilities=[vuln])
    ]

@pytest.fixture
def sample_vulnerability() -> Vulnerability:
    """
    Create a sample vulnerability for testing.
    
    Returns:
        Vulnerability: A sample vulnerability instance
    """
    return Vulnerability(
        category=VulnerabilityCategory.ARITHMETIC_OVERFLOW_AND_UNDERFLOW,
        line_ranges=[LineRange(start=1, end=9)],
        description="Can lead to arithmetic overflow",
        vulnerable_code="function add(uint a, uint b) returns (uint) { return a + b; }",
        code_to_exploit="add(MAX_UINT, 1)",
        rewritten_code_to_fix_vulnerability="function add(uint a, uint b) returns (uint) { uint c = a + b; require(c >= a); return c; }"
    )

def test_vulnerability_by_miner_from_tuple(sample_vulnerability: Vulnerability) -> None:
    """
    Test creating VulnerabilityByMiner from tuple.
    
    Args:
        sample_vulnerability: Sample vulnerability fixture
    """
    miner_id = "123"
    vuln_by_miner = VulnerabilityByMiner.from_tuple((miner_id, sample_vulnerability))
    
    assert vuln_by_miner.miner_id == miner_id
    assert vuln_by_miner.category == sample_vulnerability.category
    assert vuln_by_miner.line_ranges == sample_vulnerability.line_ranges
    assert vuln_by_miner.description == sample_vulnerability.description
    assert vuln_by_miner.vulnerable_code == sample_vulnerability.vulnerable_code
    assert vuln_by_miner.code_to_exploit == sample_vulnerability.code_to_exploit
    assert vuln_by_miner.rewritten_code_to_fix_vulnerability == sample_vulnerability.rewritten_code_to_fix_vulnerability

def test_vulnerability_by_miner_to_tuple(sample_vulnerability: Vulnerability) -> None:
    """
    Test converting VulnerabilityByMiner to tuple.
    
    Args:
        sample_vulnerability: Sample vulnerability fixture
    """
    miner_id = "123"
    vuln_by_miner = VulnerabilityByMiner(
        miner_id=miner_id,
        **sample_vulnerability.model_dump()
    )
    
    result_miner_id, result_vuln = vuln_by_miner.to_tuple()
    
    assert result_miner_id == miner_id
    assert isinstance(result_vuln, Vulnerability)
    assert result_vuln.model_dump() == sample_vulnerability.model_dump()

def test_vulnerability_by_miner_from_json(sample_vulnerability: Vulnerability) -> None:
    """
    Test creating VulnerabilityByMiner from JSON.
    
    Args:
        sample_vulnerability: Sample vulnerability fixture
    """
    miner_id = "123"
    data = {
        "miner_id": miner_id,
        **sample_vulnerability.model_dump()
    }
    
    # Test with dict
    vuln_from_dict = VulnerabilityByMiner.from_json(data)
    assert vuln_from_dict.miner_id == miner_id
    assert vuln_from_dict.model_dump(exclude={'miner_id'}) == sample_vulnerability.model_dump()
    
    # Test with JSON string
    json_str = json.dumps(data)
    vuln_from_str = VulnerabilityByMiner.from_json(json_str)
    assert vuln_from_str.miner_id == miner_id
    assert vuln_from_str.model_dump(exclude={'miner_id'}) == sample_vulnerability.model_dump()

@pytest.mark.asyncio
async def test_forward_with_valid_responses(
    mock_validator: MagicMock,
    mock_request: MagicMock,
    mock_prediction_responses: list[PredictionResponse]
) -> None:
    """
    Test the forward method with valid miner responses.
    
    Args:
        mock_validator: Mock validator fixture
        mock_request: Mock request fixture
        mock_prediction_responses: Mock prediction responses fixture
    """
    proxy = ValidatorProxy(mock_validator)
    
    # Mock the dendrite call
    proxy.dendrite = AsyncMock(return_value=mock_prediction_responses)
    
    # Call forward method
    response = await proxy.forward(mock_request)
    
    # Verify the response structure
    assert isinstance(response, dict)
    assert 'uids' in response
    assert 'ranks' in response
    assert 'incentives' in response
    assert 'emissions' in response
    assert 'fqdn' in response
    
    # Verify the values - updated to match actual behavior
    assert response['uids'] == [1, 2]  # From mock_validator.last_responding_miner_uids
    assert response['ranks'] == [0.2, 0.3]  # From mock_validator.metagraph.R
    assert response['incentives'] == [0.5, 0.6]  # From mock_validator.metagraph.I
    assert response['emissions'] == [0.8, 0.9]  # From mock_validator.metagraph.E
    
    # Verify vulnerability data
    assert 'vulnerabilities' in response
    assert 'predictions_from_miners' in response
    assert len(response['vulnerabilities']) == 2  # One vulnerability from each miner
    assert len(response['predictions_from_miners']) == 2
    
    # Check vulnerability structure
    for vuln in response['vulnerabilities']:
        assert isinstance(vuln, VulnerabilityByMiner)
        assert vuln.miner_id in ['1', '2']  # Updated miner IDs
        assert vuln.category == VulnerabilityCategory.ARITHMETIC_OVERFLOW_AND_UNDERFLOW
        assert vuln.line_ranges[0]["start"] == 1
        assert vuln.line_ranges[0]["end"] == 9
        assert isinstance(vuln.description, str)
        assert isinstance(vuln.vulnerable_code, str)
        assert isinstance(vuln.code_to_exploit, str)
        assert isinstance(vuln.rewritten_code_to_fix_vulnerability, str)
    
    # Check predictions_from_miners matches vulnerabilities
    for pred in response['predictions_from_miners']:
        assert isinstance(pred, dict)
        assert pred['miner_id'] in ['1', '2']  # Updated miner IDs
        assert pred['category'] == VulnerabilityCategory.ARITHMETIC_OVERFLOW_AND_UNDERFLOW
        assert isinstance(pred['line_ranges'], list)
        assert pred['line_ranges'][0]['start'] == 1
        assert pred['line_ranges'][0]['end'] == 9

@pytest.mark.asyncio
async def test_forward_with_no_valid_responses(
    mock_validator: MagicMock,
    mock_request: MagicMock
) -> None:
    """
    Test the forward method with no valid miner responses.
    
    Args:
        mock_validator: Mock validator fixture
        mock_request: Mock request fixture
    """
    proxy = ValidatorProxy(mock_validator)
    
    # Mock the dendrite call with no valid predictions
    proxy.dendrite = AsyncMock(return_value=[
        PredictionResponse(prediction=False, vulnerabilities=[]),
        PredictionResponse(prediction=False, vulnerabilities=[])
    ])
    
    # Call forward method and expect HTTPException
    response = await proxy.forward(mock_request)
    assert response.status_code == 500
    assert response.detail == "No valid response received"

# @pytest.mark.asyncio
# async def test_forward_with_empty_miner_uids(
#     mock_validator: MagicMock,
#     mock_request: MagicMock,
#     mock_prediction_responses: list[PredictionResponse]
# ) -> None:
#     """
#     Test the forward method when there are no responding miner UIDs.
    
#     Args:
#         mock_validator: Mock validator fixture
#         mock_request: Mock request fixture
#         mock_prediction_responses: Mock prediction responses fixture
#     """
#     # Set up additional metagraph mocks needed for random UID selection
#     mock_validator.metagraph.S = np.zeros(3)  # Stake
#     mock_validator.metagraph.validator_permit = np.ones(3, dtype=bool)  # All have permits
#     mock_validator.metagraph.block = 0
#     mock_validator.vpermit_tao_limit = 0  # No stake requirement
    
#     mock_validator.last_responding_miner_uids = []
#     proxy = ValidatorProxy(mock_validator)
    
#     # Mock the dendrite call
#     proxy.dendrite = AsyncMock(return_value=mock_prediction_responses)
    
#     # Call forward method
#     response = await proxy.forward(mock_request)
    
#     # Verify that random UIDs were sampled and response structure
#     assert mock_validator.last_responding_miner_uids == []
#     assert isinstance(response, dict)
#     assert 'uids' in response
#     assert 'ranks' in response
#     assert 'incentives' in response
#     assert 'emissions' in response
#     assert 'fqdn' in response
#     assert 'vulnerabilities' in response
#     assert 'predictions_from_miners' in response
    
#     # Since we're using random UIDs, we can't assert exact values
#     # but we can verify the response contains valid data
#     assert len(response['uids']) == 2  # Based on mock_prediction_responses having 2 items
#     assert all(isinstance(uid, int) for uid in response['uids'])
#     assert all(isinstance(rank, float) for rank in response['ranks'])
#     assert all(isinstance(incentive, float) for incentive in response['incentives'])
#     assert all(isinstance(emission, float) for emission in response['emissions'])
#     assert isinstance(response['fqdn'], str)
    
#     # Check vulnerability data
#     assert len(response['vulnerabilities']) == 2
#     assert len(response['predictions_from_miners']) == 2
#     for vuln in response['vulnerabilities']:
#         assert isinstance(vuln, VulnerabilityByMiner)
#         assert isinstance(vuln.miner_id, str)
#         assert vuln.category == VulnerabilityCategory.ARITHMETIC_OVERFLOW_AND_UNDERFLOW

@pytest.mark.asyncio
async def test_forward_with_multiple_vulnerabilities(
    mock_validator: MagicMock,
    mock_request: MagicMock
) -> None:
    """
    Test the forward method with miners reporting multiple different vulnerabilities.
    
    Args:
        mock_validator: Mock validator fixture
        mock_request: Mock request fixture
    """
    proxy = ValidatorProxy(mock_validator)
    
    # Create different vulnerabilities for each miner
    vuln1 = Vulnerability(
        category=VulnerabilityCategory.ARITHMETIC_OVERFLOW_AND_UNDERFLOW,
        line_ranges=[LineRange(start=1, end=9)],
        description="Can lead to arithmetic overflow",
        vulnerable_code="function add(uint a, uint b) returns (uint) { return a + b; }",
        code_to_exploit="add(MAX_UINT, 1)",
        rewritten_code_to_fix_vulnerability="function add(uint a, uint b) returns (uint) { uint c = a + b; require(c >= a); return c; }"
    )
    
    vuln2 = Vulnerability(
        category=VulnerabilityCategory.REENTRANCY,
        line_ranges=[LineRange(start=10, end=20)],
        description="Reentrancy vulnerability in withdraw function",
        vulnerable_code="function withdraw() { msg.sender.call{value: balance}(); balance = 0; }",
        code_to_exploit="function attack() { victim.withdraw(); }",
        rewritten_code_to_fix_vulnerability="function withdraw() { uint amount = balance; balance = 0; msg.sender.call{value: amount}(); }"
    )
    
    mock_responses = [
        PredictionResponse(prediction=True, vulnerabilities=[vuln1]),
        PredictionResponse(prediction=True, vulnerabilities=[vuln1, vuln2])
    ]
    
    # Mock the dendrite call
    proxy.dendrite = AsyncMock(return_value=mock_responses)
    
    # Call forward method
    response = await proxy.forward(mock_request)
    
    # Verify response structure
    assert isinstance(response, dict)
    assert 'vulnerabilities' in response
    assert 'predictions_from_miners' in response
    
    # Should have 3 vulnerabilities total (1 from first miner, 2 from second miner)
    assert len(response['vulnerabilities']) == 3
    
    # Verify vulnerability details
    vulnerabilities = response['vulnerabilities']
    
    # Count vulnerabilities by category
    overflow_vulns = [v for v in vulnerabilities if v.category == VulnerabilityCategory.ARITHMETIC_OVERFLOW_AND_UNDERFLOW]
    reentrancy_vulns = [v for v in vulnerabilities if v.category == VulnerabilityCategory.REENTRANCY]
    
    assert len(overflow_vulns) == 2  # Both miners reported overflow
    assert len(reentrancy_vulns) == 1  # Only second miner reported reentrancy
    
    # Verify miner IDs - using the mock validator's UIDs [1, 2]
    miner_ids = set(v.miner_id for v in vulnerabilities)
    assert miner_ids == {'1', '2'}  # Should have vulnerabilities from both miners
    
    # Verify predictions_from_miners matches vulnerabilities
    assert len(response['predictions_from_miners']) == len(response['vulnerabilities'])
    for pred in response['predictions_from_miners']:
        assert isinstance(pred, dict)
        assert 'category' in pred
        assert 'line_ranges' in pred
        assert 'description' in pred
        assert 'vulnerable_code' in pred
        assert 'code_to_exploit' in pred
        assert 'rewritten_code_to_fix_vulnerability' in pred
        assert 'miner_id' in pred
        assert pred['miner_id'] in ['1', '2']  # Match the mock validator's UIDs 