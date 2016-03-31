#!/bin/bash

BASE_PATH=$(pwd)

echo "Install packages of talk-api2x"

cd $BASE_PATH/talk-api2x && npm i --production

[[ $? -ne 0 ]] && exit $?

echo 'Install packages of talk-web'

cd $BASE_PATH/talk-web && npm i && npm run static

[[ $? -ne 0 ]] && exit $?

echo 'Install packages of talk-account'

cd $BASE_PATH/talk-account && npm i && npm run static

[[ $? -ne 0 ]] && exit $?

echo 'Install packages of talk-os'

cd $BASE_PATH && npm i --production

[[ $? -ne 0 ]] && exit $?

cd $BASE_PATH/talk-snapper && npm i --production

[[ $? -ne 0 ]] && exit $?
