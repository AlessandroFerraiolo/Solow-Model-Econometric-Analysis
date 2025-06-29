Of course, here is the README file rewritten in Markdown.

# Econometric Analysis of the Solow-Swan Growth Model

This repository contains an econometric project that tests the empirical validity of the Solow-Swan growth model. The analysis uses panel data from the World Bank to examine the impact of savings rates and population growth on GDP per capita. The project further identifies limitations of the base model, particularly concerning oil-producing nations, and proposes an augmented model that incorporates human capital.

**For a complete and in-depth discussion of the methodology, results, and conclusions, please refer to the `SolowModelEconometricAnalysis.pdf` file included in this repository.**

## Project Overview

[cite\_start]The core objective of this analysis is to empirically test the predictions of the Solow-Swan model, which analyzes how changes in population growth and savings rates affect economic output[cite: 1]. The project follows these key steps:

1.  [cite\_start]**Data Collection and Preparation**: Sourcing and cleaning panel data for 1960 to 2023 from the World Bank[cite: 8].
2.  **Base Model Estimation**: Running a regression based on the standard Solow-Swan framework.
3.  [cite\_start]**Outlier Analysis**: Identifying and excluding oil-producing nations, whose economies do not align with the model's assumptions, to improve fit[cite: 10, 14].
4.  [cite\_start]**Model Extension**: Augmenting the model with a human capital proxy (secondary education enrollment) to enhance its explanatory power[cite: 26, 27].

### The Econometric Model

[cite\_start]The analysis is centered around a log-log regression model derived from the Solow-Swan framework[cite: 2]:

$$ln(gdppc_{t}) = \alpha + \beta ln(s_{t}) - \gamma ln(n_{t})$$

Where:

  - [cite\_start]`$gdppc_{t}$` is the GDP per capita[cite: 2].
  - [cite\_start]`$s_{t}$` is the gross domestic savings rate[cite: 2].
  - [cite\_start]`$n_{t}$` is the population growth rate[cite: 2].

The model was later extended to include human capital (`$ln\_educ\_sec$`).

## Methodology

### Data

  - [cite\_start]**Source**: World Bank[cite: 3].
  - [cite\_start]**Dependent Variable**: GDP per capita (current US$), which serves as the measure for economic output per person[cite: 3, 4].
  - **Independent Variables**:
      - [cite\_start]Gross domestic savings (% of GDP), which represents the savings rate[cite: 4].
      - [cite\_start]Population growth (annual %), which captures the rate of population increase[cite: 5].
      - Net secondary education enrollment rate, used as a proxy for human capital.
  - **Structure**: The dataset, originally in a wide format with years as columns, was converted into a long panel format (country-year observations) for the analysis.

### Data Cleaning and Processing

  - Regional aggregates and other non-country entities were removed to avoid bias from data over-representation.
  - [cite\_start]A residual analysis on an initial regression confirmed that oil-producing nations behave as significant outliers[cite: 12]. [cite\_start]These countries represented about 10% of observations but accounted for a third of the detected outliers[cite: 13].
  - [cite\_start]A second model was estimated after excluding major oil-producing countries to ensure a more representative analysis[cite: 14]. [cite\_start]The list of excluded countries can be found in the PDF report[cite: 16].
  - Log transformations were applied to the variables, which required excluding observations with negative or zero values for growth and savings rates. [cite\_start]This introduced a potential selection bias, as countries excluded for negative savings tended to be poorer, while those excluded for negative population growth were often wealthier[cite: 22, 23, 24].

## Key Findings

1.  [cite\_start]**Base Model**: The initial model confirmed the Solow-Swan hypotheses and was statistically significant, achieving an $R^{2}$ of 0.358[cite: 33].

2.  [cite\_start]**Excluding Oil Producers**: Removing oil-producing nations improved the model's fit, increasing the $R^{2}$ to 0.396[cite: 20, 33]. [cite\_start]This supports the hypothesis that resource-extraction economies follow different growth dynamics not captured by the standard Solow model[cite: 10, 18].

3.  **Augmented Model with Human Capital**:

      * [cite\_start]The inclusion of secondary education enrollment as a proxy for human capital significantly improved the model's explanatory power, raising the adjusted $R^{2}$ to 0.638[cite: 31, 35].
      * [cite\_start]The coefficient for the log of education enrollment was 1.626[cite: 33]. [cite\_start]As a log-log model, this implies that a 1% increase in the net secondary enrollment rate is associated with approximately a 1.63% increase in GDP per capita[cite: 36, 37].
      * [cite\_start]Adding the human capital variable helped correct for omitted variable bias, reallocating some of the explanatory power that was previously attributed to savings and population growth[cite: 40].

## Repository Contents

  - `Group18.pdf`: The complete project report. **This document contains a more in-depth discussion of the methodology, statistical results, and conclusions of the analysis.**
  - `script.R`: The R script used for all data loading, cleaning, transformation, regression analysis, and visualization.
  - `workspace.RData`: An R data file containing the prepared datasets and final regression models.
  - `/gdppc/`, `/s/`, `/n/`, `/educ_sec/`: Directories containing the raw `.csv` datasets downloaded from the World Bank.

## How to Run the Analysis

To replicate the results, you can either load the pre-run workspace or execute the R script from the beginning.

### Required R Libraries

```r
library(readr)
library(reshape2)
library(ggplot2)
library(lmtest)
library(stargazer)
```

*Source:*

### Option 1: Load the Workspace

1.  Open R or RStudio.
2.  Load the workspace using the command: `load("workspace.RData")`.
3.  You can now access all data frames (`data_cl`, `data_no_oil`, `data_h`) and model objects (`model_all`, `model_no_oil`, `model_h`) directly.

### Option 2: Run the Script

1.  Ensure all required libraries are installed.
2.  Set the working directory to the repository's root folder.
3.  Run the `script.R` file. The script will automatically:
      - Load the raw data from the sub-directories.
      - Perform all data cleaning and transformation steps.
      - Estimate the three regression models.
      - Generate plots and the final regression table using `stargazer`.
