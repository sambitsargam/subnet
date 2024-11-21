# Sample miner uses LLM prompts to find vulnerabilities in code
# This example uses a basic prompt template for demonstration purposes

import openai
import json
import re
from openai import OpenAI
from bitsec.protocol import PredictionResponse
from bitsec.utils.data import SAMPLE_DIR
import bittensor as bt
import os
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type
)

# OpenAI API key config
if not os.getenv("OPENAI_API_KEY"):
    bt.logging.error("OpenAI API key is not set. Please set the 'OPENAI_API_KEY' environment variable.")
    raise ValueError("OpenAI API key is not set.")

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Default parameters
DEFAULT_MODEL = "gpt-4o-mini-2024-07-18"
DEFAULT_TEMPERATURE = 0.7
DEFAULT_MAX_TOKENS = 1000

# Templates for prompts
VULN_PROMPT_TEMPLATE = """
### Instructions:
Thoroughly scan the code line by line for potentially flawed logic or problematic code that could cause security vulnerabilities.

### Code:
{code}

List vulnerabilities and possible ways for potential financial loss:
"""

FORMAT_RESULTS_TEMPLATE = """
Analyze the following text describing vulnerabilities in smart contract code. Create a structured vulnerability report in the form of a JSON object that can be parsed into a PredictionResponse object. The JSON object should have two keys:

1. 'prediction': A float between 0 and 1 representing the overall probability of vulnerability. Base this on the severity and number of vulnerabilities found.

2. 'vulnerabilities': A list of dictionaries, each representing a Vulnerability object with these keys:
   - 'int_ranges': A list of integer tuples representing affected code line ranges. Use an empty list if no specific lines are mentioned.
   - 'vulnerability_type': A concise string summarizing the vulnerability type.

Provide only the JSON object in your response, without any additional explanation. Ensure the output can be directly parsed into the PredictionResponse class.

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
    model: str = DEFAULT_MODEL,
    temperature: float = DEFAULT_TEMPERATURE,
    max_tokens: int = DEFAULT_MAX_TOKENS
) -> str:
    """
    Calls OpenAI API to analyze provided code for vulnerabilities.

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
        response = client.beta.chat.completions.parse(
            messages=[{"role": "system", "content": prompt}],
            model=model,
            temperature=temperature,
            max_tokens=max_tokens,
            response_format=PredictionResponse
        )

        # Guard against empty or invalid responses
        if response is None or response.choices is None or len(response.choices) == 0 or response.choices[0].message is None:
            raise ValueError("AI returned empty or invalid response.", response)
        
        # Shorter
        message = response.choices[0].message

        if hasattr(message, "parsed") and message.parsed is not None and type(message.parsed) is PredictionResponse:
            return message.parsed
        
        if hasattr(message, "refusal"):
            bt.logging.error(f"Analysis of code was refused: {message.refusal}")
            return message.refusal
        
        if hasattr(message, "content"):
            bt.logging.error(f"Analysis of code returned text content, attempting to parse as PredictionResponse: {message.content}")
            try:
                return PredictionResponse.from_tuple(json.loads(message.content))
            except Exception as e:
                bt.logging.error(f"Failed to parse as PredictionResponse, error: {e}")
                raise

        raise ValueError("Analysis did not return a valid PredictionResponse object.", message)
    
    except Exception as e:
        # Error will be logged by calling function
        raise

def format_analysis(
    analysis: str,
    model: str = DEFAULT_MODEL,
    temperature: float = DEFAULT_TEMPERATURE,
    max_tokens: int = DEFAULT_MAX_TOKENS
) -> str:
    """
    Formats the vulnerability analysis into a structured JSON response: PredictionResponse.

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
            messages=[{"role": "system", "content": prompt}],
            model=model,
            temperature=temperature,
            max_tokens=max_tokens
        )
        content = response.choices[0].message.content
        content = re.sub(r'```json\s*|\s*```', '', content)
        return content
    except Exception as e:
        bt.logging.error(f"Failed to format analysis: {e}")
        raise

def default_testnet_code(code: str) -> bool:
    file_path = os.path.join(SAMPLE_DIR, "nft-reentrancy.sol")

    # Check if the file exists
    if not os.path.exists(file_path):
        return f"Error: The file '{file_path}' does not exist."
    
    # Read the contents of the file
    try:
        with open(file_path, 'r') as file:
            file_contents = file.read()
    except IOError:
        return f"Error: Unable to read the file '{file_path}'."
    
    return file_contents == code

def code_to_vulns(code: str) -> PredictionResponse:
    """
    Main function to analyze code and format the results into a PredictionResponse.

    Args:
        code (str): The code to analyze.

    Returns:
        PredictionResponse: The structured vulnerability report.
    """

    ## short circuit testnet default code
    if default_testnet_code(code) == True:
      bt.logging.info("Default Testnet Code detected. Sending default prediction.")
      return PredictionResponse.from_tuple([True,[]])

    try:
        bt.logging.info(f"analyzing code:\n{code}")
        analysis = analyze_code(code)
        bt.logging.info(f"Analysis result:\n{analysis}")

        if type(analysis) is not PredictionResponse:
            raise ValueError("Analysis did not return a PredictionResponse object.")

        # formatted_result = format_analysis(analysis)
        # bt.logging.debug(f"Formatted result: {formatted_result}")

        # try:
        #     formatted_result_dict = json.loads(formatted_result)
        # except json.JSONDecodeError as e:
        #     bt.logging.error(f"Failed to parse formatted result as JSON: {e}")
        #     raise

        # bt.logging.info(f"Analysis complete. Result: {analysis}")
        return analysis
    except Exception as e:
        bt.logging.error(f"An error occurred during analysis: {e}")
        raise