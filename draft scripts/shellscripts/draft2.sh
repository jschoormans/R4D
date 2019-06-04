#!/bin/bash

printf "Shellscript for bart recon --- running. All output in logfile\n"



# parameters
ITERS=100
SLICE=28
RES=712
NSPOKES=1800
NCOILS=6

#bart=/opt/amc/bart/bin/bart
#bart=/scratch/jschoormans/bart-0.4.03/bart-LAPACKE-bld/bart
#bart=~/scratch/bart-0.4.03-j/bart-LAPACKE-bld/bart
bart=/home/jschoormans/bart/bart-LAPACKE-bld/bart

touch logfile #save all output to logfile

$bart version -V
# make tmp directory for files
rootdir=$PWD
tempdir="/home/jschoormans/tmp"
imdir="$PWD/ims"
mkdir -p $imdir
cd $imdir && rm * && cd $rootdir

#copy data to temp folder
cp -n $rootdir/data/femdatacfl.cfl $tempdir
cp -n $rootdir/data/femdatacfl.hdr $tempdir

$bart show -m $tempdir/femdatacfl
# ifft in z direction
$bart fft -i 4 $tempdir/femdatacfl $tempdir/femdatacfl2

# reslice
printf "Reslice.\n"
$bart slice 2 $SLICE $tempdir/femdatacfl2 $tempdir/femdatacfl3
$bart extract 2 0 $NSPOKES $tempdir/femdatacfl3 $tempdir/femdatacfl3

# reshape dimensions
printf "Reshape dimensions.\n"
$bart reshape $(bart bitmask 0 1 2 3) 1 $RES $NSPOKES $NCOILS $tempdir/femdatacfl3 $tempdir/femdatacfl4
$bart show -m $tempdir/femdatacfl3
$bart show -m $tempdir/femdatacfl4

# calculate Trajectory
printf "calculate Trajectory.\n"
$bart traj -r -s4 -x$RES -y$NSPOKES $tempdir/trajrad

#bart nufft
printf "NUFFT.\n"
$bart nufft -g -i $tempdir/trajrad $tempdir/femdatacfl4 $tempdir/r

# back to cartesian k-space 
printf "back to cartesian k-space.\n"
$bart fft  7 $tempdir/r $tempdir/fakeksp

# bart find sensitivity maps
printf "Sensitivity maps.\n"
$bart ecalib -m1 $tempdir/fakeksp $tempdir/sensitivities

# pre-whitening? 

# sort into timeframes

#pics (one slice)
printf "CS recon.\n" 
time $bart pics -g -RT:7:0:0.01 -d5 -i$ITERS -t $tempdir/trajrad $tempdir/femdatacfl4 $tempdir/sensitivities $tempdir/reconpics

printf "\tVisualize..."
#$bart toimg $tempdir/femdatacfl4 $imdir/radksp
$bart toimg $tempdir/r $imdir/recon
$bart toimg $tempdir/reconpics $imdir/reconpics
$bart toimg $tempdir/sensitivities $imdir/sensitivities

printf "done.\n"

#rm $tempdir/*.cfl $tempdir/*.hdr
