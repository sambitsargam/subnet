import os
import pytest
import bittensor as bt
from unittest.mock import patch
import numpy as np
from bitsec.validator.reward import reward, score_response
from bitsec.protocol import PredictionResponse, Vulnerability, LineRange

SPEND_MONEY = os.environ.get("SPEND_MONEY", False)
if SPEND_MONEY:
    bt.logging.set_debug()

@pytest.fixture
def mock_prediction_response():
    return PredictionResponse(
        prediction=True,
        vulnerabilities=[
            Vulnerability(
                line_ranges=[LineRange(start=1, end=9)],
                short_description="test_vuln",
                detailed_description="test reason"
            )
        ]
    )

@pytest.fixture
def mock_chat_completion():
    with patch('bitsec.validator.reward.chat_completion') as mock:
        mock.return_value = 5
        yield mock

vuln1 = Vulnerability(line_ranges=[LineRange(start=1, end=9)], short_description="Arithmetic Overflow", detailed_description="Can lead to loss of funds")
vuln2 = Vulnerability(line_ranges=[LineRange(start=10, end=20)], short_description="Security Misconfiguration", detailed_description="Allows unauthorized access to sensitive data")
vuln3 = Vulnerability(line_ranges=[LineRange(start=21, end=30)], short_description="Reentrancy", detailed_description="Can lead to loss of funds")
vuln4 = Vulnerability(line_ranges=[LineRange(start=30, end=40)], short_description="Security Misconfiguration", detailed_description="Allows unauthorized access to terminate the contract")


def test_mock_reward_perfect_score(mock_prediction_response):
    result = reward(True, mock_prediction_response, mock_prediction_response)
    assert result == 1.0

def test_mock_reward_low_score(mock_prediction_response):
    different_response = PredictionResponse(prediction=False, vulnerabilities=[])
    result = reward(True, mock_prediction_response, different_response)
    assert result == 0.0

def test_reward_prediction_false():
    expected_response = PredictionResponse(prediction=True, vulnerabilities=[vuln1])
    response = PredictionResponse(prediction=False, vulnerabilities=[])
    result = reward(True, expected_response, response)
    assert result == 0.0

def test_reward_prediction_true():
    expected_response = PredictionResponse(prediction=False, vulnerabilities=[])
    response = PredictionResponse(prediction=True, vulnerabilities=[vuln2])
    result = reward(True, expected_response, response)
    assert result == 0.0

def test_costs_money_score_reponse_score_5():
    if not SPEND_MONEY:
        return
    
    expected_response = PredictionResponse(prediction=True, vulnerabilities=[vuln1])
    vuln1_copy = vuln1.model_copy()
    vuln1_copy.short_description += " found" # so it's different text but effectively same vulnerability
    response = PredictionResponse(prediction=True, vulnerabilities=[vuln1_copy])
    result, _, _, _, _ = score_response(expected_response, response)
    assert result == 5

def test_costs_money_score_response_score_4():
    if not SPEND_MONEY:
        return
    
    expected_response = PredictionResponse(prediction=True, vulnerabilities=[vuln1, vuln2])
    response = PredictionResponse(prediction=True, vulnerabilities=[vuln1])
    result, _, _, _, _ = score_response(expected_response, response)
    assert result == 4

def test_costs_money_score_response_score_3():
    if not SPEND_MONEY:
        return
    
    incorrect = vuln4 # reassign for clarity
    expected_response = PredictionResponse(prediction=True, vulnerabilities=[vuln1, vuln2, vuln3])
    response = PredictionResponse(prediction=True, vulnerabilities=[vuln1, vuln2, incorrect])
    result, _, _, _, _ = score_response(expected_response, response)
    assert result == 3

def test_costs_money_score_response_score_2():
    if not SPEND_MONEY:
        return
    
    expected_response = PredictionResponse(prediction=True, vulnerabilities=[vuln1, vuln2, vuln3])
    response = PredictionResponse(prediction=True, vulnerabilities=[vuln1])
    result, _, _, _, _ = score_response(expected_response, response)
    assert result == 2

def test_costs_money_score_response_score_1():
    if not SPEND_MONEY:
        return
    
    expected_response = PredictionResponse(prediction=True, vulnerabilities=[vuln1, vuln4])
    response = PredictionResponse(prediction=True, vulnerabilities=[vuln2, vuln3])
    result, _, _, _, _ = score_response(expected_response, response)
    assert result == 1
