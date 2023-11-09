PixSim <- function(Data, Np, nSpecies, WriteOut = FALSE, LocalFldr = NULL, functions, ...) {

    Ellipsis <- list(...)
    
    ## Initial checks
    if (!is.data.table(Data)) {
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
            setnames(ProjTosave, 
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
        setnames(Data,
                 old = c("H_m_2", "N_2", "B_m2ha_2", "V_m3ha_2", "Age_2", "CronAge_2"),
                 new = c("H_m", "N", "B_m2ha", "V_m3ha", "Age", "CronAge"))
        gc()
    }
}
