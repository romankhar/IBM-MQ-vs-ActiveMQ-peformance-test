#!/bin/bash

source perfharness.sh

runParallelClients $REQUESTOR $AMQ $NON_PERSISTENT $MSG_2048
