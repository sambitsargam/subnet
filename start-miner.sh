#!/bin/bash

PID_FILE="miner.pid"

# Kill previous instance if running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill $OLD_PID 2>/dev/null || true
    rm "$PID_FILE"
fi

# Start miner and save PID
python -m neurons.miner --netuid 209 --subtensor.chain_endpoint test \
    --wallet.name miner --wallet.hotkey default \
    --axon.port 8092 --axon.external_port 8092 \
    --logging.debug > miner.log 2>&1 & 
echo $! > "$PID_FILE"