#!/usr/bin/env bash
#SBATCH --job-name=Outputs-for-R                      # Job name
#SBATCH --output=Outputs-for-R.%a.%A.out              # File to which stdout will be written
#SBATCH --error=Outputs-for-R.%a.%A.err               # File to which stderr will be written
#SBATCH --partition=2tcourt                           # Partition
#SBATCH --nodes=1                                     # Number of node - 1 GENOA node has 96-core and 750 Go RAM
#SBATCH --ntasks=1                                    # Number of cores/cpus
#SBATCH --cpus-per-task=96                            # Cpus per task
#SBATCH --time=00-05:00                               # Runtime in DD-HH:MM
#SBATCH --mem=25G                                     # Memory for all cores in Gbytes
#SBATCH --mail-type=ALL                               # BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail                            # Email address

# ---------------------------------
# Version v1.9
# ---------------------------------
# author: Nicolas Nesi
# University Caen Normandy, INSERM UMR 1311 DYNAMICURE
# Date:30/01/2026
# ---------------------------------

# ---------------------------------
# Variables and Paths
# ---------------------------------
# safety for failing steps
set -euo pipefail

# Positional parameters
GROUP="${1}"
PROJECT="${2}"
RUN="${3}"
HOST="${4}"
DBKMTX="${5}"
DBK16S="${6}"
CONFIDENCE="${7}"
THRESHOLDKRACKEN="${8}"
THRESHOLDBRACKEN="${9}"
METAPHLAN="${10}"
HUMANN="${11}"

# Paths
FOLDER="/dlocal/home/2019013/Data/${GROUP}/${PROJECT}"
PATH1="${FOLDER}/TaxonomicProfile/${RUN}/Kraken2Bracken_${RUN}_confidence${CONFIDENCE}_database${DBKMTX}_tr${THRESHOLDKRACKEN}_tr${THRESHOLDBRACKEN}"
PATH2="${FOLDER}/TaxonomicProfile/${RUN}/Kraken2Bracken_${RUN}_confidence${CONFIDENCE}_database${DBK16S}_tr${THRESHOLDKRACKEN}_tr${THRESHOLDBRACKEN}"
PATH3="${FOLDER}/Microbiome_R/${RUN}"

#Database for Recentrifuge node.dmp and names.dmp from NCBI (update with retaxdump)
DBRC="/dlocal/home/2019013/Databases/Recentrifuge/taxdump"

RUNDATE="$(date '+%Y-%m-%d')"

# Threads
export THREADS="${SLURM_CPUS_PER_TASK}"
echo "number of threads used $THREADS"
# ---------------------------------

# ---------------------------------
# Environments
# ---------------------------------
module load py_env/miniconda3/25.7.0
set +u
eval "$(conda shell.bash hook)"
conda activate MTX_env
set -u
# Include:
# hclust2=1.0.0
# HUMAnN=3.9
# kraken-biom=1.2.0
# KrakenTools=1.2
# MetaPhlAn=4.1.1
# multiqc=1.28
# recentrifuge=1.16.1
# ---------------------------------

# ---------------------------------
# Create Directories
# ---------------------------------
echo "Creating directories for recentrifuge"

DIRS=(
  "${PATH1}/All_Bracken_Reports/With-${HOST}/Species"
  "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus"
  "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species"
  "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus"
  "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species"
  "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus"
  "${PATH2}/All_Bracken_Reports/microbialrRNA/Species"
  "${PATH2}/All_Bracken_Reports/microbialrRNA/Genus"
)

# Create the directories using a loop
for dir in "${DIRS[@]}"; do
  mkdir -p "${dir}"
done

# Kraken2 Recentrifuge Directories
echo "Creating Kraken2 Recentrifuge directories"

mkdir -p "${PATH1}/Recentrifuge_Kraken_With-${HOST}"
mkdir -p "${PATH1}/Recentrifuge_Kraken_Without-${HOST}"
mkdir -p "${PATH1}/Recentrifuge_Kraken_Without-${HOST}_Without-microbialrRNA"
mkdir -p "${PATH2}/Recentrifuge_Kraken_microbialrRNA"

# Microbiome R directories
echo "Creating Microbiome R subdirectories"
mkdir -p "${PATH3}/BIOM"
mkdir -p "${PATH3}/Combined"
mkdir -p "${PATH3}/HumannPathways"
mkdir -p "${PATH3}/OTU_Table"

echo "Directory setup complete."
# ---------------------------------

# ---------------------------------
# Copy Bracken outputs
# ---------------------------------
echo "Copy Bracken outputs for all samples"

cp "${PATH1}"/Reports/Bracken/Species/*_With-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Species.breport "${PATH1}/All_Bracken_Reports/With-${HOST}/Species"

cp "${PATH1}"/Reports/Bracken/Species/*_With-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Species_Bracken.tsv "${PATH1}/All_Bracken_Reports/With-${HOST}/Species"

cp "${PATH1}"/Reports/Bracken/Genus/*_With-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Genus.breport "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus"

cp "${PATH1}"/Reports/Bracken/Genus/*_With-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Genus_Bracken.tsv "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus"

cp "${PATH1}"/Reports/Bracken/Species/*_Without-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Species.breport "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species"

cp "${PATH1}"/Reports/Bracken/Genus/*_Without-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Genus.breport "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus"

cp "${PATH1}"/Reports/Bracken/Species/*_Without-"${HOST}"_Without-microbialrRNA_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Species.breport "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species"

cp "${PATH1}"/Reports/Bracken/Genus/*_Without-"${HOST}"_Without-microbialrRNA_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDBRACKEN}"_Genus.breport "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus"

cp "${PATH2}"/Reports/Bracken/Species/*_microbialrRNA_conf"${CONFIDENCE}"_db"${DBK16S}"_tr"${THRESHOLDBRACKEN}"_Species.breport "${PATH2}/All_Bracken_Reports/microbialrRNA/Species"

cp "${PATH2}"/Reports/Bracken/Genus/*_microbialrRNA_conf"${CONFIDENCE}"_db"${DBK16S}"_tr"${THRESHOLDBRACKEN}"_Genus.breport "${PATH2}/All_Bracken_Reports/microbialrRNA/Genus"

if [[ -f "${FOLDER}/Scripts/${PROJECT}_metadata.tsv" ]]; then
 cp "${FOLDER}/Scripts/${PROJECT}_metadata.tsv" "${PATH3}/Metadata/"
else 
 echo "No metadata file provided"
fi
# ---------------------------------

# ---------------------------------
# Convert Kraken/Bracken ouput to mpa style and combine for microeco
# ---------------------------------
echo "Convert Kraken2/Bracken report to mpa style"

shopt -s nullglob  # Ensure globs that match nothing expand to nothing

# With-HOST Species
files=("${PATH1}/All_Bracken_Reports/With-${HOST}/Species"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH1}/All_Bracken_Reports/With-${HOST}/Species"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH1}/All_Bracken_Reports/With-${HOST}/Species"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Species_With-${HOST}_mpa.txt"
else
    echo "No With-HOST Species files found in ${PATH1}/All_Bracken_Reports/With-${HOST}/Species/"
fi

# With-HOST Genus
files=("${PATH1}/All_Bracken_Reports/With-${HOST}/Genus"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Genus_With-${HOST}_mpa.txt"
else
    echo "No With-HOST Genus files found in ${PATH1}/All_Bracken_Reports/With-${HOST}/Genus/"
fi

# Without-HOST Species
files=("${PATH1}/All_Bracken_Reports/Without-${HOST}/Species"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Species_Without-${HOST}_mpa.txt"
else
    echo "No Without-HOST Species files found in ${PATH1}/All_Bracken_Reports/Without-${HOST}/Species/"
fi

# Without-HOST Genus
files=("${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Genus_Without-${HOST}_mpa.txt"
else
    echo "No Without-HOST Genus files found in ${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus/"
fi

# Without-HOST Without-microbialrRNA Species
files=("${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Species_Without-${HOST}_Without-microbialrRNA_mpa.txt"
else
    echo "No Without-HOST Without-microbialrRNA Species files found in ${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species/"
fi

# Without-HOST Without-microbialrRNA Genus
files=("${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Genus_Without-${HOST}_Without-microbialrRNA_mpa.txt"
else
    echo "No Without-HOST Without-microbialrRNA Genus files found in ${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus/"
fi

# microbialrRNA Species
files=("${PATH2}/All_Bracken_Reports/microbialrRNA/Species"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH2}/All_Bracken_Reports/microbialrRNA/Species"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH2}/All_Bracken_Reports/microbialrRNA/Species"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Species_microbialrRNA_mpa.txt"
else
    echo "No microbialrRNA Species files found in ${PATH2}/All_Bracken_Reports/microbialrRNA/Species/"
fi

# microbialrRNA Genus
files=("${PATH2}/All_Bracken_Reports/microbialrRNA/Genus"/*.breport)
if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
        kreport2mpa.py -r "${file}" -o "${file%.breport}_mpa.txt"
    done
    for f in "${PATH2}/All_Bracken_Reports/microbialrRNA/Genus"/*.txt; do
        filename=$(basename "$f")
        prefix="#${filename%%_*}"
        awk -v var="$prefix" 'BEGIN{print var} {print}' "$f" > tmp && mv tmp "$f"
    done
    combine_mpa.py --input "${PATH2}/All_Bracken_Reports/microbialrRNA/Genus"/*_mpa.txt \
        --output "${FOLDER}/Microbiome_R/${RUN}/Combined/Bracken_Genus_microbialrRNA_mpa.txt"
else
    echo "No microbialrRNA Genus files found in ${PATH2}/All_Bracken_Reports/microbialrRNA/Genus/"
fi
# ---------------------------------

# ---------------------------------
# Create BIOM for R package Phyloseq from Bracken reports outputs
# ---------------------------------
echo "Create BIOM files from Bracken Species outputs"

# remove part of the input file name
mkdir -p "${PATH1}/All_Bracken_Reports/With-${HOST}/Species/biom"

cd "${PATH1}/All_Bracken_Reports/With-${HOST}/Species"

for file in *.breport
  do newname=$(echo "$file" | awk -F'_' '{print $1}') 
  dest="${PATH1}/All_Bracken_Reports/With-${HOST}/Species/biom/${newname}.breport"
  mv "$file" "$dest" 
done

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/With-${HOST}/Species/biom"/*.breport \
--max D \
--min S \
--fmt json \
--otu_fp "${PATH3}/BIOM/All_BrackenSpecies_TaxID-OTUs_forPhyloT.txt" \
--output_fp "${PATH3}/BIOM/All_BrackenSpecies_BIOM-json.biom"

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/With-${HOST}/Species/biom"/*.breport \
--max D \
--min S \
--fmt tsv \
--output_fp "${PATH3}/BIOM/All_BrackenSpecies_BIOM-tsv.tsv"

if [[ -f "${PATH3}/Metadata/Project_metadata.tsv" ]]; then
  kraken-biom \
  --kraken_reports_fp "${PATH1}/All_Bracken_Reports/With-${HOST}/Species/biom"/*.breport \
  --max D \
  --min S \
  --metadata "${PATH3}/Metadata/Project_metadata.tsv" \
  --output_fp "${PATH3}/BIOM/All_BrackenSpecies_withMetadata_BIOM-HDF5.biom"
else
  echo "No metadata file found at ${PATH3}/Metadata/Project_metadata.tsv"
fi

mkdir -p "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species/biom"

cd "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species/"

for file in *.breport
  do newname=$(echo "$file" | awk -F'_' '{print $1}') 
  dest="${PATH1}/All_Bracken_Reports/Without-${HOST}/Species/biom/${newname}.breport"
  mv "$file" "$dest" 
done

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species/biom"/*.breport \
--max D \
--min S \
--fmt json \
--otu_fp "${PATH3}/BIOM/All_BrackenSpecies_TaxID-OTUs_forPhyloT.txt" \
--output_fp "${PATH3}/BIOM/All_BrackenSpecies_BIOM-json.biom"

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species/biom"/*.breport \
--max D \
--min S \
--fmt tsv \
--output_fp "${PATH3}/BIOM/All_BrackenSpecies_BIOM-tsv.tsv"

if [[ -f "${PATH3}/Metadata/Project_metadata.tsv" ]]; then
   kraken-biom \
   --kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}/Species/biom"/*.breport \
   --max D \
   --min S \
   --metadata "${PATH3}/Metadata/Project_metadata.tsv" \
   --output_fp "${PATH3}/BIOM/All_BrackenSpecies_WithoutMetadata_BIOM-HDF5.biom"
else
  echo "No metadata file found at ${PATH3}/Metadata/Project_metadata.tsv"
fi

mkdir -p "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species/biom"

cd "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species/"

for file in *.breport
  do newname=$(echo "$file" | awk -F'_' '{print $1}') 
  dest="${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species/biom/${newname}.breport"
  mv "$file" "$dest" 
done

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species/biom"/*.breport \
--max D \
--min S \
--fmt json \
--otu_fp "${PATH3}/BIOM/All_BrackenSpecies_TaxID-OTUs_forPhyloT.txt" \
--output_fp "${PATH3}/BIOM/All_BrackenSpecies_BIOM-json.biom"

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species/biom"/*.breport \
--max D \
--min S \
--fmt tsv \
--output_fp "${PATH3}/BIOM/All_BrackenSpecies_BIOM-tsv.tsv"

if [[ -f "${PATH3}/Metadata/Project_metadata.tsv" ]]; then
  kraken-biom \
  --kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Species/biom"/*.breport \
  --max D \
  --min S \
  --metadata "${PATH3}/Metadata/Project_metadata.tsv" \
  --output_fp "${PATH3}/BIOM/All_BrackenSpecies_WithoutMetadata_BIOM-HDF5.biom"
else
  echo "No metadata file found at ${PATH3}/Metadata/Project_metadata.tsv"
fi

echo "Create BIOM files from Bracken Genus outputs"

mkdir -p "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus/biom"

cd "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus/"

for file in *.breport
  do newname=$(echo "$file" | awk -F'_' '{print $1}') 
  dest="${PATH1}/All_Bracken_Reports/With-${HOST}/Genus/biom/${newname}.breport"
  mv "$file" "$dest" 
done

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus/biom"/*.breport \
--max D \
--min G \
--fmt json \
--otu_fp "${PATH3}/BIOM/All_BrackenGenus_TaxID-OTUs_forPhyloT.txt" \
--output_fp "${PATH3}/BIOM/All_BrackenGenus_BIOM-json.biom"

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus/biom"/*.breport \
--max D \
--min G \
--fmt tsv \
--output_fp "${PATH3}/BIOM/All_BrackenGenus_BIOM-tsv.tsv"

if [[ -f "${PATH3}/Metadata/Project_metadata.tsv" ]]; then
   kraken-biom \
   --kraken_reports_fp "${PATH1}/All_Bracken_Reports/With-${HOST}/Genus/biom"/*.breport \
   --max D \
   --min G \
   --metadata "${PATH3}/Metadata/Project_metadata.tsv" \
   --output_fp "${PATH3}/BIOM/All_BrackenGenus_withMetadata_BIOM-HDF5.biom"
else
  echo "No metadata file found at ${PATH3}/Metadata/Project_metadata.tsv"
fi

mkdir -p "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus/biom"

cd "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus/"

for file in *.breport
  do newname=$(echo "$file" | awk -F'_' '{print $1}') 
  dest="${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus/biom/${newname}.breport"
  mv "$file" "$dest" 
done

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus/biom"/*.breport \
--max D \
--min G \
--fmt json \
--otu_fp "${PATH3}/BIOM/All_BrackenGenus_TaxID-OTUs_forPhyloT.txt" \
--output_fp "${PATH3}/BIOM/All_BrackenGenus_BIOM-json.biom"

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus/biom"/*.breport \
--max D \
--min G \
--fmt tsv \
--output_fp "${PATH3}/BIOM/All_BrackenGenus_BIOM-tsv.tsv"

if [[ -f "${PATH3}/Metadata/Project_metadata.tsv" ]]; then
   kraken-biom \
   --kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}/Genus/biom"/*.breport \
   --max D \
   --min G \
   --metadata "${PATH3}/Metadata/Project_metadata.tsv" \
   --output_fp "${PATH3}/BIOM/All_BrackenGenus_WithoutMetadata_BIOM-HDF5.biom"
else
  echo "No metadata file found at ${PATH3}/Metadata/Project_metadata.tsv"
fi

mkdir -p "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus/biom"

cd "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus/"

for file in *.breport
  do newname=$(echo "$file" | awk -F'_' '{print $1}') 
  dest="${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus/biom/${newname}.breport"
  mv "$file" "$dest" 
done

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus/biom"/*.breport \
--max D \
--min G \
--fmt json \
--otu_fp "${PATH3}/BIOM/All_BrackenGenus_TaxID-OTUs_forPhyloT.txt" \
--output_fp "${PATH3}/BIOM/All_BrackenGenus_BIOM-json.biom"

kraken-biom \
--kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus/biom"/*.breport \
--max D \
--min G \
--fmt tsv \
--output_fp "${PATH3}/BIOM/All_BrackenGenus_BIOM-tsv.tsv"

if [[ -f "${PATH3}/Metadata/Project_metadata.tsv" ]]; then
   kraken-biom \
   --kraken_reports_fp "${PATH1}/All_Bracken_Reports/Without-${HOST}_Without-microbialrRNA/Genus/biom"/*.breport \
   --max D \
   --min G \
   --metadata "${PATH3}/Metadata/Project_metadata.tsv" \
   --output_fp "${PATH3}/BIOM/All_BrackenGenus_WithoutMetadata_BIOM-HDF5.biom"
else
  echo "No metadata file found at ${PATH3}/Metadata/Project_metadata.tsv"
fi
# ---------------------------------

# ---------------------------------
# Create a Bracken OTU_Table using New Estimated Reads (new_est_reads) column
# ---------------------------------
BRACKEN_DIR="${PATH1}/All_Bracken_Reports/With-${HOST}/Species"
OUTPUT_DIR="${PATH3}/OTU_Table"
OUTPUT_FILE="${OUTPUT_DIR}/Bracken_With${HOST}_Species_combined_otu.tsv"

for f in "$BRACKEN_DIR"/*_Bracken.tsv; do
    awk -F'\t' -v OFS='\t' 'NR==1 {print; next} {gsub(/ /, "-", $1); print}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

# Get sample names from filenames (up to first underscore)
samples=()
bracken_files=()
for f in "$BRACKEN_DIR"/*_Bracken.tsv; do
    filename=$(basename "$f")
    sample=${filename%%_*}
    samples+=("$sample")
    bracken_files+=("$f")
done

# Collect all unique taxa from all files, replace spaces with hyphens
awk 'NR==1{next} {gsub(/ /, "-", $1); print $1}' "${bracken_files[@]}" | sort -u > all_taxa.tmp

# Write header to output file
echo -e "Taxa\t${samples[*]}" | tr ' ' '\t' > "$OUTPUT_FILE"

# For each sample, extract new_est_reads and fill in zeros for missing taxa
for i in "${!bracken_files[@]}"; do
    # Extract taxon names and counts, replace spaces with hyphens in taxon names
    awk 'NR==1{next} {gsub(/ /, "-", $1); print $1 "\t" $6}' "${bracken_files[$i]}" > "${samples[$i]}_counts.tmp"
    # Join with all_taxa.tmp to fill in zeros for missing taxa
    awk 'NR==FNR {a[$1]=$2; next} {print $0 "\t" (a[$1] ? a[$1] : 0)}' "${samples[$i]}_counts.tmp" all_taxa.tmp > "${samples[$i]}_full.tmp"
    # Extract only the counts column for pasting
    cut -f2 "${samples[$i]}_full.tmp" > "${samples[$i]}_counts.tmp"
done

# Combine all taxa and counts
paste all_taxa.tmp "${samples[@]/%/_counts.tmp}" >> "$OUTPUT_FILE"

# Remove line starting by name
sed -i '/^name/d' "${OUTPUT_DIR}/Bracken_With${HOST}_Species_combined_otu.tsv"

# Clean up
rm all_taxa.tmp *_counts.tmp *_full.tmp
# ---------------------------------

# ---------------------------------
# Recentrifuge
# ---------------------------------
echo "Running Recentrifuge on Kraken2 outputs"

cp "${PATH1}"/Reports/Kraken2/*_With-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDKRACKEN}"_Kraken2.tsv "${PATH1}/Recentrifuge_Kraken_With-${HOST}"

for f in "${PATH1}"/Recentrifuge_Kraken_With-"${HOST}"/*.tsv; do mv "$f" "${f/.tsv/.krk}"; done

cd "${PATH1}"/Recentrifuge_Kraken_With-"${HOST}"/

rcf \
--nodespath "${DBRC}" \
--kraken ./ \
--scoring KRAKEN \
--minscore 25 \
--extra TSV \
--outprefix "${PATH1}/Recentrifuge_Kraken_With-${HOST}/AllSamples_With-${HOST}_Kraken2_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Recentrifuge.html" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/Recentrifuge_Kraken2_With-${HOST}_run${RUNDATE}.log"

cp "${PATH1}"/Reports/Kraken2/*_Without-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDKRACKEN}"_Kraken2.tsv "${PATH1}"/Recentrifuge_Kraken_Without-"${HOST}"/

for f in "${PATH1}"/Recentrifuge_Kraken_Without-"${HOST}"/*.tsv; do mv "$f" "${f/.tsv/.krk}"; done

cd "${PATH1}"/Recentrifuge_Kraken_Without-"${HOST}"/

rcf \
--nodespath "${DBRC}" \
--kraken ./ \
--scoring KRAKEN \
--minscore 25 \
--extra TSV \
--outprefix "${PATH1}/Recentrifuge_Kraken_Without-${HOST}/AllSamples_Without-${HOST}_Kraken2_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Recentrifuge.html" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/Recentrifuge_Kraken2_Without-${HOST}_run${RUNDATE}.log"

cp "${PATH1}"/Reports/Kraken2/*_Without-"${HOST}"_Without-microbialrRNA_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDKRACKEN}"_Kraken2.tsv "${PATH1}"/Recentrifuge_Kraken_Without-"${HOST}"_Without-microbialrRNA/

for f in "${PATH1}"/Recentrifuge_Kraken_Without-"${HOST}"_Without-microbialrRNA/*.tsv; do mv "$f" "${f/.tsv/.krk}"; done

cd "${PATH1}"/Recentrifuge_Kraken_Without-"${HOST}"_Without-microbialrRNA/

rcf \
--nodespath "${DBRC}" \
--kraken ./ \
--scoring KRAKEN \
--minscore 25 \
--extra TSV \
--outprefix "${PATH1}/Recentrifuge_Kraken_Without-${HOST}_Without-microbialrRNA/AllSamples_Without-${HOST}_Without-microbialrRNA_Kraken2_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}_Recentrifuge.html" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/Recentrifuge_Kraken2_Without-${HOST}_Without-microbialrRNA_run${RUNDATE}.log"

cp "${PATH2}"/Reports/Kraken2/*_microbialrRNA_conf"${CONFIDENCE}"_db"${DBK16S}"_tr"${THRESHOLDKRACKEN}"_Kraken2.tsv "${PATH2}"/Recentrifuge_Kraken_microbialrRNA/

for f in "${PATH2}"/Recentrifuge_Kraken_microbialrRNA/*.tsv; do mv "$f" "${f/.tsv/.krk}"; done

cd "${PATH2}"/Recentrifuge_Kraken_microbialrRNA/

rcf \
--nodespath "${DBRC}" \
--kraken ./ \
--scoring KRAKEN \
--minscore 25 \
--extra TSV \
--outprefix "${PATH2}/Recentrifuge_Kraken_microbialrRNA/AllSamples_microbialrRNA_Kraken2_conf${CONFIDENCE}_db${DBK16S}_tr${THRESHOLDKRACKEN}_Recentrifuge.html" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/Recentrifuge_Kraken/Recentrifuge_Kraken2_microbialrRNA_run${RUNDATE}.log"
# ---------------------------------

# ---------------------------------
# MultiQC of FastQC
# ---------------------------------
set +u
conda deactivate
conda activate multiqc_env
set -u
# include:
# multiqc=1.25.1

echo "Running Multiqc on Fastqc outputs"

cd "${FOLDER}/QC_Stats/${RUN}/Raw_Fastqc/"

for file in *.zip; do unzip -o "$file" -d fastqc_unzipped/ ; done

multiqc \
--outdir "${FOLDER}"/QC_Stats/"${RUN}"/Raw_Fastq/MultiQC \
--filename "${RUN}"_MultiQC_Raw_Fastq \
--force \
--export \
--clean-up \
"${FOLDER}/QC_Stats/${RUN}/Raw_Fastqc/fastqc_unzipped/" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/MultiQC_RawReads_run${RUNDATE}.log"

cd "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithHost_Fastqc/"

for file in *.zip; do unzip -o "$file" -d fastqc_unzipped/ ; done

multiqc \
--outdir "${FOLDER}"/QC_Stats/"${RUN}"/Cleaned_WithHost_Fastqc/MultiQC \
--filename "${RUN}"_MultiQC_Cleaned_WithHost_Fastq \
--force \
--export \
--clean-up \
"${FOLDER}/QC_Stats/${RUN}/Cleaned_WithHost_Fastqc/fastqc_unzipped/" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/MultiQC_CleanedReads_WithHost_run${RUNDATE}.log"

cd "${FOLDER}/QC_Stats/${RUN}/Cleaned_WithoutHost_Fastqc/"

for file in *.zip; do unzip -o "$file" -d fastqc_unzipped/ ; done

multiqc \
--outdir "${FOLDER}"/QC_Stats/"${RUN}"/Cleaned_WithoutHost_Fastqc/MultiQC \
--filename "${RUN}"_MultiQC_Cleaned_WithoutHost_Fastq \
--force \
--export \
--clean-up \
"${FOLDER}/QC_Stats/${RUN}/Cleaned_WithoutHost_Fastqc/fastqc_unzipped/" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/MultiQC_CleanedReads_WithoutHost_run${RUNDATE}.log"

mkdir -p "${FOLDER}/QC_Stats/${RUN}/MultiQC_FastpKraken/Fastp"
mkdir -p "${FOLDER}/QC_Stats/${RUN}/MultiQC_FastpKraken/Kraken2"

cp "${FOLDER}"/QC_Stats/"${RUN}"/FastpReports/*.json "${FOLDER}/QC_Stats/${RUN}/MultiQC_FastpKraken/Fastp"
cp "${PATH1}/Reports/Kraken2/"*"_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report" "${FOLDER}/QC_Stats/${RUN}/MultiQC_FastpKraken/Kraken2"

for f in "${FOLDER}"/QC_Stats/"${RUN}"/MultiQC_FastpKraken/Kraken2/*_With-"${HOST}"_conf"${CONFIDENCE}"_db"${DBKMTX}"_tr"${THRESHOLDKRACKEN}".k2report; do
  sample=$(echo "$f" | sed -E "s/_With-${HOST}_conf${CONFIDENCE}_db${DBKMTX}_tr${THRESHOLDKRACKEN}.k2report$//")
  mv "$f" "${sample}.k2report"
done

multiqc \
--outdir "${FOLDER}/QC_Stats/${RUN}/MultiQC_FastpKraken" \
--filename "${RUN}"_MultiQC_Fastp-Kraken2 \
--force \
--export \
--clean-up \
"${FOLDER}/QC_Stats/${RUN}/MultiQC_FastpKraken/Fastp/" "${FOLDER}/QC_Stats/${RUN}/MultiQC_FastpKraken/Kraken2/" 2>&1 | tee -a "${FOLDER}/Log/${RUN}_run${RUNDATE}/MultiQC_Fastp-Kraken2_run${RUNDATE}.log"
# ---------------------------------

# ---------------------------------
# Merge MetaphlAn 4 outputs
# ---------------------------------
if [[ "$METAPHLAN" == "yes" ]]; then
  
  echo "Merge abundance tables of all samples. The output merge table can then be used with file2meco R package (mpa2meco)"
  
   merge_metaphlan_tables.py \
   "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/*_MetaphlAn_profile.txt \
   -o "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/MergedSamples/AllSamples_merge_abundance_table_"${RUN}".txt
  
   merge_vsc_tables.py \
   "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/*_MetaphlAn_virome_vsc.txt \
   -o "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/MergedSamples/AllSamples_merge_virome_table_"${RUN}".txt
  
   echo "Generate a species-only abundance table"
   
  grep -E "s__|SRS" "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/MergedSamples/AllSamples_merge_abundance_table_"${RUN}".txt \
   | grep -v "t__" \
   | sed "s/^.*|//g" \
   | sed "s/SRS[0-9]*-//g" \
   > "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/MergedSamples/AllSamples_merge_abundance_table_species_"${RUN}".txt
   
   echo "Generate an heatmap of species abundance"
   hclust2.py \
   -i "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/MergedSamples/AllSamples_merge_abundance_table_species_"${RUN}".txt \
   -o "${FOLDER}"/TaxonomicProfile/MetaPhlAn_"${RUN}"/profile/MergedSamples/AllSamples_metaphlan4_abundance_heatmap_species.png \
   --f_dist_f braycurtis \
   --s_dist_f braycurtis \
   --cell_aspect_ratio 0.5 \
   --log_scale \
   --flabel_size 10 --slabel_size 10 \
   --max_flabel_len 100 --max_slabel_len 100 \
   --minv 0.1 \
   --dpi 300
else 
  echo "No MetaPhlan run"
fi
# ---------------------------------

# ---------------------------------
# Join Humann3 Output tables of all samples
# ---------------------------------
if [[ "$HUMANN" == "yes" ]]; then
   echo "Joinning Humann3 Tables of all samples"
   
   humann_join_tables \
   --input "${FOLDER}/FunctionalMicrobiome/Humann3_MetaPhlAn/Abundance_Genefamily/" \
   --output "${FOLDER}/FunctionalMicrobiome/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_genefamilies.tsv" \
   --file_name genefamilies
   
   humann_join_tables \
   --input "${FOLDER}/FunctionalMicrobiome/Humann3_Bracken/Abundance_Genefamily/" \
   --output "${FOLDER}/FunctionalMicrobiome/Humann3_Bracken/Join_Tables/$RUN_AllSamples_genefamilies.tsv" \
   --file_name genefamilies
   
   humann_join_tables \
   --input "${FOLDER}/FunctionalMicrobiome/Humann3_MetaPhlAn/Abundance_Pathway/" \
   --output "${FOLDER}/FunctionalMicrobiome/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathabundance.tsv" \
   --file_name pathabundance
   
   humann_join_tables \
   --input "${FOLDER}/FunctionalMicrobiome/Humann3_Bracken/Abundance_Pathway/" \
   --output "${FOLDER}/FunctionalMicrobiome/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathabundance.tsv" \
   --file_name pathabundance
   
   humann_join_tables \
   --input "${FOLDER}/FunctionalMicrobiome/Humann3_MetaPhlAn/Pathway_coverage/" \
   --output "${FOLDER}/FunctionalMicrobiome/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathcoverage.tsv" \
   --file_name pathcoverage
   
   humann_join_tables \
   --input "${FOLDER}/FunctionalMicrobiome/Humann3_Bracken/Pathway_coverage/" \
   --output "${FOLDER}/FunctionalMicrobiome/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathcoverage.tsv" \
   --file_name pathcoverage
# ---------------------------------
   
# ---------------------------------
# Normalization to Copy Per Million
# ---------------------------------
   echo "Normalization to CPM"
   
   humann_renorm_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathabundance.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathabundance_norm-cpm.tsv" \
   --units cpm
   
   humann_renorm_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathabundance.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathabundance_norm-cpm.tsv" \
   --units cpm
   
   humann_renorm_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathcoverage.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathcoverage_norm-cpm.tsv" \
   --units cpm
   
   humann_renorm_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathcoverage.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathcoverage_norm-cpm.tsv" \
   --units cpm
# ---------------------------------
   
# ---------------------------------
# Create stratified and non stratified tables
# ---------------------------------
   echo "Creating stratified and unstratified files"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathabundance.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathabundance.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathabundance_norm-cpm.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathabundance_norm-cpm.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathcoverage.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathcoverage.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathcoverage_norm-cpm.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/"
   
   humann_split_stratified_table \
   --input "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathcoverage_norm-cpm.tsv" \
   --output "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/"
# ---------------------------------

# ---------------------------------
# Format files for R package microeco 
# ---------------------------------
   echo "The output merge table can then be used with file2meco R package (humann2meco)"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathabundance_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathabundance_stratified_MetaphlAn.tsv"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathabundance_norm-cpm_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathabundance_norm-cpm_stratified_MetaphlAn.tsv"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathabundance_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathabundance_stratified_Bracken.tsv"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathabundance_norm-cpm_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathabundance_norm-cpm_stratified_Bracken.tsv"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathcoverage_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathcoverage_stratified_MetaphlAn.tsv"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_MetaPhlAn/Join_Tables/$RUN_AllSamples_pathcoverage_norm-cpm_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathcoverage_norm-cpm_stratified_MetaphlAn.tsv"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathcoverage_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathcoverage_stratified_Bracken.tsv"
   
   sed 's/_Abundance//g' "${FOLDER}/FunctionalMicrobiome/${RUN}/Humann3_Bracken/Join_Tables/$RUN_AllSamples_pathcoverage_norm-cpm_stratified.tsv" \
   > "${PATH3}"/HumannPathways/"$RUN_AllSamples_pathcoverage_norm-cpm_stratified_Bracken.tsv"
else 
  echo "No Humann run"
fi
# ---------------------------------

# ---------------------------------
mv "${FOLDER}"/Scripts/Outputs-for-R*.err "${FOLDER}"/Scripts/Sbatch_log/
# ---------------------------------
