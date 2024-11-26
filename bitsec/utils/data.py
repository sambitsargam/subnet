import os
import random
from typing import Tuple, List
from bitsec.protocol import PredictionResponse

SAMPLE_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'samples')
VULNERABLE_CODE_DIR = '/vulnerable'
SECURE_CODE_DIR = '/clean-codebases'

def get_code_sample(vulnerable: bool) -> Tuple[str, PredictionResponse]:
    """
    Get a random code sample and its expected response as a PredictionResponse object from the samples directory.

    Args:
        vulnerable (bool): Whether to get a random vulnerable or secure code sample.

    Returns:
        Tuple[str, PredictionResponse]: A tuple containing the code sample, and its expected response as a PredictionResponse object.
    """
    sample_files = get_all_code_samples(vulnerable)
    sample_filename = random.choice(sample_files)
    return load_sample_file(sample_filename)

def get_all_code_samples(vulnerable: bool) -> List[str]:
    """
    Get array of filenames for all code samples in vulnerable or secure directory.

    Args:
        vulnerable (bool): Whether to get the filenames for vulnerable or secure code samples.

    Returns:
        List[str]: The array of filenames for all code samples in selected directory.
    """
    code_dir = SAMPLE_DIR + (VULNERABLE_CODE_DIR if vulnerable else SECURE_CODE_DIR)
    sample_files = [os.path.join(code_dir, f) for f in os.listdir(code_dir) if f.endswith('.sol')]
    if not sample_files:
        raise ValueError("No code sample files found")
    return sample_files

def load_sample_file(sample_filename_with_path: str) -> Tuple[str, PredictionResponse]:
    """
    Load a sample file (.sol) and its expected response (same filename but .json) as a PredictionResponse object from the samples directory.

    Args:
        sample_filename_with_path (str): The filename of the sample file (including the .sol extension), including path.

    Returns:
        Tuple[str, PredictionResponse]: A tuple containing the code sample and its expected response as a PredictionResponse object.
    """
    if not os.path.exists(sample_filename_with_path):
        raise FileNotFoundError(f"Sample file not found: {sample_filename_with_path}")
    
    parts = sample_filename_with_path.split('.')
    parts_without_extension = parts[:-1]
    sample_file_base = '.'.join(parts_without_extension)

    expected_response_filename = sample_file_base + '.json'
    if not os.path.exists(expected_response_filename):
        raise FileNotFoundError(f"Expected response file not found: {expected_response_filename}")
    
    with open(sample_filename_with_path, 'r') as sample_file, open(expected_response_filename, 'r') as expected_response_file:
        expected_response = PredictionResponse.from_json(expected_response_file.read())
        return sample_file.read(), expected_response

def create_challenge(code: str, label: float) -> str:
    # TODO expand more codebases
    # TODO expand more vulnerabilities
    ## add layers of noise to make challenge harder
    return code