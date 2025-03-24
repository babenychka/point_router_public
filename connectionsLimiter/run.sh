#!/bin/bash
cd /root/connectionsLimiter
source /root/connectionsLimiter/bin/activate

echo "Starting main.py" >&2
/root/connectionsLimiter/bin/python -u main.py 2>&1
echo "Finished main.py" >&2
echo "Finished main.py" >&2

deactivate