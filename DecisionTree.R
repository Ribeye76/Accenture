
## MODELO DECISION TREE

# Entrenar modelo Decision Tree con Caret
dt_caret_model <- train(
  Churn ~ .,                          # Variable objetivo
  data = trainData,                   # Training data
  method = "rpart2",                  # Decision tree
  trControl = train_control,          # Control Cross-validation
  maxdepth = 5,                       # Maxima profundidad
  metric = "ROC"                      # Optimizar por  ROC AUC
)

# Imprimir summary
print(dt_caret_model)

# Predecir probabilidades para TestData
dt_probabilities <- predict(dt_caret_model, newdata = testData, type = "prob")

# Extraer probabilidades = Yes
dt_prob_yes <- dt_probabilities[,"Yes"]

# Predecir clases para TestData
dt_class <- predict(dt_caret_model, newdata = testData)

# Generar matriz de confusión
confmat_dt <- confusionMatrix(dt_class, testData$Churn)
confmat_dt

# Curva ROC curve y AUC para Decision Tree model
roc_dt <- roc(testData$Churn, dt_prob_yes)

# Graficar curva ROC
windows(width = 8, height = 6)
plot(roc_dt, col = "blue", main = "ROC Curve - Decision Tree")

# Calcular e imprimir AUC
auc_dt <- auc(roc_dt)
print(auc_dt)

## GRAFICA DECISION TREE
# Cargar librerías necesarias
library(rpart.plot)  # Para visualizar el árbol de decisión
library(caret)       # Para entrenar el modelo de árbol de decisión

# Entrenar modelo:
dt_caret_model <- train(
  Churn ~ .,                          # Variable objetivo y predictores
  data = trainData,                   # Datos de entrenamiento
  method = "rpart2",                  # Método de árbol de decisión
  trControl = train_control,          # Control de validación cruzada
  maxdepth = 5,                       # Profundidad máxima del árbol
  metric = "ROC"                      # Optimizar basado en el AUC
)

# Extraer el modelo rpart subyacente
tree_model <- dt_caret_model$finalModel

# Visualizar el árbol de decisión con rpart.plot
windows()
rpart.plot(tree_model,
           type = 3,            # Mostrar las etiquetas de las ramas
           extra = 104,         # Mostrar probabilidades y porcentajes de cada clase
           fallen.leaves = TRUE, # Colocar las hojas al mismo nivel
           main = "Árbol de Decisión: Predicción de Churn", # Título del gráfico
           sub = "Basado en variables predictoras",          # Subtítulo
           box.palette = "Blues", # Colorear los nodos
           shadow.col = "gray",   # Agregar sombra a los nodos
           cex = 0.8)            # Ajustar el tamaño del texto
