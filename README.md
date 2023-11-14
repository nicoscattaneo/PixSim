
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
Norway using stand-level growth models of the main species groups in
Norway. The simulation is conducted in 5-year intervals, with the
results of each time step saved locally for further analysis. For
detailed model information, see [Maleki et
al. 2022](https://doi.org/10.1080/02827581.2022.2056632).

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
## Results <- list.files(Fold, full.names = TRUE)
## lapply(Results, fst::read_fst, as.data.table = TRUE, from = 1, to = 5)
```

### Example 2

Work in progress.

``` r
## summary()
```

### Example 3

Work in progress.
