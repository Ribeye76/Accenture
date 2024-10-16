
##LOGISTIC REGRESSION

# Definir grid de hiperparametros para alpha (mezcla de L1 and L2) y lambda
elastic_grid <- expand.grid(
  alpha = seq(0, 1, by = 0.1),  # Alpha de 0 (Ridge) a 1 (Lasso)
  lambda = seq(0.001, 0.1, by = 0.01)  # Rango de valores lambda
)

logistic_model <- train(
  Churn ~ .,                         
  data = trainData,                  
  method = "glmnet",                 
  trControl = train_control,         
  tuneGrid = elastic_grid,           
  metric = "ROC"                     
)

# Imprimir sumario
print(logistic_model)

# Predecir probabilidades en testData
logistic_probabilities <- predict(logistic_model, newdata = testData, type = "prob")

# Extraer probabilidades de "Yes"
logistic_prob_yes <- logistic_probabilities[,"Yes"]

# Predecir clases en el testData
logistic_class <- predict(logistic_model, newdata = testData)

# Generar matriz de Confusion
confmat_log <- confusionMatrix(logistic_class, testData$Churn)
confmat_log

# Generar curva ROC para el modelo Logistic Regression
roc_log <- roc(testData$Churn, logistic_prob_yes)

# Graficar la curva ROC
windows(width = 8, height = 6)
plot(roc_log, col = "red", main = "ROC Curve - Logistic Regression")

# Calcular e imprimir AUC
auc_log <- auc(roc_log)
print(auc_log)