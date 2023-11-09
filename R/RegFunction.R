RegFunction <- function(Data, RegData) {
    
    if (!("Time" %in% names(Data))) {
        Data[, Time := numeric()]
    }
    
    ## Initialize inherited pixels that come from clear-cutting.
    ## Clear-cut is assumed to have occurred immediately before the start of the simulation
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
