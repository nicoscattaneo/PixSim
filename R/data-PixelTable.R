#' Pixel-Level Forest Information Table
#'
#' The `PixelTable` dataset collects pixel-level forest information from forest
#' resource maps like SR16 or other similar maps used to create modern
#' remote-sensing-based Forest Management Inventories. It represents a 10x20 km
#' region in central Norway with pixel resolution of 16x16 m, and it includes
#' variables that describe the forest's age, basal area, number of trees, site
#' index, species, stand ID, standing volume, and height. For more information on
#' building this table from raster data, see \code{\link{raster2pixeltable}} in this package.
#'
#' @format A data frame with 661,521 rows and 9 variables:
#' \describe{
#'   \item{x_UTM32}{x coordinate in UTM32 format}
#'   \item{y_UTM32}{y coordinate in UTM32 format}
#'   \item{Age}{Age of the forest}
#'   \item{B_m2ha}{Basal area in square meters per hectare}
#'   \item{N}{Number of trees per hectare}
#'   \item{SI_m}{Site index}
#'   \item{Species}{Tree species, encoded as integers}
#'   \item{Stand}{Stand ID, with each unique ID representing a forest stand}
#'   \item{V_m3ha}{Standing volume in cubic meters per hectare}
#'   \item{H_m}{Dominant height in meters}
#' }
#' @source Norwegian Forest Resource Map SR16, available online at
#' \url{https://www.nibio.no/tema/skog/kart-over-skogressurser/skogressurskart-sr16?locationfilter=true}
#' @keywords datasets
"PixelTable"
