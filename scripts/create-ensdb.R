## R code to build the EnsDb database
ENS_VERSION <- Sys.getenv("ens_version")
SPECIES <- Sys.getenv("species")
FTP_FOLDER <- Sys.getenv("ftp_folder")
DROP_FILES <- Sys.getenv("drop_files", unset = "TRUE")
DROP_FILES <- DROP_FILES != "FALSE"
message("Building EnsDb for ", SPECIES, " ensembl version ", ENS_VERSION)

if (!length(readLines("ftp://ftp.ensembl.org/robots.txt")))
    stop("Can not connect to ensembl ftp")

source(system.file("scripts/generate-EnsDBs.R", package = "ensembldb"))
createEnsDbForSpecies(ftp_folder = FTP_FOLDER, ens_version = ENS_VERSION,
                      species = SPECIES, user = "root",
                      host = "localhost", pass = "",
                      dropIntermediateFiles = DROP_FILES)
