## ---- message = FALSE, tidy = FALSE, echo = F-----------------------------------------------------------------------------------
## Create a header using devtools::use_vignette("my-vignette")
## knitr configuration: https://yihui.name/knitr/options#chunk_options
library(knitr)
showMessage <- FALSE
showWarning <- FALSE
set_alias(w = "fig.width", h = "fig.height", res = "results")
opts_chunk$set(comment = "", error= TRUE, warning = showWarning, message = showMessage,
               tidy = FALSE, cache = F, echo = T,
               fig.width = 10, fig.height = 10)

## R configuration
options(width = 130, scipen = 5)

## -------------------------------------------------------------------------------------------------------------------------------

## tableone package itself
library(tableone)
## PS matching
library(Matching)
## Weighted analysis
library(survey)
## Reorganizing data
library(reshape2)
## plotting
library(ggplot2)


## -------------------------------------------------------------------------------------------------------------------------------

## Right heart cath dataset
rhc <- read.csv("https://biostat.app.vumc.org/wiki/pub/Main/DataSets/rhc.csv")


## -------------------------------------------------------------------------------------------------------------------------------

## Covariates
vars <- c("age","sex","race","edu","income","ninsclas","cat1","das2d3pc","dnr1",
          "ca","surv2md1","aps1","scoma1","wtkilo1","temp1","meanbp1","resp1",
          "hrt1","pafi1","paco21","ph1","wblc1","hema1","sod1","pot1","crea1",
          "bili1","alb1","resp","card","neuro","gastr","renal","meta","hema",
          "seps","trauma","ortho","cardiohx","chfhx","dementhx","psychhx",
          "chrpulhx","renalhx","liverhx","gibledhx","malighx","immunhx",
          "transhx","amihx")

## Construct a table
tabUnmatched <- CreateTableOne(vars = vars, strata = "swang1", data = rhc, test = FALSE)
## Show table with SMD
print(tabUnmatched, smd = TRUE)
## Count covariates with important imbalance
addmargins(table(ExtractSmd(tabUnmatched) > 0.1))


## -------------------------------------------------------------------------------------------------------------------------------

rhc$swang1 <- factor(rhc$swang1, levels = c("No RHC", "RHC"))
## Fit model
psModel <- glm(formula = swang1 ~ age + sex + race + edu + income + ninsclas +
                         cat1 + das2d3pc + dnr1 + ca + surv2md1 + aps1 + scoma1 +
                         wtkilo1 + temp1 + meanbp1 + resp1 + hrt1 + pafi1 +
                         paco21 + ph1 + wblc1 + hema1 + sod1 + pot1 + crea1 +
                         bili1 + alb1 + resp + card + neuro + gastr + renal +
                         meta + hema + seps + trauma + ortho + cardiohx + chfhx +
                         dementhx + psychhx + chrpulhx + renalhx + liverhx + gibledhx +
                         malighx + immunhx + transhx + amihx,
               family  = binomial(link = "logit"),
               data    = rhc)

## Predicted probability of being assigned to RHC
rhc$pRhc <- predict(psModel, type = "response")
## Predicted probability of being assigned to no RHC
rhc$pNoRhc <- 1 - rhc$pRhc

## Predicted probability of being assigned to the
## treatment actually assigned (either RHC or no RHC)
rhc$pAssign <- NA
rhc$pAssign[rhc$swang1 == "RHC"]    <- rhc$pRhc[rhc$swang1   == "RHC"]
rhc$pAssign[rhc$swang1 == "No RHC"] <- rhc$pNoRhc[rhc$swang1 == "No RHC"]
## Smaller of pRhc vs pNoRhc for matching weight
rhc$pMin <- pmin(rhc$pRhc, rhc$pNoRhc)


## -------------------------------------------------------------------------------------------------------------------------------

listMatch <- Match(Tr       = (rhc$swang1 == "RHC"),      # Need to be in 0,1
                   ## logit of PS,i.e., log(PS/(1-PS)) as matching scale
                   X        = log(rhc$pRhc / rhc$pNoRhc),
                   ## 1:1 matching
                   M        = 1,
                   ## caliper = 0.2 * SD(logit(PS))
                   caliper  = 0.2,
                   replace  = FALSE,
                   ties     = TRUE,
                   version  = "fast")
## Extract matched data
rhcMatched <- rhc[unlist(listMatch[c("index.treated","index.control")]), ]

## Construct a table
tabMatched <- CreateTableOne(vars = vars, strata = "swang1", data = rhcMatched, test = FALSE)
## Show table with SMD
print(tabMatched, smd = TRUE)
## Count covariates with important imbalance
addmargins(table(ExtractSmd(tabMatched) > 0.1))


## -------------------------------------------------------------------------------------------------------------------------------

## Matching weight
rhc$mw <- rhc$pMin / rhc$pAssign
## Weighted data
rhcSvy <- svydesign(ids = ~ 1, data = rhc, weights = ~ mw)

## Construct a table (This is a bit slow.)
tabWeighted <- svyCreateTableOne(vars = vars, strata = "swang1", data = rhcSvy, test = FALSE)
## Show table with SMD
print(tabWeighted, smd = TRUE)
## Count covariates with important imbalance
addmargins(table(ExtractSmd(tabWeighted) > 0.1))


## -------------------------------------------------------------------------------------------------------------------------------

## Overlap weight
rhc$ow <- (rhc$pAssign * (1 - rhc$pAssign)) / rhc$pAssign
## Weighted data
rhcSvyOw <- svydesign(ids = ~ 1, data = rhc, weights = ~ ow)

## Construct a table (This is a bit slow.)
tabWeightedOw <- svyCreateTableOne(vars = vars, strata = "swang1", data = rhcSvyOw, test = FALSE)
## Show table with SMD
print(tabWeightedOw, smd = TRUE)
## Count covariates with important imbalance
addmargins(table(ExtractSmd(tabWeightedOw) > 0.1))


## -------------------------------------------------------------------------------------------------------------------------------

## Construct a data frame containing variable name and SMD from all methods
dataPlot <- data.frame(variable   = rownames(ExtractSmd(tabUnmatched)),
                       Unmatched  = as.numeric(ExtractSmd(tabUnmatched)),
                       Matched    = as.numeric(ExtractSmd(tabMatched)),
                       Weighted   = as.numeric(ExtractSmd(tabWeighted)),
                       WeightedOw = as.numeric(ExtractSmd(tabWeightedOw)))

## Create long-format data for ggplot2
dataPlotMelt <- melt(data          = dataPlot,
                     id.vars       = c("variable"),
                     variable.name = "Method",
                     value.name    = "SMD")

## Order variable names by magnitude of SMD
varNames <- as.character(dataPlot$variable)[order(dataPlot$Unmatched)]

## Order factor levels in the same order
dataPlotMelt$variable <- factor(dataPlotMelt$variable,
                                levels = varNames)

## Plot using ggplot2
ggplot(data = dataPlotMelt,
       mapping = aes(x = variable, y = SMD, group = Method, color = Method)) +
    geom_line() +
    geom_point() +
    geom_hline(yintercept = 0.1, color = "black", size = 0.1) +
    coord_flip() +
    theme_bw() +
    theme(legend.key = element_blank())


## -------------------------------------------------------------------------------------------------------------------------------

## Column bind tables
resCombo <- cbind(print(tabUnmatched,  printToggle = FALSE),
                  print(tabMatched,    printToggle = FALSE),
                  print(tabWeighted,   printToggle = FALSE),
                  print(tabWeightedOw, printToggle = FALSE))

## Add group name row, and rewrite column names
resCombo <- rbind(Group = rep(c("No RHC","RHC"), 4), resCombo)
colnames(resCombo) <- c("Unmatched","","Matched","","MW","","OW","")
print(resCombo, quote = FALSE)


## -------------------------------------------------------------------------------------------------------------------------------

## Unmatched model (unadjusted)
glmUnmatched <- glm(formula = (death == "Yes") ~ swang1,
                    family  = binomial(link = "logit"),
                    data    = rhc)
## Matched model
glmMatched <- glm(formula = (death == "Yes") ~ swang1,
                  family  = binomial(link = "logit"),
                  data    = rhcMatched)
## Weighted model
glmWeighted <- svyglm(formula = (death == "Yes") ~ swang1,
                      family  = binomial(link = "logit"),
                      design  = rhcSvy)

## Show results together
resTogether <- list(Unmatched = ShowRegTable(glmUnmatched, printToggle = FALSE),
                    Matched   = ShowRegTable(glmMatched, printToggle = FALSE),
                    Weighted  = ShowRegTable(glmWeighted, printToggle = FALSE))
print(resTogether, quote = FALSE)


