# Sample miner uses LLM prompts to find vulnerabilities in code
# This example uses a basic prompt template for demonstration purposes

import openai
from openai import OpenAI
from bitsec.protocol import PredictionResponse
import bittensor as bt
import os
from typing import Optional
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type
)

# Set OpenAI API key
if not os.getenv("OPENAI_API_KEY"):
    bt.logging.error("OpenAI API key is not set. Please set the 'OPENAI_API_KEY' environment variable.")
    raise ValueError("OpenAI API key is not set.")

client = OpenAI(
    # This is the default and can be omitted
    api_key=os.getenv("OPENAI_API_KEY"),
)

def code_to_vulns(code: str) -> PredictionResponse:
    """
    Analyzes the provided code for vulnerabilities using OpenAI's GPT-4o1 model.

    Args:
        code (str): The code to analyze.

    Returns:
        str: The vulnerability analysis report.
    """
    analysis = ""  # Initialize analysis
    try:
        bt.logging.info("analyzing code")
        analysis = analyze_code(code)
        bt.logging.info("Vulnerability Analysis Report:")
        bt.logging.info(f"Analysis:\n{analysis}")

        # TODO make formatting prompt
        # TODO retry and fix loop to create PredictionResponse structured outputs
        prediction_input = {
            "prediction": 0.8,
            "vulnerabilities": [
                {
                    "int_ranges": [],
                    "vulnerability_type": "Reentrancy Attack"
                },
                {
                    "int_ranges": [],
                    "vulnerability_type": "Lack of Ether Value Check"
                },
                {
                    "int_ranges": [],
                    "vulnerability_type": "No Access Control on mint()"
                }
            ]
        }
        prediction_response = PredictionResponse.model_validate(prediction_input)
        bt.logging.info(f"PredictionResponse: {pr}")
    except Exception as e:
        bt.logging.error(f"An error occurred prompt generating the prediction response: {e}")

    return prediction_response

# Define the prompt template outside the function for configurability
PROMPT_TEMPLATE = """
### Instructions:
Write a brief summary of what the code does.
Thoroughly scan the code line by line for potentially flawed logic or problematic code related to security vulnerabilities.

### Code:
{code}

List vulnerabilities and possible ways for potential financial loss. Ignore "Known Vulnerabilities" and find new ones.
Vulnerability #1:
"""

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
def analyze_code(
    code: str,
    model: str = "gpt-4o-mini-2024-07-18",
    temperature: float = 0.7,
    max_tokens: int = 1000
) -> str:
    """
    Analyzes the provided code for vulnerabilities using OpenAI's ChatCompletion API.

    Args:
        code (str): The code to analyze.
        model (str): The model to use for analysis.
        temperature (float): Sampling temperature.
        max_tokens (int): Maximum number of tokens to generate.

    Returns:
        str: The analysis result from the model.
    """
    prompt = PROMPT_TEMPLATE.format(code=code)
    bt.logging.info(f"prompt: {prompt}")

    try:
        response = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": prompt,
                }
            ],
            model=model,
            temperature=temperature,
            max_tokens=max_tokens
        )
        return response.choices[0].message.content
    except Exception as e:
        bt.logging.error(f"OpenAI API error: {e}")
        raise
