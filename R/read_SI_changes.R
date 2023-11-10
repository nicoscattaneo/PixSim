#' Read Site Index Changes Data
#'
#' This function reads the `SI_changes.fst` file, which contains site index changes
#' for Norway's main forest species. These changes occur every five years from 2021 onwards
#' and match the coordinates in the `PixelTable` dataset. The data includes site index
#' values corresponding to various years, computed after Antón-Fernández et al. (2016)
#' "Climate-sensitive site index models for Norway"
#' \url{https://doi.org/10.1139/cjfr-2015-0155}
#'
#' The dataset is expected to be used in conjunction with `PixelTable` as it has the same
#' number of rows and the coordinates are aligned. Each column `SI_x` represents the site
#' index for a specific 5-year interval.
#'
#' @return A `data.table` object with the site index changes data.
#' @importFrom fst read_fst
#' @importFrom data.table data.table
#' @export
#' @examples
#' # To read the SI_changes data as a data.table:
#' si_changes <- read_SI_changes()
#' # Now si_changes is a data.table object that can be used for analysis
#' head(si_changes)
read_SI_changes <- function() {
  data_path <- system.file("extdata", "SI_changes.fst", package = "PixSim")
  if (file.exists(data_path)) {
    data <- fst::read_fst(data_path, as.data.table = TRUE)
  } else {
    stop("Data file not found!")
  }
  return(data)
}
