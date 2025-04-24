from bitsec.utils.llm import chat_completion
from bitsec.protocol import Vulnerability
from typing import List
import bittensor as bt
import json
from fpdf import FPDF

VULNERABILITY_TO_REPORT_TEMPLATE = """You are an expert in economic security analysis for decentralized computing systems, specifically for the Bittensor network. 

Your task is to generate a new economic analysis report for a system that involves miners, validators, and reward mechanisms. The report should focus on potential financial vulnerabilities and economic exploits within the system.

For each vulnerability, the report should contain the following sections:

1. **Economic Exploit:** Describe the vulnerability and how it could be exploited for financial gain.
2. **Code Examples:** Include code snippets illustrating vulnerability and how it can be exploited. 
3. **Mitigation Strategy:** Provide code snippets with the vulnerability fixed.

Format the report in markdown:

# [vulnerability number eg 1.] [Vulnerability Category]
[vulnerability description]

### Vulnerable Code
```
[vulnerable code]
```

### Code to Exploit
```
[code to exploit]
```

### Rewritten Code to Fix Vulnerability
```
[rewritten code to fix vulnerability]
```

### Cross-Validation Score
[cross-validation score]

### Historical Accuracy
[historical accuracy]

### Vulnerability Classification Bonus
[vulnerability classification bonus]

---------
Note: Do not include any other text than the sections above.
Note: If any of the sections are not code, do not include the ``` code block.
---------

Here is the list of vulnerabilities:
{vulnerabilities}
"""

def format_vulnerability_to_report(
    vulnerabilities: List[Vulnerability],
    model: str = None,
    temperature: float = None,
) -> str:
    """
    Format the vulnerability analysis into a human readable report.

    Args:
        vulnerabilities (List[Vulnerability]): The vulnerabilities to format.
        model (str): The model to use for analysis.
        temperature (float): Sampling temperature.
        max_tokens (int): Maximum number of tokens to generate.

    Returns:
        str: The formatted report.
    """
    prompt = VULNERABILITY_TO_REPORT_TEMPLATE.format(vulnerabilities=vulnerabilities)
    max_tokens = 16384

    try:
        response = chat_completion(prompt, model=model, temperature=temperature, max_tokens=max_tokens)
        return response
    except Exception as e:
        bt.logging.error(f"Failed to format analysis: {e}")
        raise

def generate_report_json(findings: List[Vulnerability]) -> str:
    """
    Generate a human-readable and machine-actionable report in JSON format.

    Args:
        findings (List[Vulnerability]): The findings to include in the report.

    Returns:
        str: The report in JSON format.
    """
    report = {
        "findings": [vulnerability.model_dump() for vulnerability in findings]
    }
    return json.dumps(report, indent=4)

def generate_report_pdf(findings: List[Vulnerability], output_path: str):
    """
    Generate a human-readable and machine-actionable report in PDF format.

    Args:
        findings (List[Vulnerability]): The findings to include in the report.
        output_path (str): The path to save the PDF report.
    """
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)

    for i, vulnerability in enumerate(findings, 1):
        pdf.cell(200, 10, txt=f"{i}. {vulnerability.category}", ln=True, align='L')
        pdf.multi_cell(0, 10, txt=vulnerability.description)
        pdf.ln(5)
        pdf.cell(200, 10, txt="Vulnerable Code:", ln=True, align='L')
        pdf.multi_cell(0, 10, txt=vulnerability.vulnerable_code)
        pdf.ln(5)
        pdf.cell(200, 10, txt="Code to Exploit:", ln=True, align='L')
        pdf.multi_cell(0, 10, txt=vulnerability.code_to_exploit)
        pdf.ln(5)
        pdf.cell(200, 10, txt="Rewritten Code to Fix Vulnerability:", ln=True, align='L')
        pdf.multi_cell(0, 10, txt=vulnerability.rewritten_code_to_fix_vulnerability)
        pdf.ln(10)

    pdf.output(output_path)
