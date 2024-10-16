# Cargar librerías necesarias
library(readxl)
library(dplyr)
library(ggplot2)
library(readr)
#library(caret)
library(corrplot)

# Leer datos de Excel
Charges <- read_excel("Data.xlsx", sheet = "Charges")
OtherData <- read_excel("Data.xlsx", sheet = "Other data")
Churn <- read_excel("Data.xlsx", sheet = "Churn")

# Unir los tres datasets con inner join en 'CustomerID'
DMRusers <- Charges %>%
  inner_join(OtherData, by = "customerID") %>%
  inner_join(Churn, by = "customerID")

# Agregar columnas de rango para Monthly Charges, Total Charges y Tenure
DMRusers <- DMRusers %>%
  mutate(RgTenure = case_when(
    tenure < 6 ~ "Low Tenure",
    tenure >= 6 & tenure <= 24 ~ "Medium Tenure",
    tenure > 24 ~ "High Tenure"
  )) %>%
  mutate(RgTtCharges = case_when(
    TotalCharges < 1000 ~ "Low TtCharges",
    TotalCharges >= 1000 & TotalCharges <= 2500 ~ "Medium TtCharges",
    TotalCharges > 2500 ~ "High TtCharges"
  )) %>%
  mutate(RgMtCharges = case_when(
    MonthlyCharges < 50 ~ "Low MtCharges",
    MonthlyCharges >= 50 & MonthlyCharges <= 80 ~ "Medium MtCharges",
    MonthlyCharges > 80 ~ "High MtCharges"
  ))
  

# Ver el dataset integrado
head(DMRusers)

# Obtener la estructura del dataset
str(DMRusers)
summary(DMRusers)

# Eliminar valores vacíos en MonthlyCharges y TotalCharges
DMRusers <- DMRusers %>%
  filter(!is.na(TotalCharges)) %>% 
  filter(!is.na(MonthlyCharges))

# Revisar existencia de valores vacíos
sum(is.na(DMRusers))


## ANALISIS EXPLORATIORIO DE DATOS
##################################

# Summary of Churn vs. key categorical variables
table(DMRusers$Churn)
table(DMRusers$gender, DMRusers$Churn)
table(DMRusers$Partner, DMRusers$Churn)
table(DMRusers$Dependents, DMRusers$Churn)

# Numerical variables summary
summary(DMRusers$MonthlyCharges)
summary(DMRusers$TotalCharges)

# Calcular percentiles para MonthlyCharges
percentiles_monthly <- quantile(DMRusers$MonthlyCharges, probs = seq(0, 1, by = 0.25), na.rm = TRUE)
percentiles_monthly

# Calcular percentiles para TotalCharges
percentiles_total <- quantile(DMRusers$TotalCharges, probs = seq(0, 1, by = 0.25), na.rm = TRUE)
percentiles_total

# Churn por Rango MonthlyCharges
windows()
ggplot(DMRusers, aes(x = RgMtCharges, fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by RgMtCharges", x = "RgMtCharges", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por Rango Tenure
windows()
ggplot(DMRusers, aes(x = RgTenure, fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by RgTenure", x = "RgTenure", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))



# Churn por Rango TotalCharges
windows()
ggplot(DMRusers, aes(x = RgTtCharges, fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by RgTtCharges", x = "RgTtCharges", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por InternetService
windows()
ggplot(DMRusers, aes(x = InternetService, fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by InternetService", x = "InternetService", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por SeniorCitizen
windows()
ggplot(DMRusers, aes(x = as.factor(SeniorCitizen), fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by SeniorCitizen", x = "SeniorCitizen", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por PaymentMethod
windows()
ggplot(DMRusers, aes(x = PaymentMethod, fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by PaymentMethod", x = "PaymentMethod", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por Contract
windows()
ggplot(DMRusers, aes(x = Contract, fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by Contract", x = "Contract", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por Tenure
windows()
ggplot(DMRusers, aes(x = tenure, fill = Churn)) +
  geom_bar(position = "fill", aes(y = ..count.. / tapply(..count.., ..x.., sum)[..x..])) + 
  geom_text(stat = "count", 
            aes(label = scales::percent(..count.. / tapply(..count.., ..x.., sum)[..x..])),
            position = position_fill(vjust = 0.5)) + 
  labs(title = "Churn by Tenure", x = "Tenure", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por gender
windows()
ggplot(DMRusers, aes(x = gender, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by Gender", x = "Gender", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por Partner
windows()
ggplot(DMRusers, aes(x = Partner, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by Partner", x = "Partner", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por Dependents
windows()
ggplot(DMRusers, aes(x = Dependents, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by Dependents", x = "Dependents", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por PhoneService
windows()
ggplot(DMRusers, aes(x = PhoneService, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by PhoneService", x = "PhoneService", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por MultipleLines
windows()
ggplot(DMRusers, aes(x = MultipleLines, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by MultipleLines", x = "MultipleLines", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))


# Churn por OnlineSecurity
windows()
ggplot(DMRusers, aes(x = OnlineSecurity, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by OnlineSecurity", x = "OnlineSecurity", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por OnlineBackup
windows()
ggplot(DMRusers, aes(x = OnlineBackup, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by OnlineBackup", x = "OnlineBackup", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por DeviceProtection
windows()
ggplot(DMRusers, aes(x = DeviceProtection, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by DeviceProtection", x = "DeviceProtection", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por TechSupport
windows()
ggplot(DMRusers, aes(x = TechSupport, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by TechSupport", x = "TechSupport", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por StreamingTV
windows()
ggplot(DMRusers, aes(x = StreamingTV, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by StreamingTV", x = "StreamingTV", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por StreamingMovies
windows()
ggplot(DMRusers, aes(x = StreamingMovies, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by StreamingMovies", x = "StreamingMovies", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Churn por PaperlessBilling
windows()
ggplot(DMRusers, aes(x = PaperlessBilling, fill = Churn)) +
  geom_bar(position = "fill") +
  labs(title = "Churn by PaperlessBilling", x = "PaperlessBilling", y = "Proportion") +
  scale_fill_manual(values = c("steelblue", "tomato"))

# Boxplot para detectar outliers en Monthly Charges
windows()
outliers_monthly <- boxplot.stats(DMRusers$MonthlyCharges)$out
ggplot(DMRusers, aes(x = "", y = MonthlyCharges)) +
  geom_boxplot() +
  geom_text(aes(label = ifelse(MonthlyCharges %in% outliers_monthly, round(MonthlyCharges, 1), "")),
            position = position_jitter(width = 0.2), vjust = -0.5, size = 3, color = "red") +
  labs(title = "Outlier Detection in Monthly Charges", y = "Monthly Charges")

# Boxplot para detectar outliers en Total Charges
windows()
outliers_total <- boxplot.stats(DMRusers$TotalCharges)$out
ggplot(DMRusers, aes(x = "", y = TotalCharges)) +
  geom_boxplot() +
  geom_text(aes(label = ifelse(TotalCharges %in% outliers_total, round(TotalCharges, 1), "")),
            position = position_jitter(width = 0.2), vjust = -0.5, size = 3, color = "red") +
  labs(title = "Outlier Detection in Total Charges", y = "Total Charges")