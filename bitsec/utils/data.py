import os
import random
import tempfile
import subprocess
import bittensor as bt
from typing import Tuple, List
from bitsec.protocol import PredictionResponse
from bitsec.utils.llm import chat_completion

SAMPLE_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'samples')
VULNERABLE_CODE_DIR = '/vulnerable'
SECURE_CODE_DIR = '/clean-codebases'

def verify_solidity_compilation(code: str) -> bool:
    """
    Verify that the Solidity code compiles using Foundry.
    
    Args:
        code (str): The Solidity code to verify
        
    Returns:
        bool: True if compilation succeeds, False otherwise
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create a basic Foundry project structure
        os.makedirs(os.path.join(tmpdir, "src"))
        contract_path = os.path.join(tmpdir, "src", "Contract.sol")
        
        # Write the code to a temporary file
        with open(contract_path, 'w') as f:
            f.write(code)
            
        try:
            # Initialize Foundry project
            subprocess.run(["forge", "init", "--no-commit"], cwd=tmpdir, check=True, capture_output=True)
            
            # Try to compile
            result = subprocess.run(["forge", "build"], cwd=tmpdir, check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError as e:
            bt.logging.error(f"Compilation failed: {e.stderr.decode()}")
            return False

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

def create_challenge(vulnerable: bool) -> Tuple[str, PredictionResponse]:
    # 1. pick clean codebase
    sample_code, expected_response = get_code_sample(vulnerable=False)
    bt.logging.info(f"got sample code {sample_code}")

    # 2. inject / don't inject vuln
    if vulnerable:
        # inject vuln by taking a sample vulnerability from samples/vulnerabilities, 
        # TODO fix to sample vulnerabilities
        vuln_file = os.path.join(SAMPLE_DIR, 'vulnerabilities', 'bad-random.md')
        with open(vuln_file, 'r') as f:
            long_description = f.read()
        
        # Create a prompt to inject the vulnerability
        prompt = f"""You are a smart contract security expert. Your task is to modify the given smart contract code to inject a vulnerability.

Here is the vulnerability description:
{long_description}

Here is the clean code:
{sample_code}

Instructions:
1. Modify the code to use a vulnerable source of randomness (like block.timestamp or blockhash)
2. Make the changes look natural, as if a developer made them without realizing the security implications
3. Return ONLY the modified code, no explanations

Modified code:"""

        try:
            # Use the LLM to inject the vulnerability
            modified_code = chat_completion(prompt)
            
            # Create a response indicating the vulnerability
            vulnerable_response = PredictionResponse(
                prediction=True,
                vulnerabilities=[{
                    # TODO fix line ranges
                    "line_ranges": [{"start": 1, "end": 100}],
                    "short_description": "Insecure source of randomness",
                    "detailed_description": "The contract uses block.timestamp or blockhash as a source of randomness, which can be manipulated by miners to influence the outcome."
                }]
            )
            
            return modified_code, vulnerable_response
        except Exception as e:
            bt.logging.error(f"Failed to inject vulnerability: {e}")

    else:
        # do nothing, send clean code
        pass

# 3. make sure challenge codebase can compile, has labeled vuln
# 4.a miner submits wrong vuln
# 4.b miner submits right vuln
# 5. graded correctly
# TODO expand more codebases
# TODO expand more vulnerabilities
## add layers of noise to make challenge harder
    return sample_code, expected_response
