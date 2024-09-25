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
        bt.logging.info("Vulnerability Analysis Report:\n{analysis}")
        # TODO retry and fix loop to create PredictionResponse structured outputs
        prediction_input = format_analysis(analysis)
        prediction_response = PredictionResponse.model_validate(prediction_input)
        bt.logging.info(f"PredictionResponse: {prediction_response}")
    except Exception as e:
        bt.logging.error(f"An error occurred prompt generating the prediction response: {e}")

    return prediction_response

VULN_PROMPT_TEMPLATE = """
### Instructions:
Thoroughly scan the code line by line for potentially flawed logic or problematic code related to security vulnerabilities.

### Code:
{code}

List vulnerabilities and possible ways for potential financial loss.
Vulnerability #1:
"""

FORMAT_RESULTS_TEMPLATE = """
Analyze the following text describing vulnerabilities in smart contract code. 
Create a structured vulnerability report in the form of a Python dictionary that can be parsed into a PredictionResponse object. The dictionary should have two keys: 
1. 'prediction': A float 0.0 or 1.0 representing the presence of a vulnerability or not. 0.0 if no vulnerabilities found, or 1.0 if 1 or more vulnerabilities found.
2. 'vulnerabilities': A list of dictionaries, each representing a Vulnerability object with these keys: 
- 'int_ranges': A list of integer tuples representing affected code line ranges. Use an empty list if no specific lines are mentioned. 
- 'vulnerability_type': A concise string summarizing the vulnerability type.

Provide only the Python dictionary in your response, without any additional explanation. Ensure the output can be directly parsed into the PredictionResponse class. 

Here's the text to analyze:

{analysis}
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
    prompt = VULN_PROMPT_TEMPLATE.format(code=code)

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

def format_analysis(analysis: str,
    model: str = "gpt-4o-mini-2024-07-18",
    temperature: float = 0.7,
    max_tokens: int = 1000
    ) -> str:
    """
    Formats analysis report to fit into PredictionResponse

    Args:
        analysis (str): The text to format.
        model (str): The model to use for analysis.
        temperature (float): Sampling temperature.
        max_tokens (int): Maximum number of tokens to generate.

    Returns:
        str: The formatted PredictionResponse.
    """
    prompt = FORMAT_RESULTS_TEMPLATE.format(analysis=analysis)

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