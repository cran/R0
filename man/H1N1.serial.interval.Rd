% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{H1N1.serial.interval}
\alias{H1N1.serial.interval}
\title{H1N1 serial interval}
\format{
A vector of unnamed numeric values.
}
\usage{
data(H1N1.serial.interval)
}
\description{
Serial interval (in its core definition, i.e. the time delay between symptom
onset between pairs of infectors and infectees), taken from traced cases of
H1N1 viruses.

Vector of values that represents the time lag between symptoms onset for pairs
of infector/infectee, for a dataset of complete traced cases. Each value
accounts for a pair of infector/infectee.
This serial interval is often substitued for the generation time distribution,
as it is easier to observe.
}
\references{
S. Cauchemez, A. Bhattarai, T.L. Marchbanks, R.P. Fagan, S. Ostroff, N.M. Ferguson, et al., Role of Social Networks in Shaping Disease Transmission During a Community Outbreak of 2009 H1N1 Pandemic Influenza, Pnas. 108 (2011) 2825-2830.
}
\keyword{datasets}
