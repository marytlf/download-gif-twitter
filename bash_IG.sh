#!/bin/bash

TMPFILE=`mktemp XXXXXXXXXXXX.html` 

wget -O $TMPFILE $1

flex TESTE.l
cc lex.yy.c -lfl
./a.out $TMPFILE

rm list.txt
rm lex.yy.c
rm a.out
rm *.mp4.*
rm *.html

start_time=$3
duration=$4

palette="palette.png"

filters="trim=start_frame=12:end_frame=431,fps=15,subtitles=marcadagua.ass,scale=420:-1:flags=lanczos"

ffmpeg -v warning -ss $start_time -t $duration -i *.mp4 -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -ss $start_time -t $duration -i *.mp4 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $2.gif

rm *.mp4