#!/bin/gnuplot

set terminal postscript eps enhanced color

set output "Output.eps"

set title "Archery Results"
set xlabel "Date"
set xdata time
set timefmt "%m/%d/%y %H:%M"

set key autotitle columnhead
