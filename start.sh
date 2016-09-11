#! /bin/bash

tmux -2 new -s dronekit -d

tmux split-window -h -t dronekit
tmux split-window -v -t dronekit:0.0

tmux send-keys -t dronekit:0.0 'dronekit-sitl copter --home=41.699723,-86.236343,75,0' C-m
tmux send-keys -t dronekit:0.2 'sleep 2' C-m
tmux send-keys -t dronekit:0.2 'mavproxy.py --master tcp:127.0.0.1:5760 --sitl 127.0.0.1:5501 --out 127.0.0.1:14550 --out 127.0.0.1:14551 --map --console' C-m

tmux -2 attach -t dronekit
