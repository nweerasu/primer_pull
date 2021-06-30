# primer_pull.sh
This short BASH script allows Illumina MiSeq FASTQ files to be demultiplexed by their primer pairs before sample demultiplexing. This is useful when there are duplicate barcodes across primers, which will result in multiple samples being merged when sample demultiplexing.

## Requirements
If you are on a Windows machine, you must be running a Linux virtual machine either with WSL2, or as a Virtual Disk/Emulator.
I recommend using [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10) if you are on Windows 10.

If you are already on Linux or MacOS, no further action is required.

Unzip the BaseSpace files and place the forward and reverse .fastq files into your working directory. This can be done using commandline `gunzip` (WSL2, MacOS, Linux) or via gui (Windows Explorer) using [7zip](https://www.7-zip.org/) (Windows).

Place the `primer_pull.sh` script into your working directory.

## The code
There are 3 required options to run this code:

- -h     show the help message
- -f     forward original fastq **(required)**
- -r     reverse original fastq **(required)**
- -p     forward primer sequence [ITS2; LSUA; LSUBG, rbcLa, psbA3] **(required)**

Each primer sequence is defined within the script, if you need to modfy the script to add in your specific **forward** primer sequence, please do so at lines 54 - 79 under a new primer heading[<sup>1</sup>](#1). Any [wobble bases](https://www.bioinformatics.org/sms/iupac.html) must be defined and enclosed within square brackets [ ].

## To run the script
1. Set executable permissions for the script in Terminal using `chmod u+x ./primer_pull.sh`. This will allow your program to run.
2. Run the script using `./primer_pull.sh -f <forward reads.fastq> -r <reverse_reads.fastq> -p <primer name>`

## Output files
The output files will be created in order:
1. `<primer>_R1.fastq` - this will be your forward reads with the specified primer **(keep)**
2. `<primer>_samples.txt` - this will contain the unique samples ID that will be used to search your reverse fastq file (can be discarded)
3. `<primer>_R2.fastq` - this will be your reverse reads with the specified primer **(keep)**

A console output will provide a sanity-check, to make sure the number of reads in each file matches. The difference should be 0. 

A final elapsed time output will be provided.

Repeat the above for each set of primers within your fastq files.

## Next steps
### Demultiplexing samples
1. After each of your primers have been demultiplexed, proceed with the `demultiplex_dada2.pl` from [Dr. Greg Gloor's GitHub repository](https://github.com/ggloor/miseq_bin).
   + You will need to create a `samples.txt` file for **each** primer set, examples can be found in the readme section. For ease of creation, I recommend using MS Excel to create a template with all your samples across all primers, and then convert to a text file.
   + Open the samples.txt file in a text editor and double check _(!!)_ that the format is **tab-delimited**, **plain text**, **Unicode UTF-8**, and **UNIX line feeds**.
2. To run the `demultiplex_dada2.pl` script from ggloor, you will have to modify the header to include the **number of bases of your primer** (counting wobble bases only as 1 nt).
   + Alternatively, copy and paste the following chunk of code into your unedited copy from ggloor.
```
my @lprimerlen = (16, 22, 20, 18, 27, 23);  # length of forward primer
my @rprimerlen = (20, 26, 21, 17, 21, 24);  # length of reverse primer

my  $primer = 1;
if ( defined $ARGV[3]){  # list of all possible primers
	$primer = 0 if $ARGV[3] eq "PROKV4";
	$primer = 2 if $ARGV[3] eq "LSUA";
	$primer = 1 if $ARGV[3] eq "ITS2";
	$primer = 2 if $ARGV[3] eq "LSUBG";
	$primer = 4 if $ARGV[3] eq "rbcLa";
	$primer = 5 if $ARGV[3] eq "psbA3";`
```

   + Additionally, you'll have to specify your barcode length just below the primer definition section by editing:
```
my %samples;
my $bclen = 12; #Golay are 12-mers
$bclen = 8 if $ARGV[3] eq "MCHII_SOSP";
$bclen = 8 if $ARGV[3] eq "SOSP";
$bclen = 8 if $ARGV[3] eq "<your_primers_here"; # copy and edit the above lines for each primer
```
Run the script using the instructions provided in ggloor's GitHub page for each primer. 

### Bioinformatic analysis
4. After demultiplexing within samples, you are free to filter, overlap, chimera-check, and classify your sequences[<sup>2</sup>](#2).
   + Options include the [dada2 tutorial](https://benjjneb.github.io/dada2/tutorial.html). Read and follow along with a smaller subset to make sure you fully understand the process before attempting the Big Data tutorial.
   + Or the [dada2 Big Data](https://benjjneb.github.io/dada2/bigdata.html) if you have a lot of samples per primer.


***

[<sup>1</sup>](#1) It is recommended to download a reliable text editor for your platform: : [notepad++](https://notepad-plus-plus.org/) for Windows; [Sublime Text](https://www.sublimetext.com/) for Mac or Linux.

[<sup>2</sup>](#2) ASVs are created through dada2, which are becoming increasingly popular over OTUs created by Mothur, QIIME and other demultiplexing pipelines.

