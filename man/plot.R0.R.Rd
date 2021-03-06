\name{plot.R0.R}
\alias{plot.R0.R}
\title{Plot the R0/Rt value along with confidence interval}
\description{Plot the R0/Rt value along with confidence interval}
\usage{\method{plot}{R0.R}(x, all = TRUE, xscale = "w", TD.split = FALSE, ...)}
\arguments{
  \item{x}{Result of est.R (class R)}
  \item{all}{Should the whole epidemic curve be shown}
  \item{xscale}{Scale to be adjusted on X axis. Can be "d" (day), "w" (week (default)), "f" (fornight), "m" (month).}
  \item{TD.split}{Parameter to force the display of both R(t) and the epidemic curve in the same window for TD method}
  \item{\dots}{Parameters passed to plot}
}
\details{For internal use. Called by plot.}
\value{Called for its side effect :
Draws all R0 or R(t) value from one estimation methods.}

\author{Pierre-Yves Boelle, Thomas Obadia}






\keyword{internal}
