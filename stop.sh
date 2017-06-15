#!/bin/bash

branch=__default__

#stop skynet
ps -ef | grep skynet | grep $branch | awk '{print $2}' | xargs kill -9

#stop redis
ps -ef | grep redis | grep -v 'grep' | awk '{print $2}' | xargs kill -9