import pytest
import os
from flaky import flaky
from unittest.mock import patch, MagicMock
from bitsec.utils.llm import chat_completion
from bitsec.protocol import PredictionResponse, Vulnerability, LineRange
import openai
import bittensor as bt
from bitsec.utils.data import get_code_sample

SPEND_MONEY = os.environ.get("SPEND_MONEY", False)
if SPEND_MONEY:
    bt.logging.set_debug()

TEST_RESPONSE = "Test response"

@flaky(max_runs=3)
def test_chat_completion_with_real_response():
    """Test response with real response."""
    if not SPEND_MONEY:
        return
    code, expected_response = get_code_sample(vulnerable=False)
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

def test_chat_completion_basic(mock_openai_response):
    """Test basic text response from chat completion."""
    with patch('bitsec.utils.llm.client.beta.chat.completions.parse', return_value=mock_openai_response):
        result = chat_completion("Test prompt")
        assert result == TEST_RESPONSE

def test_chat_completion_with_format(mock_openai_response):
    """Test response with specific format type."""
    expected_response = PredictionResponse.from_tuple([
        True,
        [Vulnerability(
            line_ranges=[LineRange(start=2, end=5)],
            short_description="Test Vulnerability",
            detailed_description="Test Reason"
        )]
    ])
    mock_openai_response.choices[0].message.parsed = expected_response
    
    with patch('bitsec.utils.llm.client.beta.chat.completions.parse', return_value=mock_openai_response):
        result = chat_completion("Test prompt", response_format=PredictionResponse)
        assert result == expected_response

def test_chat_completion_with_format2(mock_openai_response):
    """Test response with another value."""
    expected_response = PredictionResponse.from_tuple([
        False,
        []
    ])
    mock_openai_response.choices[0].message.parsed = expected_response
    
    with patch('bitsec.utils.llm.client.beta.chat.completions.parse', return_value=mock_openai_response):
        result = chat_completion("Test prompt", response_format=PredictionResponse)
        assert result == expected_response

def test_chat_completion_empty_response():
    """Test handling of empty response."""
    empty_response = MagicMock()
    empty_response.choices = []
    
    with patch('bitsec.utils.llm.client.beta.chat.completions.parse', return_value=empty_response):
        with pytest.raises(ValueError, match="AI returned empty or invalid response"):
            chat_completion("Test prompt")

def test_chat_completion_retry():
    """Test retry mechanism for rate limits."""
    mock_response = MagicMock()
    mock_response.choices = [MagicMock(message=MagicMock(content=TEST_RESPONSE, refusal=None))]
    
    with patch('bitsec.utils.llm.client.beta.chat.completions.parse') as mock_parse:
        mock_parse.side_effect = [
            openai.RateLimitError(
                message="Rate limit exceeded",
                response=MagicMock(status_code=429),
                body={"error": {"message": "Rate limit exceeded"}}
            ),
            mock_response
        ]
        result = chat_completion("Test prompt")
        assert result == TEST_RESPONSE
        assert mock_parse.call_count == 2

def test_chat_completion_refused():
    """Test handling of refused prompts."""
    mock_response = MagicMock()
    message = MagicMock()
    message.refusal = "Content policy violation"
    mock_response.choices = [MagicMock(message=message)]
    
    with patch('bitsec.utils.llm.client.beta.chat.completions.parse', return_value=mock_response):
        with pytest.raises(ValueError, match="Prompt was refused"):
            chat_completion("Test prompt")