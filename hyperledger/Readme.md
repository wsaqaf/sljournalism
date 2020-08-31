Steps for installation for a first time (clean instance) on Ubuntu 18.04:

1) Install Node.js: https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-18-04

2) Install Ruby on Rails with rbenv (install latest ruby ver you see):
https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-18-04

3) Install PostgreSQL with Ruby on Rails App (remember db name, username and pw for later configurations):
https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-ubuntu-18-04
(only do steps 1 & 2)

4) Install Apache2 with the command: sudo apt-get install apache2-dev

5) Install Passenger as shown here:
https://codepen.io/asommer70/post/installing-ruby-rails-and-passenger-on-ubuntu-an-admin-s-guide

6) Deploy passenger to be used by the app as shown here:
https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/

7) Ensure you have git installed, else install using: sudo apt install git

8) Clone github repo from: https://github.com/wsaqaf/sljournalism.git using the command:
git clone https://github.com/wsaqaf/sljournalism.git

9) Run the commands:
bundle install

10) Run the command: bundle exec rake secret
and keep the output to use in the next step

11) Create the database using the commands (where <db> is the value in step 2)
sudo -u postgres createuser sljournalism
sudo -u postgres createdb sljournalism -O sljournalism
sudo -u postgres psql postgres
ALTER USER sljournalism WITH PASSWORD 'sljournalism';

12) Add an entry in /etc/postgresql/XX/main/pg_hba.conf under the line "local all postgres peer" as follows (<dbuser> from step 2):
local all <dbuser> trust

13) Restart postgres with the command: sudo service postgresql restart

14) Run the command
bundle exec rake assets:precompile db:schema:load RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1

15) In the file sljournalism/config/local_env.yml, fill in the top SECRET_KEY_BASE value with the output from step 7 and fill in the remaining information as appropriate. Remember to use the postgres credentials used in step 3 above

16) Restart apache with: sudo service apache2 restart

17) Install docker using instructions here:
https://www.hostinger.com/tutorials/how-to-install-docker-on-ubuntu

18) Install docker-composer using the commands:
sudo apt-get install docker-compose

19) Add the current user to the docker group and close the ssh session and login again as shown:
sudo usermod -a -G docker $USER
exit

20) install go-lang using the commands:
sudo apt update
sudo apt install golang-go

21) go to /hyperledger/ and run the command: . initialize.sh

22) go to hyperledger/ and the command: . run.sh

23) To ensure that everything works properly, open the website to go through the steps shown in the DEMO video here:
<link to youtube>

====================================

To reset the blockchain and database, empty the database (warning: all claim/claim review and blockchain data will be lost):

1) Open the Rails Console using: rails c
2) Run the following commands to delete all claims and reviews and remove user references to the blockchain:
Claim.destroy_all
ClaimReview.destroy_all
User.update_all("blockchain_tx=NULL")
User.update_all("time_added_to_blockchain=NULL")

3) If you want to preserve the users credentials, skip this step and go to step 4. Otherwise, if you aactually want to also delete the users to start from scratch, you can also use this command in Rails Console:
User.destroy_all

4) Reset the hyperledger database by running the command under the hyperledger/ folder: run.sh
5) Confirm by going to the website that all claims and proceed to sign up as admin if you deleted the users, or sign in as admin and add the users to the blockchain if you just removed them from the blockchain. Then you can do the other steps (add claims and review claims, etc.)

====================================

You can also test the setup directly on the command line (without the interface) using some dummy data like the following:

#1) Register admin,client and factchecker wallets:

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args1":["registerWallet","admin","org1","1", "The Admin"]}' --waitForEvent

peer chaincode invoke -o orderer.example.com:7050 --isInit --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args1":["registerWallet","admin","org1","1", "The Admin"]}' --waitForEvent


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

- You can find the raw blockchain data at using:
sudo less /var/lib/docker/volumes/net_orderer.example.com/_data/chains/mychannel/blockfile_000000
