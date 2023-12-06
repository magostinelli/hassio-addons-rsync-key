#!/usr/bin/env bashio
export CONFIG_PATH=/data/options.json
export server=$(jq --raw-output ".server" $CONFIG_PATH)
export port=$(jq --raw-output ".port" $CONFIG_PATH)
export user=$(jq --raw-output ".user" $CONFIG_PATH)
export directory=$(jq --raw-output ".directory" $CONFIG_PATH)
export binary_sensor=$(jq --raw-output ".binary_sensor" $CONFIG_PATH)
export access_token=$(jq --raw-output ".access_token" $CONFIG_PATH)
export auto_purge=$(jq --raw-output ".auto_purge" $CONFIG_PATH)
export SSH_OPT="ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

PUBLIC_KEY=`cat ~/.ssh/id_ed25519.pub`

if [ -n "$access_token" ] && [ -n "$binary_sensor" ] && [ "$access_token" != "MY_LONG_TERM_ACCESS_TOKEN" ]; then
	bashio::log.info "Changing binary sensor $binary_sensor to on"
	curl -s -X POST -H "Authorization: Bearer $access_token" \
	-H "Content-Type: application/json" \
	-d '{"state": "on", "attributes": {"friendly_name": "Backup Rsync"}}' \
	http://homeassistant:8123/api/states/binary_sensor.$binary_sensor
fi

bashio::log.info "A public/private key pair was generated for you."
bashio::log.notice "Please use this public key on the backup server:"
bashio::log.notice "${PUBLIC_KEY}"

error=0
rsyncurl="$user@$server:$directory"

bashio::log.info "Uploading backup to to $rsyncurl ..."
bashio::log.info "rsync -av -e "$SSH_OPT" /backup/ $rsyncurl"
rsync -av -e "$SSH_OPT" /backup/ $rsyncurl || error=1

if [ $auto_purge -ge 1 ]; then
	bashio::log.info "Start auto purge, keep last $auto_purge backups"
	for file in `ls -t /backup/*.tar | awk "NR>$auto_purge"`;do echo "Purging file $file ...";rm $file; done || bashio::exit.nok "Could not prune backups."
fi

if [ $error -eq 1 ]; then
	if [ -n "$access_token" ] && [ -n "$binary_sensor" ] && [ "$access_token" != "MY_LONG_TERM_ACCESS_TOKEN" ]; then
 		bashio::log.info "Changing binary sensor $binary_sensor to off"
 		curl -s -X POST -H "Authorization: Bearer $access_token" \
   		-H "Content-Type: application/json" \
		-d '{"state": "off", "attributes": {"friendly_name": "Backup Rsync"}}' \
    		http://homeassistant:8123/api/states/binary_sensor.$binary_sensor
	fi
 	bashio::exit.nok "Could not upload backup."
 fi

bashio::log.info 'Finished rsync-backups'

bashio::log.info 'Finished.'
bashio::exit.ok
