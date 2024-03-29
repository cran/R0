# Name   : est.GT
# Desc   : Computes the best fitting generation time distribution with provided
#          dates of onset
# Date   : 2012/01/26
# Update : 2023/03/01
# Author : Boelle, Obadia
###############################################################################


#' @title
#' Estimate generation time distribution
#' 
#' @description
#' Find the best-fitting generation time distribution from a series of serial 
#' interval.
#' 
#' @details
#' Generation Time (GT) distribution can be estimated by two inputs methods. 
#' User can either provide two vectors of dates or a unique vector of reported 
#' serial intervals. If two vectors are provided, both `*.onset.dates` vectors 
#' should have the same length. The i-th element is the onset date for individual 
#' i. This implies that infector k (symptoms on day `infector.onset.dates[k]`) 
#' infected infectee k (symptoms on day `infectee.onset.dates[k]`). If only 
#' `serial.interval` is provided, each value is assumed to be the time elapsed 
#' between each pair of infector and infectee (i.e. the difference between the 
#' two `*.onset.dates` vectors).
#' 
#' When `request.plot` is set to `TRUE`, a graphical output provides standardized 
#' histogram of observed data along with the best-fitting adjusted model.
#' 
#' @param infector.onset.dates Vector of dates for infector symptoms onset.
#' @param infectee.onset.dates Vector of dates for infectee symptoms onset.
#' @param serial.interval Vector of reported serial interval.
#' @param request.plot Boolean. Should data adjustment be displayed at the end?
#' @param ... Parameters passed to other functions (useful for hidden parameters of [generation.time()])
#' 
#' @return
#' A object of class `R0.GT` that complies with [generation.time()] distribution 
#' requirements of the R0 package.
#' 
#' @importFrom MASS fitdistr
#' @importFrom stats dgamma dlnorm dweibull density
#' @importFrom graphics curv hist
#' 
#' @export
#' 
#' @example tests/est.GT.R
#' 
#' @author Pierre-Yves Boelle, Thomas Obadia



# Function declaration

est.GT <- function(
    infector.onset.dates = NULL, 
    infectee.onset.dates = NULL, 
    serial.interval      = NULL, 
    request.plot         = FALSE, 
    ...
)
  
  
  # Code
  
{
  # Data integrity checks
  # 1- Vector dimension
  if ((is.null(infector.onset.dates) | is.null(infectee.onset.dates)) && is.null(serial.interval)) {
    stop("Please provide either 'serial.interval' alone or both 'infector.onset.dates' and 'infectee.onset.dates'.")
  }
  
  if (is.null(serial.interval)) {
    if (length(infector.onset.dates) != length(infectee.onset.dates)) {
      stop("onset.dates vectors should have the same length.")
    }
    nb.obs <- length(infector.onset.dates)
    
    # 2- Content class
    if (!identical(class(infector.onset.dates), class(infector.onset.dates))) {
      stop("onset.dates vector should be of the same class.")
      # From now on, they are assumed to be of same class
    }
    
    
    if (is.character(infector.onset.dates)) {
      infector.onset.dates <- as.Date(infector.onset.dates)
      infectee.onset.dates <- as.Date(infectee.onset.dates)
    }
    
    # 3- Improper data
    else if (!is.numeric(infector.onset.dates) & !inherits(infector.onset.dates, "Date")) {
      stop("onset.dates vector does not contain a compatible format format (numeric, integer, character, Date)")
    }
    
    serial.interval <- infectee.onset.dates - infector.onset.dates
  }
  
  # 4- Negative serial interval value
  if (any(serial.interval < 0)) {
    stop(paste("Infectee symptom onset should always be after infector onset (see index:", paste(which(serial.interval < 0), collapse = ", "), ").\n"))
  }
  
  
  # Computing Generation Time for each pair of infector/infectee
  
  #If date of onset is identical, then we assume t1 follows a uniform distribution on [0;1]
  #and t2 follows a uniform distribution on [t1;1]. Hence, E(t2-t1) = t1/2
  serial.interval[serial.interval == 0] <- 1/2
  
  
  # Finding best fitting distribution. This uses code from package MASS 
  # (Venables, W. N. & Ripley, B. D. (2002) Modern Applied Statistics with S. Fourth Edition. Springer, New York. ISBN 0-387-95457-0)
  fit.gamma <- try(fitdistr(serial.interval,"gamma"))
  if (inherits(fit.gamma,  "try-error")) {
    fit.gamma$loglik <- NA
  }
  
  fit.weib <- try(fitdistr(serial.interval,"weibull"))
  if (inherits(fit.weib, "try-error")) {
    fit.weib$loglik <- NA
  }
  
  fit.lognorm <- try(fitdistr(serial.interval,"log-normal"))
  if (inherits(fit.lognorm, "try-error")) {
    fit.lognorm$loglik <- NA
  }
  
  fit.type <- c("gamma", "weibull", "lognormal")
  distribution.type <- fit.type[which.max(c(fit.gamma$loglik, fit.weib$loglik, fit.lognorm$loglik))]
  
  
  # Computing mean and standard deviation to use with generation.time function
  # At the same time, if request.plot is enabled, graphical output is generated
  # 
  # Trick to avoid a R CMD CHECK saying "no visible binding for global variable x"
  # This is caused by calls to dgamma(), dweibull() and dlnorm()
  x <- NULL
  rm(x)
  
  if (distribution.type == "gamma") {
    shape <- fit.gamma$estimate[1]
    rate  <- fit.gamma$estimate[2]
    
    mean <- shape/rate
    sd   <- sqrt(shape)/rate
    
    if (request.plot) {
      hist(serial.interval, 
           prob = TRUE, 
           col  = "deepskyblue", 
           xlim = c(0, max(serial.interval)), 
           ylim = c(0, (max(density(serial.interval)$y)) + 0.1), 
           xlab = "Serial Interval", 
           ylab = "PDF", 
           main = "Serial Interval and Generation Time density")
      curve(dgamma(x, shape = shape, rate = rate), add = TRUE, col = "red")
    }
  }
  else if (distribution.type == "weibull") {
    shape <- fit.weib$estimate[1]
    scale <- fit.weib$estimate[2]
    
    mean <- scale * exp(lgamma(1 + 1/shape))
    sd   <- sqrt(scale^2 * (exp(lgamma(1 + 2/shape)) - (exp(lgamma(1 + 1/shape)))^2))
    
    if (request.plot) {
      hist(serial.interval, 
           prob = TRUE, 
           col  = "deepskyblue", 
           xlim = c(0,max(serial.interval)), 
           ylim = c(0,(max(density(serial.interval)$y)) + 0.1), 
           xlab = "Serial Interval", 
           ylab = "PDF", 
           main = "Serial Interval and Generation Time density")
      curve(dweibull(x, shape = shape, scale = scale), add = TRUE, col = "red")
    }
  }
  else if (distribution.type == "lognormal") {
    meanlog <- fit.lognorm$estimate[1]
    sdlog   <- fit.lognorm$estimate[2]
    
    mean <- exp(1/2 * sdlog^2 + meanlog)
    sd   <- sqrt(exp(2 * meanlog + sdlog^2) * (exp(sdlog^2) - 1))
    
    if (request.plot) {
      hist(serial.interval, 
           prob = TRUE, 
           col  = "deepskyblue", 
           xlim = c(0,max(serial.interval)), 
           ylim = c(0,(max(density(serial.interval)$y)) + 0.1), 
           xlab = "Serial Interval", 
           ylab = "PDF", 
           main = "Serial Interval and Generation Time density")
      curve(dlnorm(x, meanlog = meanlog, sdlog = sdlog), add = TRUE, col = "red")
    }
  }
  
  # Creating adapted generation time distribution with best-fitting parameters
  gt.distrib <- generation.time(type = distribution.type, val = c(mean, sd), ...)
  cat("Best fitting GT distribution is a", distribution.type, "distribution with mean =", mean, "and sd =", sd, ".\n")
  
  return(gt.distrib)
}
