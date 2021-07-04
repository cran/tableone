## ---- message = FALSE, tidy = FALSE, echo = F---------------------------------------------------------------------
## Create a header using devtools::use_vignette("my-vignette")
## knitr configuration: https://yihui.name/knitr/options#chunk_options
library(knitr)
showMessage <- FALSE
showWarning <- TRUE
set_alias(w = "fig.width", h = "fig.height", res = "results")
opts_chunk$set(comment = "", error= TRUE, warning = showWarning, message = showMessage,
               tidy = FALSE, cache = F, echo = T,
               fig.width = 7, fig.height = 7)

## R configuration
options(width = 116, scipen = 5)

## -----------------------------------------------------------------------------------------------------------------
## tableone package itself
library(tableone)
## survival package for Mayo Clinic's PBC data
library(survival)
data(pbc)

## -----------------------------------------------------------------------------------------------------------------
CreateTableOne(data = pbc)

## -----------------------------------------------------------------------------------------------------------------
## Get variables names
dput(names(pbc))
## Vector of variables to summarize
myVars <- c("time", "status", "trt", "age", "sex", "ascites", "hepato",
          "spiders", "edema", "bili", "chol", "albumin", "copper", "alk.phos",
          "ast", "trig", "platelet", "protime", "stage")
## Vector of categorical variables that need transformation
catVars <- c("status", "trt", "ascites", "hepato",
             "spiders", "edema", "stage")
## Create a TableOne object
tab2 <- CreateTableOne(vars = myVars, data = pbc, factorVars = catVars)

## -----------------------------------------------------------------------------------------------------------------
tab2

## -----------------------------------------------------------------------------------------------------------------
print(tab2, showAllLevels = TRUE, formatOptions = list(big.mark = ","))

## -----------------------------------------------------------------------------------------------------------------
summary(tab2)

## -----------------------------------------------------------------------------------------------------------------
biomarkers <- c("bili","chol","copper","alk.phos","ast","trig","protime")
print(tab2, nonnormal = biomarkers, formatOptions = list(big.mark = ","))

## -----------------------------------------------------------------------------------------------------------------
tab3 <- CreateTableOne(vars = myVars, strata = "trt" , data = pbc, factorVars = catVars)
print(tab3, nonnormal = biomarkers, formatOptions = list(big.mark = ","))

## -----------------------------------------------------------------------------------------------------------------
print(tab3, nonnormal = biomarkers, exact = "stage", smd = TRUE)

## -----------------------------------------------------------------------------------------------------------------
print(tab3, nonnormal = biomarkers, exact = "stage", quote = TRUE, noSpaces = TRUE)

## ---- eval = FALSE------------------------------------------------------------------------------------------------
#  tab3Mat <- print(tab3, nonnormal = biomarkers, exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#  ## Save to a CSV file
#  write.csv(tab3Mat, file = "myTable.csv")

## -----------------------------------------------------------------------------------------------------------------
## Categorical part only
tab3$CatTable
## Continous part only
print(tab3$ContTable, nonnormal = biomarkers)

