#' Stand-Level Growth Simulation
#'
#' Performs stand-level growth simulations on a `PixelTable` created from Forest Resource Map rasters.
#' Users can refer to the `raster4pixeltable` documentation for details on creating a `PixelTable`.
#' The simulation projects the growth of forest stands over a specified number of time steps.
#'
#' @param Data A `data.table` object representing a forest inventory derived from a Forest Resource map.
#'        See `PixelTable` dataset in the package for table format example.
#' @param Np An integer indicating the number of projection time steps to simulate.
#' @param nSpecies A numeric vector specifying the species codes to simulate, corresponding to codes in `Data`.
#' @param WriteOut Logical; if `TRUE`, simulation results for each time step are saved to `LocalFldr`.
#' @param LocalFldr A character string specifying the path to a local folder where results should be written,
#'        used if `WriteOut` is `TRUE`.
#' @param functions A named list of functions that define the growth models and other operations to be
#'        applied during the simulation. At minimum, should contain a function with a forest growth model.
#'        Refer to the `GrowthModels` function included in the package.
#' @param ... Additional arguments to pass to the functions within the `functions` list.
#'
#' @details
#' The `PixSim` function takes a `PixelTable`, the number of simulation periods (`Np`), the species to simulate (`nSpecies`),
#' and a list of functions (`functions`) that perform various steps in the simulation process. If `WriteOut` is `TRUE`, the
#' results of each simulation period are saved to disk at the location specified by `LocalFldr`. Extra parameters required
#' by the functions in `functions` can be passed through the `...` argument.
#'
#' @examples
#' \dontrun{
#'   PixelTableCopy <- data.table::copy(PixelTable)
#'   Functions <- list(GrowthModels = GrowthModels)
#'   myMM <- ModelsAndParameters[[1]]
#'   mySSP <- c(1, 2, 3)
#'
#'   Fold <- tempfile()
#'   unlink(Fold, recursive = TRUE)
#'   dir.create(Fold)
#'
#'   PixSim(Data = PixelTableCopy,
#'          Np = 15,
#'          nSpecies = mySSP,
#'          functions = Functions,
#'          WriteOut = TRUE,
#'          LocalFldr = Fold,
#'          ModelsAndParameters = myMM)
#'
#'   Results <- list.files(Fold, full.names = TRUE)
#'   lapply(Results, fst::read_fst, as.data.table = TRUE)
#' }
#'
#' @export
#' @importFrom data.table data.table
#' @importFrom fst write_fst read_fst
PixSim <- function(Data, Np, nSpecies, WriteOut = FALSE, LocalFldr = NULL, functions, ...) {

    Ellipsis <- list(...)

    ## Initial checks
    if (!data.table::is.data.table(Data)) {
        stop("Data must be a data.table object")
    }

    if (!is.list(functions)) {
        stop("functions should be a list")
    }

    if (!all(unique(Data$Species) %in% nSpecies)) {
        stop("Species in Data and nSpecies must be the same")
    }

    ## "code" column. Needed to skip problematic pixels
    if (!("code" %in% colnames(Data))) {
        Data[, code := 1]
    }

    ## SetAside function application
    if ("SetAside" %in% names(functions)) {
        functions$SetAside(Data = Data,
                           SetAsideFile = Ellipsis$SetAsideFile,
                           SetAsidePercent = Ellipsis$SetAsidePercent)
    }

    ## Write a copy of the initial database?
    if (WriteOut) {
        fst::write_fst(Data, paste0(LocalFldr, "/", "DataPred_000.fst"), compress = 100)
        gc()
    }

    ## Some climatic-driven SI changes are translated into modification of the stand age.
    ## Keep track of the chronological Age.
    Data[code == 1, CronAge := Age]

    ## Start simulation periods
    for (XX in 1:Np) {
        if ("RegFunction" %in% names(functions)) {
            functions$RegFunction(Data = Data, RegData = Ellipsis$RegData)
        }

        if ("SIchange" %in% names(functions)) {
            functions$SIchange(Data = Data,
                               ModelsAndParameters = Ellipsis$ModelsAndParameters,
                               nSpecies = nSpecies,
                               SIChangePath = Ellipsis$SIChangePath,
                               TimStep = XX)
        }

        ## Apply growth models
        functions$GrowthModels(Data = Data,
                               ModelsAndParameters = Ellipsis$ModelsAndParameters,
                               nSpecies = nSpecies)

        if ("PostRegFunction" %in% names(functions)) {
            functions$PostRegFunction(Data = Data, RegData = Ellipsis$RegData)
        }

        ## Apply harvest
        if ("ManagementFunction" %in% names(functions)) {
            functions$ManagementFunction(Data = Data,
                                         Harvest = Ellipsis$Harvest,
                                         PixelSize = Ellipsis$PixelSize,
                                         nSpecies,
                                         Save = WriteOut,
                                         TmpFldR = LocalFldr,
                                         Round = XX)
        }

        if (WriteOut) {
            ProjTosave <- Data[, .(H_m_2, N_2, B_m2ha_2, V_m3ha_2, CronAge_2)]
            data.table::setnames(ProjTosave,
                     old = c("H_m_2", "N_2", "B_m2ha_2", "V_m3ha_2", "CronAge_2"),
                     new = c("H_m", "N", "B_m2ha", "V_m3ha", "Age"))
            ProjTosave <- ProjTosave[, round(.SD, 2), .SDcols = 1:5]
            nameTosave <- paste0(LocalFldr, "/", "DataPred_", sprintf("%04d", XX), ".fst")
            fst::write_fst(ProjTosave, nameTosave, compress = 100)
            rm(ProjTosave, nameTosave)
            gc()
        }

        ## Reset Data to t0 before starting a new simulation period
        Data[, c("Age", "N", "H_m", "B_m2ha", "V_m3ha", "CronAge") := NULL]
        data.table::setnames(Data,
                 old = c("H_m_2", "N_2", "B_m2ha_2", "V_m3ha_2", "Age_2", "CronAge_2"),
                 new = c("H_m", "N", "B_m2ha", "V_m3ha", "Age", "CronAge"))
        gc()
    }
}
