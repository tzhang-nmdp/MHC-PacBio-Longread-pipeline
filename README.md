WORKFLOW


PROCEDURE
Installation
git clone folder into your work directory: 
git clone https://github.com/tzhang-nmdp/MHC-PacBio-Longread-pipeline.git

mkdir in_dir 
mkdir out_dir
Please make the changes for 'PATH' in "config/mhc_longread_pipeline.toml" based on your home/work directory
Please donwload benchmark data (https://github.com/tzhang-nmdp/giab_data_indexes) *.fastq into in_dir


#################################### PIPELINE STEUP #######################################
``` r
make setup
```
Note: Due to certain conda environment setting restriction, you might need manually run "conda activate mhc_longread_pipeline" after this step.

################ you can also install pipeline in separate and manual steps ################
``` r
conda install  -c bioconda hifiasm minimap2 samtools pbmm2  

# https://github.com/chhylp123/hifiasm
pip3 install --user whatshap
export PATH=$HOME/.local/bin:$PATH 

sudo docker pull google/deepvariant:latest
sudo docker pull kishwars/pepper_deepvariant:r0.8
sudo docker pull ghcr.io/pangenome/pggb:latest
git clonehttps://github.com/tzhang-nmdp/Immuannot

# reference data under Immuannot folder
tar xvf refData-2023Jun05.tgz
# tar xvf Data-2024Feb02.tar.gz
```
################################### BENCHMARK RUN #########################################
``` r
make benchmark-run CONFIG_TOML_PATH="mhc_longread_pipeline.toml"
```


################### you can also test pipeline in separate and manual steps ###############
1. Assembly/alignment
1.1 de novo assembly by hifiasm (1. only need 1~2 hr walltime / 20~40 cpu time, 100 time faster than Hicanu)
``` r
hifiasm -o ${out_dir}/${sample}.MHC.asm -t ${no_thread} ${in_dir}/${sample}.chr6.fastq -N 10000
awk '/^S/{print ">"$2;print $3}' ${out_dir}/${sample}.MHC.asm.p_ctg.gfa >${out_dir}/${sample}.MHC.asm.p_ctg.gfa.fa
samtools faidx ${out_dir}/${sample}.MHC.asm.p_ctg.gfa.fa
```

 

1.2 Reference based Alignment by pbmm2 (5~10 hr walltime / 50~100 cpu time) # consider pangenome reference panel
``` r
pbmm2  align \ 
               ${reference.fasta} ${in_dir}/${sample}.chr6.fastq ${out_dir}/${sample}.chr6.bam
```

2. Variant calling
Variant calling by DeepVariant
``` r
docker run \

           --ipc=host \

           -v "${in_dir}":"${in_dir}" -v "${out_dir}":"${out_dir}" \

           kishwars/pepper_deepvariant:r0.8 run_pepper_margin_deepvariant call_variant \

           -b "${in_dir}/${sample}.chr6.bam" -f "${in_dir}/${reference.fasta}" -o "${out_dir}" -p "${sample}.MHC" -t "${THREADS}" --hifi
```

3. Phasing 
phasing by whatshap
``` r
whatshap phase --reference=${reference.fasta} \
                 -o ${out_dir}/${sample}.MHC.wh.phase.vcf ${in_dir}/${sample}.MHC.vcf ${sample}.chr6.bam
```

4. HLA/KIR typing
4.1 immunotation HLA/KIR annotation
``` r
ctg=${out_dir}/${sample}.MHC.asm.bp.p_ctg.gfa.fa
script=${immunotation_dir}/scripts/immuannot.sh
refdir=${immunotation_dir}/${ref_dir}
outpref=${out_dir}/${sample}.MHC
bash ${script} -c ${ctg} -r ${refdir} -o ${outpref}
```
 
5. Pangenome graph
``` r
sudo docker run -it \
                             -v ${out_dir}:/data ghcr.io/pangenome/pggb:latest /bin/bash \
                             -c "pggb -i /data/${sample}.MHC.asm.p_ctg.gfa.fa -p 70 -s 3000 -G 2000 -n 2 -t ${no_thread} -o /data/out"
```

#######################################################################################

