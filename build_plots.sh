#!/bin/bash

CURRENTDIR="$(pwd)"
OUTPATH="$CURRENTDIR/Output"
INPATH="$CURRENTDIR/Data"
SCRIPTPATH="$CURRENTDIR/Scripts"
TEMPLATEPATH="$CURRENTDIR/Templates"

#Output files
SCOREOUT="score.dat" #Score/Arrow
TENSOUT="tens.dat" #combined X's and 10's
XSOUT="x.dat" #X's 
MISSESOUT="miss.dat" #average miss rate
OUTPLOT="plot.plt" #the output plot


OPTIONS="all"

#Expected Dir Structure
#$INPATH/[TYPE]/[LOCATION/EVENT]/[DATE].dat

#Expected Dat File Structure:
#[Distance(meters)]	[Arrows]	[Score] [10's (no X's)] [X's]	[Misses]
#$1					$2			$3		$4				$5		$6

#Usage: ./build_plots [options]
#Valid Options:
#all - no data discrimination
#[LOCATION/EVENT], ex: 'Papago' - only show data from papago
#[TYPE], ex: 'Tournament' - only show data from tournaments
#range, ex '60' - only show data from 60 meters


#Function Insert_Entry
#USAGE:
#$1 - Filepath
#$2 - [TYPE]
#$3 - [LOCATION/EVENT]
#$4 - [DATE]
function Insert_Entry(){
	#Parse
	while read foo
	do
		foo=(${foo})
		#score out
		score=$(bc <<< "scale=2; ${foo[2]}/${foo[1]}")
		Add_Entry ${OUTPATH}/${SCOREOUT} $4 ${foo[0]} $score
		
		#tens out
		Add_Entry ${OUTPATH}/${TENSOUT} $4 ${foo[0]} $((${foo[3]}+${foo[4]}))
	
		#Xs out
		Add_Entry ${OUTPATH}/${XSOUT} $4 ${foo[0]} ${foo[4]}
		
		#Misses out
		Add_Entry ${OUTPATH}/${MISSESOUT} $4 ${foo[0]} ${foo[5]}
	done < $1
}

#Function Add_Entry
#USAGE:
#$1 - Output Filepath
#$2 - [DATE]
#$3 - [Distance]
#$4 - [Value to Insert]
function Add_Entry(){
	counter=0
	colnum=-1
	arrsize=-1
	topline=""
	

	while read OUTLINE <&3
	do
		#if first line
		if [ $counter -eq 0 ]
		then
			topline=(${OUTLINE})

			arrsize=${#topline[*]}
			#if no top line, insert one
			if [ $arrsize -eq 0 ]
			then
				printf "0\t%d" "${3}" > ${1}
				colnum=0
			else
				#find column with distance
				for i in $(seq 0 "$(($arrsize-1))")
				do
					if [ "${topline[$i]}" -eq "${3}" ]
					then
						colnum=$(($i-1))
					fi
				done
				
				#if not found, add it
				if [ ${colnum} -eq -1 ]
				then 
					sed -i  "1s/.*/${topline[*]}\t${3}/" ${1}
					colnum=$(($arrsize-1))
				fi
			fi
		fi
		((counter++))
	done 3< $1
	
	exec 3<&-

	#create new line , add date
	echo  "" >> $1
	echo -n "${2}" >> $1
	echo -ne "\t" >> $1
	#fill in question marks except for our distance
	for i in $(seq 1 $colnum)
	do
		echo -n "?" >> $1
		echo -ne "\t" >> $1
	done
	#insert data
	echo -n ${4} >> $1
	echo -ne "\t" >> $1

	#add extraneous ?'s
	for i in $(seq $colnum $(($arrsize-1)))
	do
		echo -n "?" >> $1
		echo -ne "\t" >> $1
	done
}

function Sort_Data(){
	sort -g -t '/' -o $OUTPATH/$SCOREOUT -k3 -k1 -k2 $OUTPATH/$SCOREOUT
}

function Make_GNUPlot(){
	cp $TEMPLATEPATH/gnuplot_template.plt $OUTPATH/$OUTPLOT
	printf "plot for [i=2:10] %s using 1:i with linespoint" "\"$OUTPATH/$SCOREOUT\"" >> $OUTPATH/$OUTPLOT



}

function Execute_Graphing(){

	echo "moo"
}


#Program Start

echo "" > ${OUTPATH}/${SCOREOUT}
echo "" > ${OUTPATH}/${TENSOUT}
echo "" > ${OUTPATH}/${XSOUT}
echo "" > ${OUTPATH}/${MISSESOUT}

for f in $INPATH/*/*/*
do 
	DATA=${f#$INPATH}
	DATA=($(echo ${DATA} | sed 's/\//\n/g'))
	
	#format date
	DATA[2]=${DATA[2]%".dat"}
	#replace dashes with slashes
	DATA[2]=$(echo ${DATA[2]} | sed 's/-/\//g')
	
	#[0] - [TYPE], [1] - [LOCATION/EVENT], [2] - [DATE]
	Insert_Entry  ${f} ${DATA[*]}
done

Sort_Data

Make_GNUPlot

$OUTPATH/$OUTPLOT
