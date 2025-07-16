#! /bin/bash
SPEC=$1
echo "Processing species: $SPEC"
export species=$SPEC

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
