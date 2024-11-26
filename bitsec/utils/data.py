import os
import random
from typing import Tuple
from bitsec.protocol import PredictionResponse

SAMPLE_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'samples')
VULNERABLE_CODE_DIR = '/vulnerable'
SECURE_CODE_DIR = '/secure'

def get_code_sample(vulnerable: bool) -> Tuple[str, str]:
    """
    Get a code sample from the samples directory.
    """
    code_dir = SAMPLE_DIR
    code_dir += VULNERABLE_CODE_DIR if vulnerable else SECURE_CODE_DIR
    if not os.path.exists(code_dir):
        raise FileNotFoundError(f"Sample directory not found: {code_dir}")

    """Load a random code sample from the samples directory."""
    sample_files = [f for f in os.listdir(code_dir) if f.endswith('.sol')]
    if not sample_files:
        raise ValueError("No code sample files found")
    
    sample_file_base = random.choice(sample_files).split('.')[0]

    sample_filename = os.path.join(code_dir, sample_file_base + '.sol')
    expected_response_filename = os.path.join(code_dir, sample_file_base + '.json')
    if not os.path.exists(expected_response_filename):
        raise FileNotFoundError(f"Expected response file not found: {expected_response_filename}")
    with open(sample_filename, 'r') as sample_file, open(expected_response_filename, 'r') as expected_response_file:
        expected_response = PredictionResponse.from_json(expected_response_file.read())
        return sample_file.read(), expected_response

def create_challenge(code: str, label: float) -> str:
    # TODO expand more codebases
    # TODO expand more vulnerabilities
    ## add layers of noise to make challenge harder
    return code