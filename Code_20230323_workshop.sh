#!/bin/bash

# Code for March 23, 2023 workshop

#===================
# Getting started...

# 1. Open the terminal and navigate to the conda_workshop folder on your desktop

cd /mnt/c/Users/Username/Desktop/conda_workshop

# 2. Make a new directory called Bacterial_Genomics

mkdir Bacterial_Genomics

# 3. List the contents of the directory to confirm the new directory has been created

ls

# 5. Clone the 2023-03-23-Bacterial-Genomics repository in the Bacterial_Genomics directory

git clone https://github.com/mmid-bioinformatics-workshop/2023-03-23-Bacterial-Genomics.git

# 6. Download the fastq dataset to the Bacterial_Genomics directory

https://drive.google.com/drive/folders/1bm2I6Ti4t-Bymw2k6K_I2JE_5cIL46tM?usp=share_link


# 7. Click on the link to download the Bowtie2 index from the MMID Bioinformatics Github repository to the Bacterial_Genomics folder

https://www.dropbox.com/s/wrb253faf3i1bfo/Bowtie2Index.tar.gz?dl=0


# 8. Unzip the fastq.zip folder than gunzip the individual fastq.gz files

unzip fastq.gz
gunzip *fastq.gz



#=============================
# Step by step guide - FastQC

# 1. Make a new directory called fastq in the Bacterial_Genomics directory

mkdir fastq

# 2. Move fastq files into the fastq directory

mv *.fastq ./fastq

# 3. Verify the fastq files have been moved

cd fastq
ls

# 4. Activate conda environment that contains the FastQC package

conda activate conda_workshop

# 5. Return to the Bacterial_Genomics directory

cd ..

# 6. Make a new directory called fastqc_reports

mkdir fastqc_reports

# 7. Run fastqc

fastqc ./fastq/*.fastq -o ./fastqc_reports/


### NOTE: **Waffles Users Only**
sbatch -c 1 --mem 2G -p NMLResearch --wrap="fastqc ./fastq/*.fastq -o ./fastqc_reports"




#===========================
# Step by step guide - fastp

# 1. Activate conda environment that contains the fastp package

conda activate conda_workshop

# 2. Make a new directory called fastp in the Bacterial_Genomics directory

mkdir fastp

# 3. Run fastp 

fastp -i ./fastq/SAMN02368311_R1.fastq -I ./fastq/SAMN02368311_R2.fastq -o ./fastp/SAMN02368311-fp_R1.fastq -O ./fastp/SAMN02368311-fp_R2.fastq -h ./fastp/SAMN02368311.html -j ./fastp/SAMN02368311.json



#==========================
# Installing Bowtie2

# 1. Install the bowtie2 package in the conda_workshop environment

conda install -y -c bioconda bowtie2



#=============================
# Step by step guide - Bowtie2

# 1. Make a new directory in Bacterial_Genomics directory called host_filtered

mkdir host_filtered

# 2. Decompress the Bowtie2Index.tar.gz file

tar -xvzf Bowtie2Index.tar.gz

# 3. Filter host reads using the iGenomes Homo sapiens bowtie2 index

bowtie2 -x ./Bowtie2Index/genome -1 ./fastp/SAMN02368311-fp_R1.fastq -2 ./fastp/SAMN02368311-fp_R2.fastq -S ./host_filtered/SAMN02368311.sam

# 4. Move into the host_filtered directory and convert sam to b

cd host_filtered
samtools view -bS SAMN02368311.sam > SAMN02368311.bam

# 5. Make a new directory called unmapped

mkdir unmapped

# 6. Extract unmapped reads for both pairs

samtools view -b -f 12 -F 256 SAMN02368311.bam > ./unmapped/SAMN02368311_unmapped.bam

# 7. Move into the unmapped directory and make a new directory called sorted

cd unmapped/
mkdir sorted

# 8. Sort the bam file

samtools sort -n -o ./sorted/SAMN02368311_sorted.bam --output-fmt BAM SAMN02368311_unmapped.bam

# 9. Move into the sorted directory and convert BAM file to fastq

cd sorted/
samtools fastq -@ 2 -1 SAMN02368311-HR_R1.fastq -2 SAMN02368311-HR_R2.fastq SAMN02368311_sorted.bam


#============================
# Step by step guide - checkM

# 1. Make a new directory in Bacterial_Genomics directory called checkM

mkdir checkM

# 2. Navigate to the downloaded assemblies folder and decompress the fasta files

cd 2023-03-23-Bacterial-Genomics
cd assemblies_skesa
gunzip *.gz

# 3. Return to the Bacterial_Genomics folder

cd ../../

# 4. Run checkM taxonomy_wf on assembled data

checkm taxonomy_wf genus Vibrio ./2023-03-23-BacterialGenomics/assemblies_skesa/ ./checkM/ -t 2 -x fasta

# 5. Run qa workflow

checkm qa -o 2 -f ./checkM/checkM_quality.tsv --tab_table ./checkM/Vibrio.ms ./checkM/



