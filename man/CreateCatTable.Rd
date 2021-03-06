% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CreateCatTable.R
\name{CreateCatTable}
\alias{CreateCatTable}
\title{Create an object summarizing categorical variables}
\usage{
CreateCatTable(
  vars,
  strata,
  data,
  includeNA = FALSE,
  test = TRUE,
  testApprox = chisq.test,
  argsApprox = list(correct = TRUE),
  testExact = fisher.test,
  argsExact = list(workspace = 2 * 10^5),
  smd = TRUE,
  addOverall = FALSE
)
}
\arguments{
\item{vars}{Variable(s) to be summarized given as a character vector.}

\item{strata}{Stratifying (grouping) variable name(s) given as a character vector. If omitted, the overall results are returned.}

\item{data}{A data frame in which these variables exist. All variables (both vars and strata) must be in this data frame.}

\item{includeNA}{If TRUE, NA is handled as a regular factor level rather than missing. NA is shown as the last factor level in the table. Only effective for categorical variables.}

\item{test}{If TRUE, as in the default and there are more than two groups, groupwise comparisons are performed. Both tests that require the large sample approximation and exact tests are performed. Either one of the result can be obtained from the print method.}

\item{testApprox}{A function used to perform the large sample approximation based tests. The default is \code{chisq.test}. This is not recommended when some of the cell have small counts like fewer than 5.}

\item{argsApprox}{A named list of arguments passed to the function specified in testApprox. The default is \code{list(correct = TRUE)}, which turns on the continuity correction for \code{chisq.test}.}

\item{testExact}{A function used to perform the exact tests. The default is \code{fisher.test}. If the cells have large numbers, it will fail because of memory limitation. In this situation, the large sample approximation based should suffice.}

\item{argsExact}{A named list of arguments passed to the function specified in testExact. The default is \code{list(workspace = 2*10^5)}, which specifies the memory space allocated for \code{fisher.test}.}

\item{smd}{If TRUE, as in the default and there are more than two groups, standardized mean differences for all pairwise comparisons are calculated.}

\item{addOverall}{(optional, only used if strata are supplied) Adds an overall column to the table. Smd and p-value calculations are performed using only the stratifed clolumns.}
}
\value{
An object of class \code{CatTable}.
}
\description{
Create an object summarizing categorical variables optionally stratifying by one or more startifying variables and performing statistical tests. Usually, \code{\link{CreateTableOne}} should be used as the universal frontend for both continuous and categorical data.
}
\examples{

## Load
library(tableone)

## Load Mayo Clinic Primary Biliary Cirrhosis Data
library(survival)
data(pbc)
## Check variables
head(pbc)

## Create an overall table for categorical variables
catVars <- c("status","ascites","hepato","spiders","edema","stage")
catTableOverall <- CreateCatTable(vars = catVars, data = pbc)

## Simply typing the object name will invoke the print.CatTable method,
## which will show the sample size, frequencies and percentages.
## For 2-level variables, only the higher level is shown for simplicity
## unless the variables are specified in the cramVars argument.
catTableOverall

## If you need to show both levels for some 2-level factors, use cramVars
print(catTableOverall, cramVars = "hepato")

## Use the showAllLevels argument to see all levels for all variables.
print(catTableOverall, showAllLevels = TRUE)

## You can choose form frequencies ("f") and/or percentages ("p") or both.
## "fp" frequency (percentage) is the default. Row names change accordingly.
print(catTableOverall, format = "f")
print(catTableOverall, format = "p")

## To further examine the variables, use the summary.CatTable method,
## which will show more details.
summary(catTableOverall)

## The table can be stratified by one or more variables
catTableBySexTrt <- CreateCatTable(vars = catVars,
                                   strata = c("sex","trt"), data = pbc)

## print now includes p-values which are by default calculated by chisq.test.
## It is formatted at the decimal place specified by the pDigits argument
## (3 by default). It is formatted like <0.001 if very small.
catTableBySexTrt

## The exact argument toggles the p-values to the exact test result from
## fisher.test. It will show which ones are from exact tests.
print(catTableBySexTrt, exact = "ascites")

## summary now includes both types of p-values
summary(catTableBySexTrt)

## If your work flow includes copying to Excel and Word when writing manuscripts,
## you may benefit from the quote argument. This will quote everything so that
## Excel does not mess up the cells.
print(catTableBySexTrt, exact = "ascites", quote = TRUE)

## If you want to center-align values in Word, use noSpaces option.
print(catTableBySexTrt, exact = "ascites", quote = TRUE, noSpaces = TRUE)

}
\seealso{
\code{\link{CreateTableOne}}, \code{\link{print.CatTable}},  \code{\link{summary.CatTable}}
}
\author{
Kazuki Yoshida (based on \code{Deducer::frequencies()}), Alexander Bartel
}
