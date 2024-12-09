import os
import pytest
from flaky import flaky
import bittensor as bt
from bitsec.miner.prompt import analyze_code
from bitsec.protocol import PredictionResponse, Vulnerability, LineRange
from bitsec.utils.data import create_challenge, get_all_vulnerability_and_secure_filenames
from bitsec.validator.reward import score_response
from rich.console import Console
from rich.table import Table
from bitsec.utils.logging import shorten_to_filename


SPEND_MONEY = os.environ.get("SPEND_MONEY", False)

console = Console()
if SPEND_MONEY:
    bt.logging.set_debug()

def setup_identical_responses():
    """
    Create two identical vulnerability responses for testing.
    Tests can modify specific parts to test different scenarios.

    Yields:
        PredictionResponse, PredictionResponse: Two identical response objects
    """
    line_range = LineRange(start=1, end=9)
    vulnerability = Vulnerability(
        short_description="Potential for reentrancy attack during withdrawal.",
        detailed_description="Can lead to loss of funds",
        line_ranges=[line_range]
    )
    
    response1 = PredictionResponse(
        prediction=True,
        vulnerabilities=[vulnerability]
    )
    
    # Create a deep copy to avoid shared references
    response2 = PredictionResponse.model_validate(response1.model_dump())
    
    return response1, response2

@flaky(max_runs=3, min_passes=1, rerun_filter=lambda err, *args: True)
def test_similarity_of_short_descriptions1():
    if not SPEND_MONEY:
        return

    response1, response2 = setup_identical_responses()
    short_description_2 = "Withdrawal is vulnerable to reentrancy attack."
    response2.vulnerabilities[0].short_description = short_description_2

    score, reason, _, _, _ = score_response(response1, response2)
    assert score >= 4, f"Score is {score}, expected 4. Reason: {reason}\nShort descriptions: {response1.vulnerabilities[0].short_description} and {short_description_2}"

@flaky(max_runs=3, min_passes=1, rerun_filter=lambda err, *args: True)
def test_similarity_of_short_descriptions2():
    if not SPEND_MONEY:
        return

    response1, response2 = setup_identical_responses()
    short_description_2 = "Reentrancy attack."
    response2.vulnerabilities[0].short_description = short_description_2
    score, reason, _, _, _ = score_response(response1, response2)
    assert score >= 4, f"Score is {score}, expected 4. Reason: {reason}\nShort descriptions: {response1.vulnerabilities[0].short_description} and {short_description_2}"

@flaky(max_runs=3, min_passes=1, rerun_filter=lambda err, *args: True)
def test_similarity_of_long_descriptions():
    if not SPEND_MONEY:
        return

    response1, response2 = setup_identical_responses()
    long_description_2 = "because of the vulnerability to a reentrancy attack during withdrawal, funds can be stolen"
    response2.vulnerabilities[0].detailed_description = long_description_2
    score, reason, _, _, _ = score_response(response1, response2)
    assert score >= 4, f"Score is {score}, expected 4. Reason: {reason}\nLong descriptions: {response1.vulnerabilities[0].detailed_description} and {long_description_2}"


@flaky(max_runs=1, min_passes=1, rerun_filter=lambda err, *args: True)
def test_response_for_every_sample_no_vulnerabilities():
    """Test response with real response."""
    if not SPEND_MONEY:
        return

    _, secure_filenames = get_all_vulnerability_and_secure_filenames()

    # Test no vulnerabilities
    for filename in secure_filenames:
        if "TheRun" in filename:
            print("skipping", filename, "because it has vulnerabilities")
            continue

        code, expected_response = create_challenge(vulnerable=False, secure_filename=filename)
        result = analyze_code(code)
        assert isinstance(result, PredictionResponse)

        # Calculate score so if wrong, print comparison before failing the assertion below
        score, reason, vulnerabilities_expected_and_found, vulnerabilities_expected_but_not_found, vulnerabilities_found_but_not_expected = score_response(expected_response, result)
        if len(result.vulnerabilities) > 0:
            _print_vulnerability_comparison(filename, None, score, reason, vulnerabilities_expected_and_found, vulnerabilities_expected_but_not_found, vulnerabilities_found_but_not_expected, console, bt)
        
        assert result.prediction == expected_response.prediction, f"{filename}: Prediction is {result.prediction}, expected {expected_response.prediction}"
        assert len(result.vulnerabilities) == 0, f"{filename}: Number of vulnerabilities is {len(result.vulnerabilities)}, should be 0"
        assert score >= 4, f"{filename}: Score is {score}, expected at least 4"

@flaky(max_runs=1, min_passes=1, rerun_filter=lambda err, *args: True)
def test_response_for_every_sample_inject_vulnerability():
    """Test response with real response."""
    if not SPEND_MONEY:
        return
    
    vulnerable_filenames, secure_filenames = get_all_vulnerability_and_secure_filenames()
    total_secure = len(secure_filenames)
    total_vulnerable = len(vulnerable_filenames)

    secure_filename_index = 0
    vulnerable_filename_index = 0
    while vulnerable_filename_index < total_vulnerable or secure_filename_index < total_secure:
        vulnerability_filename = vulnerable_filenames[vulnerable_filename_index % total_vulnerable]
        secure_filename = secure_filenames[secure_filename_index % total_secure]
        test_name = f"{shorten_to_filename(secure_filename)} + {shorten_to_filename(vulnerability_filename)}"

        code, expected_response = create_challenge(
            vulnerable=True,
            secure_filename=secure_filename,
            vulnerability_filename=vulnerability_filename
        )
        
        # Check prediction
        result = analyze_code(code)
        assert isinstance(result, PredictionResponse)
        assert result.prediction == expected_response.prediction, f"{test_name}: Prediction is {result.prediction}, expected {expected_response.prediction}"
        assert len(result.vulnerabilities) >= 1, f"{test_name}: Number of vulnerabilities is {len(result.vulnerabilities)}, expected at least 1"
        # Note: do not check exact number of vulnerabilities, since test bot is very simple and does not find all vulnerabilities

        for vuln in result.vulnerabilities:
            assert vuln.short_description is not None, f"{test_name}: Short description is None"
            assert vuln.detailed_description is not None, f"{test_name}: Detailed description is None"
            assert len(vuln.short_description) > 0, f"{test_name}: Short description is empty"
            assert len(vuln.detailed_description) > 0, f"{test_name}: Detailed description is empty"

        # Score response
        score, reason, vulnerabilities_expected_and_found, vulnerabilities_expected_but_not_found, vulnerabilities_found_but_not_expected = score_response(expected_response, result)
        if score < 2:
            _print_vulnerability_comparison(secure_filename, vulnerability_filename, score, reason, vulnerabilities_expected_and_found, vulnerabilities_expected_but_not_found, vulnerabilities_found_but_not_expected, console, bt)
        assert score >= 2, f"{test_name}: Score is {score}, expected at least 2"

        # Increment indices
        vulnerable_filename_index += 1
        secure_filename_index += 1


def _print_vulnerability_comparison(
    secure_filename: str,
    vulnerability_filename: str | None,
    score: float,
    reason: str,
    vulnerabilities_expected_and_found: list[str],
    vulnerabilities_expected_but_not_found: list[str],
    vulnerabilities_found_but_not_expected: list[str],
    console: Console,
    bt: bt # bitTensor logger
) -> None:
    """
    Print a table comparing expected and actual vulnerabilities.

    Args:
        secure_filename: Name of the secure file being analyzed
        vulnerability_filename: Name of the vulnerability file being analyzed, or None if no injected vuln
        score: Analysis score
        reason: Reason for the score
        vulnerabilities_expected_and_found: List of correctly identified vulnerabilities
        vulnerabilities_expected_but_not_found: List of missed vulnerabilities
        vulnerabilities_found_but_not_expected: List of false positive vulnerabilities
        console: Rich console instance for output
    """
    try:
        if bt.logging.current_state_value not in ["Debug", "Trace"]:
            return

        test_name = shorten_to_filename(secure_filename)
        if vulnerability_filename is None:
            test_name += " + (no injected vuln)"
        else:
            test_name += " + " + shorten_to_filename(vulnerability_filename)

        table = Table(title=f"score: [bold blue]{score}[/bold blue] [dark grey]{test_name}[/dark grey]\n[grey]{reason}[/grey]")
        table.add_column("Vulnerability")
        table.add_column("Correct")
        table.add_column("Response")

        # Add rows in order: correct, missing, false positives
        for vuln in vulnerabilities_expected_and_found:
            table.add_row(vuln, "✓", "✓")
        
        for vuln in vulnerabilities_expected_but_not_found:
            table.add_row(vuln, "✓", " ", style="red")

        for vuln in vulnerabilities_found_but_not_expected:
            table.add_row(vuln, " ", "✓", style="red")

        console.print(table)
        console.print()
    except:
        pass
