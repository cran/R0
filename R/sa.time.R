# Name   : sa.time
# Desc   : Sensitivity analysis of reproduction ratio to varying time windows 
#          using supported estimation methods
# Date   : 2011/11/09
# Update : 2023/03/03
# Author : Boelle, Obadia
###############################################################################


#' @title
#' Sensitivity of R0 to time estimation windows
#' 
#' @description
#' Sensitivity analysis to estimate the variation of reproduction numbers 
#' according to period over which the incidence is analyzed.
#' 
#' @details
#' By varying different pairs of begin and end dates,different estimates of 
#' reproduction ratio can be analyzed.
#' 
#' 'begin' and 'end' vector must have the same length for the sensitivity 
#' analysis to run. They can be provided either as dates or numeric values, 
#' depending on the other parameters (see [check.incid()]). If some begin/end 
#' dates overlap, they are ignored, and corresponding uncomputed data are set 
#' to `NA`. 
#' 
#' Also, note that unreliable Rsquared values are achieved for very small time 
#' periods (begin ~ end). These values are not representative of the epidemic 
#' outbreak behaviour.
#' 
#' @param incid A vector of incident cases.
#' @param GT Generation time distribution from [generation.time()].
#' @param begin Vector of begin dates for the estimation of epidemic.
#' @param end Vector of end dates for estimation of the epidemic.
#' @param est.method Estimation method used for sensitivity analysis.
#' @param t Dates vector to be passed to estimation function.
#' @param date.first.obs Optional date of first observation, if t not specified.
#' @param time.step Optional. If date of first observation is specified, number of day between each incidence observation.
#' @param res If specified, will extract most of data from a `R0.R`-class contained within the `$estimate` component of a result from [estimate.R()] and run sensitivity analysis with it.
#' @param ... Parameters passed to inner functions
#' 
#' @return
#' A list with components :
#' \item{df}{data.frame object with all results from sensitivity analysis.}
#' \item{df.clean}{the same object, with NA rows removed. Used only for easy export of results.}
#' \item{mat.sen}{Matrix with values of R0 given begin (rows) and end (columns) dates.}
#' \item{begin}{A range of begin dates in epidemic.}
#' \item{end}{A range of end dates in epidemic.}
#' 
#' @export
#' 
#' @author Pierre-Yves Boelle, Thomas Obadia



# Function declaration

sa.time <- function(
    incid, 
    GT, 
    begin          = NULL, 
    end            = NULL, 
    est.method, 
    t              = NULL, 
    date.first.obs = NULL, 
    time.step      = 1, 
    res            = NULL, 
    ...
)


# Code

{
  #Warning note and integrity check
  warning("If 'begin' and 'end' overlap, cases where begin >= end are skipped.\nThese cases often return Rsquared = 1 and are thus ignored.", call. = FALSE)
  if (!is.null(res)) {
    if (!inherits(res, "R0.R")) {
      stop("Currently, sensitivity analysis from a result object only supports 'R0.R' class objects. Try using res$estimates$EG or res$estimates$ML if they are defined.")
    }
    else if ((res$method %in% c("Exponential Growth","Maximum Likelihood")) == FALSE) {
      stop("Sensitivity analysis can only be conducted on objects with method EG or ML.")
    }
    else if (res$method == "Exponential Growth") {
      est.method <- "EG"
    }
    else if (res$method == "Maximum Likelihood") {
      est.method <- "ML"
    }
    if (is.null(begin) | is.null(end)) {
      stop("Arguments \"begin\" and \"end\" must both be provided as vectors of index dates.")
    }
    
    incid <- res$epid$incid
    GT <- res$GT
  }
  
  if (is.null(begin) | is.null(end)) {
    stop("'begin' and/or 'end' is/are missing.")
  }
  
  if (length(begin) != length(end)) {
    stop("'begin' and 'end' vector must have the same length.")
  }
  if (is.null(est.method)) {
    stop("Argument est.method should be 'EG' or 'ML'")
  }
  else if ((est.method %in% c("EG","ML")) == FALSE) {
    stop("Argument est.method should be 'EG' or 'ML'")
  }
  
  
  #tmp.epid is only used to keep trace of (incidence,date) pairs, and to use
  #estimation method with correct data input
  tmp.epid <- check.incid(incid, t, date.first.obs, time.step)
  
  #All results will be stored in a matrix
  s.a <- matrix(NA, nrow=length(begin)*length(end), ncol=8)
  
  #Columns are named so that display is easy to read
  colnames(s.a) <- c("Time.period", "Begin.dates","End.dates","R", "Growth.rate", "Rsquared", "CI.lower", "CI.upper")
  
  for(i in 1:length(begin)) {
    for(j in 1:length(end)) {
      
      #Skip test if begin>=end, and correspondig cells are filled with NA in matrix
      #if ((begin[i]>=end[j]) | (end[j] == (begin[i]+1))) {
      if (tmp.epid$t[begin[i]] >= tmp.epid$t[end[j]]) {
        s.a[length(begin)*(i-1)+j,1] <- NA
        s.a[length(begin)*(i-1)+j,2] <- tmp.epid$t[begin[i]]
        s.a[length(begin)*(i-1)+j,3] <- tmp.epid$t[end[j]]
        s.a[length(begin)*(i-1)+j,4] <- NA
        s.a[length(begin)*(i-1)+j,5] <- NA
        s.a[length(begin)*(i-1)+j,6] <- NA
        s.a[length(begin)*(i-1)+j,7] <- NA
        s.a[length(begin)*(i-1)+j,8] <- NA
        next
      }
      
      #Simulation is ran according to the requested method, with each correct begin/end value
      if (est.method == "EG") {
        res <- est.R0.EG(incid, GT, begin=tmp.epid$t[begin[i]], end=tmp.epid$t[end[j]], date.first.obs=date.first.obs, t=t, time.step=time.step,...)
      }
      else if (est.method == "ML") {
        res <- est.R0.ML(incid, GT, begin=tmp.epid$t[begin[i]], end=tmp.epid$t[end[j]], date.first.obs=date.first.obs, t=t, time.step=time.step,...)
      }
      
      else {
        stop("Please enter a supported method for R0 estimation.")
      }
      s.a[length(begin)*(i-1)+j,1] <- (tmp.epid$t[end[j]] - tmp.epid$t[begin[i]])/time.step
      s.a[length(begin)*(i-1)+j,2] <- tmp.epid$t[begin[i]]
      s.a[length(begin)*(i-1)+j,3] <- tmp.epid$t[end[j]]
      s.a[length(begin)*(i-1)+j,4] <- res$R
      
      #EG method provides a growth rate (r)...
      if (est.method == "EG") {
        s.a[length(begin)*(i-1)+j,5] <- res$r
      }
      
      #but ML method doesn't
      else if (est.method == "ML") {
        s.a[length(begin)*(i-1)+j,5] <- NA
      }
      
      s.a[length(begin)*(i-1)+j,6] <- res$Rsquared
      s.a[length(begin)*(i-1)+j,7] <- res$conf.int[1]
      s.a[length(begin)*(i-1)+j,8] <- res$conf.int[2]
    }
  }
  
  df <- data.frame(s.a)
  
  #initial "matrix" s.a can't store content of different class. We re-cast dates as a proper format in data.frame df
  if (!is.numeric(tmp.epid$t)) {
    df[,2] <- as.Date(df[,2], origin="1970-01-01")
    df[,3] <- as.Date(df[,3], origin="1970-01-01")
  }
  
  #Most likely df will contain rows with only NA (begin >= end result case : no R0 value)
  df.clean <- df[!is.na(df[,4]),]
  
  #Create a matrix for color-rendering of sensitivity analysis
  mat.sen <- matrix(df$R,nrow=length(begin),ncol=length(end),dimnames=list(end,begin))
  
  
  return(structure(list(epid=tmp.epid, df=df, df.clean=df.clean, mat.sen=mat.sen, begin=begin, end=end), class="R0.S"))
  
}
