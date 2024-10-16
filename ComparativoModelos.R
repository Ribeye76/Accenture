
## COMPARATIVO DE MODELOS

# Comparar Accuracy
accuracy_tree <- confusionMatrix(dt_class, testData$Churn)$overall['Accuracy']
accuracy_rf <- confusionMatrix(rf_class, testData$Churn)$overall['Accuracy']
accuracy_log <- confusionMatrix(logistic_class, testData$Churn)$overall['Accuracy']
accuracy_gbm <- confusionMatrix(gbm_class, testData$Churn)$overall['Accuracy']

# Extraer Sensitivity
sensitivity_tree <- confmat_dt$byClass["Sensitivity"]
sensitivity_rf <- confmat_rf$byClass["Sensitivity"]
sensitivity_log <- confmat_log$byClass["Sensitivity"]
sensitivity_gbm <- confmat_gbm$byClass["Sensitivity"]

# Extraer specificity
specificity_tree <- confmat_dt$byClass["Specificity"]
specificity_rf <- confmat_rf$byClass["Specificity"]
specificity_log <- confmat_log$byClass["Specificity"]
specificity_gbm <- confmat_gbm$byClass["Specificity"]

# Crear tabla sumaria
model_comparison <- data.frame(
  Model = c("Decision Tree", "Random Forest", "Logistic Regression", "Gradient Boosting"),
  Specificity = c(specificity_tree, specificity_rf, specificity_log, specificity_gbm),
  Sensitivity = c(sensitivity_tree, sensitivity_rf, sensitivity_log, sensitivity_gbm),
  Accuracy = c(accuracy_tree, accuracy_rf, accuracy_log, accuracy_gbm),
  AUC = c(auc(roc_tree), auc(roc_rf), auc(roc_log), auc(roc_gbm))
)

# Imprimir comparativo
print(model_comparison)
