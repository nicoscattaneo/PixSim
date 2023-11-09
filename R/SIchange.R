SIchange <- function(Data, ModelsAndParameters, nSpecies, SIChangePath, TimStep) {

    if (!inherits(ModelsAndParameters, "list")) {
        stop("ModelsAndParameters object must be a list")
    }

    for (i in seq_along(ModelsAndParameters)) {
        assign(names(ModelsAndParameters)[i], ModelsAndParameters[[i]])
    }

    Data[, SI_m_Old := SI_m]

    columnName <- paste0("SI_", TimStep)

    ## Check if SIChangePath is a data.table
    if (inherits(SIChangePath, "data.table")) {
        if (columnName %in% names(SIChangePath)) {
            Data[, SI_m := SIChangePath[[columnName]]]
        } else {
            stop(paste("Column", columnName, "not found in provided data.table"))
        }
    } else if (is.character(SIChangePath) && file.exists(SIChangePath)) {
        Data[, SI_m := fst::read_fst(SIChangePath, columns = columnName)]
    } else {
        stop("SIChangePath must be either a valid file path or a data.table")
    }

    invisible(lapply(nSpecies, function(specie) {
        P.A.1 <- ModelsAndParameters[[paste0("Params.", specie, ".AgeNew")]]
        P.A.2 <- ModelsAndParameters[[paste0("Params.", specie, ".AgeNew2")]]
        M.A.1 <- ModelsAndParameters[[paste0("Model.", specie, ".AgeNew")]]
        M.A.2 <- ModelsAndParameters[[paste0("Model.", specie, ".AgeNew2")]]
        
        Data[code == 1 & Species == specie, Age := {
            for (i in seq_along(P.A.1)) {
                assign(names(P.A.1)[i], P.A.1[i])
            }
            Model.A.1 <- parse(text = M.A.1)
            eval(Model.A.1) - round({
                for (i in seq_along(P.A.2)) {
                    assign(names(P.A.2)[i], P.A.2[i])
                }
                Model.A.2 <- parse(text = M.A.2)
                eval(Model.A.2)
            }, 0)
        }]
    }))
    
    Data[, SI_m_Old := NULL]
}
