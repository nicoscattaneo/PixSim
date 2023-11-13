
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

<img src="inst/extdata/logo.png" align="right" width="20%" />

# PixSim

## Overview

Work in progress.

## Installation

You can install the development version of PixSim from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("nicoscattaneo/PixSim")
```

## Basic usage

### Example 1

Simulate 15 years of forest growth for a 10x20 km region in central
Norway using the growth models of Maleki et al. (2022). The simulation
is conducted in 5-year intervals, with the results of each time step
saved locally for further analysis. For detailed model information,
refer to the publication: Maleki et al. 2022, DOI:
\[<https://doi.org/10.1080/02827581.2022.2056632>\].”

``` r
library("PixSim")

## See below in the Basic usage - Pixeltable section to learn 
## how to create a PixelTable from forest resource maps.
PixelTableCopy <- data.table::copy(PixelTable)

## Here we use a function that implement stand-level 
## growth models of the main species groups in Norway
Functions <- list(GrowthModels = GrowthModels)

## "GrowthModels" function needs equations and parameters to be specified.
args(GrowthModels)
#> function (Data, ModelsAndParameters, nSpecies) 
#> NULL
myMM <- ModelsAndParameters[[1]]

## Species codes
mySSP <- c(1, 2, 3)

## A local folder where simulation results should be written.
Fold <- tempfile()
dir.create(Fold)

PixSim(Data = PixelTableCopy,
       Np = 3, ## 3 5-year projections
       nSpecies = mySSP,
       functions = Functions,
       WriteOut = TRUE,
       LocalFldr = Fold,
       ModelsAndParameters = myMM)

## Check the results
Results <- list.files(Fold, full.names = TRUE)
lapply(Results, fst::read_fst, as.data.table = TRUE, from = 1, to = 5)
#> [[1]]
#>    x_UTM32 y_UTM32 Age B_m2ha   N SI_m Species   Stand V_m3ha  H_m code
#> 1:  664232 6748520  71     20 514   14       2 1093264    170 19.3    1
#> 2:  664232 6748536  65     21 578   14       2 1093264    175 18.4    1
#> 3:  664232 6748552  82     19 436   14       2 1093264    172 20.9    1
#> 4:  664232 6748568  85     25 596   14       2 1093264    241 21.5    1
#> 5:  664232 6748584  91     24 528   14       2 1093264    224 22.2    1
#> 
#> [[2]]
#>      H_m      N B_m2ha V_m3ha Age
#> 1: 20.07 496.68  21.63 186.72  76
#> 2: 19.25 559.13  22.92 194.03  70
#> 3: 21.55 420.64  20.26 185.66  87
#> 4: 22.12 574.80  26.44 257.32  90
#> 5: 22.77 508.89  25.25 238.51  96
#> 
#> [[3]]
#>      H_m      N B_m2ha V_m3ha Age
#> 1: 20.78 479.58  23.20 203.28  81
#> 2: 20.03 540.39  24.75 212.97  75
#> 3: 22.15 405.59  21.46 199.07  92
#> 4: 22.70 554.05  27.81 273.23  95
#> 5: 23.30 490.22  26.44 252.62 101
#> 
#> [[4]]
#>      H_m      N B_m2ha V_m3ha Age
#> 1: 21.44 462.75  24.68 219.56  86
#> 2: 20.75 521.85  26.50 231.68  80
#> 3: 22.71 390.87  22.60 212.15  97
#> 4: 23.24 533.78  29.10 288.68 100
#> 5: 23.79 472.04  27.57 266.30 106
```

### Example 2

Work in progress.

``` r
## summary()
```

### Example 3

Work in progress.
