#!/bin/bash -x
./byfn.sh -m down
./byfn.sh up -s couchdb -n
docker cp ../../chaincode/factcheck cli:/opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode
docker cp ../../chaincode/run2.sh cli:/opt/gopath/src/github.com/hyperledger/fabric/peer
docker cp ../../chaincode/.bashrc cli:/root
echo "Going into cli... Once you are in cli, run: . run2.sh"
docker exec -it cli /bin/bash
