#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script runs the primer split from Illumina FASTQ files before you run demultiplex_fastq_dada2.pl 
OPTIONS:
   -h      Show this message
   -c 	   clean; wipe intermediate files and re-run; to be implemented later
   -f      forward original fastq
   -r      reverse original fastq
   -p      forward primer sequence [ITS2; LSUA; LSUBG, rbcLa, psbA3, ProkV4, AMFV4]
EOF
}

FFILE=
RFILE=
PRI=
VERBOSE=
LP=
CLEAN=

while getopts “hcf:r:p:m:v” OPTION; do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
	 c) 
	     CLEAN=$OPTARG
	     ;;	
         f)
             FFILE=$OPTARG
             ;;
         r)
             RFILE=$OPTARG
             ;;
         p)
             PRI=$OPTARG
	     ;;
         ?)
             usage
             exit
             ;;
     esac
done

# state variables
echo "forward_reads=$FFILE...reverse_reads=$RFILE...primer=$PRI"
START_TIME=$SECONDS

case $PRI in # define the 
	LSUA)
		LP="AAC[GT]GCGAGTGAAGC[AG]G[CT]A"
		echo "Primer is LSUA: "$LP
	;;
	LSUBG)
		LP="AAC[GT]GCGAGTGAAG[AC]GGGA"
		echo "Primer is LSUBG: "$LP
	;;
	ITS2)
		LP="AACTTT[CT][AG][AG]CAA[CT]GGATC[AT]CT"
		echo "Primer is ITS2: "$LP
	;;
	rbcLa)
		LP="ATGTCACCACAAACAGAGACTAAAGC"
		echo "Primer is rbcLa: "$LP
	;;
	psbA3)
		LP="GTTATGCATGAACGTAATGCTC"
		echo "Primer is psbA3/trnH: "$LP
	;;
	ProkV4)
		LP="CCAGC[AC]GCCGCGGTAA"
		echo "Primer is ProkV4: "$LP
	;;
	AMFV4)
		LP="AAC[GT]GCGAGTGAAGC[AG]G[CT]A"
		echo "Primer is AMFV4: "$LP
	;;
	*)
	echo Primer not defined, try again
	exit 1
	;;
esac

#if [ $CLEAN = true ]; then
#	echo clean option is ON: $CLEAN
#	else
#	echo clean option is OFF: $CLEAN
#fi
#exit 1	
	

# read in original F1.fastq for fqgrep to create primer_F1.fastq
# . for any character x 12 for 4N+8BC
if [ ! -f $PRI"_R1.fastq" ]; then
	echo "Making fqgrep file from "$FFILE
	#fqgrep -p $LP -m $MIS $FFILE > $PRI'_R1.fastq' # run fqgrep 
	grep "^............$LP" -A 2 -B 1 --no-group-separator $FFILE > $PRI"_R1.fastq" # try grep since fqgrep with 0 mismatches isn't working
	else 
	echo "Fqgrep file exists ("$PRI"_R1.fastq). Moving on..."
fi	

#exit 1

# grep the @M00388 motif from the new file
if [ ! -f $PRI"_samples.txt" ]; then
	echo "Making the "$PRI"_samples.txt file"
	grep '^@M00388' $PRI"_R1.fastq" > $PRI"_samples.txt" #grep the sample names
	sed -i 's/1:N:0:1/2:N:0:1/g' $PRI"_samples.txt" # find fwd identifier, remove it but keep the [[space]]
	#grep '^@M00388' $PRI"_R1.fastq" |	sed 's/\s.*$//' > $PRI"_samples.txt"
	else
	echo "Samples.txt file exists. Moving on..."
fi

#exit 1

# grep the samples.txt from R2.fastq
if [ ! -f $PRI"_R2.fastq" ]; then
	echo "Making the new reverse reads: "$PRI"_R2.fastq"
	grep -f $PRI"_samples.txt" -A 3 --no-group-separator $RFILE > $PRI"_R2.fastq"
	else
	echo "R2.fastq exists. Moving on..."
fi

# check the line numbers to make sure they match up a little
echo "Sanity check: "
WC_L=$(grep -c '@M00388' $PRI"_R1.fastq")
echo "Your fwd sample count is "$WC_L
WC_R=$(grep -c '@M00388' $PRI"_R2.fastq")
echo "Your rev sample count is "$WC_R
DIFF=$(($WC_L-$WC_R))
echo "difference: "$DIFF

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

exit 1

