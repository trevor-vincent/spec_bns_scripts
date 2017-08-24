#!/bin/bash

#BEGIN DEFINITIONS: SET THESE BEFORE RUNNING
PATH_TO_EOS_DMR_GEN_SCRIPT="/RQexec/tvincent/Test/eos_dmr_gen.py"
SFHO_TABLE='Tabulated(filename=/RQexec/foucartf/EoSFiles/SFHo_ColdTable-T0.1.dat;)' #EOS TABLES (these are on briaree)
LS220_TABLE='Tabulated(filename=/RQexec/foucartf/EoSFiles/LS220app_ColdTable.dat;)'
DD2_TABLE='Tabulated(filename=/RQexec/foucartf/EoSFiles/HempDD2_ColdTable-T0.1.dat;)'
POLY_TABLE='Gamma(Gamma=2.0; Kappa=123.6)'
SHEN_TABLE='Tabulated(filename=/RQexec/foucartf/EoSFiles/HShen_ColdTable.dat;)'
#END DEFINITIONS

if [ "$#" -ne 7 ]; then
    echo "bns_id_create.sh <separation> <m1> <m2> <eos=sfho,ls220,dd2,hshen,poly> <lastres> <paramres> <initial_data_directory_full_path>"
    echo "lastres = last resolution for solve, I use 10"
    echo "paramres = last resolution for solution of parameters, I use 4"
    echo "WARNING: SET THE DEFINITIONS AT THE BEGINNING OF THIS BASH SCRIPT BEFORE USING"
    echo
    exit
fi

sep=$1
m1=$2
m2=$3
eos=$4
lastres=$5
paramres=$6
export NSNS_DIR=$7

echo "Separation = $sep"
echo "M1 = $m1"
echo "M2 = $m2"
echo "EOS = $eos"
echo "Hours = $hours"
echo "Last Resolution = $lastres"
echo "Top Level Parameter Solve = $paramres"

cd $NSNS_DIR

PrepareID -t nsns
sed -i.bak -e '24,311d' DoMultipleRuns.input
cat DoMultipleRuns.input | sed -n '23,495p' >> DMR_temp.txt
sed -i.bak -e '23,495d' DoMultipleRuns.input

if [ $eos = "sfho" ]
then
    echo "Using sfho table"
    ${SPEC_HOME}/FluidInitialData/TOVSolverC/Executables/dmrgen_spec -e  $SFHO_TABLE -d $sep -q m_adm $m1 $m2 > TOV_output.txt
elif [ $eos = "ls220" ]
then
    echo "Using ls220 table"
    ${SPEC_HOME}/FluidInitialData/TOVSolverC/Executables/dmrgen_spec -e  $LS220_TABLE -d $sep -q m_adm $m1 $m2 > TOV_output.txt
elif [ $eos = "dd2" ]
then
    echo "Using dd2 table"
    ${SPEC_HOME}/FluidInitialData/TOVSolverC/Executables/dmrgen_spec -e $DD2_TABLE -d $sep -q m_adm $m1 $m2 > TOV_output.txt     
elif [ $eos = "poly" ]
then
    echo "Using gamma2 poly table"
    ${SPEC_HOME}/FluidInitialData/TOVSolverC/Executables/dmrgen_spec -e $POLY_TABLE -d $sep -q m_adm $m1 $m2 > TOV_output.txt
elif [ $eos = "hshen" ]
then
    echo "Using hshen table"
    ${SPEC_HOME}/FluidInitialData/TOVSolverC/Executables/dmrgen_spec -e  $SHEN_TABLE -d $sep -q m_adm $m1 $m2 > TOV_output.txt
else
    echo "Not a supported EOS"
    exit
fi

sed -i 's/=>/|/g' TOV_output.txt
sed -i '1d' TOV_output.txt 
sed -i '1d' TOV_output.txt 
sed -i '$ d' TOV_output.txt 
sed -i 's/,//g' TOV_output.txt
python $PATH_TO_EOS_DMR_GEN_SCRIPT
cat DoMultipleRuns.input TOV_output_fortab.txt DMR_temp.txt >> DoMultipleRunsNew.input
rm DoMultipleRuns.input *.txt
mv DoMultipleRunsNew.input DoMultipleRuns.input
sed -i.bak '/eos_dir/d' DoMultipleRuns.input
sed -i 's/$lastRes  = [[:digit:]]\+/$lastRes = '"$lastres"'/g' DoMultipleRuns.input
sed -i "s/'TopLevParamSolve'=> [[:digit:]]\+/'TopLevParamSolve'=> $paramres/g" DoMultipleRuns.input
./StartJob.sh
