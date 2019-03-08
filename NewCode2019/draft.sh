#!/bin/bash

printf "Shellscript for bart recon --- running. All output in logfile\n"



# parameters
RES=128
NCOILS=5
NSPOKES=500
ITERS=1000

#bart= /opt/amc/bart-0.4.03/bin/bart
bart=/scratch/jschoormans/bart-0.4.03/bart-LAPACKE-bld/bart

touch logfile #save all output to logfile

bart version 
# make tmp directory for files
tempdir="/home/jschoormans/tmp"
imdir="$PWD/ims"

mkdir -p $imdir;
cd $tempdir

printf "\tMake radial trajectory..."
$bart traj -x$RES -y$NSPOKES -r -G $tempdir/radialtrajectory
printf "done.\n"

printf "\tMake phantom data..."
$bart phantom -s$NCOILS -x$RES "$tempdir/phantomimage"
$bart phantom -s$NCOILS -x$RES -k -t $tempdir/radialtrajectory $tempdir/phantomkspace
$bart phantom -S$NCOILS -x$RES $tempdir/sensitivities
printf "done.\n"

printf "\tCS Reconstruction..."
$bart pics -g -RT:7:0:0.01 -i $ITERS -t $tempdir/radialtrajectory $tempdir/phantomkspace $tempdir/sensitivities $tempdir/r
printf "done.\n"


printf "\tVisualize..."
$bart toimg $tempdir/phantomimage $imdir/img
$bart toimg "$tempdir/sensitivities" "$imdir/sensemaps"
$bart toimg "$tempdir/r" "$imdir/r"
printf "done.\n"

printf "\tDo Random Tests..."
sleep 0
printf "done.\n"

#cleanup
cd $tempdir
rm *.cfl *.hdr

{ echo "to do - curly braces around outputs logfile" ;} > $imdir/logfile

printf "done.\n"


