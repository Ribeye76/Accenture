# Cargar librerías necesarias
library(readxl)
library(dplyr)
library(ggplot2)
library(readr)
library(caret)
library(corrplot)

# Cargar dataset
Charges <- read_excel("Data.xlsx", sheet = "Charges")
OtherData <- read_excel("Data.xlsx", sheet = "Other data")
Churn <- read_excel("Data.xlsx", sheet = "Churn")

# Unir los datasets con inner join en 'CustomerID'
DMRusers <- Charges %>%
  inner_join(OtherData, by = "customerID") %>%
  inner_join(Churn, by = "customerID")

# Agregar columnas en forma de rango para Monthly Charges, Total Charges y Tenure
DMRusers <- DMRusers %>%
  mutate(RgTenure = case_when(
    tenure <= 6 ~ "Low Tenure",
    tenure > 6 & tenure <= 24 ~ "Medium Tenure",
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

# Eliminar usuarios de mas de 6 meses
DMRusers <- DMRusers %>%
  filter(tenure < 60) 

# Remover renglones con NA
DMRusers <- DMRusers %>%
  filter(!is.na(TotalCharges)) %>% 
  filter(!is.na(MonthlyCharges))

# Revisar presencia de NA
sum(is.na(DMRusers))

#Eliminar columna de CustomerID
dropcolumns <- "customerID"
DMRusers = DMRusers[,!(names(DMRusers) %in% dropcolumns)]

# Convertir variables categóricas a factores
DMRusers$Churn <- as.factor(DMRusers$Churn)  # Target variable
DMRusers$gender <- as.factor(DMRusers$gender)
DMRusers$SeniorCitizen <- as.factor(DMRusers$SeniorCitizen)
DMRusers$Partner <- as.factor(DMRusers$Partner)
DMRusers$Dependents <- as.factor(DMRusers$Dependents)
DMRusers$PhoneService <- as.factor(DMRusers$PhoneService)
DMRusers$MultipleLines <- as.factor(DMRusers$MultipleLines)
DMRusers$InternetService <- as.factor(DMRusers$InternetService)
DMRusers$OnlineSecurity <- as.factor(DMRusers$OnlineSecurity)
DMRusers$OnlineBackup <- as.factor(DMRusers$OnlineBackup)
DMRusers$DeviceProtection <- as.factor(DMRusers$DeviceProtection)
DMRusers$TechSupport <- as.factor(DMRusers$TechSupport)
DMRusers$StreamingTV <- as.factor(DMRusers$StreamingTV)
DMRusers$StreamingMovies <- as.factor(DMRusers$StreamingMovies)
DMRusers$Contract <- as.factor(DMRusers$Contract)
DMRusers$PaperlessBilling <- as.factor(DMRusers$PaperlessBilling)
DMRusers$PaymentMethod <- as.factor(DMRusers$PaymentMethod)
DMRusers$RgTenure <- as.factor(DMRusers$RgTenure)
DMRusers$RgMtCharges <- as.factor(DMRusers$RgMtCharges)
DMRusers$RgTtCharges <- as.factor(DMRusers$RgTtCharges)


# Set seed para reproductibilidad
set.seed(1306)

# Dividir los datos (80% train, 20% test)
trainIndex <- createDataPartition(DMRusers$Churn, p = 0.8, list = FALSE)
trainData <- DMRusers[trainIndex,]
testData <- DMRusers[-trainIndex,]

# Definir el parámetro training control de Caret con 5 cross-validaciones para entrtenar modelos
train_control <- trainControl(
  method = "cv",                    # Cross-validation
  number = 5,                       # 5 veces
  classProbs = TRUE,                
  summaryFunction = twoClassSummary, # Usar AUC para seleccionar mejor modelo
  verboseIter = FALSE                
)