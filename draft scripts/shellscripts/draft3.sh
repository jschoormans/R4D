#!/bin/bash

printf "Test trajectory angles\n"



# parameters
RES=256
NCOILS=2
NSPOKES=800
ITERS=100

#bart= /opt/amc/bart-0.4.03/bin/bart
#bart=/scratch/jschoormans/bart-0.4.03/bart-LAPACKE-bld/bart
bart=~/bart/bart-LAPACKE-bld/bart


$bart version
# make tmp directory for files
tempdir="/home/jschoormans/tmp"
imdir="$PWD/ims"

mkdir -p $imdir;
cd $tempdir

printf "\tMake radial trajectory..."
#$bart traj -x$RES -y$NSPOKES -r -G $tempdir/radialtrajectory
$bart traj -x$RES -y$NSPOKES -r -G -s5 $tempdir/radialtrajectory
printf "done.\n"

printf "\tMake phantom data..."
$bart phantom -s$NCOILS -x$RES "$tempdir/phantomimage"
$bart phantom -s$NCOILS -x$RES -k -t $tempdir/radialtrajectory $tempdir/phantomkspace
$bart phantom -S$NCOILS -x$RES $tempdir/sensitivities
printf "done.\n"

$bart delta 0 100 $tempdir/delta
$bart show -m $tempdir/delta 

$bart show -m $tempdir/phantomkspace

printf "\tNUFFT Reconstruction..."
$bart nufft -i $tempdir/radialtrajectory $tempdir/phantomkspace $tempdir/r
printf "done.\n"

printf "\tVisualize..."
$bart toimg $tempdir/phantomkspace $imdir/phantomkspace
#$bart toimg "$tempdir/sensitivities" "$imdir/sensemaps"
$bart toimg "$tempdir/r" "$imdir/r"
printf "done.\n"

printf "\tDo Random Tests..."
sleep 0
printf "done.\n"

#cleanup
cd $tempdir
rm *.cfl *.hdr

printf "done.\n"
