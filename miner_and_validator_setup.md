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

1. Copy the miner's ss58 address.
2. Go to
   https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Ftest.finney.opentensor.ai%3A443#/accounts
3. Click the send button next to any account e.g. Alice
4. Paste the ss58 address in the "Send to address" box
5. Set amount to 100
6. Click the "Make Transfer" button

Repeat for all wallets, hot and cold.

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
