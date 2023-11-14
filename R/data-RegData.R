#' Regeneration Data for Norway's Main Forest Species
#'
#' This dataset provides a regeneration look-up table for the main forest species in Norway.
#' It includes variables such as the number of trees per hectare (N), basal area (B, in m2/ha),
#' dominant height (H, in meters), and total standing volume (V, in m3/ha) at the forest age
#' when trees reach 5 cm in diameter at breast height.
#'
#' @format A data frame with 24 rows and 9 variables:
#' \describe{
#'   \item{SI_m}{Site index in meters, indicating the potential growth height of a species at the specific age of 40 years.}
#'   \item{Species}{An integer code representing the species: 1 for Norway spruce, 2 for Scots pine, 3 for broadleaves (birch).}
#'   \item{Latency_yr}{Regeneration latency time in years after harvest.}
#'   \item{Age}{Age of the forest when trees reach 5 cm in diameter at breast height.}
#'   \item{Time}{Total time elapsed from clearcut until the trees are (on average) 5 cm in diameter at breast height.}
#'   \item{H_m}{Dominant height in meters.}
#'   \item{N}{Number of trees per hectare.}
#'   \item{B_m2ha}{Basal area in square meters per hectare.}
#'   \item{V_m3ha}{Total standing volume in cubic meters per hectare.}
#' }
#' @examples
#' data(RegData)
"RegData"
