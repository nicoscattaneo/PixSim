#' Stand-level Growth Models for Norway's Main Species Groups
#'
#' This list contains growth models for predicting stand-level increments over a 5-year period
#' for Norway's main forest species groups based on the work by Maleki et al. (2022). It includes
#' models for the number of trees per hectare (N), basal area (B, m2/ha), dominant height (H, m),
#' and total standing volume (V, m3/ha).
#'
#' The species groups are:
#' 1. Norway spruce
#' 2. Scots pine
#' 3. Broadleaves (birch)
#'
#' @format A list with model equations and parameter vectors for each species group.
#' Each model is provided as an R expression string and each parameter set is a named vector.
#'
#' @details
#' The list structure for each species is as follows:
#' \describe{
#'   \item{Model.x.N}{Model for the number of trees per hectare (N).}
#'   \item{Params.x.N}{Parameters for the N model.}
#'   \item{Model.x.H}{Model for dominant height (H).}
#'   \item{Params.x.H}{Parameters for the H model.}
#'   \item{Model.x.B}{Model for basal area (B).}
#'   \item{Params.x.B}{Parameters for the B model.}
#'   \item{Model.x.V}{Model for total standing volume (V).}
#'   \item{Params.x.V}{Parameters for the V model.}
#'   \item{Model.x.AgeNew}{Model for estimating age change based SI change.}
#'   \item{Params.x.AgeNew}{Parameters for the AgeNew model.}
#' }
#' Replace 'x' with the species number (1, 2, or 3).
#'
#' Users are advised to follow the same format when adding models for additional species.
#'
#' @source
#' Maleki et al. (2022). "Stand-level growth models for long-term projections of the main species groups in Norway".
#' \url{https://www.tandfonline.com/doi/full/10.1080/02827581.2022.2056632}
#'
#' @examples
#' # Access the model and parameters for Norway spruce number of trees per hectare (N)
#' ModelsAndParameters$Model.1.N
#' ModelsAndParameters$Params.1.N
#'
#' # Access the model and parameters for Scots pine's basal area (B)
#' ModelsAndParameters$Model.2.B
#' ModelsAndParameters$Params.2.B
#'
#' # Access the model and parameters for Broadleaves' dominant height (H)
#' ModelsAndParameters$Model.3.H
#' ModelsAndParameters$Params.3.H
"ModelsAndParameters"
