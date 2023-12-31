% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PostRegFunction.R
\name{PostRegFunction}
\alias{PostRegFunction}
\title{Adjust Forest Inventory Data Post-Regeneration}
\usage{
PostRegFunction(Data, RegData)
}
\arguments{
\item{Data}{A \code{data.table} object representing the forest inventory, expected to have been previously
modified by \code{RegFunction} and growth model functions.}

\item{RegData}{A \code{data.table} with regeneration data for initializing simulation pixels,
structured as per the \code{RegData} dataset included in the package.}
}
\value{
The function modifies the \code{Data} table by reference, updating the forest inventory variables
to their correct values for the current simulation period. It returns invisibly.
}
\description{
After applying regeneration functions and growth models, this function adjusts forest inventory variables
that were initialized at times other than the exact start of the simulation. It ensures that the attributes
of the forest data (\code{Data}) reflect the correct values for the simulation's current time step.
}
\details{
The \code{PostRegFunction} is called internally within the \code{PixSim} function to adjust the forest variables
such as number of trees per hectare (N), basal area (B), dominant height (H), and total standing volume (V)
for pixels that were initialized at a time other than the start of the simulation. This adjustment accounts
for the "latency time" until the pixel enters the simulation.

The function adjusts these variables by interpolating or extrapolating their values to align with the
simulation's current time step, based on the previously simulated growth and the time since initialization.
}
\examples{
\dontrun{
 ## PixelTableCopy <- copy(PixelTable) # Assuming PixelTable is already initialized and simulated
 ## RegDataCopy <- copy(RegData) # Assuming RegData is your regeneration dataset
 ## PostRegFunction(Data = PixelTableCopy, RegData = RegDataCopy)
 ## Now PixelTableCopy has adjusted forest inventory variables
}
}
\seealso{
\code{\link{PixSim}}, \code{\link{RegFunction}}
}
