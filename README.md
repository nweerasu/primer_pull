# primer_pull.sh
This short BASH script allows Illumina MiSeq files to be demultiplexed by their primers first, before sample demultiplexing.

## Requirements
If you are on a Windows machine, you must be running a Linux virtual machine either with WSL2, or as a Virtual Disk/Emulator.
I recommend using WSL2, which can be activated using this website: [WSL2 on Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

If you are alread on Linux or MacOS, no further action is required.

## The code
There are 3 required options to run this code:
   -h      Show this message
   -f      forward original fastq
   -r      reverse original fastq
   -p      forward primer sequence [ITS2; LSUA; LSUBG, rbcLa, psbA3]

Each primer is defined within the script, if you need to modfy the script to add in your specific **forward** primer sequence, please do so. Any [wobble bases](https://www.bioinformatics.org/sms/iupac.html) must be defined. 

