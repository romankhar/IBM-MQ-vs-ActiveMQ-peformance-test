#!/bin/bash

# This script runs workload on the MOM server - waiting for messages on the input queue and sending those same messages to the output queue.
# In doing so it works as a partner to the requestor script.
#
# Params
# 1 - Type of server (WMQ or AMQ)
# 2 - Type of test (persistent or not)

source perfharness.sh

# Message size is irrelevant since responder just uses whatever message is on the queue
runParallelClients $RESPONDER $1 $2 $MSG_1024 1
