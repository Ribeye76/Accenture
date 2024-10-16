# Accenture
Proyecto DMR Resources Limited - personalized micro credits

**********************************
**Análisis Exploratorio de Datos**
**********************************
Se analizó la base de datos de 7,043 clientes con características demográficas, monto de cargos y churn uniéndola en una tabla única. A la misma base se agregaron 3 columnas de rango con tres niveles para las variables numéricas en los datos: Tenure, MontlyCharges y TotalCharges.

El evento Churn se tuvo para cerca del 50% de los casos en la base de datos. Para analizar las variables que inciden, se cruzó la tasa de Churn con cada una de las dimensiones disponibles usando ggplot, para la mayoría de las variables se vió muy poca relevancia, teniendo porcentajes similares para los diferentes niveles de cada dimensión.
Las más destacables fueron:

-Tenure.- Fue la variable más relevante de las analizadas. Tomando la columna de rangos RgTenure, para Clientes con Tenure menor o igual a 6, la tasa de churn fue de 69.7%, mientras que usuarios con Tenure mayor o igual a 24 tuvieron tasa de 41.8%. Para esta variable tambien fue relevante tomar en cuenta la estructura de la población según su Tenure considerando que en los meses de 0 a 24 se tuvo una adquisición de usuarios acelerada. Por ejemplo, de los clientes con menos de 1 mes de antigüedad (Tenure <= 1), la tasa de Churn es de 74.5%.
-InternetService.- Los clientes con servicio de internet de Fibra Óptica tuvieron una tasa de Churn de 60.9% vs una de 37.0% para clientes sin servicio de internet.
-SeniorCitizen.- Los clientes identificados como Senior Citizens tuvieron una tasa de churn de 60.7%
-PaymentMethod.- Para clientes con PaymentMethod = Electronic check la tasa de Churn fue de 62.5%
-Contract.- Los clientes con Contrat = month-to-month tuvieron una tasa de Churn de 61%

Tambien se analizó mediante gráficos de Boxplot y tablas con valores de los percentiles la dispersión en las variables continuas: MonthlyCharges y TotalCharges. En ambos casos no se encontraron casos que considerar atípicos.

Datos Faltantes.- Sin embargo, se tuvieron 76 valores vacíos (NA), presentes en alguna o algunas de las columnas MonthlyCharges y TotalCharges, en un total de 38 clientes. Al representar 0.5% se decidió eliminar estos casos de la base de datos.

El código correspondiente para analizar y generar todos los gráficos y tablas mencionados se puede visualizar en la rama (insertar rama)


*****************************************************
**Extracción, Transformación y Carga de Datos (ETL)**
*****************************************************
Para preparar los datos para la selección de modelos, se definieron como factores cada una de las columnas de datos demográficos o rangos construidos de la tabla.
Usando set.seed(1306), se crearon los datasets: TrainData y TestData con 80% y 20% de los casos respectivamente.

**************************************
**Selección de Modelos y Comparación**
**************************************
Por las características del problema planteado, se decidió probar con los siguientes modelos: Random Forest, Logistic Regression y Gradient Boosting.
Adicional, se consideró tambien un Decision Tree, por su interpretabilidad.

Para cada caso, se usó el paquete Caret, con el fin de seleccionar los parámetros óptimos y calcular mejor el rendimiento del modelo usando 5 crosvalidaciones especificadas mediante TrainControl(). Los resultados obtenidos fueron:

                 Model Specificity Sensitivity  Accuracy       AUC
1       Decision Tree   0.5681818   0.6810345 0.6242857 0.6091056
2       Random Forest   0.5639205   0.7040230 0.6335714 0.6707423
3 Logistic Regression   0.6022727   0.6839080 0.6428571 0.6829621
4   Gradient Boosting   0.5951705   0.6824713 0.6385714 0.6757364

El modelo con mejor performance fue Logistic Regression, con una AUC de 0.6829
Sin embargo, este performance se encuentra por debajo de un desempeño aceptable (entre 70% y 80%)

Considerando el resultado obtenido por el modelo de Decision Tree, donde el primer corte es cliente con Tenure < 6, separando clientes con una probabilidad de Churn de 70%, se decidió correr nuevamente el modelo, pero considerando solo clientes con un Tenure menor a 6. Con esto, se obtuvieron los siguientes resultados:

Clientes con Tenure < 6
                Model Specificity Sensitivity  Accuracy       AUC
1       Decision Tree   0.9153439   0.3048780 0.7306273 0.6091056
2       Random Forest   0.9470899   0.2560976 0.7380074 0.7345141
3 Logistic Regression   0.9365079   0.2682927 0.7343173 0.7530326
4   Gradient Boosting   0.8941799   0.3292683 0.7232472 0.7421925

Para los datos de clientes con Tenure < 6, aunque el mejor modelo sigue siendo Logistic Regression, es de destacar los niveles de Specificity que alcanzan los modelos.
En particular, por ejemplo, el modelo de Decision Tree, con un Specificity de 0.91, es capaz de predecir correctamente el 91% de los casos que efectivamente resultan en Churn. Es decir, el modelo habría predicho que de los 271 casos, 230 resultarían en Churn, de los cuales, 173 efectivamente resultaron en Churn y 57 no.

En contraparte, el valor de Sensivity de 0.30 indica que solo 30% de los casos que no produjeron Churn fueron identificados previamente por el modelo. Es decir, el modelo habría predicho que 41 de los 271 casos no resultarían en Churn, de los cuales 25 efectivamente resultaron en Churn y 16 no.

Confusion Matrix Decision Tree
          Reference
Prediction    No Yes Total
       No     25  16   41
       Yes    57 173  230
       Total l82 189  271

Usar este modelo produciría que rechazáramos 84% del total de créditos

Dentro de la base de datos compartida, se encontró que un 21% de los clientes tienen un valor de Tenure >= 60. La tasa de Churn para este grupo de clientes es de 37%. Tomando esto en cuenta, se decidió filtrar este grupo de clientes de alta permanencia, que parece tener un comportamiento diferente en terminos de Churn, debido a vinculación, fidelidad y/o costos de cambio. Entonces se corrieron los modelos filtrando clientes con Tenure < 60, obteniendo los siguientes resultados:

Clientes con Tenure < 60
                Model Specificity Sensitivity  Accuracy       AUC
1       Decision Tree   0.6346801   0.6484375 0.6410488 0.6091056
2       Random Forest   0.6851852   0.6035156 0.6473779 0.6967313
3 Logistic Regression   0.6868687   0.6152344 0.6537071 0.6994604
4   Gradient Boosting   0.6498316   0.6562500 0.6528029 0.6982504

El valor de AUC obtenido por el modelo Logistic Regression tiene una AUC de 0.699, muy cercana al mínimo requerido de 70%. Adicionalmente muestra unos valores de Specificity y Sensitivity balanceados. Este modelo podría ser considerado como una alternativa, resultando en lo siguiente:

Confusion Matrix Logistic Regression
          Reference
Prediction  No Yes Total
       No  315 186 501
       Yes 197 408 605
     Total 512 594 1,106

Es decir, el modelo Logistic Regression, haría las siguientes predicciones:
- Para 54% de los créditos predecirá que harán churn. De estos, 67.4% efectivamente lo harán y 32.6% no (es decir, serán rechazados erroneamente por el modelo). Esto equivale a 17.6% de los créditos colocados en el período respectivo.
- Para el otro 46% de los créditos predecirá que no hará churn. De estos,62.8% no lo harán y 37.1% si (es decir, se dejarán pasar como buenos, pero eventualmente harán Churn). Esto equivale a 17.0% de los créditos colocados en el período respectivo.

Haciendo un comparativo para un periodo, suponiendo una adquision de 500 nuevos créditos:

*Actual
Colocados Churn NoChurn %Churn
500       269   231     53.8%

*Con Modelo
Solicitados Colocados  Churn NoChurn %Churn
500         226        84    142     37.2%    
            Rechazados Churn NoChurn %Churn
            274        184   90      67.2%


Adicional, el modelo de Decision Tree resultante para este set de datos consta de dos variables y resulta en 3 niveles de probabilidad de Churn, tal como se puede ver en el gráfico correspondiente.

Ambos modelos arrojan un valor probabilístico, el Decision Tree resultante en 3 niveles la Logistic Regression con probabilidad continua. Una alternativa que propone, dada la pérdida de créditos en cartera que el modelo directo generaría es usar el modelo para fines de ajuste de la tasa de interés, colocando a mayores tasas aquellos créditos más riesgosos.

Con el fin de avanzar rapidamente con esta implementación, se propone avanzar en dos fases, implementando el modelo Decision Tree como reglas de negocio, ofreciendo una de tres tasas diferenciadas según el nivel de riesgo calculado. En paralelo se prepararía el deployment del modelo de Logistic Regression, con resultado probabilístico para su impacto en el precio.

Adicionalmente, agregando más datos demográficos y comportamentales, será posible llegar a un modelo más robusto que pueda ser usado como discriminador. 



