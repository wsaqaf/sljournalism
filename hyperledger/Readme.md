To install this, just follow all the instructions shown here:
https://hyperledger-fabric.readthedocs.io/en/release-2.0/build_network.html

1) If you haven't already done so, download and run the latest version of Hyperledger Fabric (v2.0):
curl -sSL https://bit.ly/2ysbOFE | bash -s

2) run run.sh in the chaincode folder as: bash run.sh

3) You are now done and have the chaincode installed.
 You are now ready to interact with the chaincode in adding, fetching and deleting factchecks.

Here are examples:

#For linux commands, start with:
### docker exec -ti peer0.org1.example.com sh

#1) Register admin,client and factchecker wallets:

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args1":["registerWallet","admin","org1","1", "The Admin"]}' --waitForEvent

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["registerWallet","client","org1","2", "The Client"]}' --waitForEvent

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["registerWallet","factchecker","org1","3", "The Factchecker"]}' --waitForEvent

#Three more wallets for factcheckers:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["registerWallet","factchecker","org1","4", "The Factchecker 2"]}' --waitForEvent

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["registerWallet","factchecker","org1","5", "The Factchecker 3"]}' --waitForEvent

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["registerWallet","factchecker","org1","6", "The Factchecker 4"]}' --waitForEvent


#4) Fund client wallet:

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addToClientWallet","WC5477479596831767879","1000"]}' --waitForEvent

#5) Add claim: //pay attention to deadline and amount of reward!
#"2020-05-27 19:44",

#with deadline and good reward:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addClaim","org1","1","2","Claim: Hydroxychloroquine cures COVID19","http://factcheck1.org/claimreview_a133","2020-08-17 10:00","100","Provide sufficient evidence to support your factcheck results","http://twitter.com/1232324","Trump claims that this Hydroxychloroquine can help cure COVID19 or mitigate its impact.","realDonaldTrump","Twitter","0","0","1","[twitter, Hydroxychloroquine, coronavirus, cure]"]}' --waitForEvent

#with deadline and bad reward:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addClaim","org1","1","2","Hydroxychloroquine cures COVID19","http://factcheck1.org/claimreview_a2","2020-08-17 09:35","1000","Provide sufficient evidence to support your factcheck results","http://twitter.com/123232","Trump claims that this Hydroxychloroquine can help cure COVID19 or mitigate its impact.","realDonaldTrump","Twitter","0","0","1","[twitter, Hydroxychloroquine, coronavirus, cure]"]}' --waitForEvent

#without deadline and reasonable reward
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addClaim","org1","1","2","Hydroxychloroquine cures COVID19","http://factcheck1.org/claimreview_a5",

"",

"300","Provide sufficient evidence to support your factcheck results","http://twitter.com/123232","Trump claims that this Hydroxychloroquine can help cure COVID19 or mitigate its impact.","realDonaldTrump","Twitter","0","0","1","[twitter, Hydroxychloroquine, coronavirus, cure]"]}' --waitForEvent

#6) Add factchecks
#By factchecker 1 for claim1:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addFactcheck","org1","32","3","C1136223178968734305", "false","http://factcheck1.org/claimreview_a1"]}' --waitForEvent

#By factchecker 2 for claim1:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addFactcheck","org1","34","4","C1136223178968734305", "true","http://factcheck1.org/claimreview_a12"]}' --waitForEvent

#By factchecker 3 for claim1:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addFactcheck","org1","34","5","C1136223178968734305", "true","http://factcheck1.org/claimreview_a13"]}' --waitForEvent

#By factchecker 4 for claim2:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addFactcheck","org1","34","6","C8966432708480531031", "true","http://factcheck1.org/claimreview_a4"]}' --waitForEvent

#By factchecker 5 for claim2:
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["addFactcheck","org1","35","7","C8966432708480531031", "true","http://factcheck1.org/claimreview_a5"]}' --waitForEvent


#7) Assess factchecks
#Assess factcheck 1
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["assessFactcheck","org1","F3801206318160426762","1","rejected", "No good!"]}' --waitForEvent

#Assess factcheck 2
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["assessFactcheck","org1","F991998547258116569","1","approved", "Verifiable, clear and thorough factcheck. Well done!"]}' --waitForEvent

#Assess factcheck 3
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["assessFactcheck","org1","F1097948769149161881","1","approved", "Verifiable, clear and thorough factcheck. Well done!"]}' --waitForEvent

#Assess factcheck 4
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["assessFactcheck","org1","F11217180540739326448","1","approved", "Verifiable, clear and thorough factcheck. Well done!"]}' --waitForEvent

#Assess factcheck 5
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["assessFactcheck","org1","F4922028546561623039","1","approved", "Verifiable, clear and thorough factcheck. Well done!"]}' --waitForEvent



#8) QueryByRange
# for records (get all wallets):
peer chaincode query -C mychannel -n factcheck -c '{"Args":["getRecordsByRange","W0","WZZZZZZZZZZZZZZZZZZZZ"]}'
# for records (get admin wallets):
peer chaincode query -C mychannel -n factcheck -c '{"Args":["getRecordsByRange","WA0","WA99999999999999999999"]}'
# for records (get client wallets):
peer chaincode query -C mychannel -n factcheck -c '{"Args":["getRecordsByRange","WC0","WC99999999999999999999"]}'
# for records (get factchecker wallets):
peer chaincode query -C mychannel -n factcheck -c '{"Args":["getRecordsByRange","WF0","WF99999999999999999999"]}'
# for records (get all claims):
peer chaincode query -C mychannel -n factcheck -c '{"Args":["getRecordsByRange","C0","C99999999999999999999"]}'
# for records (get all factchecks):
peer chaincode query -C mychannel -n factcheck -c '{"Args":["getRecordsByRange","F0","F99999999999999999999"]}'

#get all factchecks):
peer chaincode query -C mychannel -n factcheck -c '{"Args":["getRecordsByRange","F0","F99999999999999999999"]}'

#QueryByOrg for claims:
peer chaincode query -C mychannel -n factcheck -c '{"Args":["queryRecordsByOrg","org1","claim"]}'

#QueryByOrg for factchecks:
peer chaincode query -C mychannel -n factcheck -c '{"Args":["queryRecordsByOrg","org1","factcheck"]}'

#QueryRecords for a record with certain characteristics, e.g., :
peer chaincode query -C mychannel -n factcheck -c '{"Args":["queryRecordsByOrg","org1","factcheck"]}'

#QueryRecords to get ownerName, orgID and ownerType of wallets:
peer chaincode query -C mychannel -n factcheck -c '{"Args":["queryRecords","{\"selector\":{\"docType\":\"wallet\"},\"fields\":[\"ownerName\",\"orgID\",\"ownerType\"]}"]}'

#Show wallet balance of a particular wallet:
peer chaincode query -C mychannel -n factcheck -c '{"Args":["queryRecords","{\"selector\":{\"docType\":\"wallet\",\"ownerIDInOrg\":\"38\",\"orgID\":\"org1\"},\"fields\":[\"balance\"]}"]}'

Notes:
- You can find the couchdb statedb data via the links (make sure your firewall ingress port settings are open):
http://<server ip>:<port for couchdb1/_utils/#/_all_dbs
http://<server ip>:<port for couchdb2/_utils/#/_all_dbs
http://<server ip>:<port for couchdb3/_utils/#/_all_dbs

- You can find the raw blockchain data at using:
sudo less /var/lib/docker/volumes/net_orderer.example.com/_data/chains/mychannel/blockfile_000000


====
Contents of run1.sh:

#!/bin/bash -x
./byfn.sh -m down
./byfn.sh up -s couchdb -n
docker cp ../../chaincode/factcheck cli:/opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode
docker cp ../../chaincode/run2.sh cli:/opt/gopath/src/github.com/hyperledger/fabric/peer
docker cp ../../chaincode/.bashrc cli:/root
echo "Going into cli... Once you are in cli, run: . run2.sh"
docker exec -it cli /bin/bash

Contents of run2.sh:

#!/bin/bash
set -x
export CHANNEL_NAME=mychannel
peer lifecycle chaincode package mycc.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/factcheck/go/ --lang golang --label mycc_1
peer lifecycle chaincode install mycc.tar.gz
output=$(peer lifecycle chaincode queryinstalled)
CC_PACKAGE_ID=$(echo $output| sed 's/[^,]*ID: \([^,]*\).*/\1/')

CORE_PEER_MSPCONFIGPATH=$TESTNET_PATH/organizations/ordererOrganizations/example.com/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=peer0.org2.example.com:9051
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=$TESTNET_PATH/organizations/ordererOrganizations/example.com/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

peer lifecycle chaincode install mycc.tar.gz
peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CORE_PEER_MSPCONFIGPATH=$TESTNET_PATH/organizations/ordererOrganizations/example.com/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=$TESTNET_PATH/organizations/ordererOrganizations/example.com/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --sequence 1 --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name mycc --version 1.0 --sequence 1 --init-required --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
peer chaincode invoke -o orderer.example.com:7050 --isInit --tls true --cafile $TESTNET_PATH/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles $TESTNET_PATH/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["Init"]}' --waitForEvent
