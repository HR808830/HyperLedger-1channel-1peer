#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Grab the file names of the keystore keys
ORG1KEY="$(ls composer/crypto-config/peerOrganizations/org1.nhsolution.com/users/Admin@org1.nhsolution.com/msp/keystore/)"

#echo
# check that the composer command exists at a version >v0.14
if hash composer 2>/dev/null; then
    composer --version | awk -F. '{if ($2<15) exit 1}'
    if [ $? -eq 1 ]; then
        echo 'Sorry, Use createConnectionProfile for versions before v0.15.0' 
        exit 1
    else
        echo Using composer-cli at $(composer --version)
    fi
else
    echo 'Need to have composer-cli installed at v0.15 or greater'
    exit 1
fi
# need to get the certificate

cat << EOF > org1connection.json
{
    "name": "nhsolution",
    "x-type": "nhsolution",
    "x-commitTimeout": 300,
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "nhsolutionchannel": {
            "orderers": [
                "orderer.nhsolution.com"
            ],
            "peers": {
                "peer0.org1.nhsolution.com": {}
            }
        },
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.nhsolution.com"
            ],
            "certificateAuthorities": [
                "ca.org1.nhsolution.com"
            ]
        }
    },
    "orderers": {
        "orderer.nhsolution.com": {
            "url": "grpc://localhost:7050",
            "hostnameOverride" : "orderer.nhsolution.com"
        }
    },
    "certificateAuthorities": {
        "ca.org1.nhsolution.com": {
            "url": "http://localhost:7054",
            "name": "ca.org1.nhsolution.com",
            "hostnameOverride": "ca.org1.nhsolution.com"
        }
    },
    "peers": {
        "peer0.org1.nhsolution.com": {
            "url": "grpc://localhost:7051",
            "eventUrl": "grpc://localhost:7053",
            "hostnameOverride": "peer0.org1.nhsolution.com"
        }
    }
}
EOF




PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org1.nhsolution.com/users/Admin@org1.nhsolution.com/msp/keystore/"${ORG1KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org1.nhsolution.com/users/Admin@org1.nhsolution.com/msp/signcerts/Admin@org1.nhsolution.com-cert.pem

if sudo composer card list -n @nhsolution > /dev/null; then
    sudo composer card delete -n @nhsolution
fi
echo "nhsolution PeerAdmin card has been Found------"

sudo composer card create -p org1connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@nhsolution.card
sudo composer card import --file /tmp/PeerAdmin@nhsolution.card

echo "Hyperledger Composer PeerAdmin card has been imported"
sudo composer card list


echo "Hyperledger Composer PeerAdmin card Install"


# composer network install --card PeerAdmin@nhsolution --archiveFile nhsolution-network@0.0.1.bna
# composer network start --networkName nhsolution-network --networkVersion 0.0.1 --networkAdmin admin --networkAdminEnrollSecret adminpw --card PeerAdmin@nhsolution --file nhsolution-network.card
# composer card import --file nhsolution-network.card