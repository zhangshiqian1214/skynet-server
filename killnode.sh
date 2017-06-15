#!/bin/bash

if [ $# == 1 ]; then
	progress=$1
	ps -ef | grep skynet | grep $progress | awk '{print $2}' | xargs kill -9
	echo "kill $progress ok"
fi
