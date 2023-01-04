#!/bin/sh

set -eu

INSTANCE_NAME=$INSTANCE_NAME
PRIVATE_KEY=$PRIVATE_KEY

INSTANCE_ID=${INSTANCE_NAME##*-}
INSTANCE_URL=$INSTANCE_NAME.dev.odoo.com

echo "Instance id : $INSTANCE_ID"
echo "Instance name : $INSTANCE_NAME"
echo "Instance URL :$INSTANCE_ID@$INSTANCE_URL"

echo "Configure SSH"
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
echo "$PRIVATE_KEY" >> ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub && chmod 644 ~/.ssh/id_rsa.pub
ssh-keyscan -H $INSTANCE_URL > ~/.ssh/known_hosts 2> /dev/null && chmod 600 ~/.ssh/known_hosts
alias odoo_sh_ssh='ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=/github/home/.ssh/known_hosts'
alias odoo_sh_scp='scp -i ~/.ssh/id_rsa -o UserKnownHostsFile=/github/home/.ssh/known_hosts'

echo "Wait current revision"
odoo_sh_ssh $INSTANCE_ID@$INSTANCE_URL "mkdir -p github_actions"
echo $GITHUB_SHA > /tmp/last_revision
odoo_sh_scp /tmp/last_revision $INSTANCE_ID@$INSTANCE_URL:/home/odoo/github_actions/last_revision

TRY=3
SLEEP=15
until [ $TRY -eq 0 ] || odoo_sh_ssh $INSTANCE_ID@$INSTANCE_URL '
    cd /home/odoo/src/user
    REV=$(/usr/bin/git rev-parse HEAD)
    LAST_REV=$(cat /home/odoo/github_actions/last_revision)
    if [ "$REV" != "$LAST_REV" ]
    then
      exit 1
    fi
  ' ;
do
  echo $TRY;
  echo "Error retry in $SLEEPs";
  TRY=$(expr $TRY - 1);
  sleep $SLEEP;
done;
