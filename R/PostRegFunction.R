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
