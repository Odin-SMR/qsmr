echo $LD_LIBRARY_PATH
MATLAB_ROOT=/opt/MATLAB/R2015b
${MATLAB_ROOT}/bin/mcc \
	-a ./Settings \
	-a ./Mscripts_arts \
	-a ./Mscripts_atmlab \
	-a ./Mscripts_atmlab/time \
	-a ./Mscripts_atmlab/xml \
	-a ./Mscripts_database \
	-a ./Mscripts_external \
	-a ./Mscripts_qsystem \
	-a ./Mscripts_precalc \
	-a ./Mscripts_webapi \
	-v \
	-N \
	-m \
	-R -nojvm \
	-R -nodisplay \
	runscript
