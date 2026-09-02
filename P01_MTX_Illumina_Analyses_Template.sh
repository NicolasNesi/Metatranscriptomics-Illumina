#!/usr/bin/env bash
#SBATCH --job-name=MTX_Illumina                   # Job name
#SBATCH --output=MTX_Illumina.%a.%A.out           # File to which stdout will be written
#SBATCH --error=MTX_Illumina.%a.%A.err            # File to which stderr will be written
#SBATCH --partition=long                          # Partition
#SBATCH --nodes=1                                 # Number of node - 1 GENOA node has 96-core and 750 Go RAM
#SBATCH --ntasks=1                                # Number of cores/cpus
#SBATCH --cpus-per-task=96                        # Number of cpu per task
#SBATCH --time=04-00:00                           # Runtime in DD-HH:MM
#SBATCH --mem=500G                                # Memory for all cores in Gbytes (or --mem 752000 in Mbytes)
#SBATCH --mail-type=ALL                           # BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail       # Email address

# ---------------------------------
# Version v2.8
# ---------------------------------
# author: Nicolas Nesi, Amelie Blanchetiere
# University Caen Normandy, INSERM UMR 1311 DYNAMICURE
# Date: 13/04/2026
# ---------------------------------

# ---------------------------------
# Variables and Paths
# ---------------------------------
set -euo pipefail

# Positional parameters
GROUP="${1}"
PROJECT="${2}"
RUN="${3}"
QSCORE="${4}"
HOST="${5}"
DBKMTX="${6}"
DBK16S="${7}"
CONFIDENCE="${8}"
THRESHOLDKRACKEN="${9}"
THRESHOLDBRACKEN="${10}"
READLENGTHBRACKEN="${11}"
BLASTDATABASE="${12}"
EVALUE="${13}"
CUTOFF="${14}"
MOTUS="${15}"
BLASTN="${16}"
SPADES="${17}"
METAPHLAN="${18}"
HUMANN="${19}"
SALMON="${20}"
PIPELINE="${21}"
ARRAY="${22}"
SEQUENCER="${23}"
KRAKEN="${24}"

# Paths
FOLDER="/dlocal/home/2019013/Data/${GROUP}/${PROJECT}"
PATH1="${FOLDER}/Output_Illumina/${RUN}"
 
# Databases
BOWTIEDB="/dlocal/home/2019013/Databases/bowtie_index"
PATHRNADB="/dlocal/home/2019013/Databases/SortMeRNA"
DATABASESALMON="/dlocal/home/2019013/Databases/Salmon_HumanTranscriptome_db/salmon_index_homemade"
PATHDBKMTX="/dlocal/home/2019013/Databases/Kraken2_$DBKMTX"
PATHDBK16S="/dlocal/home/2019013/Databases/Kraken2_$DBK16S"
export BLASTDB="/dlocal/home/2019013/Databases/BLAST_NCBI"
TAX="/dlocal/home/2019013/Databases/Krona_Taxonomy"
DBHNuc="/dlocal/home/2019013/Databases/Humann3/chocophlan"
DBHPro90="/dlocal/home/2019013/Databases/Humann3/uniref90"

# Array job
SAMPLE="$(sed -n -e "${SLURM_ARRAY_TASK_ID}p" "${FOLDER}/Scripts/List_samples_${RUN}.txt")"
RUNDATE="$(date '+%Y-%m-%d')"

echo "Job started with SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"

# Threads
export THREADS="${SLURM_CPUS_PER_TASK}"
echo "number of threads used ${THREADS}"
# ---------------------------------

# ---------------------------------
# Copy input data to LOCAL_WORK_DIR
# ---------------------------------
if [[ "$SEQUENCER" == "yes" ]]; then
 cp "${PATH1}"/Alignment_1/*/Fastq/"${SAMPLE}"_R*.fastq.gz "${LOCAL_WORK_DIR}"
elif [[ "$SEQUENCER" == "no" ]]; then
 cp "${PATH1}"/"${SAMPLE}"_R*.fastq.gz "${LOCAL_WORK_DIR}"
fi

cd "${LOCAL_WORK_DIR}"/
gunzip "${SAMPLE}"_R*.fastq.gz

# Genereate setting file of the analysis:
cat <<EOF > "${FOLDER}/Scripts/Settings_for_${PROJECT}_${RUN}_sample-${SAMPLE}_submitted_${RUNDATE}.log"
Description of the analysis submitted the $RUNDATE:
Part of the pipeline submitted: $PIPELINE
Group folder: $GROUP
Project folder: $PROJECT
Input folder: $RUN
Size array job: $ARRAY
Sequencer MiSeq: $SEQUENCER
Minimum Qscore Illumina reads: $QSCORE
Host genome for cleaning and mapping: $HOST
Kraken2 database used for metatranscriptomic taxonomic profiling: $DBKMTX
Kraken2 database used for rRNA taxonomic profiling: $DBK16S
Kraken2 analyses run with a confidence score of: $CONFIDENCE
Kraken2 analyses run with a number of minimum hit groups of: $THRESHOLDBRACKEN
Bracken analyses run with a number of reads required PRIOR to abundance estimation of: $THRESHOLDBRACKEN
Bracken reads length used : $READLENGTHBRACKEN
Is taxonomic profile run with Blastn? $BLASTN - if yes with the database: $BLASTDATABASE and an evalue threshold of: $EVALUE
Is taxonomic profile run with MetaPhlAn? $METAPHLAN
Is taxonomic profile run with mOTUs? $MOTUS - if yes with a minimum number of $CUTOFF marker genes
Is functional profiling of microbial pathways performed with Humann3? $HUMANN
Is host transcriptome reads count performed with Salmon? $SALMON
Is denovo assembly of viral genomes  performed with SPAdes? $SPADES
Job started with SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID
Number of threads used $THREADS
Working directory $PWD
Submission command: P01_MTX_Illumina_Analyses_Template.sh -g $GROUP -p $PROJECT -r $RUN -ar $ARRAY -qs $QSCORE -ho $HOST -dbk $DBKMTX -dbS $DBK16S -c $CONFIDENCE -tk $THRESHOLDKRACKEN -tb $THRESHOLDBRACKEN -kb $READLENGTHBRACKEN -b $BLASTN -dbb $BLASTDATABASE -e $EVALUE -me $METAPHLAN -mo $MOTUS -cu $CUTOFF -hu $HUMANN -sa $SALMON -sp $SPADES -pi $PIPELINE
EOF

echo Working directory: "${PWD}"
# ---------------------------------

# ---------------------------------
# Environments
# ---------------------------------
module load py_env/miniconda3/25.7.0
set +u
eval "$(conda shell.bash hook)"
conda activate MTX_env
set -u
# include:
# BLAST=2.15.0
# Bowtie2=2.5.4
# Bracken=2.8.0
# csvtk=0.30.0
# Diamond=2.1.4
# Fastp=0.24.1
# Fastqc=0.12.1
# HUMAnN=3.9
# Kraken2=2.1.3
# KrakenTools=1.2
# Krona=2.8.1
# MetaPhlAn=4.1.1
# mOTUs=3.1.0
# NGmerge=0.5
# Salmon=1.10.3
# Samtools=1.16.1
# Seqkit=2.8.0
# Sortmerna=4.3.7
# SPAdes=3.15.5
# ---------------------------------

# ---------------------------------
# For whatever reason have to redefine HOST variable because otherwise it is lost!

echo "Arguments received: $@"

export HOST="${5}"

: "${HOST:?HOST is not set. Check argument 5.}"

echo "HOST variable=${HOST}"
# ---------------------------------

# ---------------------------------
# Size, quality trimming
# ---------------------------------
echo "Quality, size trimming of Illumina paired reads of sample: ${SAMPLE}"

fastp \
--in1 "${SAMPLE}_R1.fastq" \
--in2 "${SAMPLE}_R2.fastq" \
--detect_adapter_for_pe \
--length_required 15 \
--qualified_quality_phred "${QSCORE}" \
--low_complexity_filter \
--dedup \
--thread 24 \
--json "${SAMPLE}"_ReportFastp.json \
--html "${SAMPLE}"_ReportFastp.html \
--report_title "${SAMPLE} Illumina Fastp report" \
--out1 "${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R1.fastq" \
--out2 "${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R2.fastq" \
--unpaired1 "${SAMPLE}_CleanedReads_With-${HOST}_unpaired.fastq" \
--unpaired2 "${SAMPLE}_CleanedReads_With-${HOST}_unpaired.fastq" 2>&1 | tee -a "${SAMPLE}_fastp_run${RUNDATE}.log"
# ---------------------------------

# ---------------------------------
# Cleaning Reads with Bowtie2 mapping
# ---------------------------------
echo "Mapping $HOST reads for sample: ${SAMPLE}"

bowtie2 \
-1 "${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R1.fastq" \
-2 "${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R2.fastq" \
-U "${SAMPLE}_CleanedReads_With-${HOST}_unpaired.fastq" \
-x "${BOWTIEDB}"/Mammals/"${HOST}" \
--threads "${THREADS}" \
--very-sensitive \
--dovetail \
--al-conc "${SAMPLE}_CleanedReads_${HOST}_PairedReads.fastq" \
--al "${SAMPLE}_CleanedReads_${HOST}_SingleReads.fastq" \
--un-conc "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads.fastq" \
--un "${SAMPLE}_CleanedReads_Without-${HOST}_SingleReads.fastq" \
-S "${SAMPLE}_mapping_${HOST}.sam" 2>&1 | tee -a "${SAMPLE}_Bowtie2_Mapping-${HOST}_run${RUNDATE}.log"

mv "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads.1.fastq" "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R1.fastq"
mv "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads.2.fastq" "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R2.fastq"
mv "${SAMPLE}_CleanedReads_${HOST}_PairedReads.1.fastq" "${SAMPLE}_CleanedReads_${HOST}_PairedReads_R1.fastq"
mv "${SAMPLE}_CleanedReads_${HOST}_PairedReads.2.fastq" "${SAMPLE}_CleanedReads_${HOST}_PairedReads_R2.fastq"
# ---------------------------------

# ---------------------------------
# Mapping Statistics
# ---------------------------------
echo "Statistics of mapping to $HOST for sample: ${SAMPLE}"

samtools view --threads "${THREADS}" -b -F 4 "${SAMPLE}_mapping_${HOST}.sam" -o "${SAMPLE}_mapping_${HOST}_aligned.bam"
samtools sort --threads "${THREADS}" "${SAMPLE}_mapping_${HOST}_aligned.bam" -o "${SAMPLE}_mapping_${HOST}_aligned_sorted.bam"
samtools index "${SAMPLE}_mapping_${HOST}_aligned_sorted.bam"
samtools flagstat --output-fmt tsv "${SAMPLE}_mapping_${HOST}_aligned_sorted.bam" > "${SAMPLE}_MappedReads_to_${HOST}.tsv"
rm "${SAMPLE}_mapping_${HOST}.sam"
# ---------------------------------

# ---------------------------------
# Merging of Paired-End Reads
# ---------------------------------
echo "Merging of paired-end cleaned reads of sample: ${SAMPLE}"

# Cleaned reads with host
/soft/2019013/Logiciels/NGmerge-master/NGmerge \
-1 "${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R1.fastq" \
-2 "${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R2.fastq" \
-n "${THREADS}" \
-f "${SAMPLE}_CleanedReads_With-${HOST}_NotMerged" \
-o "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq"

# Cleaned reads without host
/soft/2019013/Logiciels/NGmerge-master/NGmerge \
-1 "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R1.fastq" \
-2 "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R2.fastq" \
-n "${THREADS}" \
-f "${SAMPLE}_CleanedReads_Without-${HOST}_NotMerged" \
-o "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq"
# ---------------------------------

# ---------------------------------
# Extraction of microbial rRNA reads
# ---------------------------------
echo "Binning of microbial ribosomal Reads for sample: ${SAMPLE}"

sortmerna \
--reads "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq" \
--ref "${PATHRNADB}"/smr_v4.3_sensitive_db.fasta \
--threads "${THREADS}" \
--fastx \
--sam \
--SQ \
--blast 1 \
--num_alignments 1 \
-e 0.00001 \
--workdir sortmerna/ \
--other sortmerna/"${SAMPLE}"_without-MicrobialrRNA \
--aligned sortmerna/"${SAMPLE}"_MicrobialrRNA 2>&1 | tee -a "${SAMPLE}_sortmerna_run${RUNDATE}.log"

mv sortmerna/"${SAMPLE}"_MicrobialrRNA.fq "${SAMPLE}_CleanedReads_microbialrRNA_MergedPE.fastq"
mv sortmerna/"${SAMPLE}"_without-MicrobialrRNA.fq "${SAMPLE}_CleanedReads_Without-${HOST}_Without-microbialrRNA_MergedPE.fastq"
# ---------------------------------

# ---------------------------------
# Human mRNA quantification
# ---------------------------------
if [[ "$SALMON" == "yes" ]]; then
    echo "Quantification of human mRNA using Salmon for sample: ${SAMPLE}"
    
    salmon quant \
    --index "${DATABASESALMON}" \
    --libType A \
    --mates1 "${SAMPLE}_CleanedReads_${HOST}_PairedReads_R1.fastq" \
    --mates2 "${SAMPLE}_CleanedReads_${HOST}_PairedReads_R2.fastq" \
    --threads "${THREADS}" \
    --seqBias \
    --gcBias \
    --recoverOrphans \
    --numBootstraps 1000 \
    --output ./"${SAMPLE}"_Salmon_Quant_RNA 2&>1 | tee -a "${SAMPLE}_salmon-quant_run${RUNDATE}.log"
    
    # rename output file with TPM per transcripts
    mv ./"${SAMPLE}"_Salmon_Quant_RNA/quant.sf ./"${SAMPLE}"_Salmon_Quant_RNA/"${SAMPLE}"_quant_ENST.tsv

elif [[ "$SALMON" == "no" ]]; then
  echo "Not running Salmon"
else
  echo "invalid value for SALMON variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# Quality Control of Reads
# ---------------------------------
echo "Quality Control of reads for sample: ${SAMPLE}"

mkdir Fastqc_Raw/
mkdir Fastqc_Cleaned_With-"${HOST}"/
mkdir Fastqc_Cleaned_Without-"${HOST}"/

# Raw data
fastqc \
"${SAMPLE}_R1.fastq" \
"${SAMPLE}_R2.fastq" \
--outdir Fastqc_Raw/ \
--extract \
--svg \
--threads "${THREADS}" 2>&1 | tee -a "${SAMPLE}_fastqc_Raw_run${RUNDATE}.log"

rename "_fastqc" "_Fastqc_Raw" Fastqc_Raw/*

# Cleaned data
fastqc \
"${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R1.fastq" \
"${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R2.fastq" \
--outdir Fastqc_Cleaned_With-"${HOST}"/ \
--extract \
--svg \
--threads "${THREADS}" 2>&1 | tee -a "${SAMPLE}_fastqc_Cleaned_With-${HOST}_run${RUNDATE}.log"

rename "_fastqc" "_Fastqc_Cleaned" Fastqc_Cleaned_With-"${HOST}"/*

fastqc \
"${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R1.fastq" \
"${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R2.fastq" \
--outdir Fastqc_Cleaned_Without-"${HOST}"/ \
--extract \
--svg \
--threads "${THREADS}" 2>&1 | tee -a "${SAMPLE}_fastqc_Cleaned_Without-${HOST}_run${RUNDATE}.log"

rename "_fastqc" "_Fastqc_Cleaned" Fastqc_Cleaned_Without-"${HOST}"/*
# ---------------------------------

# ---------------------------------
# Statistics number of Reads
# ---------------------------------
echo "Statistic fastq files of sample: ${SAMPLE}"

seqkit stats --all -T "${SAMPLE}"*.fastq > "${SAMPLE}_Statistics_Fastq.tsv"
# ---------------------------------

# ---------------------------------
# Classify Reads using Kraken2/Bracken
# ---------------------------------
if [[ "$KRAKEN" == "yes" ]]; then
  echo "Taxonomic profiling with Kraken2/Bracken of sample: ${SAMPLE}"
  
  # Cleaned Reads With HOST
  kraken2 \
  --db "${PATHDBKMTX}" \
  --memory-mapping \
  --confidence "${CONFIDENCE}" \
  --threads "${THREADS}" \
  --minimum-hit-groups "${THRESHOLDKRACKEN}" \
  --output "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  --unclassified-out "${SAMPLE}_With-${HOST}_Kraken2_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_NoHit.fastq" \
  "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" 2>&1 | tee -a "${SAMPLE}_Kraken2_CleanedReads_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_run${RUNDATE}.log"
  
  # Kraken2 Krona
  kreport2krona.py \
  -r "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt"
  
  ktImportText "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.html"
  
  # Cleaned Reads With HOST Species level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken.tsv" \
  -w "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l S \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_With-${HOST}_level-Species_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.html"
  
  # Cleaned Reads With HOST Genus level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken.tsv" \
  -w "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l G \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_With-${HOST}_level-Genus_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt" \
  -o "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.html"
  
  # Cleaned Reads Without HOST
  kraken2 \
  --db "${PATHDBKMTX}" \
  --memory-mapping \
  --confidence "${CONFIDENCE}" \
  --threads "${THREADS}" \
  --minimum-hit-groups "${THRESHOLDKRACKEN}" \
  --output "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  --unclassified-out "${SAMPLE}_Without-${HOST}_Kraken2_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_NoHit.fastq" \
  "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq" 2>&1 | tee -a "${SAMPLE}_Kraken2_CleanedReads_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_run${RUNDATE}.log"
  
  # Kraken2 Krona
  kreport2krona.py \
  -r "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt"
  
  ktImportText "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.html"
  
  # Cleaned Reads Without HOST Species level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken.tsv" \
  -w "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l S \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_Without-${HOST}_level-Species_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.html"
  
  # Cleaned Reads Without HOST Genus level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken.tsv" \
  -w "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l G \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_Without-${HOST}_level-Genus_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt" \
  -o "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.html"
  
  # Cleand Reads Without HOST and Without Microbial rRNA
  kraken2 \
  --db "${PATHDBKMTX}" \
  --memory-mapping \
  --confidence "${CONFIDENCE}" \
  --threads "${THREADS}" \
  --minimum-hit-groups "${THRESHOLDKRACKEN}" \
  --output "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  --unclassified-out "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_Kraken2_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_NoHit.fastq" \
  "${SAMPLE}_CleanedReads_Without-${HOST}_Without-microbialrRNA_MergedPE.fastq" 2>&1 | tee -a "${SAMPLE}_Kraken2_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_run${RUNDATE}.log"
  
  # Kraken2 Krona
  kreport2krona.py \
  -r "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt"
  
  ktImportText "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.html"
  
  # Cleaned Reads Without HOST and Without Microbial rRNA Species level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken.tsv" \
  -w "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l S \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_Without-${HOST}_Without-microbialrRNA_level-Species_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.html"
  
  # Cleaned Reads Without HOST and Without Microbial rRNA Genus level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken.tsv" \
  -w "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l G \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_Without-${HOST}_Without-microbialrRNA_level-Genus_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt" \
  -o "${SAMPLE}_Without-${HOST}_Without-microbialrRNA_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.html"
  
  # Microbial 16S rRNA
  kraken2 \
  --db "${PATHDBK16S}" \
  --memory-mapping \
  --confidence "${CONFIDENCE}" \
  --threads "${THREADS}" \
  --minimum-hit-groups "${THRESHOLDKRACKEN}" \
  --output "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}.k2report" \
  --unclassified-out "${SAMPLE}_microbialrRNA_Kraken2_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_NoHit.fastq" \
  "${SAMPLE}_CleanedReads_microbialrRNA_MergedPE.fastq" 2>&1 | tee -a "${SAMPLE}_Kraken2_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_run${RUNDATE}.log"
  
  # Kraken2 Krona
  kreport2krona.py \
  -r "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt"
  
  ktImportText "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.txt" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.html"
  
  # Microbial 16S rRNA Species level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species_Bracken.tsv" \
  -w "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l S \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_microbialrRNA_level-Species_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species.breport" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.txt" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.html"
  
  # Microbial 16S rRNA Genus level
  bracken \
  -d "${PATHDBKMTX}" \
  -i "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}.k2report" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus_Bracken.tsv" \
  -w "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -r "${READLENGTHBRACKEN}" \
  -l G \
  -t "${THRESHOLDBRACKEN}" 2>&1 | tee -a "${SAMPLE}_Bracken_CleanedReads_microbialrRNA_level-Genus_run${RUNDATE}.log"
  
  # Bracken Krona
  kreport2krona.py \
  -r "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus.breport" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt"
  
  ktImportText "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.txt" \
  -o "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.html"
  
  # Number of NoHit reads
  seqkit stats -T *_NoHit.fastq | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbNoHitReads.txt"
  # ---------------------------------
  
  # ---------------------------------
  # Extract Reads
  # ---------------------------------
  echo "Extract Microbiome reads for sample: ${SAMPLE}"
  
  # Reads which are not Metazoa(33208)/Plants(33090)/Unclassified(0)
  extract_kraken_reads.py \
  -k "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -s "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
  --taxid 33208 33090 0 \
  --exclude \
  --include-children \
  --fastq-output \
  --output "${SAMPLE}_OnlyMicrobiome.fastq"
  
  seqkit stats -T "${SAMPLE}_OnlyMicrobiome.fastq" | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbOnlyMicrobiomeReads.txt"
  
  echo "Extract Viruses, Bacteria, Fungi, Eukaryote and Human reads for sample: ${SAMPLE}"
  
  # Bacteria (TaxID 2)
  extract_kraken_reads.py \
  -k "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -s "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
  --taxid 2 \
  --include-children \
  --fastq-output \
  --output "${SAMPLE}_OnlyBacteria.fastq"
  
  seqkit stats -T "${SAMPLE}_OnlyBacteria.fastq" | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbOnlyBacteriaReads.txt"
  
  # Viruses (TaxID 10239)
  extract_kraken_reads.py \
  -k "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -s "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
  --taxid 10239 \
  --include-children \
  --fastq-output \
  --output "${SAMPLE}_OnlyViruses.fastq"
  
  seqkit stats -T "${SAMPLE}_OnlyViruses.fastq" | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbOnlyVirusesReads.txt"
  
  # Archaea (TaxID 2157)
  extract_kraken_reads.py \
  -k "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -s "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
  --taxid 2157 \
  --include-children \
  --fastq-output \
  --output "${SAMPLE}_OnlyArchaea.fastq"
  
  seqkit stats -T "${SAMPLE}_OnlyArchaea.fastq" | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbOnlyArchaeaReads.txt"
  
  # Fungi (TaxID 4751)
  extract_kraken_reads.py \
  -k "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -s "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
  --taxid 4751 \
  --include-children \
  --fastq-output \
  --output "${SAMPLE}_OnlyFungi.fastq"
  
  seqkit stats -T "${SAMPLE}_OnlyFungi.fastq" | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbOnlyFungiReads.txt"
  
  # Eukaryota (TaxID 2759)
  extract_kraken_reads.py \
  -k "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -s "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
  --taxid 2759 \
  --include-children \
  --fastq-output \
  --output "${SAMPLE}_OnlyEukaryota.fastq"
  
  seqkit stats -T "${SAMPLE}_OnlyEukaryota.fastq" | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbOnlyEukaryotaReads.txt"
  
  # Homo sapiens (TaxID 9606)
  extract_kraken_reads.py \
  -k "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" \
  --report "${SAMPLE}_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" \
  -s "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
  --taxid 9606 \
  --fastq-output \
  --output "${SAMPLE}_Homosapiens.fastq"
  
  seqkit stats -T "${SAMPLE}_Homosapiens.fastq" | csvtk cut -t -f "num_seqs" | csvtk del-header > "${SAMPLE}_nbOnlyHsapiensReads.txt"
elif [[ "$KRAKEN" == "no" ]]; then
  echo "Not running Kraken2/Bracken"
else
  echo "invalid value for Kraken2 variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# Classify Reads using mOTUs3
# ---------------------------------
if [[ "$MOTUS" == "yes" ]]; then
  echo "Classifying reads using mapping approach with mOTUs for sample: ${SAMPLE}"

  motus profile \
  -f "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R1.fastq" \
  -r "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R2.fastq" \
  -n "${SAMPLE}" \
  -I "${SAMPLE}_mOTUs.bam" \
  -y insert.scaled_counts \
  -M "${SAMPLE}_mgc_reads.count" \
  -A \
  -l 75 \
  -g "${CUTOFF}" \
  -k mOTU \
  -c \
  -v 3 \
  -t "${THREADS}" \
  -o "${SAMPLE}_l75_c${CUTOFF}_motus_taxonomy.tsv" 2>&1 | tee -a "${SAMPLE}_mOTUs_run${RUNDATE}.log"

elif [[ "$MOTUS" == "no" ]]; then
  echo "Not running mOTUs3"
else
  echo "invalid value for MOTUS variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# Classify Reads using MetaPhlAn 4.1.1
# ---------------------------------
if [[ "$METAPHLAN" == "yes" ]]; then
  echo "Classifying reads using mapping approach with MetaPhlAn4.1.1 for sample: ${SAMPLE}"

metaphlan \
"${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq" \
--input_type fastq \
--bowtie2db "/dlocal/home/2019013/Databases/MetaPhlAn_mpa_vJun23" \
--min_mapq_val 5 \
--unclassified_estimation \
--tax_lev 'a' \
--stat 'tavg_g' \
-t 'rel_ab_w_read_stats' \
--profile_vsc \
--offline \
--nproc "${THREADS}" \
--sample_id "${SAMPLE}" \
--bowtie2out "${SAMPLE}_MetaPhlAn_Bowtie2.bz2" \
--biom_output_file "${SAMPLE}_MetaphlAn.biom" \
--vsc_out "${SAMPLE}_MetaphlAn_virome_vsc.txt" \
--output_file "${SAMPLE}_MetaphlAn_profile.txt" 2>&1 | tee -a "${SAMPLE}_MetaPhlAn_run${RUNDATE}.log"

elif [[ "$METAPHLAN" == "no" ]]; then
  echo "Not running MetaPhlAn"
else
  echo "invalid value for METAPHLAN variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# Classify Reads using BLASTN
# ---------------------------------
if [[ "$BLASTN" == "yes" ]]; then
   echo "Running Blastn against $BLASTDATABASE with evalue $EVALUE for sample: ${SAMPLE}"

# fastq to fasta
   seqkit fq2fa "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq" -o "${SAMPLE}.fasta"

   blastn \
   -query "${SAMPLE}.fasta" \
   -db "${BLASTDATABASE}" \
   -num_threads "${THREADS}" \
   -evalue "${EVALUE}" \
   -num_alignments 5 \
   -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids sscinames sskingdoms' \
   -out "${SAMPLE}_vs_${BLASTDATABASE}_blastn.tsv" 2>&1 | tee -a "${SAMPLE}_vs_${BLASTDATABASE}_blastn_run${RUNDATE}.log"

# Get top bitscore per query
   cat "${SAMPLE}_vs_${BLASTDATABASE}_blastn.tsv" | sort -u -k1,1 --merge > "${SAMPLE}_vs_${BLASTDATABASE}_blastn_filter_topBitscore.tsv" 
   awk 'BEGIN{FS=OFS="\t"; print "qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tstaxids\tsscinames\tsskingdoms"} {print}' \
   "${SAMPLE}_vs_${BLASTDATABASE}_blastn_filter_topBitscore.tsv" > tmp_file && mv tmp_file "${SAMPLE}_vs_${BLASTDATABASE}_blastn_filter_topBitscore.tsv"

# Create a Krona output
   ktImportBLAST "${SAMPLE}_vs_${BLASTDATABASE}_blastn_filter_topBitscore.tsv" -tax "${TAX}" -o "${SAMPLE}_vs_${BLASTDATABASE}_blastn_best-hit_Krona.html"

# Create List of Hit per Taxa
   sed '1d' "${SAMPLE}_vs_${BLASTDATABASE}_blastn_filter_topBitscore.tsv" | cut -f 13,14,15 -d $'\t' | sort | uniq -c | sort -nrk1 > "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv"
   sed -i 's/^[ ]*//' "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv"
   sed -i 's/ /\t/' "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv"
   awk 'BEGINFILE {split(FILENAME,f,"_")} {$0=f[1]"\t"$0}1' "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv" > tmp_file && mv tmp_file "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv"
   awk 'BEGIN{FS=OFS="\t"; print "SampleID\tNbHit\tNCBITaxID\tScientificNames\tKingdoms"} {print}' "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv" > tmp_file && mv tmp_file "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv"

elif [[ "$BLASTN" == "no" ]]; then
   echo "Not running Blastn"
else
   echo "invalid value for BLAST variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# Convert Bracken output to metaphlan tsv for Humann
# ---------------------------------
if [[ "$KRAKEN" == "yes" ]]; then
 echo "Convert Bracken outputs to mpa format for Humann"
 
 kreport2mpa.py \
 -r "${SAMPLE}_Without-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" \
 -o "${SAMPLE}_temp.mpa.tsv"
 
 grep "k__Bacteria" "${SAMPLE}_temp.mpa.tsv" > "${SAMPLE}_temp.mpa_filteredBacteria.tsv"
 awk '{printf("%s\t\n", $0)}' "${SAMPLE}_temp.mpa_filteredBacteria.tsv" > "${SAMPLE}_temp.mpa_filteredBacteria2.tsv"
 sed '1i #clade_name	relative_abundance' "${SAMPLE}_temp.mpa_filteredBacteria2.tsv" > "${SAMPLE}_temp.mpa_filteredBacteria3.tsv"
 sed '1i #mpa_vJun23_CHOCOPhlAnSGB_202403' "${SAMPLE}_temp.mpa_filteredBacteria3.tsv" > "${SAMPLE}_Bracken_Bacteria_Species_mpa.tsv"
 rm "${SAMPLE}_temp.mpa.tsv" "${SAMPLE}_temp.mpa_filteredBacteria.tsv" "${SAMPLE}_temp.mpa_filteredBacteria2.tsv" "${SAMPLE}_temp.mpa_filteredBacteria3.tsv"

elif [[ "$$KRAKEN" == "no" ]]; then
   echo "Not running Kraken2/Bracken"
else
   echo "invalid value for KRAKEN variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# Funtional profile of microbiome
# ---------------------------------
if [[ "$HUMANN" == "yes" ]]; then
   echo "Functional analyses of microbial expression for sample: ${SAMPLE}" 
   
   humann \
   --input "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq" \
   --nucleotide-database "${DBHNuc}" \
   --protein-database "${DBHPro90}" \
   --metaphlan-options "-t rel_ab --index mpa_vJun23_CHOCOPhlAnSGB_202403 --bowtie2db /dlocal/home/2019013/Databases/MetaPhlAn_mpa_vJun23" \
   --verbose \
   --threads "${THREADS}" \
   --output Humann3_MetaPhlAn_"${SAMPLE}"/ \
   --output-basename "${SAMPLE}" \
   --o-log "${SAMPLE}_humann3_MetaPhlan_run${RUNDATE}.log"
   
   humann \
   --input "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq" \
   --nucleotide-database "${DBHNuc}" \
   --protein-database "${DBHPro90}" \
   --taxonomic-profile "${SAMPLE}_Bracken_Bacteria_Species_mpa.tsv" \
   --verbose \
   --threads "${THREADS}" \
   --output Humann3_Bracken_"${SAMPLE}"/ \
   --output-basename "${SAMPLE}" \
   --o-log "${SAMPLE}_humann3_BrackenSpecies_run${RUNDATE}.log"

elif [[ "$HUMANN" == "no" ]]; then
  echo "Not running functional analyses of microbial expression with HUMANN"
else
  echo "invalid value for HUMANN variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# DeNovo assembly of virus from metagenomic data
# ---------------------------------
if [[ "$SPADES" == "yes" ]]; then
  echo "Running SPAdes DeNovo Assembly of virus metadata on ${SAMPLE}"

  spades.py \
  --metaviral \
  -1 "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R1.fastq" \
  -2 "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R2.fastq" \
  -s "${SAMPLE}_CleanedReads_Without-${HOST}_SingleReads.fastq" \
  --merged "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq" \
  -o "${SAMPLE}"_metaviralspades/ \
  --threads "${THREADS}"

elif [[ "$SPADES" == "no" ]]; then
  echo "Not running De Novo Assembly with Metaviral SPAdes"
else
  echo "invalid value for SPADES variable. Please set it to 'yes' or 'no'"
fi
# ---------------------------------

# ---------------------------------
# Create directories and Move outputs
# ---------------------------------
echo "Starting creating directories and moving outputs data for sample: ${SAMPLE}"

# Function to create a directory if it doesn't exist
create_directory() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
    else
        echo "Directory already exists: $dir"
    fi
}

# Function to move files with error checking
move_file() {
    local pattern=$1
    local dest=$2
    for src in $pattern; do
        if [[ -f "$src" ]]; then
            local filename=$(basename "$src")
            mv "$src" "$dest/$filename"
            echo "Moved $src to $dest/$filename"
        else
            echo "Warning: File $src not found"
        fi
    done
}

# Sbatch_log
create_directory "${FOLDER}/Scripts/Sbatch_log"

# Log
echo "Starting moving log files"
create_directory "${FOLDER}/Log/${RUN}_run${RUNDATE}"
mv *.log "${FOLDER}/Log/${RUN}_run${RUNDATE}"
mv sortmerna/*.log "${FOLDER}/Log/${RUN}_run${RUNDATE}"

# Reads
echo "Starting moving reads.gz files"
create_directory "${FOLDER}/RawReads_Illumina/${RUN}"
pigz "${SAMPLE}"_R*.fastq
mv "${SAMPLE}"_R*.fastq.gz "${FOLDER}/RawReads_Illumina/${RUN}"

create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_WithHost_Reads"
pigz "${SAMPLE}_CleanedReads_With-${HOST}"_*.fastq
mv "${SAMPLE}_CleanedReads_With-${HOST}_PairedReads"_R*.fastq.gz "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_WithHost_Reads"
mv "${SAMPLE}_CleanedReads_With-${HOST}_unpaired.fastq.gz" "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_WithHost_Reads"

create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_WithHost_Reads/Merged"
move_file "${SAMPLE}_CleanedReads_With-${HOST}_MergedPE.fastq.gz" "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_WithHost_Reads/Merged"

create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_NoHost_Reads"
pigz "${SAMPLE}_CleanedReads_Without-${HOST}"_*.fastq
mv "${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads"_R*.fastq.gz "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_NoHost_Reads"
move_file "${SAMPLE}_CleanedReads_Without-${HOST}_SingleReads.fastq.gz" "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_NoHost_Reads"

create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_NoHost_Reads/Merged"
move_file "${SAMPLE}_CleanedReads_Without-${HOST}_MergedPE.fastq.gz" "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_NoHost_Reads/Merged"

create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_OnlyHost_Reads"
pigz "${SAMPLE}_CleanedReads_${HOST}"_*.fastq
mv "${SAMPLE}_CleanedReads_${HOST}"_*.fastq.gz "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_OnlyHost_Reads"

create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_microbialrRNA_Reads"
pigz "${SAMPLE}_CleanedReads_microbialrRNA_MergedPE.fastq"
move_file "${SAMPLE}_CleanedReads_microbialrRNA_MergedPE.fastq.gz" "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_microbialrRNA_Reads"

create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_NoHost_NomicrobialrRNA_Reads"
move_file "${SAMPLE}_CleanedReads_Without-${HOST}_Without-microbialrRNA_MergedPE.fastq.gz" "${FOLDER}/CleanedReads_Illumina/${RUN}/Cleaned_NoHost_NomicrobialrRNA_Reads"

# Mapping BAM
echo "Starting moving bowtie BAM files"
create_directory "${FOLDER}/CleanedReads_Illumina/${RUN}/BAM"
mv "${SAMPLE}_mapping_${HOST}_aligned"*.ba* "${FOLDER}/CleanedReads_Illumina/${RUN}/BAM"
create_directory "${FOLDER}/QC_Stats/${RUN}/Mapping"
move_file "${SAMPLE}_MappedReads_to_${HOST}.tsv" "${FOLDER}/QC_Stats/${RUN}/Mapping"

# Sortmerna
echo "Starting moving Sortmerna files"
create_directory "${FOLDER}/sortmerna/${RUN}"
mv sortmerna/"${SAMPLE}_MicrobialrRNA".* "${FOLDER}/sortmerna/${RUN}"

# QC_Stats
echo "Starting moving Fastqc files"
create_directory "${FOLDER}/QC_Stats/${RUN}/Raw_Fastqc"
mv "Fastqc_Raw/${SAMPLE}"_R*_Fastqc_Raw.html "${FOLDER}/QC_Stats/${RUN}/Raw_Fastqc"
mv "Fastqc_Raw/${SAMPLE}"_R*_Fastqc_Raw.zip "${FOLDER}/QC_Stats/${RUN}/Raw_Fastqc"

create_directory "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithHost_Fastqc"
mv "Fastqc_Cleaned_With-${HOST}/${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R"*_Fastqc_Cleaned.html "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithHost_Fastqc"
mv "Fastqc_Cleaned_With-${HOST}/${SAMPLE}_CleanedReads_With-${HOST}_PairedReads_R"*_Fastqc_Cleaned.zip "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithHost_Fastqc"

create_directory "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithoutHost_Fastqc"
mv "Fastqc_Cleaned_Without-${HOST}/${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R"*_Fastqc_Cleaned.html "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithoutHost_Fastqc"
mv "Fastqc_Cleaned_Without-${HOST}/${SAMPLE}_CleanedReads_Without-${HOST}_PairedReads_R"*_Fastqc_Cleaned.zip "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithoutHost_Fastqc"

# Fastp Reports
echo "Starting moving Fastp report files"
create_directory "${FOLDER}/QC_Stats/${RUN}/FastpReports"
mv "${SAMPLE}_ReportFastp".* "${FOLDER}/QC_Stats/${RUN}/FastpReports"

# Seqkit
echo "Starting moving Seqkit stats files"
create_directory "${FOLDER}/QC_Stats/${RUN}/Seqkit"
mv "${SAMPLE}_Statistics_Fastq.tsv" "${FOLDER}/QC_Stats/${RUN}/Seqkit"

# Taxonomic Profile Kraken2/Bracken
if [[ "$KRAKEN" == "yes" ]]; then
  echo "Starting moving taxonomic profile files"
  BASE_OUTPUT_MTX="${FOLDER}/TaxonomicProfile/${RUN}/Kraken2Bracken_${RUN}_confidence${CONFIDENCE}_database${DBKMTX}_tr${THRESHOLDKRACKEN}_tr${THRESHOLDBRACKEN}"
  BASE_OUTPUT_16S="${FOLDER}/TaxonomicProfile/${RUN}/Kraken2Bracken_${RUN}_confidence${CONFIDENCE}_database${DBK16S}_tr${THRESHOLDKRACKEN}_tr${THRESHOLDBRACKEN}"
  
  # List of subdirectories to create
  SUBDIRS=(
    "Reports/Kraken2"
    "Reports/Bracken/Species"
    "Reports/Bracken/Genus"
    "FilteredbyTaxa/NoHit"
    "FilteredbyTaxa/OnlyArchaea"
    "FilteredbyTaxa/OnlyBacteria"
    "FilteredbyTaxa/OnlyEukaryota"
    "FilteredbyTaxa/OnlyFungi"
    "FilteredbyTaxa/OnlyMicrobiome"
    "FilteredbyTaxa/OnlyViruses"
    "FilteredbyTaxa/OnlyHsapiens"
    "Krona/Kraken2"
    "Krona/Bracken"
  )
  
  # Create required subdirectories
  for SUBDIR in "${SUBDIRS[@]}"; do
    create_directory "${BASE_OUTPUT_MTX}/${SUBDIR}"
    create_directory "${BASE_OUTPUT_16S}/${SUBDIR}"
  done
  
  # Move Kraken2 reports
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" "${BASE_OUTPUT_MTX}/Reports/Kraken2"
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" "${BASE_OUTPUT_MTX}/Reports/Kraken2"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_Kraken2.tsv" "${BASE_OUTPUT_16S}/Reports/Kraken2"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}.k2report" "${BASE_OUTPUT_16S}/Reports/Kraken2"
  
  # Move Bracken species and genus reports
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken.tsv" "${BASE_OUTPUT_MTX}/Reports/Bracken/Species"
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species.breport" "${BASE_OUTPUT_MTX}/Reports/Bracken/Species"
  mv "${SAMPLE}_Bracken_Bacteria_Species_mpa.tsv" "${BASE_OUTPUT_MTX}/Reports/Bracken/Species"
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken.tsv" "${BASE_OUTPUT_MTX}/Reports/Bracken/Genus"
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus.breport" "${BASE_OUTPUT_MTX}/Reports/Bracken/Genus"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species_Bracken.tsv" "${BASE_OUTPUT_16S}/Reports/Bracken/Species"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species.breport" "${BASE_OUTPUT_16S}/Reports/Bracken/Species"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus_Bracken.tsv" "${BASE_OUTPUT_16S}/Reports/Bracken/Genus"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus.breport" "${BASE_OUTPUT_16S}/Reports/Bracken/Genus"
  
  # Move filtered reads by taxa
  declare -A FILTERED_TAXA=(
    ["NoHit"]="${SAMPLE}"_*_"Kraken2_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_NoHit.fastq"
    ["OnlyArchaea"]="${SAMPLE}_OnlyArchaea.fastq"
    ["OnlyBacteria"]="${SAMPLE}_OnlyBacteria.fastq"
    ["OnlyEukaryota"]="${SAMPLE}_OnlyEukaryota.fastq"
    ["OnlyFungi"]="${SAMPLE}_OnlyFungi.fastq"
    ["OnlyMicrobiome"]="${SAMPLE}_OnlyMicrobiome.fastq"
    ["OnlyViruses"]="${SAMPLE}_OnlyViruses.fastq"
    ["OnlyHsapiens"]="${SAMPLE}_Homosapiens.fastq"
  )
  
  # Move filtered reads and count files
  for TAXA in "${!FILTERED_TAXA[@]}"; do
    for file in ${FILTERED_TAXA[$TAXA]}; do
      move_file "$file" "${BASE_OUTPUT_MTX}/FilteredbyTaxa/${TAXA}"
    done
    move_file "${SAMPLE}_nb${TAXA}Reads.txt" "${BASE_OUTPUT_MTX}/FilteredbyTaxa/${TAXA}"
  done
  
  move_file "${SAMPLE}_microbialrRNA_Kraken2_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_NoHit.fastq" "${BASE_OUTPUT_16S}/FilteredbyTaxa/NoHit"
  
  # Move Krona visualization files
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.html" "${BASE_OUTPUT_MTX}/Krona/Kraken2"
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.html" "${BASE_OUTPUT_MTX}/Krona/Bracken"
  mv "${SAMPLE}"_*_"conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.html" "${BASE_OUTPUT_MTX}/Krona/Bracken"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_Kraken2_Krona.html" "${BASE_OUTPUT_16S}/Krona/Kraken2"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Species_Bracken_Krona.html" "${BASE_OUTPUT_16S}/Krona/Bracken"
  move_file "${SAMPLE}_microbialrRNA_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDBRACKEN}_Genus_Bracken_Krona.html" "${BASE_OUTPUT_16S}/Krona/Bracken"
  
  echo "Summary of Moved Files"
  find "${BASE_OUTPUT_MTX}" -type f
  find "${BASE_OUTPUT_16S}" -type f
fi

# Taxonomic Profile MetaPhlAn4
if [[ "$METAPHLAN" == "yes" ]]; then
    echo "Organizing MetaPhlAn output for sample: $SAMPLE"
    # Create necessary directories
    create_directory "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/profile"
    create_directory "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/profile/virus"
    create_directory "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/biom"
    create_directory "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/bowtie2"
    # Move files and check if they exist
    for file in "${SAMPLE}_MetaphlAn_profile.txt" \
                "${SAMPLE}_MetaphlAn_virome_vsc.txt" \
                "${SAMPLE}_MetaphlAn.biom" \
                "${SAMPLE}_MetaPhlAn_Bowtie2.bz2" ; do

        if [[ -f "$file" ]]; then
            case "$file" in
                *_MetaphlAn_profile.txt)
                    move_file "$file" "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/profile/"
                    ;;
                *_MetaphlAn_virome_vsc.txt)
                    move_file "$file" "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/profile/virus/"
                    ;;
                *.biom)
                    move_file "$file" "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/biom/"
                    ;;
                *.bz2)
                    move_file "$file" "${FOLDER}/TaxonomicProfile/${RUN}/MetaPhlAn/bowtie2/"
                    ;;
            esac
        else
            echo "Warning: $file not found for sample $SAMPLE."
        fi
    done
fi

# Taxonomic Profile BLAST
if [[ "$BLASTN" == "yes" ]]; then
     echo "Starting moving BLASTn files"
    # Create required directories
    create_directory "${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}/TopHit"
    create_directory "${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}/Krona"

    # Define log file per sample
    LOG_FILE="${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}/${SAMPLE}_move_log_${SLURM_ARRAY_TASK_ID}.txt"
    echo "Log for ${SAMPLE}" > "${LOG_FILE}"

    # Move BLASTn output files
    move_file "${SAMPLE}_vs_${BLASTDATABASE}_blastn.tsv" "${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}/TopHit"
    move_file "${SAMPLE}_vs_${BLASTDATABASE}_blastn_filter_topBitscore.tsv" "${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}/TopHit"
    move_file "${SAMPLE}_vs_${BLASTDATABASE}_List_nbHit_per_Taxa.tsv" "${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}/TopHit"
    move_file "${SAMPLE}_vs_${BLASTDATABASE}_blastn_best-hit_Krona.html" "${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}/Krona"

    # Summary
    echo "Finished moving files for ${SAMPLE}" >> "${LOG_FILE}"
    find "${FOLDER}/TaxonomicProfile/${RUN}/BLAST_db-${BLASTDATABASE}" -type f >> "${LOG_FILE}"
fi

# Taxonomic Profile mOTU profiler
if [[ "$MOTUS" == "yes" ]]; then
   echo "Starting moving mOTUs files"
   # Create required directories
   create_directory "${FOLDER}/TaxonomicProfile/${RUN}/mOTUs"

   # Move mOTUs output files
   move_file "${SAMPLE}_l75_c${CUTOFF}_motus_taxonomy.tsv" "${FOLDER}/TaxonomicProfile/${RUN}/mOTUs"
   move_file "${SAMPLE}_mOTUs.bam" "${FOLDER}/TaxonomicProfile/${RUN}/mOTUs"
   move_file "${SAMPLE}_mgc_reads.count" "${FOLDER}/TaxonomicProfile/${RUN}/mOTUs"
fi

# DeNovo MetaViralSPAdes
if [[ "$SPADES" == "yes" ]]; then
   echo "Starting moving Spades assemblies files"
   # Create required directories
   create_directory "${FOLDER}/DeNovoVirus/${RUN}/Contigs"
   create_directory "${FOLDER}/DeNovoVirus/${RUN}/Graph"

   # Move SPAdes output files
   mv "${SAMPLE}_metaviralspades/scaffolds.fasta" "${FOLDER}/DeNovoVirus/${RUN}/Contigs/${SAMPLE}_metaviralSPAdes_scaffolds.fasta"
   mv "${SAMPLE}_metaviralspades/contigs.fasta" "${FOLDER}/DeNovoVirus/${RUN}/Contigs/${SAMPLE}_metaviralSPAdes_contigs.fasta"
   mv "${SAMPLE}_metaviralspades/assembly_graph_with_scaffolds.gfa" "${FOLDER}/DeNovoVirus/${RUN}/Graph/${SAMPLE}_assembly_graph_with_scaffolds.gfa"
   mv "${SAMPLE}_metaviralspades/assembly_graph.fastg" "${FOLDER}/DeNovoVirus/${RUN}/Graph/${SAMPLE}_assembly_graph.fastg"
   mv "${SAMPLE}_metaviralspades/assembly_graph_after_simplification.gfa" "${FOLDER}/DeNovoVirus/${RUN}/Graph/${SAMPLE}_assembly_graph_after_simplification.gfa"
   mv "${SAMPLE}_metaviralspades/spades.log" "${FOLDER}/Log/${RUN}_run${RUNDATE}/${SAMPLE}_metaviralSPAdes_run${RUNDATE}.log"
fi

# Functional Human host
if [[ "$SALMON" == "yes" ]]; then
   echo "Starting moving Salmon reads count files"
   create_directory "${FOLDER}/FunctionalHumanHost/${RUN}/TSV_DESeq2"
   move_file "./${SAMPLE}_Salmon_Quant_RNA/${SAMPLE}_quant_ENST.tsv" "${FOLDER}/FunctionalHumanHost/${RUN}/TSV_DESeq2"
fi

# Functional Microbiome
if [[ "$HUMANN" == "yes" ]]; then
   echo "Starting moving Humann files"
   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/MetaPhlAn_TaxonomicProfile"
   move_file "Humann3_MetaPhlAn_${SAMPLE}/${SAMPLE}_humann_temp/${SAMPLE}_metaphlan_bug_list.tsv" "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/MetaPhlAn_TaxonomicProfile"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Abundance_Genefamily"
   move_file "Humann3_MetaPhlAn_${SAMPLE}/${SAMPLE}_genefamilies.tsv" "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Abundance_Genefamily"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Abundance_Pathway"
   move_file "Humann3_MetaPhlAn_${SAMPLE}/${SAMPLE}_pathabundance.tsv" "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Abundance_Pathway"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Pathway_coverage"
   move_file "Humann3_MetaPhlAn_${SAMPLE}/${SAMPLE}_pathcoverage.tsv" "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Pathway_coverage"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Abundance_Genefamily"
   move_file "Humann3_Bracken_${SAMPLE}/${SAMPLE}_genefamilies.tsv" "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Abundance_Genefamily"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Abundance_Pathway"
   move_file "Humann3_Bracken_${SAMPLE}/${SAMPLE}_pathabundance.tsv" "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Abundance_Pathway"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Pathway_coverage"
   move_file "Humann3_Bracken_${SAMPLE}/${SAMPLE}_pathcoverage.tsv" "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Pathway_coverage"

   create_directory "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables"
fi

# Microbiome R
create_directory "${FOLDER}/Microbiome_R/${RUN}/Metadata"
create_directory "${FOLDER}/Microbiome_R/${RUN}/BIOM"
create_directory "${FOLDER}/Microbiome_R/${RUN}/Combined"
# ---------------------------------

# ---------------------------------
# Cleaning Working Directory
# ---------------------------------
ls * > "${FOLDER}/Scripts/List_files_remaining_in_LocalWorkingDir_for_${SAMPLE}_run${RUNDATE}.txt"
rm -R "${LOCAL_WORK_DIR}"/*
# ---------------------------------

# ---------------------------------
mv "${FOLDER}"/Scripts/MTX_Illumina."${SLURM_ARRAY_TASK_ID}".*.err "${FOLDER}/Scripts/Sbatch_log"
# ---------------------------------
