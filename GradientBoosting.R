
## GRADIENT BOOSTING

# Entrenar modelo Gradient Boosting usando Caret
gbm_caret_model <- train(
  Churn ~ .,
  data = trainData,                
  method = "gbm",                  
  trControl = train_control,       
  metric = "ROC",                  
  tuneLength = 5,                  
  verbose = FALSE                  
)

# Sumario del modelo
print(gbm_caret_model)

# Predecir probabilidades
gbm_probabilities <- predict(gbm_caret_model, newdata = testData, type = "prob")

# Extraer probabilidades de "Yes"
gbm_prob_yes <- gbm_probabilities[,"Yes"]

# Predecir clases
gbm_class <- predict(gbm_caret_model, newdata = testData)

# Generar Matriz de Confusion
confmat_gbm <- confusionMatrix(gbm_class, testData$Churn)

# Generar curva ROC y AUC
roc_gbm <- roc(testData$Churn, gbm_prob_yes)

# Graficar la curva ROC
windows(width = 8, height = 6)
plot(roc_gbm, col = "orange", main = "ROC Curve - Gradient Boosting")

# Calcular e imprimir ROC
auc_gbm <- auc(roc_gbm)
print(auc_gbm)