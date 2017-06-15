#!/bin/bash
dir=.
branch=__default__
redisdir=$dir/redis
skynetdir=$dir/skynet

cd $dir
sh stop.sh > /dev/null 2>&1

#start redis
($redisdir/redis-server $redisdir/redis.conf &)

#start skynet
($skynetdir/skynet $dir/config/config_test $branch &)
