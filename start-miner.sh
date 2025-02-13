#!/bin/bash

# Directly pass all command-line arguments to the Python module
echo "Starting validator with arguments: $@"
python -m neurons.validator "$@"