FROM ubuntu:24.04

LABEL name="Ensembld EnsDb annotation databases" \
    url="https://github.com/jorainer/ensdb_docker" \
    maintainer="johannes.rainer@gmail.com" \
    description="Docker image to create EnsDb databases from Ensembl" \
    license="Artistic-2.0"

ARG ens_version=113
ENV ens_version=$ens_version

## Setup system requirements
RUN apt-get update && \
    apt-get install -y wget dirmngr curl libcurlpp-dev libxml2-dev software-properties-common mysql-server mysql-client mysql-common libdbd-mysql libmysqlclient-dev perlbrew bzip2 git
    # apt-get install -y wget mariadb-server mariadb-client libmariadb-dev libmariadb-dev-compat perlbrew bzip2

## Fixing permissions for MySQL
RUN echo "local_infile=1" >> /etc/mysql/mysql.conf.d/mysql.cnf && \
    echo "local_infile=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf

SHELL ["/bin/bash", "-c"]

## Install perl 5.18.0
RUN perlbrew init && \
    perlbrew install --notest perl-5.18.0 -n --switch && \
    perlbrew install-cpanm

WORKDIR /root

RUN echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.bashrc && \
    echo "export PERLBREW_ROOT=~/perl5/perlbrew" >> ~/.bashrc && \
    echo "export PATH=~/perl5/perlbrew/bin:$PATH" >> ~/.bashrc && \
    echo "perlbrew use perl-5.18.0" >> ~/.bashrc && \
    echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.profile && \
    echo "export PERLBREW_ROOT=~/perl5/perlbrew" >> ~/.profile && \
    echo "export PATH=~/perl5/perlbrew/bin:$PATH" >> ~/.profile && \
    echo "perlbrew use perl-5.18.0" >> ~/.profile

RUN source ~/.profile && \
    ~/perl5/perlbrew/bin/cpanm Config::Simple && \
    ~/perl5/perlbrew/bin/cpanm Array::Compare && \
    ~/perl5/perlbrew/bin/cpanm Getopt::Std && \
    ~/perl5/perlbrew/bin/cpanm Carp && \
    ~/perl5/perlbrew/bin/cpanm Carp::Assert && \
    ~/perl5/perlbrew/bin/cpanm Carp::Clan && \
    ~/perl5/perlbrew/bin/cpanm Class::Base && \
    ~/perl5/perlbrew/bin/cpanm Compress::Bzip2 && \
    ~/perl5/perlbrew/bin/cpanm Exception::Class && \
    ~/perl5/perlbrew/bin/cpanm Getopt::Simple && \
    ~/perl5/perlbrew/bin/cpanm IO::Stringy && \
    ~/perl5/perlbrew/bin/cpanm Sort::Naturally && \
    ~/perl5/perlbrew/bin/cpanm List::MoreUtils && \
    ~/perl5/perlbrew/bin/cpanm Exporter::Tiny && \
    ~/perl5/perlbrew/bin/cpanm DBI && \
    ~/perl5/perlbrew/bin/cpanm DBI::DBD && \
    ~/perl5/perlbrew/bin/cpanm DBD::mysql && \
    ~/perl5/perlbrew/bin/cpanm Class::DBI && \
    ~/perl5/perlbrew/bin/cpanm --notest --force Class::DBI::mysql

## Install bioperl and Ensembl Perl API
RUN mkdir -p ~/ensembl && \
    mkdir -p ~/ensembl/API && \
    cd ~/ensembl/API && \
    git clone -b bioperl-release-1-6-1 --depth 1 https://github.com/bioperl/bioperl-live.git && \
    git clone -b release/${ens_version} https://github.com/Ensembl/ensembl.git && \
    git clone -b release/${ens_version} https://github.com/Ensembl/ensembl-funcgen.git && \
    git clone -b release/${ens_version} https://github.com/Ensembl/ensembl-io.git && \
    echo "export PERL5LIB=~/ensembl/API/bioperl-live/:~/ensembl/API/ensembl/modules/:~/ensembl/API/ensembl-funcgen/modules/:~/ensembl/API/ensembl-io/modules/:$PERL5LIB" >> ~/.bashrc && \
    echo "export PERL5LIB=~/ensembl/API/bioperl-live/:~/ensembl/API/ensembl/modules/:~/ensembl/API/ensembl-funcgen/modules/:~/ensembl/API/ensembl-io/modules/:$PERL5LIB" >> ~/.profile

# git clone https://github.com/Ensembl/ensembl-variation.git
# git clone https://github.com/Ensembl/ensembl-compara.git

RUN apt update

## Install R
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" && \
    apt -y install r-base
RUN Rscript -e "install.packages(c('BiocManager'))" && \
    Rscript -e "BiocManager::install(c('ensembldb', 'RMariaDB'))"

RUN apt clean

## Copying the shell script that does the work
COPY scripts/create-ensdb.sh /root/
COPY scripts/create-ensdb.R /root/
RUN chmod a+x /root/create-ensdb.sh

ENTRYPOINT ["/root/create-ensdb.sh"]
CMD ["homo_sapiens"]
