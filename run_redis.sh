#!/bin/bash
dir=.
branch=__default__
redisdir=$dir/redis

#start redis
($redisdir/redis-server $redisdir/redis.conf &)

