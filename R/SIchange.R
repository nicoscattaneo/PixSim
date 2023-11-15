#' Apply Site Index Changes to Simulated Forest Data
#'
#' This internal function applies changes in Site Index (SI_m) to the simulated forest data to reflect
#' alterations in growth potential over time. These changes in SI are translated into modifications
#' of the stand age using functions specified in the
#' `ModelsAndParameters` list.
#'
#' @param Data A `data.table` object representing a forest inventory derived from a Forest Resource map.
#'        See `PixelTable` dataset in the package for table format example.
#' @param ModelsAndParameters A list containing functions that define how stand age is adjusted
#'        based on SI changes. The list structure should follow the specification in the
#'        `ModelsAndParameters` dataset documentation.
#' @param nSpecies A numeric vector specifying the species codes to simulate, corresponding to codes in `Data`.
#' @param SIChangePath The path to the file containing SI change data or a `data.table` object
#'        with SI change data. If it's a path, it should point to the `SI_changes.fst` dataset file.
#' @param TimStep The current time step in the simulation for which the SI change is being applied.
#'
#' @details
#' The `SIchange` function is designed to be used within the `PixSim` function as part of the
#' simulation process. It reads the SI changes either from a `data.table` or a file, and then
#' updates the `Age` attribute of `Data` according to the models provided in `ModelsAndParameters`.
#' The function assumes that the `SI_changes.fst` dataset included in the package will be used
#' to provide the necessary SI changes.
#'
#' @return The function modifies `Data` by reference, updating the `Age` attribute to reflect
#'         the applied SI changes. It returns invisibly.
#'
#' @export
#' @importFrom data.table data.table
#' @importFrom fst read_fst
#' @examples
#' \dontrun{
#'  ## PixelTableCopy <- copy(PixelTable) # Assuming PixelTable is already initialized
#'  ## myModelsAndParameters <- ModelsAndParameters[[1]] # Assuming this contains age adjustment models
#'  ## mySpecies <- c(1, 2, 3) # Example species codes
#'  ## SIChangeFilePath <- system.file("extdata", "SI_changes.fst", package = "PixSim")
#'  ## SIchange(Data = PixelTableCopy, ModelsAndParameters = myModelsAndParameters, nSpecies = mySpecies, SIChangePath = SIChangeFilePath, TimStep = 1)
#'  ## Now PixelTableCopy has updated Ages based on SI changes
#' }
SIchange <- function (Data, ModelsAndParameters, nSpecies, SIChangePath, TimStep){
    if (!inherits(ModelsAndParameters, "list")) {
      stop("ModelsAndParameters object must be a list")
    }
    for (i in seq_along(ModelsAndParameters)) {
      assign(names(ModelsAndParameters)[i], ModelsAndParameters[[i]])
    }
    Data[, `:=`(SI_m_Old, SI_m)]
    columnName <- paste0("SI_", TimStep)
    if (inherits(SIChangePath, "data.table")) {
      if (columnName %in% names(SIChangePath)) {
        Data[, `:=`(SI_m, SIChangePath[[columnName]])]
      }
      else {
        stop(paste("Column", columnName, "not found in provided data.table"))
      }
    }
    else if (is.character(SIChangePath) && file.exists(SIChangePath)) {
      Data[, `:=`(SI_m, fst::read_fst(SIChangePath, columns = columnName))]
    }
    else {
      stop("SIChangePath must be either a valid file path or a data.table")
    }
    invisible(lapply(nSpecies, function(specie) {
      P.A.1 <- ModelsAndParameters[[paste0("Params.", specie,
                                           ".AgeNew")]]
      P.A.2 <- ModelsAndParameters[[paste0("Params.", specie,
                                           ".AgeNew2")]]
      M.A.1 <- ModelsAndParameters[[paste0("Model.", specie,
                                           ".AgeNew")]]
      M.A.2 <- ModelsAndParameters[[paste0("Model.", specie,
                                           ".AgeNew2")]]

      Data[code == 1 & Species == specie, Age := {
        for (i in seq_along(P.A.1)) {
          assign(names(P.A.1)[i], P.A.1[i])
        }
        Model.A.1 <- parse(text = M.A.1)
        result1 <- eval(Model.A.1)

        for (i in seq_along(P.A.2)) {
          assign(names(P.A.2)[i], P.A.2[i])
        }
        Model.A.2 <- parse(text = M.A.2)
        result2 <- eval(Model.A.2)

        as.integer(round(result1 - result2, 0))
      }]

    }))
    Data[, `:=`(SI_m_Old, NULL)]
    }
