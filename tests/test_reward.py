import pytest
from unittest.mock import patch
import numpy as np
from bitsec.validator.reward import reward
from bitsec.protocol import PredictionResponse, Vulnerability, LineRange

@pytest.fixture
def mock_prediction_response():
    return PredictionResponse(
        prediction=True,
        vulnerabilities=[
            Vulnerability(
                int_ranges=[LineRange(start=1, end=9)],
                vulnerability_type="test_vuln",
                reason_for_potential_financial_loss="test reason"
            )
        ]
    )

@pytest.fixture
def mock_chat_completion():
    with patch('bitsec.validator.reward.chat_completion') as mock:
        mock.return_value = 5
        yield mock

def test_reward_perfect_score(mock_prediction_response, mock_chat_completion):
    result = reward(True, "expected", mock_prediction_response)
    assert result == 1.0
    mock_chat_completion.assert_called_once()

def test_reward_low_score(mock_prediction_response, mock_chat_completion):
    mock_chat_completion.return_value = 1
    result = reward(True, "expected", mock_prediction_response)
    assert result == 0.0
