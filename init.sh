#!/usr/bin/env bash

BASE_PATH=$(pwd)

echo "Install talk-api2x dependencies"

cd $BASE_PATH/talk-api2x && npm i --production

[[ $? -ne 0 ]] && exit $?

echo 'Install talk-web dependencies and build front-end assets'

cd $BASE_PATH/talk-web && npm i && npm run static

[[ $? -ne 0 ]] && exit $?

echo 'Install talk-account dependencies and build front-end assets'

cd $BASE_PATH/talk-account && npm i && npm run static

[[ $? -ne 0 ]] && exit $?

echo 'Install talk-snapper dependencies'

cd $BASE_PATH/talk-snapper && npm i --production

[[ $? -ne 0 ]] && exit $?

echo 'Install talk-os dependencies'

cd $BASE_PATH && npm i --production

[[ $? -ne 0 ]] && exit $?

exit 0
