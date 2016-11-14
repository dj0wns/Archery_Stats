#!/bin/bash

for f in */*/*
do 
	echo $f | sed 's/\//\n/g'

done
