## R code to build the EnsDb database
EV <- Sys.getenv("ens_version")
SP <- Sys.getenv("species")
message("Building EnsDb for ", SP, " ensembl version ", EV)

if (!length(readLines("ftp://ftp.ensembl.org/robots.txt")))
    stop("Can not connect to ensembl ftp")

source(system.file("scripts/generate-EnsDBs.R", package = "ensembldb"))
createEnsDbForSpecies(ens_version = EV, species = SP,
                      user = "root", host = "localhost", pass = "")
