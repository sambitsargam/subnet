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

def reward(expected_response: PredictionResponse, response: PredictionResponse, dynamic_stake: float) -> float:
    """
    Reward the miner response.

    Returns:
    - float: The reward value for the miner.
    """
    
    # Jaccard score of the vulnerabilities
    score = jaccard_score(expected_response, response)
    
    # Add weights and other factors
    participation_weight = 1.0 + (dynamic_stake / 1000.0)
    score *= participation_weight

    return score


def jaccard_score(expected_response: PredictionResponse, response: PredictionResponse) -> float:
    """
    Calculate the Jaccard score of the vulnerabilities. That is, the intersection over the union of the vulnerabilities. 

    Args:
    - expected_response (PredictionResponse): The expected response.
    - response (PredictionResponse): The response to score.

    Returns:
    - float: The Jaccard score.
    """
    if response.prediction != expected_response.prediction:
        return 0.0
    
    if response.vulnerabilities == expected_response.vulnerabilities:
        return 1.0

    score = 0.0

    #### Compare categories
    category_expected = set([vulnerability.category for vulnerability in expected_response.vulnerabilities])
    category_response = set([vulnerability.category for vulnerability in response.vulnerabilities])

    category_intersection = category_expected.intersection(category_response)
    category_union = category_expected.union(category_response)
 
    # Handle empty union case to prevent division by zero
    if len(category_union) == 0:
        return 1.0
    else:
        score = len(category_intersection) / len(category_union)

    # TODO: line range
    # TODO: description

    return score

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
    expected_response: PredictionResponse,
    responses: List[PredictionResponse],
    dynamic_stake: float
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
        [reward(expected_response, response, dynamic_stake) for response in responses]
    )

def cross_validation_scoring(miner_results, aggregate_consensus, dynamic_stake: float):
    """
    Implement cross-validation scoring to compare each miner’s results with the aggregate consensus.
    """
    score = sum(1 for result in miner_results if result in aggregate_consensus) / len(miner_results)
    participation_weight = 1.0 + (dynamic_stake / 1000.0)
    return score * participation_weight

def historical_accuracy_weighting(miner_id, performance_history):
    """
    Add historical accuracy weighting to prioritize miners with consistent past performance.
    """
    return sum(performance_history[miner_id]) / len(performance_history[miner_id])

def vulnerability_classification_bonus(vulnerability_class):
    """
    Include vulnerability classification bonus for identifying novel or severe classes.
    """
    bonus_mapping = {
        "novel": 1.5,
        "severe": 2.0,
        "common": 1.0
    }
    return bonus_mapping.get(vulnerability_class, 1.0)
