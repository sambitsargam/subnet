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
from bitsec.protocol import PredictionResponse
import numpy as np
from typing import List, Tuple
import bittensor as bt
from bitsec.utils.llm import chat_completion

def reward(vulnerable: bool, expected_response: str, response: PredictionResponse) -> float:
    """
    Reward the miner response to the dummy request. This method returns a reward
    value for the miner, which is used to update the miner's score.

    Returns:
    - float: The reward value for the miner.
    """
    bt.logging.info(f"response: {response}")

    # Use LLM to compare the response to the expected response
    # and return a reward based on the similarity
    prompt = f"""You are a security expert tasked with evaluating the response to a security vulnerability scan. Rate the response based upon the expected vulnerability report:
      1: totally incorrect
      2: includes <50% of the expected vulnerabilities
      3: includes most/all expected vulnerabilities but also includes 1+ incorrect vulnerabilities
      4: includes >50% of the expected vulnerabilities but not all
      5: exactly the same vulnerabilities
      Return only the number.

    <Expected response>
        {expected_response}
    </Expected response>
    <Actual response>
        {response.prediction}
    </Actual response>
    """
    score = chat_completion(prompt, response_format=int)
    bt.logging.info(f"Score: {score}")

    if score >= 5:
        reward = 1
    elif score >= 4:
        reward = 0.5
    elif score >= 3:
        reward = 0.25
    elif score >= 2:
        reward = 0.1
    else:
        reward = 0

    return reward


def get_rewards(
    label: bool,
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
        [reward(label, response) for response in responses]
    )
