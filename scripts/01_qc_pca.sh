#!/usr/bin/env bash
# Step 1: quality control, LD pruning and PCA on 1000 Genomes chr22
# Run this from the main project folder (ancestry-prediction-1000genomes).
# Needs: plink2 (put plink2.exe in data/, or change PLINK below)
#        data/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz

set -e   # stop if any command fails

PLINK="data/plink2.exe"
VCF="data/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"

# 1. Quality control: keep simple SNPs, drop rare variants and ones with lots of missing data
$PLINK --vcf "$VCF" \
  --snps-only just-acgt \
  --max-alleles 2 \
  --set-all-var-ids '@:#:$r:$a' \
  --new-id-max-allele-len 20 truncate \
  --maf 0.05 \
  --geno 0.05 \
  --make-bed \
  --out data/qc

# 2. LD pruning: remove SNPs that are copies of their neighbours
$PLINK --bfile data/qc \
  --indep-pairwise 50 5 0.2 \
  --out data/prune

# 3. PCA: 10 numbers per person
$PLINK --bfile data/qc \
  --extract data/prune.prune.in \
  --pca 10 \
  --out data/pca

echo "Done. PCA results are in data/pca.eigenvec"