import os , sys , time , toml , subprocess
from subprocess import run , call

# parameter dictionary
args_dict = toml.load(sys.argv[1])

# checking parameters
args_home_dir_path = f"{args_dict['path']['home_dir']}"
if args_home_dir_path:
    home_dir = args_home_dir_path
else:
    sys.exit("Missing home dir, check path.home_dir")

args_in_dir_path = f"{args_dict['path']['in_dir']}"
if args_in_dir_path:
    in_dir = args_in_dir_path
else:
    sys.exit("Missing input dir, check path.in_dir")

args_out_dir_path = f"{args_dict['path']['out_dir']}"
if args_out_dir_path:
    out_dir = args_out_dir_path
else:
    sys.exit("Missing output dir, check path.out_dir")
    
args_immuannot_dir_path = f"{args_dict['path']['immuannot_dir']}"
if args_immuannot_dir_path:
    immuannot_dir = args_immuannot_dir_path
else:
    sys.exit("Missing output dir, check path.out_dir")
    
args_ref_dir_path = f"{args_dict['path']['ref_dir']}"
if args_ref_dir_path:
    ref_dir = args_ref_dir_path
else:
    sys.exit("Missing output dir, check path.out_dir")

no_thread = args_dict['parameter']['no_thread']
if no_thread:
    no_thread = no_thread
else:
    no_thread=1
    
hifiasm_olr = args_dict['parameter']['assembly']['hifiasm_olr']
if hifiasm_olr:
    hifiasm_olr = hifiasm_olr
else:
    hifiasm_olr = 10000
    
immunannot_olr = args_dict['parameter']['mhc_annotation']['immunannot_olr']
if immunannot_olr:
    immunannot_olr = immunannot_olr
else:
    immunannot_olr = 0.9
    
immunannot_dif = args_dict['parameter']['mhc_annotation']['immunannot_dif']
if immunannot_dif:
    immunannot_dif = immunannot_dif
else:
    immunannot_dif = 0.03    
    
pggb_hap = args_dict['parameter']['pangenomic_graph']['pggb_hap']
if pggb_hap:
    pggb_hap = pggb_hap
else:
    pggb_hap = 2
                    
# additional parameters
sample = args_dict['path']['sample']    
    
print("### run mhc longread pipeline ###")
# mhc_longread_pipeline_commandline = ['bash mhc_longread_pipeline.sh' , '-w' ,  home_dir , '-r' , ref_dir , '-s' , sample , '-p' , '_'.join(str(para) for para in [no_thread , hifiasm_olr , immunannot_olr , immunannot_dif , pggb_hap])]
# run(mhc_longread_pipeline_commandline , shell=True)
mhc_longread_pipeline_commandline = 'bash mhc_longread_pipeline.sh -w ' + home_dir + ' -r ' + ref_dir + ' -s ' + sample + ' -p ' + '_'.join(str(para) for para in [no_thread , hifiasm_olr , immunannot_olr , immunannot_dif , pggb_hap])
os.system(mhc_longread_pipeline_commandline)
