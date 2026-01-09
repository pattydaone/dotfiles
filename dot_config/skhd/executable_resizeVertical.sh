#!/bin/sh

y=$(yabai -m query --windows --window | jq '.frame.y')

if [ $y = "40.0000" ]; then
    yabai -m window --resize bottom:0:$1
else
    yabai -m window --resize top:0:$1
fi
