# primer_pull.sh
This short BASH script allows Illumina MiSeq FASTQ files to be demultiplexed by their primer pairs before sample demultiplexing. This is useful when there are duplicate barcodes across primers, which will result in multiple samples being merged when sample demultiplexing _if_ the primers aren't separated first.

## Requirements
If you are on a Windows machine, you must be running a Linux virtual machine either with WSL2, or as a Virtual Disk/Emulator.
I recommend using [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10) if you are on Windows 10.

If you are already on Linux or MacOS, no further action is required, however _I have not tested this code on a Mac_.

### Downloading the files from BaseSpace
To download the necessary files, first, log in to your [BaseSpace account](https://basespace.illumina.com), then follow along with the screenshots below:

1. Click the _Paper icon_ > _Download_ > _Run_.
<img src="https://github.com/nweerasu/primer_pull/blob/main/downloadFASTQ/base1.PNG" width=50% height=50%>
2. Install the Downloader > Download as a FASTQ file.
<img src="https://github.com/nweerasu/primer_pull/blob/main/downloadFASTQ/base2.PNG" width=50% height=50%>

***

## Modifying the code
There are 3 required options to run this code:

- -f     forward original fastq **(required)**
- -r     reverse original fastq **(required)**
- -p     forward primer sequence [ITS2; LSUA; LSUBG, rbcLa, psbA3] **(required)**
- -h     show the help message

Each primer sequence is defined within the script, if you need to modfy the script to add in your specific **forward** primer sequence, please do so at the primer definition section ~line 54, under a new primer heading[<sup>1</sup>](#1). Any [wobble bases](https://www.bioinformatics.org/sms/iupac.html) must be defined and enclosed within square brackets [ ].

## To run the script
1. Unzip the BaseSpace files and place the forward and reverse .fastq files into your working directory. This can be done using commandline `gunzip` (WSL2, MacOS, Linux) or via gui (Windows Explorer) using [7zip](https://www.7-zip.org/) (Windows).
2. Download and place the `primer_pull.sh` script into your working directory.
3. Open a Terminal window and navigate to your working directory using commands such as `cd`, `ls`.
4. Set executable permissions for the script in Terminal using `chmod u+x ./primer_pull.sh`. This will allow your program to run.
5. Run the script using `./primer_pull.sh -f <forward reads.fastq> -r <reverse_reads.fastq> -p <primer name>`

## Output files
The output files will be created in order:
1. `<primer>_R1.fastq` - this will be your forward reads with the specified primer **(keep)**
2. `<primer>_samples.txt` - this will contain the unique sequence ID that will be used to search your reverse fastq file (can be discarded)
3. `<primer>_R2.fastq` - this will be your reverse reads with the specified primer **(keep)**

A console output will provide a sanity-check, to make sure the number of reads in each file matches. The difference should be 0. 

A final elapsed time output will be provided.

Repeat the above for each set of primers within your fastq files.

***

## Next steps
### Demultiplexing samples
1. After each of your primers have been demultiplexed, proceed with the `demultiplex_dada2.pl` from [Dr. Greg Gloor's GitHub repository](https://github.com/ggloor/miseq_bin).
   + You will need to create a `samples.txt` file for **each** primer set, examples can be found in the readme section. For ease of creation, I recommend using MS Excel to create a template with all your samples across all primers, and then convert to a text file.
   + Open the samples.txt file in a text editor and double check _(!!)_ that the format is **tab-delimited**, **plain text**, **Unicode UTF-8**, and **UNIX line feeds**.
2. To run the `demultiplex_dada2.pl` script from ggloor, you will have to:
   + Modify the shebang line **(if you are in Windows)** to: `#!/usr/bin/perl -w`; otherwise for Unix machines, leave the shebang as: `#!/usr/bin/env perl -w`
   + Modify the primer variables to include the **number of bases of your primer** (counting wobble bases only as 1 nt).
   + Specify your barcode length just below the primer definition section to the length of most of your barcodes (8). Individual primers with different barcode lengths can be specified as ggloor has done in their original script, e.g.
```
$bclen = 8 if $ARGV[3] eq "MCHII_SOSP"; # check that the primer names match, capitalizations included
$bclen = 8 if $ARGV[3] eq "SOSP";
```
   + Alternatively, copy and paste the following chunk of code into your unedited copy from ggloor **if** you are in the Thorn Lab or are using our primers. Check the primer references below to make sure the same primers are being used.

```
#!/usr/bin/perl -w
use strict; 

my @lprimerlen = (16, 22, 20, 18, 27, 23);  # length of forward primer
my @rprimerlen = (20, 26, 21, 17, 21, 24);  # length of reverse primer

my  $primer = 1;
if ( defined $ARGV[3]){  # list of all possible primers
	$primer = 0 if $ARGV[3] eq "PROKV4";
	$primer = 2 if $ARGV[3] eq "LSUA";
	$primer = 1 if $ARGV[3] eq "ITS2";
	$primer = 2 if $ARGV[3] eq "LSUBG";
	$primer = 4 if $ARGV[3] eq "rbcLa";
	$primer = 5 if $ARGV[3] eq "psbA3";
	$primer = 6 if $ARGV[3] eq "AMFV4";

my %samples;
my $bclen = 8; # Change this to the length of your barcodes (ALL barcodes must be this length)
```

Run the script using the instructions provided in ggloor's GitHub page for each primer. 

### Bioinformatic analysis
4. After demultiplexing within samples, you are free to filter, overlap, chimera-check, and classify your sequences[<sup>2</sup>](#2). Options include:
	+ the [dada2 tutorial](https://benjjneb.github.io/dada2/tutorial.html). Read and follow along with a smaller subset to make sure you fully understand the process before attempting the Big Data tutorial.
	+ the [dada2 Big Data tutorial](https://benjjneb.github.io/dada2/bigdata.html) if you have a lot of samples per primer, and if you find your R program crashing due to insufficient computer RAM or processing power. _Note:_ this will likely happen if you are on a personal computer.

***

[<sup>1</sup>](#1) It is recommended to download a reliable text editor for your platform: [notepad++](https://notepad-plus-plus.org/) for Windows; [Sublime Text](https://www.sublimetext.com/) for Mac or Linux.

[<sup>2</sup>](#2) ASVs are created through dada2, which are becoming increasingly popular over OTUs created by Mothur, QIIME and other demultiplexing pipelines.

***
# Appendix

## Primers

**AMFV4 (AMV4.5N-F/AMDG-R)**: rRNA 18S V4; Fungi; Glomeromycota (Sato _et al._, 2005)

**ITS2 (5.8S_Fun [F]/ITS4_Fun [R])**: rRNA ITS-2; Fungi (Taylor _et al._, 2016)

**LSUA (28S200A-F/28S476A-R)**: rRNA 28S D1-D2 region; Fungi; Ascomycota (Asemaninejad _et al._, 2016)

**LSUBG (28S200-F/28S481-R)**: rRNA 28S D1-D2 region; Fungi; non-Ascomycota (Asemaninejad _et al._, 2016)

**ProkV4 (U518F/806R)**: rRNA 18S V4 region; Bacteria/Archaea (Caporaso _et al._, 2011)

**rbcLa (rbcLa-F/rbcLa-R)**: ribulose-1,5-bisphosphate 156 carboxylase/oxygenase; Viridiplantae (Kress _et al._, 2009)

**psbA3 (psbA3-F/trnH-R)**: trnH-psbA spacer; Viridiplantae (Kress _et al._, 2009)


## References

Asemaninejad, Asma, et al. 2016. “New Primers for Discovering Fungal Diversity Using Nuclear Large Ribosomal DNA.” PLoS ONE 11 (7) [doi:10.1371/journal.pone.0159043](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0159043).

Caporaso, J Gregory, et al. 2011. “Global Patterns of 16S RRNA Diversity at a Depth of Millions of Sequences per Sample.” Proceedings of the National Academy of Sciences 108 (Supplement 1): 4516–4522. [doi:10.1073/pnas.1000080107](https://doi.org/10.1073/pnas.1000080107).

Kress, W.J., et al. 2009. “Plant DNA Barcodes and a Community Phylogeny of a Tropical Forest Dynamics Plot in Panama.” Proceedings of the National Academy of Sciences USA 106 (44): 18621–18626 [doi:10.1073/pnas.0909820106](https://doi.org/10.1073/pnas.0909820106).

Taylor, D Lee, et al. 2016. “Accurate Estimation of Fungal Diversity and Abundance through Improved Lineage-Specific Primers Optimized for Illumina Amplicon Sequencing.” Applied and Environmental Microbiology 82 (24): 7217–7226 [doi.org/10.1128/AEM.02576-16](https://doi.org/10.1128/AEM.02576-16).

Sato, Kouichi, et al. 2005. “A New Primer for Discrimination of Arbuscular Mycorrhizal Fungi with Polymerase Chain Reaction-Denature Gradient Gel Electrophoresis.” Grassland Science 51 (2): 179–181. [doi:10.1111/j.1744-697X.2005.00023.x](https://doi.org/10.1111/j.1744-697X.2005.00023.x)
