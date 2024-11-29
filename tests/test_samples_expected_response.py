import os
from bitsec.miner.prompt import analyze_code
from bitsec.protocol import PredictionResponse
from bitsec.utils.data import get_all_code_samples, load_sample_file
from bitsec.validator.reward import score_response


SPEND_MONEY = os.environ.get("SPEND_MONEY", False)

def test_response_for_every_sample():
    """Test response with real response."""
    if not SPEND_MONEY:
        print(f"Skipping test {test_response_for_every_sample.__name__}, since it costs money")
        return

    vulnerable_filenames = get_all_code_samples(vulnerable=True)
    for filename in vulnerable_filenames:
        code, expected_response = load_sample_file(filename)
        result = analyze_code(code)
        assert isinstance(result, PredictionResponse)
        # assert result.prediction == expected_response.prediction, f"{filename}: Prediction is {result.prediction}, expected {expected_response.prediction}"
        # assert len(result.vulnerabilities) == len(expected_response.vulnerabilities), f"Number of vulnerabilities for {filename} is {len(result.vulnerabilities)}, expected {len(expected_response.vulnerabilities)}. Expected vulnerabilities: {expected_response.model_dump_json(indent=2)}\n\nResult vulnerabilities: {result.model_dump_json(indent=2)}\n\n"
        print(f"{filename}: vuln.lines >1: {len(list(filter(lambda v: len(v.line_ranges)>1, result.vulnerabilities)))}")

        # score = score_response(expected_response, result)
        # assert score >= 4, f"{filename}: Score is {score}, expected at least 4"
        with open(f"{filename}.new2.json", "w") as f:
            f.write(result.model_dump_json(indent=4))
    
    return

    secure_filenames = get_all_code_samples(vulnerable=False)
    for filename in secure_filenames:
        code, expected_response = load_sample_file(filename)
        result = analyze_code(code)
        assert isinstance(result, PredictionResponse)
        with open(f"{filename}.new2.json", "w") as f:
            f.write(result.model_dump_json(indent=4))
        # assert result.prediction == expected_response.prediction, f"{filename}: Prediction is {result.prediction}, expected {expected_response.prediction}"
        # assert len(result.vulnerabilities) == len(expected_response.vulnerabilities), f"Number of vulnerabilities for {filename} is {len(result.vulnerabilities)}, expected {len(expected_response.vulnerabilities)}. Expected vulnerabilities: {expected_response.model_dump_json(indent=2)}\n\nResult vulnerabilities: {result.model_dump_json(indent=2)}\n\n"

        score = score_response(expected_response, result)
        # assert score >= 4, f"{filename}: Score is {score}, expected at least 4"
