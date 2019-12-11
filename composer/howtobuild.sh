cd "$(dirname "$0")"

../bin/cryptogen generate --config=./crypto-config.yaml
export FABRIC_CFG_PATH=$PWD
../bin/configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block
../bin/configtxgen -profile nhsolutionChannel -outputCreateChannelTx ./jnhsolutionchannel.tx -channelID nhsolutionchannel


ORG1KEY="$(ls crypto-config/peerOrganizations/org1.jacksolution.com/ca/ | grep 'sk$')"

#sed -i -e "s/{ORG1-CA-KEY}/$ORG1KEY/g" docker-compose.yml

