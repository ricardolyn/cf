#!/bin/sh

set -e

truffle deploy --reset
redis-cli flushall
cp build/contracts/* ../cf-core/blockchain/contracts
cp build/contracts/* ../cf-web/src/contracts
cd ../cf-core
pm2 restart ./ecosystem.config.js
cd ../cf