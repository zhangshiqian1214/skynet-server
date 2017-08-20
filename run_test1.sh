#!/bin/bash
dir=.
branch=__default__
redisdir=$dir/redis
skynetdir=$dir/skynet

($skynetdir/skynet $dir/config/config_test1 $branch )
