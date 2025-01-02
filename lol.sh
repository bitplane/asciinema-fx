#!/bin/bash

num_prints=150

while getopts "n:" opt; do
  case $opt in
    n) num_prints=$OPTARG ;;
    *) exit 1 ;;
  esac
done

shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
  words=(" LOL ")
else
  words=("$@" " $* ")
fi

width=$(tput cols)
height=$(tput lines)

get_random_colours() {
  local contrasting_pairs=(
    "31 47" "32 41" "33 44" "34 43" "35 42" "36 41" "37 46"
    "37 41" "31 42" "32 47" "33 45" "34 46" "35 44" "36 43"
  )

  pair=${contrasting_pairs[RANDOM % ${#contrasting_pairs[@]}]}
  rand_fg=$(echo $pair | cut -d' ' -f1)
  rand_bg=$(echo $pair | cut -d' ' -f2)
}

printf "\033[s"

for i in $(seq 1 "$num_prints"); do
  text=${words[RANDOM % ${#words[@]}]}
  rand_x=$((RANDOM % (width - ${#text} + 1)))
  rand_y=$((RANDOM % height + 1))

  get_random_colours

  printf "\033[%d;%dH\033[%d;%dm%s\033[0m" "$rand_y" "$rand_x" "$rand_fg" "$rand_bg" "$text"
  
  sleep 0.01

done

printf "\033[u"
