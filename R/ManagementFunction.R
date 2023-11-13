#' Apply Forest Management within Simulation
#'
#' This internal function simulates the harvesting process during a timestep of a forest growth simulation.
#' It determines which stands can be harvested based on the regeneration period and harvests a specified
#' percentage of the total volume increase. The function prioritizes stands from most to least productive,
#' stopping once the harvest objective is reached.
#'
#' @param Data A `data.table` object representing a forest inventory derived from a Forest Resource map.
#'        See `PixelTable` dataset in the package for table format example.
#' @param Harvest A numeric value representing the percentage of the total volume increase to harvest.
#' @param PixelSize The size of each pixel in the inventory, used for total volume calculations.
#' @param nSpecies A numeric vector specifying the species codes, matching species codes in `Data`.
#' @param Save Inherited from WriteOut param in `PixSim` function.
#' @param TmpFldR Inherited from LocalFldr param in in `PixSim` function.
#' @param Round The current timestep. Internally set by the `PixSim` function.
#'
#' @details
#' The `ManagementFunction` function is intended to be called within the `PixSim` function. It reads
#' the growth increment from the simulation data and applies a harvesting rule based on the `Harvest`
#' parameter. The function adjusts the forest inventory in `Data` to reflect the harvesting by setting
#' the harvested stands' attributes to zero. It also optionally writes the harvesting results to disk.
#'
#' @return The function modifies `Data` by reference, updating the attributes to reflect the harvested
#'         volumes. It returns invisibly.
#' @importFrom data.table data.table
#' @importFrom fst write_fst
#' @examples
#' \dontrun{
#'  ## PixelTableCopy <- copy(PixelTable)
#'  ## HarvestPercent <- 10 # Example harvest percentage
#'  ## PixelSizeExample <- 16
#'  ## ManagementFunction(Data = PixelTableCopy, Harvest = HarvestPercent, PixelSize = PixelSizeExample,
#'  ##                    nSpecies = c(1, 2, 3), Save = WriteOut, TmpFldR = LocalFldr, Round = XX)
#'  ## Now PixelTableCopy has updated attributes reflecting the harvesting
#' }
ManagementFunction <- function(Data, Harvest, PixelSize,
                               nSpecies = nSpecies,
                               Save = WriteOut,
                               TmpFldR = LocalFldr,
                               Round) {

    ## Check stands that can potentially be harvested
    ## (a.k.a. stands that are not in regeneration period)
    A <- unique(Data[code == 1, ][is.na(Time) | (!is.na(Time) & Time < -2.5), Stand])
    B <- unique(Data[code == 1, ][!is.na(Time) & Time >= -2.5, Stand])
    A <- setdiff(A, B)

    if (length(A) == 0) {
        if (Save == TRUE) {
            ProjTosave2 <- data.frame(
                volumeGrowthCut = "Nothing to harvest yet",
                volumeGrowthCutPerc = paste0(Harvest, "%")
            )
            nameTosave2 <- paste0(TmpFldR, "/", "Harvest_", sprintf("%03d", Round), ".fst")
            fst::write_fst(ProjTosave2, nameTosave2, compress = 100)
            rm(ProjTosave2, nameTosave2, A, B)
        }
    } else {
        Vt1_m3 <- Data[code == 1 & Stand %in% A, sum((PixelSize * V_m3ha) / 10000)]
        Vt2_m3 <- Data[code == 1 & Stand %in% A, sum((PixelSize * V_m3ha_2) / 10000)]
        Vcut_m3 <- (Vt2_m3 - Vt1_m3) * (Harvest / 100)
        rm(Vt1_m3, Vt2_m3)

        Data[code == 1 & Stand %in% A, V_m3ha_0.5 := ((V_m3ha_2 - V_m3ha) / 2) + V_m3ha]

        ## Select pixels without environmental restrictions, if needed
        if ("envRestr" %in% names(Data)) {
            DataCut0 <- Data[code == 1 & Stand %in% A, .(Stand, V_m3ha_0.5, Species, envRestr)]
            DataCut0 <- DataCut0[envRestr == 0, ]
            DataCut0[, envRestr := NULL]
        } else {
            DataCut0 <- Data[code == 1 & Stand %in% A, .(Stand, V_m3ha_0.5, Species)]
        }

        DataCut <- DataCut0[
          , .(mVol_m3ha = mean(V_m3ha_0.5),
              TVol_m3 = mean(V_m3ha_0.5) * (PixelSize * length(V_m3ha_0.5)) / 10000),
            by = Stand
        ]
        DataCut <- DataCut[order(Stand), ]
        DataCut0 <- DataCut0[
          , mean(V_m3ha_0.5) * (PixelSize * length(V_m3ha_0.5)) / 10000,
            by = list(Stand, Species)
        ]

        DataCut0 <- dcast(DataCut0, Stand ~ Species, value.var = "V1")
        invisible(lapply(nSpecies, function(XX) {
            if (!(any(names(DataCut0) == XX))) {
                DataCut0[, (XX) := NA]
            }
        }))

        Order <- c("Stand", as.character(nSpecies))
        DataCut0 <- DataCut0[, .SD, .SDcols = Order]
        names(DataCut0)[2:ncol(DataCut0)] <- paste0("Species_", nSpecies)
        DataCut0[is.na(DataCut0)] <- 0

        specieScolumns <- paste0("Species_", nSpecies)
        Total <- rowSums(DataCut0[, ..specieScolumns])

        DataCut0[, (specieScolumns) := lapply(.SD, function(x) x / Total), .SDcols = specieScolumns]

        DataCut <- cbind(DataCut, DataCut0[, -1])
        rm(Total, specieScolumns, DataCut0)
        gc()

        DataCut <- DataCut[order(-mVol_m3ha), ]
        DataCut[, Cut := cumsum(TVol_m3)]
        DataCut[, Cut2 := as.numeric(Cut <= Vcut_m3)]

        if (DataCut[match(0, DataCut$Cut2) - 1, Cut] == Vcut_m3) {
            DataCut[, Cut2 := Cut2]
        } else {
            DataCut[match(0, DataCut$Cut2), Cut2 := 1]
        }

        DataCut[, Cut := NULL]
        setnames(DataCut, "Cut2", "Cut")
        Data[, V_m3ha_0.5 := NULL]

        ## Set to 0 the harvested pixels
        Data[
            code == 1 & envRestr != 1 & Stand %in% DataCut[Cut == 1, Stand],
            `:=` (H_m_2 = 0, N_2 = 0, B_m2ha_2 = 0, V_m3ha_2 = 0, Age_2 = 0)
        ]

        if (Save == TRUE) {
            ProjTosave2 <- data.frame(
                volumeGrowthCut = Vcut_m3,
                volumeGrowthCutPerc = paste0(Harvest, "%")
            )
            ProjTosave3 <- DataCut

            nameTosave2 <- paste0(TmpFldR, "/", "SR16Pred02_", sprintf("%03d", Round), ".fst")
            nameTosave3 <- paste0(TmpFldR, "/", "SR16Pred03_", sprintf("%03d", Round), ".fst")

            fst::write_fst(ProjTosave2, nameTosave2, compress = 100)
            fst::write_fst(ProjTosave3, nameTosave3, compress = 100)
        }
    }
}
