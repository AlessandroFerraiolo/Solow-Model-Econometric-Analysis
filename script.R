#load workspace data
load("workspace.RData")

# Load necessary libraries
library(readr)     # for reading CSV files
library(reshape2)  # for reshaping data from wide to long format
library(ggplot2)   # for plotting
library(lmtest)    # for linear model testing
library(stargazer) # for creating regression tables

# Import datasets (wide format from World Bank)
# Import GDP per capita dataset 
gdppc_w <- read_csv("gdppc/API_NY.GDP.PCAP.CD_DS2_en_csv_v2_76317.csv",
                    col_types = cols(`Indicator Name` = col_skip(), 
                                     `Indicator Code` = col_skip(),
                                     ...69 = col_skip()), 
                    skip = 3)

# Import gross domestic savings dataset (as % of GDP)
s_w <- read_csv("s/API_NY.GDS.TOTL.ZS_DS2_en_csv_v2_76031.csv",
                col_types = cols(`Indicator Name` = col_skip(),
                                 `Indicator Code` = col_skip(), 
                                 ...69 = col_skip()),
                skip = 3)

# Import population growth dataset
n_w <- read_csv("n/API_SP.POP.GROW_DS2_en_csv_v2_87.csv",
                col_types = cols(`Indicator Name` = col_skip(),
                                 `Indicator Code` = col_skip(), 
                                 ...69 = col_skip()),
                skip = 3)

# Convert all datasets from wide to long format
gdppc_l <- melt(data = gdppc_w, id.vars = c("Country Name","Country Code"),
                measure.vars = 3:66, variable.name = "Year", value.name = "gdppc")

s_l <- melt(data = s_w, id.vars = c("Country Name","Country Code"),
            measure.vars = 3:66, variable.name = "Year", value.name = "s")

n_l <- melt(data = n_w, id.vars = c("Country Name","Country Code"),
            measure.vars = 3:66, variable.name = "Year", value.name = "n")

# Convert percentages to decimals
s_l$s <- s_l$s / 100
n_l$n <- n_l$n / 100

# Merge datasets by Country and Year
data <- merge(gdppc_l, s_l, by = c("Country Name", "Country Code", "Year"))
data <- merge(data, n_l, by = c("Country Name", "Country Code", "Year"))

# Log-transform variables to match Solow model's functional form
data$ln_gdppc <- log(data$gdppc)
data$ln_s <- log(data$s)
data$ln_n <- log(data$n)
summary(data)

# Remove regional aggregates and groups (non-country codes)
non_countries <- c("ARB", "OED", "CEB", "AFE", "AFW", "EAP", "EAR", "EAS", "ECA", "ECS", "EMU",
                   "EUU", "FCS", "HPC", "IBD", "IBT", "IDA", "IDB", "IDX", "INX", "LNC", "LDC",
                   "LIC", "LCN", "LMC", "LMY", "LTE", "MNA", "OSS", "PRE", "PSS", "PST", "SSA",
                   "SST", "TEA", "TEC", "TLA", "TMN", "TSA", "TSS", "UMC", "WLD", "LAC", "HIC",
                   "MEA", "MIC", "SAS", "SSF", "VIR")
data_cl <- data[!(data$`Country Code` %in% non_countries), ]

# Check for selection bias in the dataset
# Hypothesis: Missing data may not be random and could correlate with GDP
# Average GDP for countries (exp of the mean of log GDP per capita)
mean_gdppc <- exp(mean(data_cl$ln_gdppc, na.rm = TRUE))
mean_gdppc

# Average GDP for countries with missing savings data
gdppc_missing_saving <- data_cl$ln_gdppc[is.na(data_cl$ln_s) | is.nan(data_cl$ln_s)]
mean_gdppc_missing_saving <- exp(mean(gdppc_missing_saving, na.rm = TRUE))
mean_gdppc_missing_saving

# Average GDP for countries with missing population growth data
gdppc_missing_pop_growth <- data_cl$ln_gdppc[is.na(data_cl$ln_n) | is.nan(data_cl$ln_n)]
mean_gdppc_missing_pop_growth <- exp(mean(gdppc_missing_pop_growth, na.rm = TRUE))
mean_gdppc_missing_pop_growth


# Remove missing values and estimate the basic Solow model with savings and population growth
data_cl <- na.omit(data_cl)
model_all <- lm(ln_gdppc ~ ln_s + ln_n, data = data_cl)
summary(model_all)

data_cl$prediction <- predict(model_all)
data_cl$residuals <- data_cl$ln_gdppc - data_cl$prediction



# Identify outliers with high residuals and flag oil producers
oil_countries <- c("AGO", "AZE", "BHR", "BRN", "DZA", "GAB", "IRN", "IRQ", "KAZ", "KWT",
                   "LBY", "NGA", "OMN", "QAT", "SAU", "SSD", "ARE", "VEN", "YEM")

bp <- boxplot.stats(abs(data_cl$residuals))
upper <- bp$stats[5]  # upper whisker
all_outlier_idx <- which(data_cl$residuals > upper)

oil_outliers <- all_outlier_idx[data_cl$`Country Code`[all_outlier_idx] %in% oil_countries]
non_oil_outliers <- setdiff(all_outlier_idx, oil_outliers)

# Boxplot visualization of residuals
boxplot(abs(data_cl$residuals), outline = FALSE, main = "Linear model residuals", ylim = c(0, 6))
points(rep(1, length(non_oil_outliers)), data_cl$residuals[non_oil_outliers], col = "black", pch = 16)
points(rep(1, length(oil_outliers)), data_cl$residuals[oil_outliers], col = "cyan4", pch = 16)
legend("topright", legend = c("Non Oil Outliers", "Oil Outliers"), col = c("black", "cyan4"), pch = 16)

# Proportion of oil countries among outliers
length(oil_outliers) / length(all_outlier_idx)

# Proportion of oil countries in the full cleaned dataset
nrow(data_cl[data_cl$`Country Code` %in% oil_countries, ]) / nrow(data_cl)

# Remove oil-focused countries and re-estimate the model
data_no_oil <- data_cl[!(data_cl$`Country Code` %in% oil_countries), ]
model_no_oil <- lm(ln_gdppc ~ ln_s + ln_n, data = data_no_oil)
summary(model_no_oil)
data_no_oil$prediction <- predict(model_no_oil)
data_no_oil$residuals <- data_no_oil$ln_gdppc- data_no_oil$prediction


#plot predicted vs actual values, coloring in red the oil countries, and in black the remaining
oil_points <- data_cl[data_cl$`Country Code` %in% oil_countries, ]

x_range <- range(data_cl$ln_gdppc, na.rm = TRUE)
y_range <- range(data_cl$prediction, na.rm = TRUE)

plot(x_range, y_range, type = "n", ylab = "Actual ln(gdppc)", 
     xlab = "Predicted ln(gdppc)", main = "Actual vs Predicted Values")
points(data_cl$ln_gdppc, data_cl$prediction, col = rgb(0, 0, 0, 0.3))
points(oil_points$ln_gdppc,oil_points$prediction,  col="cyan4",  pch =1, lwd = 2)
abline(a = 0, b = 1, lty =2, col = "red")
legend("topleft", legend = c("Non-Oil Countries","Oil Countries"), col = c("black", "cyan4"), pch =16)


plot(x_range, range(data_no_oil$residuals, na.rm = TRUE), type = "n",  xlab = "Predicted ln(gdppc)", 
     ylab = "Residuals", main = "Residuals")
points(data_no_oil$prediction, data_no_oil$residuals, col="black")
abline(a = 0, b = 0, lty =2, col = "red")
points(oil_points$prediction, oil_points$residuals, col="cyan4")

# Import human capital data (secondary school enrollment)
educ_sec <- read_csv("educ_sec/API_SE.SEC.NENR_DS2_en_csv_v2_15603.csv",
                     col_types = cols(`1960` = col_double(), `1961` = col_double(), `1962` = col_double(),
                                      `1963` = col_double(), `1964` = col_double(), `1965` = col_double(),
                                      `1966` = col_double(), `1967` = col_double(), `1968` = col_double(),
                                      `1969` = col_double(), `Indicator Name` = col_skip(),
                                      `Indicator Code` = col_skip(), ...69 = col_skip()),
                     skip = 3)

# Convert human capital dataset to long format
educ_sec_l <- melt(data = educ_sec, id.vars = c("Country Name", "Country Code"),
                   measure.vars = 3:66, variable.name = "Year", value.name = "educ_sec")

# Merge human capital data and prepare for regression
data_h <- merge(data, educ_sec_l, by = c("Country Name", "Country Code", "Year"))
data_h$educ_sec <- data_h$educ_sec / 100  # convert to decimal

data_h$ln_educ_sec <- log(data_h$educ_sec)  # log transform

data_h <- data_h[!(data_h$`Country Code` %in% oil_countries), ]
data_h <- na.omit(data_h)

# Estimate extended Solow model with human capital
model_h <- lm(ln_gdppc ~ ln_s + ln_n + ln_educ_sec, data = data_h)
summary(model_h)
data_h$prediction <- predict(model_h)
data_h$residuals <- data_h$ln_gdppc- data_h$prediction

# Display regression results using stargazer
stargazer(model_all, model_no_oil, model_h,
          type = "text",
          column.labels = c("Model All", "Model No Oil", "Model H"))

x_range <- range(data_cl$ln_gdppc, na.rm = TRUE)
y_range <- range(data_cl$prediction, na.rm = TRUE)

plot(x_range, y_range, type = "n", xlab = "Actual ln(gdppc)", 
     ylab = "Predicted ln(gdppc)", main = "Actual vs Predicted Values")

#points(data_cl$ln_gdppc, data_cl$prediction, col="red")
points(data_no_oil$ln_gdppc, data_no_oil$prediction, col=rgb(0,0,0,0.5))
points(data_h$ln_gdppc, data_h$prediction, col="cyan4")
abline(a = 0, b = 1, lty = 2, col = "red")
legend("topleft", legend = c("No Oil model", "No Oil + Human Capital model"), 
       col = c("black", "cyan4"), pch =1)
