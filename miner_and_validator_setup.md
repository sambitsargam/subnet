# Section 1: Build/Install

This section is for first-time setup and installations.

```
btcli wallet new_coldkey --wallet.name owner --no-use-password --quiet
btcli wallet new_coldkey --wallet.name miner --no-use-password --quiet
btcli wallet new_hotkey --wallet.name miner --wallet.hotkey default --quiet
btcli wallet new_coldkey --wallet.name validator --no-use-password --quiet
btcli wallet new_hotkey --wallet.name validator --wallet.hotkey default --quiet
touch .wallets_setup
btcli wallet list
```

# Send tokens to all the wallets

Go to Bittensor Discord, and submit a Request for Testnet TAO
Send TAO to your tokens.

# Register to subnet

Once all wallets have tokens, register the miner and validator to the subnet.

For TESTNET 209:

```
btcli subnet register --wallet.name miner --netuid 209 --wallet.hotkey default --subtensor.chain_endpoint test
btcli subnet register --wallet.name validator --netuid 209 --wallet.hotkey default --subtensor.chain_endpoint test
```

For MAINNET 60:

```
btcli subnet register --wallet.name miner --netuid 60 --wallet.hotkey default --subtensor.chain_endpoint test
btcli subnet register --wallet.name validator --netuid 60 --wallet.hotkey default --subtensor.chain_endpoint test
```

You also need to change `start-validator.sh` and `start-miner.sh` with your mainnet settings and use `--netuid 60`.

If installs are failing, try the following:

```
brew install pyenv-virtualenv
pyenv virtualenv 3.11.9 bt-venv
pyenv activate bt-venv
pip install -r requirements.txt
./start_miner.sh
```

# Validator installation

When generating synthetic vulnerabilities, you need to make sure the code is valid Solidity. We use Foundry to compile the code.

1. If on a Mac, you may need to run `brew install libusb` first.
2. `curl -L https://foundry.paradigm.xyz | bash`
3. Then install by running: `foundryup`
