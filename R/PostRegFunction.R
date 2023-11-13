#' Adjust Forest Inventory Data Post-Regeneration
#'
#' After applying regeneration functions and growth models, this function adjusts forest inventory variables
#' that were initialized at times other than the exact start of the simulation. It ensures that the attributes
#' of the forest data (`Data`) reflect the correct values for the simulation's current time step.
#'
#' @param Data A `data.table` object representing the forest inventory, expected to have been previously
#'        modified by `RegFunction` and growth model functions.
#' @param RegData A `data.table` with regeneration data for initializing simulation pixels,
#'        structured as per the `RegData` dataset included in the package.
#'
#' @details
#' The `PostRegFunction` is called internally within the `PixSim` function to adjust the forest variables
#' such as number of trees per hectare (N), basal area (B), dominant height (H), and total standing volume (V)
#' for pixels that were initialized at a time other than the start of the simulation. This adjustment accounts
#' for the "latency time" until the pixel enters the simulation.
#'
#' The function adjusts these variables by interpolating or extrapolating their values to align with the
#' simulation's current time step, based on the previously simulated growth and the time since initialization.
#'
#' @return The function modifies the `Data` table by reference, updating the forest inventory variables
#'         to their correct values for the current simulation period. It returns invisibly.
#' @export
#' @importFrom data.table data.table
#' @examples
#' \dontrun{
#'  ## PixelTableCopy <- copy(PixelTable) # Assuming PixelTable is already initialized and simulated
#'  ## RegDataCopy <- copy(RegData) # Assuming RegData is your regeneration dataset
#'  ## PostRegFunction(Data = PixelTableCopy, RegData = RegDataCopy)
#'  ## Now PixelTableCopy has adjusted forest inventory variables
#' }
#' @seealso \code{\link{PixSim}}, \code{\link{RegFunction}}
PostRegFunction <- function(Data, RegData) {

    ## Set as 0 all pixels in waiting time
    if ("CronAge_2" %in% names(Data)) {
        Data[(!is.na(Time) & Time >= 0), CronAge_2 := 0]
    }

    Data[code == 1 & (!is.na(Time) & Time >= 0),
         `:=`(H_m_2 = 0,
              N_2 = 0,
              B_m2ha_2 = 0,
              V_m3ha_2 = 0,
              Age_2 = 0)]

    ## Fit in time
    Data[code == 1 & (!is.na(Time) & Time < 0),
         `:=`(
             H_m_2 = H_m_2 - (H_m_2 - H_m) * ((5 + Time) / 5),
             N_2 = N_2 - (N_2 - N) * ((5 + Time) / 5),
             B_m2ha_2 = B_m2ha_2 - (B_m2ha_2 - B_m2ha) * ((5 + Time) / 5),
             V_m3ha_2 = V_m3ha_2 - (V_m3ha_2 - V_m3ha) * ((5 + Time) / 5),
             Age_2 = Age_2 - (Age_2 - Age) * ((5 + Time) / 5)
         )]

    if ("CronAge_2" %in% names(Data)) {
        Data[(!is.na(Time) & Time < 0),
             CronAge_2 := CronAge_2 - (CronAge_2 - CronAge) * ((5 + Time) / 5)]
    }
}
