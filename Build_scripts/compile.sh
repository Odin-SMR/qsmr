set -e

rm -rf mcr
mkdir -p mcr
cp runscript.m mcr/

echo $LD_LIBRARY_PATH
MATLAB_ROOT=/opt/MATLAB/R2015b

cd mcr && ${MATLAB_ROOT}/bin/mcc \
	-a ../../Mscripts_arts \
	-a ../../Mscripts_atmlab \
	-a ../../Mscripts_atmlab/time \
	-a ../../Mscripts_atmlab/xml \
	-a ../../Mscripts_database \
	-a ../../Mscripts_qsystem \
	-a ../../Mscripts_webapi \
	-v \
	-N \
	-m \
	-R -nojvm \
	-R -nodisplay \
	runscript

tar -czf qsmr.tar.gz readme.txt run_runscript.sh runscript
