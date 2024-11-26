# Utility function for interacting with LLMs
import bittensor as bt
from typing import Type, Optional, TypeVar, Union
import openai
from openai import OpenAI
import os
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type
)

# Define generic type T
T = TypeVar('T')

# OpenAI API key config
if not os.getenv("OPENAI_API_KEY"):
    bt.logging.error("OpenAI API key is not set. Please set the 'OPENAI_API_KEY' environment variable.")
    raise ValueError("OpenAI API key is not set.")

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Default parameters
DEFAULT_MODEL = "gpt-4o-mini-2024-07-18"
DEFAULT_TEMPERATURE = 0.7
DEFAULT_MAX_TOKENS = 1000

# Define which exceptions we want to retry on
retryable_exceptions = (
    openai.Timeout,
    openai.APIConnectionError,
    openai.RateLimitError
)

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10),
    retry=retry_if_exception_type(retryable_exceptions)
)
def chat_completion(
    prompt: str,
    response_format: Optional[Type[T]] = None,
    model: str = DEFAULT_MODEL,
    temperature: float = DEFAULT_TEMPERATURE,
    max_tokens: int = DEFAULT_MAX_TOKENS
) -> Union[str, T]:
    """
    Calls OpenAI API to analyze provided prompt.

    Args:
        prompt (str): The prompt to analyze.
        response_format (Optional[Type[T]]): The expected response format.
        model (str): The model to use for analysis.
        temperature (float): Sampling temperature.
        max_tokens (int): Maximum number of tokens to generate.

    Returns:
        Union[str, T]: The analysis result from the model, either as string or specified object.
    """
    parameters = {
        "messages": [{"role": "system", "content": prompt}],
        "model": model,
        "temperature": temperature,
        "max_tokens": max_tokens
    }
    if response_format is not None:
        parameters["response_format"] = response_format

    try:
        response = client.beta.chat.completions.parse(**parameters)

        # Guard against empty or invalid responses
        if response is None or response.choices is None or not hasattr(response, "choices") or len(response.choices) == 0 or not hasattr(response.choices[0], "message") or response.choices[0].message is None:
            raise ValueError("AI returned empty or invalid response.", response)
        
        # Shorter access to message, more readable
        message = response.choices[0].message

        if hasattr(message, "refusal") and message.refusal:
            raise ValueError(f"Prompt was refused: {message.refusal}")
        
        if response_format: 
            if hasattr(message, "parsed") and message.parsed is not None:
                if isinstance(message.parsed, response_format):
                    return message.parsed
                else:
                    bt.logging.error(f"Response wasn't format {response_format}, was {type(message.parsed)}, content: {message.content}")
                    raise ValueError(f"Response format {response_format} not found in response.")
            else:
                raise ValueError(f"Response didn't have parsed attribute, content: {message.content}")
        
        if hasattr(message, "content"):
            return message.content
        
        # Else, raise an error
        raise ValueError("Response didn't have content attribute.", message)
    
    except Exception as e:
        # Error will be logged by calling function
        raise
