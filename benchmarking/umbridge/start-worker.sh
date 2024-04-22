#!/bin/bash


base_dir="$HOME/.hq-server"
highest_dir=$(find "$base_dir" -type d -exec basename {} \; | grep '^[0-9]*$' | sort -n | tail -1)

echo $highest_dir

scp -r 10.10.10.12:/home/crambor/.hq-server $HOME 
rm $HOME/.hq-server/hq-current
ln -s $HOME/.hq-server/$highest_dir $HOME/.hq-server/hq-current 

./hq worker start
