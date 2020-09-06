#!/bin/bash -x
cd fabric-samples/test-network

bash ./network.sh down

export TESTNET_PATH=$PWD
export CHANNEL_NAME=mychannel
export PATH=${TESTNET_PATH}/../bin:$PATH
export FABRIC_CFG_PATH=${TESTNET_PATH}/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${TESTNET_PATH}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${TESTNET_PATH}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

bash ./network.sh up createChannel -ca -c $CHANNEL_NAME -s couchdb
bash ./network.sh deployCC -ccn factcheck -ccp ${TESTNET_PATH}/../../chaincode/factcheck/go
