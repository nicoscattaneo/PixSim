#' @name raster2pixeltable
#' @title Norwegian Forest Resource Rasters
#' @description
#' Raster files describing various forest resource variables in a 10x20 km region
#' in central Norway, sourced from the Norwegian Forest Resource Map SR16.
#' These files are intended to be used to construct the `PixelTable` for the PixSim package.
#' The pixel resolution is 16x16 m, and the coordinate reference system is UTM32.
#'
#' The following raster files are included:
#' \itemize{
#'   \item \code{Age.tif}: Forest age.
#'   \item \code{H_dm.tif}: Forest dominant height in decimeters.
#'   \item \code{SI_m.tif}: Site index.
#'   \item \code{Stand.tif}: Pixel ID where each unique ID represents a forest stand.
#'   \item \code{B_m2ha.tif}: Forest basal area in square meters per hectare.
#'   \item \code{N.tif}: Number of trees per hectare.
#'   \item \code{Species.tif}: Tree species.
#'   \item \code{V_m3ha.tif}: Standing volume in cubic meters per hectare.
#' }
#'
#' Data source: \url{https://kilden.nibio.no/}
#' @export
#' @examples
#' Dir <- system.file("extdata", package = "PixSim")
#' Files <- list.files(Dir, full.names = TRUE, pattern = "\\.tif$")
#' Names <- sapply(strsplit(basename(Files), "\\."), `[`, 1)
#' # The following is an illustrative example and is not intended to be run as is.
#' \dontrun{
#' # Example code to read and plot the Site Index raster
#' # Requires the 'terra' package, which is suggested but not required
#' library(terra)
#' SI_raster <- rast(file.path(Dir, "SI_m.tif"))
#' plot(SI_raster)
#'
#' # Illustrative example to construct PixelTable from rasters
#' Files <- lapply(Files, function(XX){
#'   as.data.frame(rast(XX), xy = TRUE)[, 1:3]
#' })
#' Files <- Reduce(function(...) merge(..., all = FALSE), Files)
#' names(Files) <- c("x_UTM32", "y_UTM32", Names)
#' Files$H_m <- Files$H_dm * 0.1
#' Files$H_dm <- NULL
#' head(Files)
#' }
raster2pixeltable <- function() {
  Dir <- system.file("extdata", package = "PixSim")
  Files <- list.files(Dir, full.names = TRUE, pattern = "\\.tif$")
  Names <- sapply(strsplit(basename(Files), "\\."), `[`, 1)
  return(list(Names = Names, Paths = Files))
}
