#!/usr/bin/with-contenv bash
if [[ -z "${NC_PASS}" ]]; then
  echo "NEXTCLOUD VARIABLES NOT SET"
  echo "Please fill the env file"
  sleep 100
  exit 1
fi

echo "Sync NC file in progress"
sync=$(/usr/bin/nextcloudcmd --path ${NC_PATH} /vaults https://${NC_USER}:${NC_PASS}@${NC_HOST})
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "SYNC FAILED"
  echo $sync
  echo $exit_code
  echo "SYNC FAILED"
  sleep 100
else
  echo "Sync complete"
  sleep 5
fi
