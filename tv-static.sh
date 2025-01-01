#!/bin/bash

FPS=${1:-15}
CHARS=("▀" "▄" "▌" "▐" "▖" "▗" "▘" "▝")

while true; do
    HEIGHT=$(tput lines)
    WIDTH=$(tput cols)
    echo -ne "\e[1;1H"
    for ((i=0; i<HEIGHT-1; i++)); do
        for ((j=0; j<WIDTH; j++)); do
            SHADE=$((232 + RANDOM % 22))
            CHAR=${CHARS[RANDOM % ${#CHARS[@]}]}
            echo -ne "\e[38;5;${SHADE}m${CHAR}\e[0m"
        done
        echo 
    done
    sleep $(echo "scale=3; 1.0 / $FPS" | bc)
done
