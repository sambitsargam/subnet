#!/bin/bash
PID_FILE="validator.pid"

# Kill previous instance if running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill -9 $OLD_PID
    sleep 1
    rm "$PID_FILE"
fi

echo "Starting validator in ./start-validator.sh..."

# Activate virtual environment
source venv/bin/activate
echo "Activated virtual environment"

python -m neurons.validator --netuid 209 --subtensor.chain_endpoint test \
    --wallet.name validator --wallet.hotkey default \
    --axon.port 8091 --axon.external_port 8091 \
    --logging.debug