#!/bin/bash

TMPFILE=`mktemp XXXXXXXXXXXX.html` 

wget -O $TMPFILE $1

flex TESTE.l
cc lex.yy.c -lfl
./a.out $TMPFILE
ffmpeg -i *.mp4 -vf palettegen palette.png -y
ffmpeg -i *.mp4 -i palette.png -lavfi paletteuse $2.gif

rm $TMPFILE
rm list.txt
rm lex.yy.c
rm *.mp4*
rm a.out

echo $TMPFILE	
