
## RANDOM FOREST MODEL

# Entrenar modelo Random Forest con custom tuning grid
rf_caret_model <- train(
  Churn ~ .,                        # Target variable
  data = trainData,                 # Training data
  method = "rf",                    # Random Forest method
  trControl = train_control,        # Cross-validation control
  tuneLength = 3,                   # Number of different mtry values to try
  ntree = 500,                      # Number of trees
  metric = "ROC"                    # Optimize based on ROC AUC
)

# Ver mejores parámetros
print(rf_caret_model$bestTune)

# Ver resultados
print(rf_caret_model)

# Predecir probabilidades en TestData
rf_probabilities <- predict(rf_caret_model, newdata = testData, type = "prob")

# Extraer probabilidades de Yes
rf_prob_yes <- rf_probabilities[,"Yes"]

# Predecir clases en el testData
rf_class <- predict(rf_caret_model, newdata = testData)

# Generar Matriz de Confusión
confmat_rf <- confusionMatrix(rf_class, testData$Churn)

# Generar Curva ROC para modelo Random Forest
roc_rf <- roc(testData$Churn, rf_prob_yes)

# Graficar curva ROC
windows(width = 8, height = 6)
plot(roc_rf, col = "green", main = "ROC Curve - Random Forest")

# Calcular e imprimir AUC
auc_rf <- auc(roc_rf)
print(auc_rf)