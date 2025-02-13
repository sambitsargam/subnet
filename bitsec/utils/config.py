# The MIT License (MIT)
# Copyright © 2023 Yuma Rao
# Copyright © 2023 Opentensor Foundation

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

import os
import subprocess
import argparse
import bittensor as bt
from .logging import setup_events_logger

def is_cuda_available() -> str:
    """Check if CUDA is available on the system."""
    try:
        output = subprocess.check_output(["nvidia-smi", "-L"], stderr=subprocess.STDOUT)
        if "NVIDIA" in output.decode("utf-8"):
            return "cuda"
    except Exception:
        pass
    try:
        output = subprocess.check_output(["nvcc", "--version"]).decode("utf-8")
        if "release" in output:
            return "cuda"
    except Exception:
        pass
    return "cpu"

def base_args(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    """Add common Bittensor arguments."""
    bt.wallet.add_args(parser)
    bt.subtensor.add_args(parser)
    bt.logging.add_args(parser)
    bt.axon.add_args(parser)
    parser.add_argument("--netuid", type=int, default=60, help="Subnet netuid")
    parser.add_argument("--network", type=str, default="finney", help="Subtensor network (test / finney)")
    parser.add_argument("--neuron.device", type=str, default=is_cuda_available(), help="Device to run on.")
    parser.add_argument("--neuron.epoch_length", type=int, default=100, help="Epoch length in 12 second blocks.")
    parser.add_argument("--mock", action="store_true", default=False, help="Mock neuron and all network components.")
    parser.add_argument("--neuron.events_retention_size", type=int, default=2 * 1024 * 1024 * 1024, help="Events retention size.")
    parser.add_argument("--neuron.dont_save_events", action="store_true", default=False, help="If set, we don't save events to a log file.")
    parser.add_argument("--wandb.off", action="store_true", default=False, help="Turn off wandb.")
    parser.add_argument("--wandb.offline", action="store_true", default=False, help="Runs wandb in offline mode.")
    parser.add_argument("--wandb.notes", type=str, default="", help="Notes to add to the wandb run.")
    return parser

def add_common_wandb_args(parser: argparse.ArgumentParser, project_name: str, entity: str) -> None:
    """Add common wandb arguments."""
    parser.add_argument("--wandb.project_name", type=str, default=project_name, help="Wandb project to log to.")
    parser.add_argument("--wandb.entity", type=str, default=entity, help="Wandb entity to log to.")

def add_miner_args(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    """Add miner specific arguments."""
    parser.add_argument("--neuron.name", type=str, default="miner", help="Name for the miner neuron")
    parser.add_argument("--blacklist.force_validator_permit", action="store_true", default=False, help="Force incoming requests to have a permit.")
    parser.add_argument("--blacklist.allow_non_registered", action="store_true", default=False, help="Accept queries from non-registered entities.")
    add_common_wandb_args(parser, "bitsec-miners", "bitsecai")
    return parser

def add_validator_args(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    """Add validator specific arguments."""
    parser.add_argument("--neuron.name", type=str, default="validator", help="Name for the validator neuron")
    parser.add_argument("--neuron.timeout", type=float, default=30, help="Timeout for forward calls (seconds)")
    parser.add_argument("--neuron.num_concurrent_forwards", type=int, default=1, help="Number of concurrent forwards running at any time.")
    parser.add_argument("--neuron.sample_size", type=int, default=100, help="Number of miners to query in a single step.")
    parser.add_argument("--neuron.disable_set_weights", action="store_true", default=False, help="Disables setting weights.")
    parser.add_argument("--neuron.moving_average_alpha", type=float, default=0.1, help="Moving average alpha parameter.")
    parser.add_argument("--neuron.axon_off", "--axon_off", action="store_true", default=False, help="Set this flag to not attempt to serve an Axon.")
    parser.add_argument("--neuron.vpermit_tao_limit", type=int, default=4096, help="Max TAO allowed to query a validator with a vpermit.")
    parser.add_argument("--proxy.port", type=int, default=10913, help="Port to run the proxy on.")
    add_common_wandb_args(parser, "bitsec-validators", "bitsecai")
    return parser

def get_config(mode: str = "validator") -> bt.Config:
    """Returns the configuration object specific to this miner or validator after adding relevant arguments."""
    parser = argparse.ArgumentParser(description="Consolidated config for Bittensor node")
    parser = base_args(parser)
    
    if mode == "validator":
        parser = add_validator_args(parser)
    elif mode == "miner":
        parser = add_miner_args(parser)
    else:
        raise ValueError("Mode must be either 'validator' or 'miner'")
    
    config = bt.config(parser)
    check_config(config)
    return config

def check_config(config: bt.Config) -> None:
    """Validate the configuration to ensure all necessary settings are correct."""
    if config.neuron.device not in ["cuda", "cpu"]:
        raise ValueError("Invalid device specified. Must be 'cuda' or 'cpu'.")
    if config.neuron.epoch_length <= 0:
        raise ValueError("Epoch length must be a positive integer.")
    if config.mode not in ["validator", "miner"]:
        raise ValueError("Mode must be either 'validator' or 'miner'.")
    
    full_path = os.path.expanduser(
        "{}/{}/{}/netuid{}/{}".format(
            config.logging.logging_dir,  # TODO: change from ~/.bittensor/miners to ~/.bittensor/neurons
            config.wallet.name,
            config.wallet.hotkey,
            config.netuid,
            config.neuron.name,
        )
    )
    print("full path:", full_path)
    config.neuron.full_path = os.path.expanduser(full_path)
    if not os.path.exists(config.neuron.full_path):
        os.makedirs(config.neuron.full_path, exist_ok=True)
    
    # Log the configuration for debugging
    if not config.neuron.dont_save_events:
        # Add custom event logger for the events.
        events_logger = setup_events_logger(
            config.neuron.full_path, config.neuron.events_retention_size
        )
        bt.logging.register_primary_logger(events_logger.name)