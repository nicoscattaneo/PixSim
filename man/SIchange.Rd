% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SIchange.R
\name{SIchange}
\alias{SIchange}
\title{Apply Site Index Changes to Simulated Forest Data}
\usage{
SIchange(Data, ModelsAndParameters, nSpecies, SIChangePath, TimStep)
}
\arguments{
\item{Data}{A \code{data.table} object representing a forest inventory derived from a Forest Resource map.
See \code{PixelTable} dataset in the package for table format example.}

\item{ModelsAndParameters}{A list containing functions that define how stand age is adjusted
based on SI changes. The list structure should follow the specification in the
\code{ModelsAndParameters} dataset documentation.}

\item{nSpecies}{A numeric vector specifying the species codes to simulate, corresponding to codes in \code{Data}.}

\item{SIChangePath}{The path to the file containing SI change data or a \code{data.table} object
with SI change data. If it's a path, it should point to the \code{SI_changes.fst} dataset file.}

\item{TimStep}{The current time step in the simulation for which the SI change is being applied.}
}
\value{
The function modifies \code{Data} by reference, updating the \code{Age} attribute to reflect
the applied SI changes. It returns invisibly.
}
\description{
This internal function applies changes in Site Index (SI_m) to the simulated forest data to reflect
alterations in growth potential over time. These changes in SI are translated into modifications
of the stand age using functions specified in the
\code{ModelsAndParameters} list.
}
\details{
The \code{SIchange} function is designed to be used within the \code{PixSim} function as part of the
simulation process. It reads the SI changes either from a \code{data.table} or a file, and then
updates the \code{Age} attribute of \code{Data} according to the models provided in \code{ModelsAndParameters}.
The function assumes that the \code{SI_changes.fst} dataset included in the package will be used
to provide the necessary SI changes.
}
\examples{
\dontrun{
 ## PixelTableCopy <- copy(PixelTable) # Assuming PixelTable is already initialized
 ## myModelsAndParameters <- ModelsAndParameters[[1]] # Assuming this contains age adjustment models
 ## mySpecies <- c(1, 2, 3) # Example species codes
 ## SIChangeFilePath <- system.file("extdata", "SI_changes.fst", package = "PixSim")
 ## SIchange(Data = PixelTableCopy, ModelsAndParameters = myModelsAndParameters, nSpecies = mySpecies, SIChangePath = SIChangeFilePath, TimStep = 1)
 ## Now PixelTableCopy has updated Ages based on SI changes
}



}
