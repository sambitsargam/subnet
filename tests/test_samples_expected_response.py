import pytest
import os
from unittest.mock import patch, MagicMock
from bitsec.utils.llm import chat_completion
from bitsec.protocol import PredictionResponse, Vulnerability, LineRange
import openai
import bittensor as bt
from bitsec.utils.data import get_all_code_samples, load_sample_file


SPEND_MONEY = os.environ.get("SPEND_MONEY", False)
TEST_RESPONSE = "Test response"



def test_response_for_every_sample():
    """Test response with real response."""
    if not SPEND_MONEY:
        return # costs money, comment out to run

    filenames = get_all_code_samples()
    for filename in filenames:
        code, expected_response = load_sample_file(filename)
        result = chat_completion(code, response_format=PredictionResponse)
        assert isinstance(result, PredictionResponse)
        assert result.prediction == expected_response.prediction
    # do not compare vulnerabilities, since LLM may write in different way
    # assert result.vulnerabilities == expected_response.vulnerabilities


@pytest.fixture
def mock_openai_response():
    """Create a mock OpenAI API response."""
    message = MagicMock()
    message.content = TEST_RESPONSE
    message.parsed = None
    message.refusal = None
    
    response = MagicMock()
    response.choices = [MagicMock(message=message)]
    return response

# def test_chat_completion_basic(mock_openai_response):
#     """Test basic text response from chat completion."""
#     with patch('bitsec.utils.llm.client.beta.chat.completions.parse', return_value=mock_openai_response):
#         result = chat_completion("Test prompt")
#         assert result == TEST_RESPONSE

