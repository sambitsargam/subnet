from bitsec.protocol import PredictionResponse
import numpy as np
import openai

base_prompt = ""

## Predicting vulnerabilities is a multifaceted task. Here are some example improvements:
# - train custom model
# - use a more powerful foundational model
# - improve prompt
# - increase inference time compute
def predict(code: str) -> PredictionResponse:
    """
    Perform prediction. You may need to modify this if you train a custom model.

    Args:
        code (str): The input str is a challenge that either has a severe code vulnerability or does not.

    Returns:
        float: The predicted output value.
    """
    

    "TODO fix. return 1.0 for now to stabilize validator input."
    return PredictionResponse.from_tuple([1.0, []])