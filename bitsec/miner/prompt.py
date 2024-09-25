# sample miner uses LLM prompts to find vulnerabilities in code

import openai
from bitsec.protocol import PredictionResponse

def code_to_vulns(code: str) -> PredictionResponse:
    return PredictionResponse.from_tuple([1.0, []])