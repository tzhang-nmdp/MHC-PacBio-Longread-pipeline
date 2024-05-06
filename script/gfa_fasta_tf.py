import os , sys

# gfa and fasta files
gfa_file = open(str(sys.argv[1]) , 'r')
fasta_file = open(gfa_file + '.fa' , 'w')

# read and transform
for line in gfa_file:
    if line.startswith('S') :
        item = line.strip().split('\t')
        fasta_file.write('>' + str(item[2]) + '\n' + str(item[3]))
