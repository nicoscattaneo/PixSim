#' Set Aside Pixels for Environmental Considerations
#'
#' This function marks certain pixels in the forest inventory data table (`Data`) to be set aside from forest management,
#' which can be useful for preserving areas with environmental restrictions.
#'
#' @param Data A `data.table` object representing the forest inventory, where certain pixels will be marked as restricted.
#' @param SetAsideFile A file path or a `data.table` object with a single column, aligned with `Data`, that indicates
#'        which pixels to set aside with 1 (cannot be harvested) and 0 (can be harvested).
#' @param SetAsidePercent A numeric value representing the percentage of pixels within each forest stand to set aside.
#'
#' @details
#' The function can take either a `SetAsideFile` and/or `SetAsidePercent` to determine which pixels to set aside. If a
#' `SetAsideFile` is provided, the function reads the file and marks the pixels accordingly. If `SetAsidePercent` is given,
#' it calculates the number of pixels to set aside within each stand based on the percentage. The pixels are then marked
#' with an `envRestr` flag in the `Data` table, where a value of 1 indicates a pixel set aside.
#'
#' @return The function modifies `Data` by reference, adding an `envRestr` column that marks set-aside pixels.
#'         It returns invisibly.
#' @export
#' @importFrom data.table data.table
#' @importFrom fst read_fst
#' @examples
#' \dontrun{
#'   ## Assuming `Data` is your forest inventory data.table
#'   ## Make a `SetAsideFile` file by labeling 20% of the pixels in the forest inventory data:
#'
#'   # library("data.table")
#'   # SetAsidePxls <- data.table(toSetAside = rep(0, nrow(Data)))
#'   # SetAsidePxls[sample(1:nrow(SetAsidePxls), nrow(SetAsidePxls) * 0.20), toSetAside := 1]
#'   # fst::save_fst(SetAsidePxls, "SetAsideFile.fst")
#'
#'   SetAside(Data, SetAsideFile = "SetAsideFile.fst")
#' }
#' @seealso \code{\link{PixSim}}
SetAside <- function(Data, SetAsideFile = NULL, SetAsidePercent = NULL) {

    Data[, `:=`(envRestr, integer())]
    Data[, `:=`(envRestr, 0)]
    if (!is.null(SetAsideFile)) {
      if (class(SetAsideFile) == "data.table") {
        tmp <- SetAsideFile[, 1]
        Data[(tmp == 1), `:=`(envRestr, 1)]
      }
      else if (file.exists(SetAsideFile)) {
        tmp <- fst::read_fst(SetAsideFile)[, 1]
        Data[(tmp == 1), `:=`(envRestr, 1)]
      }
      else {
        stop("SetAsideFile does not exist or is not a data.table.")
      }
      if (exists("tmp"))
        rm(tmp)
    }
    if (!is.null(SetAsidePercent)) {
      Data[envRestr != 1, `:=`(envRestr, c(2, envRestr[-1])),
           by = Stand]
      Data[envRestr != 1, `:=`(Npxl, .N), by = .(Stand)]
      Data[, Npxl := as.numeric(Npxl)]
      Data[envRestr != 1, `:=`(Npxl, round((1:.N)/.N, 2)),
           by = .(Stand)]
      SetAsideValue <- SetAsidePercent/100
      Data[Npxl <= SetAsideValue, `:=`(envRestr, 1)]
      Data[, `:=`(Npxl, NULL)]
    }
}
