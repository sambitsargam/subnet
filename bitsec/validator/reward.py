# The MIT License (MIT)
# Copyright © 2023 Yuma Rao
# TODO(developer): Set your name
# Copyright © 2023 <your name>

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
import json
import numpy as np
from typing import List
import bittensor as bt
import pydantic
from bitsec.utils.llm import chat_completion
from bitsec.protocol import PredictionResponse

def reward(vulnerable: bool, expected_response: PredictionResponse, response: PredictionResponse) -> float:
    """
    Reward the miner response to the dummy request. This method returns a reward
    value for the miner, which is used to update the miner's score.

    Returns:
    - float: The reward value for the miner.
    """
    score, _, _, _, _ = score_response(expected_response, response)

    if score >= 5:
        return 1.0
    elif score >= 4:
        return 0.5
    elif score >= 3:
        return 0.25
    elif score >= 2:
        return 0.1
    
    return 0.0


def score_response(expected_response: PredictionResponse, response: PredictionResponse) -> int:
    """
    Score the response to the expected response.

    Args:
    - expected_response (PredictionResponse): The expected response.
    - response (PredictionResponse): The response to score.

    Returns:
    - int: The score for the response.
    - str: The reason for the score.
    - List[str]: The vulnerabilities expected and found.
    - List[str]: The vulnerabilities expected but not found.
    - List[str]: The vulnerabilities found but not expected.
    """
    if response.prediction != expected_response.prediction:
        # Prediction is wrong, no need to compare vulnerabilities
        return 0, "Prediction boolean is wrong", [], expected_response.vulnerabilities, response.vulnerabilities
    elif response.vulnerabilities == expected_response.vulnerabilities:
        # Text is exactly the same, so it's a perfect match
        return 5, "Vulnerabilities are exactly the same", expected_response.vulnerabilities, [], []

    class Score(pydantic.BaseModel):
        vulnerabilities_expected_and_found: List[str]
        vulnerabilities_expected_but_not_found: List[str]
        vulnerabilities_found_but_not_expected: List[str]
        verbose_reason: str
        score: int

    # Use LLM to compare the response to the expected response
    # and return a reward based on the similarity
    prompt = f"""You are a security expert tasked with evaluating the response to a security vulnerability scan. 

    Focus on the short descriptions of the vulnerabilities, consider similar short descriptions to be the same vulnerability. 
    If the long descriptions are similar, consider them the same vulnerability. 
    If the line ranges are similar, consider them the same vulnerability. 
    If the line ranges are different, but the short descriptions or long descriptions are similar, consider them the same vulnerability.
    
    Compared to the expected vulnerability report, score the actual response:
      1: does not include any of the expected vulnerabilities, may include incorrect vulnerabilities
      2: includes 1+ expected vulnerabilities, no incorrect vulnerabilities
      3: includes 1+ expected vulnerabilities but also includes 1+ incorrect vulnerabilities
      4: no incorrect vulnerabilities, includes >50% of the expected vulnerabilities
      5: has all the same vulnerabilities

    <Expected>
        {expected_response.model_dump_json()}
    </Expected>
    <Actual>
        {response.model_dump_json()}
    </Actual>

    Focus on the short descriptions of the vulnerabilities, pay less attention to the long descriptions. Try to use line ranges to recognize similar vulnerabilities. If short descriptions are similar, but line ranges are different, consider them the same vulnerability.
    """
    score = chat_completion(prompt, response_format=Score)
    return score.score, score.verbose_reason, score.vulnerabilities_expected_and_found, score.vulnerabilities_expected_but_not_found, score.vulnerabilities_found_but_not_expected

def get_rewards(
    label: bool,
    expected_response: PredictionResponse,
    responses: List[PredictionResponse],
) -> np.ndarray:
    """
    Returns an array of rewards for the given query and responses.

    Args:
    - label (bool): The true label (True for vulnerable, False for secure).
    - responses (List[Tuple]): A list of responses from the miner.

    Returns:
    - np.ndarray: An array of rewards for the given query and responses.
    """
    # Get all the reward results by iteratively calling your reward() function.
    
    return np.array(
        [reward(label, expected_response, response) for response in responses]
    )
