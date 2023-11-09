SetAside <- function(Data, SetAsideFile = NULL, SetAsidePercent = NULL) {
    
    ## Initialize the 'envRestr' column with zeros
    Data[, envRestr := integer()]
    Data[, envRestr := 0]
    
    if (!is.null(SetAsideFile)) {
        if (class(SetAsideFile) == "data.table") {
            tmp <- SetAsideFile[, 1]
            Data[(tmp == 1), envRestr := 1]
        } else if (file.exists(SetAsideFile)) {
            tmp <- fst::read_fst(SetAsideFile)[, 1]
            Data[(tmp == 1), envRestr := 1]
        } else {
            stop("SetAsideFile does not exist or is not a data.table.")
        }
        if (exists("tmp")) rm(tmp)
    }
    
    ## Perform operations if SetAsidePercent is provided
    if (!is.null(SetAsidePercent)) {
        Data[envRestr != 1,
             envRestr := c(2, envRestr[-1]),
             by = Stand]
        
        Data[envRestr != 1, Npxl := .N, by = .(Stand)]
        
        Data[envRestr != 1,
             Npxl := round((1:.N) / .N, 2),
             by = .(Stand)]
        
        SetAsideValue <- SetAsidePercent / 100
        Data[Npxl <= SetAsideValue, envRestr := 1]
        Data[, Npxl := NULL]
    }
}
