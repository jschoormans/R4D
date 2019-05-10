#!/bin/bash

printf "Shellscript for bart recon --- running. All output in logfile\n"



# parameters
RES=128
NCOILS=24
NSPOKES=500
ITERS=1000

#bart=/opt/amc/bart/bin/bart
#bart=/scratch/jschoormans/bart-0.4.03/bart-LAPACKE-bld/bart
#bart=~/scratch/bart-0.4.03-j/bart-LAPACKE-bld/bart
bart=/home/jschoormans/bart-bld/bart-LAPACKE-bld/bart

touch logfile #save all output to logfile

$bart version
# make tmp directory for files
rootdir=$PWD
tempdir="/home/jschoormans/tmp"
imdir="$PWD/ims"
mkdir -p $imdir
cd $imdir && rm * && cd $rootdir

rm $tempdir/*.cfl $tempdir/*.hdr
#copy data to temp folder
#cp -n $rootdir/data/fem_one_slice.cfl $tempdir
#cp -n $rootdir/data/fem_one_slice.hdr $tempdir
#cp -n $rootdir/data/noisedata.hdr $tempdir
#cp -n $rootdir/data/noisedata.cfl $tempdir

cp -n $rootdir/data/data_allcoils.cfl $tempdir
cp -n $rootdir/data/data_allcoils.hdr $tempdir
cp -n $rootdir/data/noise_allcoils.hdr $tempdir
cp -n $rootdir/data/noise_allcoils.cfl $tempdir


$bart reshape $(bart bitmask 0 1 2) 1 712 1800 $tempdir/data_allcoils $tempdir/data1
$bart extract 2 0 100 $tempdir/data1 $tempdir/data2
$bart show -m $tempdir/data


# noise whitening 
# reshape noisedata
$bart show -m $tempdir/noise_allcoils
$bart reshape $(bart bitmask 0 1 2 3 4 5 6 7) 19936 1 1 24 1 1 1 1 $tempdir/noise_allcoils $tempdir/noisedata
$bart show -m $tempdir/noisedata

# whitening
$bart whiten -n $tempdir/data2 $tempdir/noisedata $tempdir/data3 $tempdir/optmatout $tempdir/covarout

echo "optmatout"
$bart show $tempdir/optmatout
echo "covarout"
$bart show $tempdir/covarout

# calculate Trajectory
RES=712
NSPOKES=100
$bart traj -r -s4 -x$RES -y$NSPOKES $tempdir/trajrad


$bart show -m $tempdir/data_allcoils
# TO DO --> CHANGE DIMENSIONS HERE ?!? 

#bart nufft
$bart nufft $tempdir/trajrad $tempdir/data3 $tempdir/r
#nufft GPU does NOT work - pics does tho


printf "\tVisualize..."
#$bart toimg $tempdir/femdatacfl4 $imdir/radksp
$bart toimg $tempdir/r $imdir/recon
printf "done.\n"

rm $tempdir/*.cfl $tempdir/*.hdr
