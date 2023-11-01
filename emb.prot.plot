---
title: "embryo.protein.quant"
output: html_document
date: "2023-07-28"
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:
  
```{r}
emb.all <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vTElQBIq1HxfNIbB98zeaF2Blsx8_4MPQhdM4njwJiX6tS7EovpZa4ZL2KhFNPWADiVsVJOT4Jj29MN/pub?gid=0&single=true&output=csv", header = T)

emb.all$sample.type<- as.factor(emb.all$sample.type)
emb.all$Theiler.stage<- as.factor(emb.all$Theiler.stage)
emb.all$digestion.method<- as.factor(emb.all$digestion.method)


emb.all
```


```{r}
install.packages("Rmisc")
library(Rmisc)

#Theiler stage and total protein summary stats
emb_sum <- summarySE(emb.all, measurevar="total.protein",
                     groupvars=c("Theiler.stage"),na.rm = T)

emb_sum
```
Summary statistics of total protein via BCA or Bradford detected at each Theiler
stage.

```{r}
#summary statistics of total protein with both Theiler stage and digestion method

library(Rmisc)
dig_sum <- summarySE(emb.all, measurevar = "total.protein",
                     groupvars = c("digestion.method","Theiler.stage"),
                     na.rm = T)

write.csv(dig_sum, "dig_sum.csv", row.names = F)

dig_sum
```
Total protein detected at each Theiler stage/digestion method combo.

```{r}
install.packages("car")
```


```{r}
protein.lm <- lm(total.protein ~ Theiler.stage*digestion.method*quantification.assay,
                 data = emb.all)

plot(protein.lm)
```

What is driving differences in total protein in whole embryo lysate over different
Theiler stages?
  
  Do digestion method and quantification assay also affect these?
  
  Null hypothesis: there is no difference in total protein between embryos of different ages.

Alternative: there is a difference in total protein between embryos of different ages.

```{r}
summary.aov(protein.lm)
```

Embryonic age determined by Theiler staging drives the variation in total protein.

Further, digestion method and quantification assay by themselves do not affect total
protein levels

Theiler stage and digestion method interact, indicating the relationship between
total protein detected and Theiler stage depends on digestion method.

2023-10-17: I used a new Benzonase nuclease during this experiment. Lysates were less
viscous, but effects on protein yeild are unclear.

Also I was late to getting the ELISA plate out of incubation or let it cool
too long at RT.

I will repeat the BCA assay with these samples later or tomorrow
(2023-10-18).

I am getting quite variable results for S-trap at E8.5 and E10.5

```{r}
library(car)
Anova(protein.lm, type = "III")
```


I attempted Type III Anova, but there is colinearity between at least 2 variables.

Therefore, I set up an alternative model:

```{r}
library(car)

proteinalt.lm <- lm(total.protein~Theiler.stage+digestion.method+quantification.assay, data = emb.all)

plot(proteinalt.lm)
```
```{r}
summary(proteinalt.lm)
Anova(proteinalt.lm, type = "III")
```


```{r}
library(ggplot2)
paired.prot.plot <- ggplot(data = emb.all, aes(x = Theiler.stage,
                                               y = total.protein,
                                               fill = digestion.method))+
  geom_point(aes(shape = digestion.method,
                 color = digestion.method),
             position = position_jitterdodge(), alpha=1)+
  geom_boxplot(outlier.shape = NA,
               alpha = 0.1)+
  stat_summary(fun = mean, color = "black", position = position_dodge(0.75),
               width = 0.2,
               geom = "crossbar",
               show.legend = FALSE)+
  xlab("Theiler stage")+
  ylab("total protein (µg)")+
  scale_colour_discrete(na.translate = F)+
  theme_bw(base_size = 12, base_family = "Helvetica")+scale_fill_grey()

paired.prot.plot
```
```{r}
library(ggplot2)
ggplot(data = emb.all, aes(x = Theiler.stage,
                           y = total.protein,
                           fill = digestion.method))+
  geom_point(aes(shape = digestion.method,
                 color = quantification.assay),
             position = position_jitterdodge(), alpha=1)+
  geom_boxplot(outlier.shape = NA,
               alpha = 0.1)+
  stat_summary(fun = mean, color = "black", position = position_dodge(0.75),width = 0.2,
               geom = "crossbar",
               show.legend = FALSE)+
  xlab("Theiler stage")+
  ylab("total protein (µg)")+
  scale_colour_discrete(na.translate = F)+
  theme_bw(base_size = 12, base_family = "Helvetica")+scale_fill_grey()
```


```{r}
library(ggplot2)

emb.prot.plot <- ggplot(data = emb.all, aes(x = Theiler.stage,
                                            y = total.protein))+
  geom_jitter(aes(shape = digestion.method),
              alpha = 2.0,
              size = 2)+
  geom_boxplot(outlier.shape = NA,
               alpha = 0.1)+
  stat_summary(fun = mean, color = "black", position = position_dodge(0.75),width = 0.2,
               geom = "crossbar",
               show.legend = FALSE)+
  geom_errorbar(data = emb_sum, aes(ymin=total.protein-sd,
                                    ymax=total.protein+sd),
                width=.2,
                position=position_dodge(0.75))+
  xlab("Theiler stage")+
  ylab("total protein (µg)")+
  scale_colour_discrete(na.translate = F)+
  theme_bw(base_size = 12, base_family = "Helvetica")+scale_fill_grey()

emb.prot.plot
```


2023-10-17
Big picture wise, both digestion methods extract appreciable amounts of protein
to digest with endoproteases to prepare peptide samples for LC-MS.

Both digestion methods seem reasonable. Preference for either will come down to cost
or peptides/proteins/Nt-proteins/Nt
terminal-peptides obtained.

S-trap at this point seems more variable at E8.5 and E9.5 embryos; I will need to
re-run NB5-107-2023-10-17 samples.

I will also do an additional comparison between BCA and Bradford assay using
BSA standards. I recapitulated protein levels from my first Rapigest-lysed embryo
samples, but want to make sure absorbance/protein readings between both are
relatively correlated.


```{r}

```



Alternative plotting

```{r}
install.packages("ggbeeswarm")
library(ggbeeswarm)
```

```{r}

emb.prot.plot.2 <- ggplot(data = emb.all, aes(x = digestion.method,
                                              y = total.protein),
                          fill = Theiler.stage)+
  geom_jitter(aes(shape = Theiler.stage),
              alpha = 2.0,
              size = 2)+
  geom_boxplot(outlier.shape = NA,
               alpha = 0.1)+
  xlab("Digestion method")+
  ylab("total protein (µg)")+
  scale_colour_discrete(na.translate = F)+
  theme_bw(base_size = 12, base_family = "Helvetica")+scale_fill_grey()

emb.prot.plot.2
```


```{r}
emb9.5 <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vSmVToNNXZJgAwEeA5L8peYS-wVDpgBlwUPZIrNR0vxWjzcZlV5ShLP1nHaV8Twwy07oC9Yu9xpDGlm/pub?gid=761795663&single=true&output=csv",header = T)

head(emb9.5)
```

Addendum for NB5-104-2023-10-12-1600h

I also needed to compare the protein concentrations of my total protein lysates
from several months ago, which were mostly digested in Rapigest, urea, and TEAB buffer. I could quantify proteins using Bradford assay. As a reminder, even diluting protein 1:9 in TBS did not sufficiently dilute SDS to prevent interference in Bradford assay.

Therefore, I 1) tested 2 TS17 (E10.5) embryo samples digested using S-trap lysis buffer and 2) re-quantified my Rapigest-digested samples (TS13-TS17, 11-mix)


```{r}
bca.brad.comp <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vTAzoKgpClrgZYWR7Vg-LE1UF1wyMSPUwvrfhCi3FXlmWwaYWdL-ZXCZ8uW1l7frPZV6vbpWKR85-Sq/pub?gid=0&single=true&output=csv",
                          header = T)

bca.brad.comp$sample.type<- as.factor(bca.brad.comp$sample.type)
bca.brad.comp$Theiler.stage<- as.factor(bca.brad.comp$Theiler.stage)
bca.brad.comp$digestion.method<- as.factor(bca.brad.comp$digestion.method)


head(bca.brad.comp)
```

```{r}
bca.brad.sum <- summarySE(bca.brad.comp, measurevar="total.protein",
                          groupvars=c("Theiler.stage"),na.rm = T)
```

```{r}
quant_dig.sum <- summarySE(bca.brad.comp, measurevar = "total.protein",
                           groupvars = c("digestion.method","Theiler.stage"),
                           na.rm = T)

quant_dig.sum
```

```{r}
library(ggplot2)

bca.brad.plot <- ggplot(data = bca.brad.comp, aes(x = Theiler.stage,
                                                  y = total.protein),
                        fill = digestion.method)+
  geom_jitter(aes(shape = digestion.method),
              alpha = 2.0,
              size = 2)+
  geom_boxplot(outlier.shape = NA,
               alpha = 0.1)+
  stat_summary(fun = mean, color = "black", position = position_dodge(0.75),width = 0.2,
               geom = "crossbar",
               show.legend = FALSE)+
  geom_errorbar(data = bca.brad.sum, aes(ymin=total.protein-sd,
                                         ymax=total.protein+sd),
                width=.2,
                position=position_dodge(0.75))+
  xlab("Theiler stage")+
  ylab("total protein (µg)")+
  scale_colour_discrete(na.translate = F)+
  theme_bw(base_size = 12, base_family = "Helvetica")+scale_fill_grey()

bca.brad.plot
```

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

