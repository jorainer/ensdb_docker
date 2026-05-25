#! /bin/bash
SPEC=$1

if [ $# -eq 1 ]
then
    FTP_FOLDER="ftp://ftp.ensembl.org/pub/release-${ens_version}/mysql/"
else
    FTP_FOLDER=$2
fi

DROP_FILES="TRUE"
if [ $# -eq 3 ]
then
    DROP_FILES=$3
fi

echo "Processing species: $SPEC"
echo "ftp folder: $FTP_FOLDER"
export species=$SPEC
export ftp_folder=$FTP_FOLDER
export drop_files=$DROP_FILES

OUT_DIR="/ensdb_dir"
if [ ! -d "$OUT_DIR" ]; then
    echo "$OUT_DIR does exist! Please pass the output directory using -v <local_dir>:/ensdb_dir to the docker command."
    exit 1
fi

## Perl settings
source ~/perl5/perlbrew/etc/bashrc
source ~/.profile

service mysql start

Rscript "./create-ensdb.R"

mv *.sqlite "$OUT_DIR/"
