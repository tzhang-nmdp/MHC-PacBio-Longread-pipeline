#!/bin/bash
# Set some default values:
WORKDIR=unset
REFDIR=unset
SAMPLEID=unset=unset
PARAVECTOR=unset

SCRIPTPATH=$(dirname $0)

usage()
{
  echo "
  Usage: bash mhc_longread_pipeline.sh  [OPTIONS] value
                           [ -w | --workdir     home/work dir     ] 
                           [ -r | --refdir      reference dir     ] 
                           [ -s | --sampleid    sample id         ]                            
                           [ -p | --paravector  parameter vector  ] 
                           "
  exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n immuannot \
    -o w:r:s:p: \
    --long workdir:,refdir:,sampleid:,para_file:\
    -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
  exit 1
fi

#echo "PARSED_ARGUMENTS is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -w | --workdir)  WORKDIR="$2"    ; shift 2 ;;
    -r | --refdir)  REFDIR="$2"    ; shift 2 ;;
    -s | --sampleid) SAMPLEID="$2"   ; shift 2 ;;
    -p | --paravector)  PARAVECTOR="$2"    ; shift 2 ;;    
    --) shift; break ;;
    *) echo "Unexpected option: $1."
       usage
       ;;
  esac
done

echo "test" $WORKDIR

if [ $WORKDIR == unset ]; then
  echo "Error: home/work directory is required."
  usage
fi

if [ $REFDIR == unset ]; then
  echo "Error: reference directory is required."
  usage
fi

if [ $SAMPLEID == unset ]; then
  echo "Error: sample id is required."
  usage
fi

if [ $PARAVECTOR == unset ]; then
  echo "Error: parameter vector is required."
  usage
fi


################################################################################################################################################# 
# parameter settings
in_dir=$WORKDIR"/in_dir"
out_dir=$WORKDIR"/out_dir"
immunotation_dir=$WORKDIR"/Immuannot"
ref_dir=$REFDIR
sample=$SAMPLEID
no_thread=$(echo $PARAVECTOR | cut -d "_" -f 1)
hifiasm_olc=$(echo $PARAVECTOR | cut -d "_" -f 2) # hifiasm parameter
# hifiasm_gm=4m # hifiasm parameter
immunannot_olr=$(echo $PARAVECTOR | cut -d "_" -f 3) # immunannot parameter
immunannot_dif=$(echo $PARAVECTOR | cut -d "_" -f 4) # immunannot parameter
pggb_hap=$(echo $PARAVECTOR | cut -d "_" -f 5) # pggb parameter
echo $in_dir $WORKDIR
################################################################################################################################################# 

if true; then
  echo ""
  echo "#### 1. de novo assembly by hifiasm #############"
    hifiasm ${in_dir}/${sample}.chr6.fastq -o ${out_dir}/${sample}.MHC.asm -t ${no_thread} -N ${hifiasm_olc} 
    awk '/^S/{print ">"$2;print $3}' ${out_dir}/${sample}.MHC.asm.bp.p_ctg.gfa >${out_dir}/${sample}.MHC.asm.bp.p_ctg.gfa.fa
    samtools faidx ${out_dir}/${sample}.MHC.asm.bp.p_ctg.gfa.fa
  if [ $? != "0" ]; then
    echo ERROR: Failed to assembly HLA/Kir genes
    exit 1
  fi
fi

if true; then
  echo ""
  echo "#### 2. MHC gene/variant annotation #############"
    ctg=${out_dir}/${sample}.MHC.asm.bp.p_ctg.gfa.fa
    script=${immunotation_dir}/scripts/immuannot.sh
    refdir=${ref_dir}
    outpref=${out_dir}/${sample}.MHC
    bash ${script} -c ${ctg} -r ${refdir} -o ${outpref} -t ${no_thread} --overlap ${immunannot_olr} --diff ${immunannot_dif}
  if [ $? != "0" ]; then
    echo ERROR: Failed to annotate HLA/Kir genes
    exit 1
  fi
fi

if true; then
  echo ""
  echo "#### 3. MHC pangenomic graph #############"
    sudo docker run -it \
                    -v ${out_dir}:/data ghcr.io/pangenome/pggb:latest /bin/bash \
                    -c "pggb -i /data/${sample}.MHC.asm.bp.p_ctg.gfa.fa  -G 2000 -p 70 -s 3000 -n ${pggb_hap} -t ${no_thread} -o /data/"
  if [ $? != "0" ]; then
    echo ERROR: Failed to graph HLA/Kir genes
    exit 1
  fi
fi
