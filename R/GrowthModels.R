#' Apply Stand-level Growth Models from Maleki et al. (2022)
#'
#' Applies growth models to a `data.table` of forest inventory data, specifically using the
#' models developed by Maleki et al. (2022) for predicting stand-level increments over a
#' 5-year period. The `ModelsAndParameters` list should contain the models and parameters
#' as described in the cited study.
#'
#' @param Data A `data.table` object representing the forest inventory to which the
#'        Maleki et al. (2022) growth models will be applied.
#' @param ModelsAndParameters A list structured according to the `ModelsAndParameters`
#'        dataset documentation, containing growth models and parameters from Maleki et al. (2022).
#' @param nSpecies A numeric vector specifying the species codes for which the growth models
#'        should be applied, corresponding to species codes in `Data`.
#'
#' @details
#' The function iterates over the species specified in `nSpecies`, applying the corresponding
#' growth models from the `ModelsAndParameters` list to project the number of trees per hectare (N),
#' basal area (B), dominant height (H), and total standing volume (V) for each species group. These
#' models are based on the methodologies outlined in Maleki et al. (2022) and are intended for use
#' with Norwegian forest species groups.
#'
#' @return Invisibly returns the modified `Data` table with updated growth projections.
#' @export
#' @importFrom data.table data.table
#' @examples
#' \dontrun{
#' ## Assuming `Data` is your forest inventory data.table, `myMP` contains
#' ## the models and parameters, and `mySSP` is the species vector:
#' ## GrowthModels(Data = Data, ModelsAndParameters = myMP, nSpecies = mySSP)
#' }
#'
#' @seealso \code{\link{PixSim}}, \code{\link[=ModelsAndParameters]{ModelsAndParameters dataset}}
#' @references
#' Maleki et al. (2022). "Stand-level growth models for long-term projections of the main species groups in Norway".
#' \emph{Scandinavian Journal of Forest Research}, 37(1), 1-12.
#' \url{https://doi.org/10.1080/02827581.2022.2056632}
GrowthModels <- function(Data, ModelsAndParameters, nSpecies) {

    if (!inherits(ModelsAndParameters, "list")) {
        stop("ModelsAndParameters object must be a list")
    }

    for (i in seq_along(ModelsAndParameters)) {
        assign(names(ModelsAndParameters)[i], ModelsAndParameters[[i]])
    }

    invisible(
        lapply(nSpecies, function(specie) {
            Data[code == 1 & Species == specie, Age_2 := Age + 5]
            Data[code == 1 & Species == specie, CronAge_2 := CronAge + 5]

            N.P <- paste0("Params.", specie, ".N")
            N.M <- paste0("Model.", specie, ".N")
            Data[code == 1 & Species == specie, N_2 := {
                for (i in seq_along(ModelsAndParameters[[N.P]])) {
                    assign(names(ModelsAndParameters[[N.P]])[i], ModelsAndParameters[[N.P]][i])
                }
                Model.N <- parse(text = ModelsAndParameters[[N.M]])
                eval(Model.N)
            }]

            H.P <- paste0("Params.", specie, ".H")
            H.M <- paste0("Model.", specie, ".H")
            Data[code == 1 & Species == specie, H_m_2 := {
                for (i in seq_along(ModelsAndParameters[[H.P]])) {
                    assign(names(ModelsAndParameters[[H.P]])[i], ModelsAndParameters[[H.P]][i])
                }
                Model.H <- parse(text = ModelsAndParameters[[H.M]])
                eval(Model.H)
            }]

            B.P <- paste0("Params.", specie, ".B")
            B.M <- paste0("Model.", specie, ".B")
            Data[code == 1 & Species == specie, B_m2ha_2 := {
                for (i in seq_along(ModelsAndParameters[[B.P]])) {
                    assign(names(ModelsAndParameters[[B.P]])[i], ModelsAndParameters[[B.P]][i])
                }
                Model.B <- parse(text = ModelsAndParameters[[B.M]])
                eval(Model.B)
            }]

            V.P <- paste0("Params.", specie, ".V")
            V.M <- paste0("Model.", specie, ".V")
            Data[code == 1 & Species == specie, V_m3ha_2 := V_m3ha + {
                for (i in seq_along(ModelsAndParameters[[V.P]])) {
                    assign(names(ModelsAndParameters[[V.P]])[i], ModelsAndParameters[[V.P]][i])
                }
                Model.V <- parse(text = ModelsAndParameters[[V.M]])
                eval(Model.V)
            }]
        })
    )

    ## Skip problematic pixels
    Data[is.na(Age_2) | Age_2 < 0, code := 2]
    Data[is.na(N_2) | N_2 < 0, code := 2]
    Data[is.na(H_m_2) | H_m_2 < 0, code := 2]
    Data[is.na(B_m2ha_2) | B_m2ha_2 < 0, code := 2]
    Data[is.na(V_m3ha_2) | V_m3ha_2 < 0, code := 2]
}
