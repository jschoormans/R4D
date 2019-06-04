#!/bin/bash


# new script - grasp recon with pics (GPU) 
#-(test whitening)


printf "Shellscript for BART GRASP reconstruction --- running. All output in logfile\n\n"
printf "To do \n-logfile \n-automate reading of philips listfile \n-3D support \n-etc...\n\n"


# parameters
export ITERS=30
export REG=0.01
export CALIB=100
export SCALE=0.5
export SPOKES=40
export PHASES=20

#define BART version to use
printf "\nBART version:\n"
export bart=/home/jschoormans/bart-bld/bart-LAPACKE-bld/bart

#create logfile
touch logfile 

# output version of BART used (as a check) 
$bart version -V

# make tmp directory for files
tempdir=`mktemp -d`
trap 'rm -rf "$tempdir"' EXIT #remove files and exit upon ctrl-C

rootdir=$PWD
imdir="$PWD/ims"
mkdir -p $imdir
cd $imdir && rm * 2>/dev/null 

cd $tempdir

# copy data to temp folder
printf "\nCopying data to tmp folder...\n"
cp -n $rootdir/data/data_allcoils.cfl $tempdir/grasp.cfl
cp -n $rootdir/data/data_allcoils.hdr $tempdir/grasp.hdr
cp -n $rootdir/data/noise_allcoils.hdr $tempdir/noise.hdr
cp -n $rootdir/data/noise_allcoils.cfl $tempdir/noise.cfl


printf "Extracting scan parameters...\n"
export READ=$($bart show -d0 grasp)
export COILS=$($bart show -d3 grasp)
export NSPOKES=$($bart show -d1 grasp)

echo $READ $COILS $NSPOKES


# noise whitening 
# reshape noisedata
#$bart show -m $tempdir/noise_allcoils
#$bart reshape $(bart bitmask 0 1 2 3 4 5 6 7) 19936 1 1 24 1 1 1 1 $tempdir/noise_allcoils $tempdir/noisedata
#$bart show -m $tempdir/noisedata

# whitening
#$bart whiten -n $tempdir/data2 $tempdir/noisedata $tempdir/data3 $tempdir/optmatout $tempdir/covarout

#echo "optmatout"
#$bart show $tempdir/optmatout
#echo "covarout"
#$bart show $tempdir/covarout

# calculate trajectory for calibration
printf "Calculating trajectories...\n"
$bart traj -r -s4 -x$READ -y$CALIB t
$bart scale $SCALE t trajcalib

# create trajectory with 2064 spokes and 2x oversampling
$bart traj -G -s4 -x$READ -y$(($SPOKES * $PHASES)) t
$bart scale $SCALE t t2

# split off time dimension into index 10
$bart reshape $(bart bitmask 2 10) $SPOKES $PHASES t2 trajfull

calib_slice()
{
	printf "Reshaping raw data...\n"
	$bart reshape $(bart bitmask 0 1 2) 1 $READ $NSPOKES grasp data1

	# extract first $CALIB spokes
	$bart extract 2 0 $CALIB data1 data3

	# apply inverse nufft to first $CALIB spokes
	$bart nufft -i -t trajcalib data3 imgnufft

	# transform back to k-space
	$bart fft -u $(bart bitmask 0 1 2) imgnufft ksp

	# find sensitivity map
	$bart ecalib -S -c0.8 -m1 -r20 ksp sens2
}


recon_slice()
{
	# extract spokes and split-off time dim
	printf "extract"
	$bart extract 1 0 $(($SPOKES * $PHASES)) grasp grasp2
	$bart show -m grasp
	$bart show -m grasp2
	printf "reshape"
	$bart reshape $(bart bitmask 1 2) $SPOKES $PHASES grasp2 grasp1

	# move time dimensions to dim 10 and reshape
	$bart transpose 2 10 grasp1 grasp2
	$bart reshape $(bart bitmask 0 1 2) 1 $READ $SPOKES grasp2 grasp1

	# reconstruction with tv penality along dimension 10
	$bart pics -G -S -u10 -RT:$(bart bitmask 10):0:$REG -i$ITERS -t trajfull grasp1 sens2 impics

}




calib_slice
recon_slice

# pics recon
#printf "CS RECON...\n"
#$bart pics -RT:0:0:$REG -i$ITER -t trajrad sensemaps data2 r

# visualize recon
printf "\tVisualize..."
$bart toimg imgnufft $imdir/recon
$bart toimg sens2 $imdir/sens2
$bart toimg impics $imdir/impics
#rm $tempdir/*.cfl $tempdir/*.hdr

printf "End of script. \n" 
