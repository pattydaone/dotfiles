#!/bin/sh

x=$(yabai -m query --windows --window | jq '.frame.x')

if [ $x = "-0.0000" ]; then
    yabai -m window --resize right:$1:0
else
    yabai -m window --resize left:$1:0
fi
