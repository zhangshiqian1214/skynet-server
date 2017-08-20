#!/bin/bash
dir=.
branch=__default__
redisdir=$dir/redis
skynetdir=$dir/skynet

#start skynet
($skynetdir/skynet $dir/config/config_db $branch)
