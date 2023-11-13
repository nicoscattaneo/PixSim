#' Apply Regeneration Data to Initialize Pixels
#'
#' This function initializes the regeneration stage in the forest simulation by applying
#' regeneration data from a lookup table. It uses expert knowledge from the
#' `RegData` dataset to set the initial state for pixels that represent new growth following
#' clear-cutting.
#'
#' @param Data A `data.table` object representing the forest inventory to be simulated,
#'        expected to be in the same format as the `PixelTable` dataset.
#' @param RegData A `data.table` with regeneration data for initializing simulation pixels,
#'        structured as per the `RegData` dataset included in the package.
#'
#' @details
#' The `RegFunction` is intended for use within the `PixSim` function as part of a larger
#' simulation workflow. After clear-cuts,
#' the `RegFunction` uses the `RegData` dataset to set the initial conditions for forest
#' regeneration. The function matches entries in `RegData` with the corresponding pixels in
#' `Data` by site index and species.
#'
#' @return The function modifies the `Data` table by reference; therefore, it does not return
#'         anything. `Data` will have updated columns reflecting the initial state for
#'         regeneration based on the `RegData` lookup table.
#' @export
#' @importFrom data.table data.table
#' @examples
#' \dontrun{
#'   PixelTableCopy <- copy(PixelTable)
#'   RegDataCopy <- copy(RegData)
#'   RegFunction(Data = PixelTableCopy, RegData = RegDataCopy)
#'   # Now PixelTableCopy contains the initial regeneration data
#' }
#' @seealso \code{\link{PixSim}}, \code{\link[=RegData]{RegData dataset}}
RegFunction <- function(Data, RegData) {

    if (!("Time" %in% names(Data))) {
        Data[, Time := numeric()]
    }

    ## Initialize inherited pixels that come from clear-cutting.
    ## Here, clear-cut is assumed to have occurred immediately before the start of the simulation
    Data[code == 1 & is.na(Time) &
         N == 0 & B_m2ha == 0 & H_m == 0 & V_m3ha == 0 & Age == 0,
         Code := 1]
    RegData[, Code := 1]

    Data[RegData, on = .(SI_m, Species, Code), `:=`(Time = i.Time)]

    RegData[, Code := NULL]
    Data[, Code := NULL]

    ## Use a look-up table to initialize the pixels.
    ## Initialization is based on "latency time" (years) and "time to reach 5cm dbh" (years).
    Data[code == 1 & !is.na(Time), Time := Time - 5]
    Data[code == 1 & !is.na(Time) & Time < -5, Time := NA]
    Data[code == 1 & !is.na(Time) & Time < 0, Code := 1]

    RegData[, Code := 1]
    Data[RegData, on = .(SI_m, Species, Code),
         `:=`(H_m = i.H_m, N = i.N, B_m2ha = i.B_m2ha, V_m3ha = i.V_m3ha, Age = i.Age)]

    if ("CronAge" %in% names(Data)) {
        Data[RegData, on = .(SI_m, Species, Code), `:=`(CronAge = i.Age)]
    }

    RegData[, Code := NULL]
    Data[, Code := NULL]
}
