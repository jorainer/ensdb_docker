# Docker image to create EnsDb databases from Ensembl

This repository defines a docker image that can be used to create an `EnsDb`
SQLite database for a specified species.

The docker image contains the required software including the Perl API and
R. A different docker image will be defined for each release of the Ensembl Perl
API (and hence for each Ensembl release).

By launching the docker image, the scripts will first download and install a
local copy of the selected species' Ensembl database and then use the Perl API
to extract the relevant annotations to store them into a SQLite database in
`EnsDb` format.

The local host path where the final SQLite database should be stored to needs to
be specified using the `-v` parameter, mapping the local (existing!) directory
to the guest (docker) internal */ensdb_dir* directory.

## Configuration/settings

The Ensembl version is defined through the tag of the docker image,
e.g. *jorainer/ensdb_docker:release_113* will create a database with annotations
from Ensembl release 113.

The path to store the generated needs to be configured by mapping the respective
(local) folder to the */ensdb_dir* docker-internal directory.

The species can be defined with the first parameter passed to the docker
command. This **has** to be the official name of the species, all in lower case,
i.e., *mus_musculus* for mouse, *homo_sapiens* for human etc. It defaults to
*homo_sapiens*.

## Example

To create an `EnsDb` SQLite database file for *c elegans* and Ensembl release
113 use:

```
docker run -v /tmp:/ensdb_dir jorainer/ensdb_docker:release_113 caenorhabditis_elegans
```

Where `-v /tmp:/ensdb_dir` defines the path where the resulting SQLite file will
be stored to (i.e., to a directory */tmp*).

To create an `EnsDb` for species provided through
[ensemblgenomes](https://ensemblgenomes.org/) the base ftp server url containing
the respective annotation database dumps needs to be specified. Note also that
Ensemblgenomes and Ensembl use different release version numbers. The command
below creates an `EnsDb` for the fungus *Aspergillus nidulans*. Note also the
trailing */* for the FTP server directory.

```
docker run -v /tmp:/ensdb_dir jorainer/ensdb_docker:release_113
aspergillus_nidulans ftp://ftp.ensemblgenomes.org/pub/release-60/fungi/mysql/
```
