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

import random
import time
import asyncio
import wandb
import bittensor as bt

from bitsec.protocol import prepare_code_synapse, PredictionResponse, Vulnerability
from bitsec.validator.reward import get_rewards, cross_validation_scoring, historical_accuracy_weighting, vulnerability_classification_bonus
from bitsec.utils.data import create_challenge
from bitsec.utils.uids import get_random_uids
from bitsec.utils.llm import chat_completion
from bitsec.validator.make_report import format_vulnerability_to_report

async def forward(self):
    """
    The forward function is called by the validator every time step.
    It is responsible for querying the network and scoring the responses.

    Steps are:
    1. Sample miner UIDs
    2. Get a code sample. 50/50 chance of:
        A. SECURE (label = 0): No vulnerability injected.
        B. VULNERABLE (label = 1): Inject a vulnerability into the code.
    3. Apply random data augmentation to turn the code sample into a challenge.
    4. Prepare a Synapse
    5. Query miner axons
    6. Log results, including challenge and miner responses
    7. Compute rewards and update scores

    Args:
        self (:obj:`bittensor.neuron.Neuron`): The neuron object which contains all the necessary state for the validator.

    """
    # Initialize seen_miners set if it doesn't exist
    if not hasattr(self, 'seen_miners'):
        self.seen_miners = set()

    # get_random_uids is an example method, but you can replace it with your own.
    miner_uids = get_random_uids(self, k=self.config.neuron.sample_size)
    bt.logging.info(f"Attempting to connect to {self.config.neuron.sample_size} miners, UIDs found: {miner_uids}")
    wandb.log({"miner_uids": miner_uids})


    if len(miner_uids) == 0:
        bt.logging.warning(f"❌❌❌❌❌ No miners found, skipping challenge")
        return
    
    # generate challenge
    # handle errors when generating challenges
    vulnerable = random.random() < 0.8
    challenge = None
    expected_response = None

    while not challenge:
        try:
            challenge, expected_response = create_challenge(vulnerable=vulnerable)
            bt.logging.info(f"created challenge")
            wandb.log({"challenge": challenge})
        except Exception as e:
            bt.logging.warning(f"Error creating challenge: {e}")
            time.sleep(1)


    # The dendrite client queries the network.
    axons = [self.metagraph.axons[uid] for uid in miner_uids]
    bt.logging.info(f"⏳ Connecting to miner axons at: {[axon.ip + ':' + str(axon.port) for axon in axons]}")
    
    start_time = time.time()
    responses = await self.dendrite(
        # Send the query to selected miner axons in the network.
        axons=axons,
        synapse=prepare_code_synapse(code=challenge),
        deserialize=True,
    )
    response_time = time.time() - start_time
    wandb.log({"response_time": response_time})

    # Log the results for monitoring purposes.
    bt.logging.info(f"Received {len(responses)} responses")

    # Normalize miner outputs
    normalized_responses = [normalize_response(response) for response in responses]

    # Group and deduplicate findings using NLP techniques
    grouped_findings = group_and_deduplicate_findings(normalized_responses)

    # Rank findings based on severity, consensus strength, and historical accuracy
    ranked_findings = rank_findings(grouped_findings)

    # Generate a human-readable and machine-actionable report in JSON and PDF formats
    report_json, report_pdf = generate_report(ranked_findings)

    # Log the cross-validation score, historical accuracy, and vulnerability classification bonus for each miner
    for response in responses:
        wandb.log({
            "cross_validation_score": response.cross_validation_score,
            "historical_accuracy": response.historical_accuracy,
            "vulnerability_classification_bonus": response.vulnerability_classification_bonus
        })

    # Adjust the scores based on responses from miners.
    rewards = get_rewards(expected_response=expected_response, responses=responses)
    wandb.log({"rewards": rewards})

    # bt.logging.info(f"Scored responses: {rewards}")
    # Update the scores based on the rewards. You may want to define your own update_scores function for custom behavior.
    self.update_scores(rewards, miner_uids)

def normalize_response(response: PredictionResponse) -> PredictionResponse:
    """
    Normalize the miner response.

    Args:
        response (PredictionResponse): The response to normalize.

    Returns:
        PredictionResponse: The normalized response.
    """
    # Implement normalization logic here
    return response

def group_and_deduplicate_findings(responses: List[PredictionResponse]) -> List[Vulnerability]:
    """
    Group and deduplicate findings using NLP techniques.

    Args:
        responses (List[PredictionResponse]): The responses to group and deduplicate.

    Returns:
        List[Vulnerability]: The grouped and deduplicated findings.
    """
    # Implement grouping and deduplication logic here
    return []

def rank_findings(findings: List[Vulnerability]) -> List[Vulnerability]:
    """
    Rank findings based on severity, consensus strength, and historical accuracy.

    Args:
        findings (List[Vulnerability]): The findings to rank.

    Returns:
        List[Vulnerability]: The ranked findings.
    """
    # Implement ranking logic here
    return []

def generate_report(findings: List[Vulnerability]) -> (str, str):
    """
    Generate a human-readable and machine-actionable report in JSON and PDF formats.

    Args:
        findings (List[Vulnerability]): The findings to include in the report.

    Returns:
        (str, str): The report in JSON and PDF formats.
    """
    # Implement report generation logic here
    return "", ""
