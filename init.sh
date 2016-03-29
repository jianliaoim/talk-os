#!/bin/bash

echo "Install packages of talk-api2x"

cd talk-api2x && npm i --production

[[ $? -ne 0 ]] && exit $?

echo 'Install packages of talk-web'

[[ $? -ne 0 ]] && exit $?

echo 'Install packages of talk-account'

[[ $? -ne 0 ]] && exit $?
