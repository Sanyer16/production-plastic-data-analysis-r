# 📊 Estadística Descriptiva de Datos de Producción Industrial con RStudio

Este proyecto presenta un análisis estadístico descriptivo aplicado a datos reales de producción de una planta de plásticos. Utilizando R y RStudio, se realiza un flujo completo de análisis que incluye la carga, limpieza, transformación y visualización de los datos, con el objetivo de extraer información clave sobre eficiencia, uso de máquinas, turnos de trabajo y desempeño operativo.

---

## 🔧 Herramientas y Librerías Utilizadas

- **R** y **RStudio**
- `readxl` – Importación de archivos Excel
- `dplyr` – Manipulación de datos
- `lubridate` – Manejo de fechas
- `ggplot2` – Visualización de datos
- `moments` – Asimetría y curtosis
- `tidyr` – Transformación de datos en formato largo

---

## 🗂️ Estructura del Proyecto

- **PLANTA PRODUCCION.xlsx**: Archivo de datos original en Excel.
- **script_R.R**: Script en R con todo el proceso de carga, limpieza, análisis y visualización.
- **rdata.RData**: Archivo con los objetos guardados en memoria (df, df2, etc.).
- **r.jpg**: Imagen ilustrativa del entorno R.
- **README.md**: Documentación del proyecto.

### Carpeta `output/` – Visualizaciones generadas:
- `Barplot-TurnosMaquina.png`
- `Barplot-TurnosPorTipo.png`
- `boxplot-conformes.png`
- `boxplot-conformesMaquina.png`
- `boxplot-dispersionEficienciaMaquina.png`
- `Histograma-eficiencia.png`
- `pie-DistribucionTurnos.png`
- `plot-eficienciaMinutosParada.png`
- `PoligonoFrecuencia-MinutosParada.png`


---

## 📌 Pasos Clave del Análisis

1. **Carga de Datos**
   - Lectura del archivo Excel conservando nombres originales, incluso si están duplicados.

2. **Exploración Inicial**
   - Análisis de estructura, dimensiones, tipos de datos, y detección de valores nulos.

3. **Limpieza de Datos**
   - Conversión de tipos de datos, eliminación de registros con errores, tratamiento de valores atípicos y nulos.

4. **Transformación**
   - Subconjuntos de columnas, creación de nuevas variables como porcentaje de eficiencia, y etiquetado para reportes.

5. **Visualización**
   - Diagramas de barras, gráficos de pastel, polígonos de frecuencia, boxplots y correlaciones entre variables.

6. **Estadística Descriptiva**
   - Cálculo de media, mediana, desviación estándar, rango, varianza, IQR, asimetría y curtosis.

7. **Análisis Segmentado**
   - Comparaciones entre turnos (diurno vs nocturno), desempeño por máquina y dispersión de variables clave.

---

## 🧠 Objetivo del Proyecto

Brindar una comprensión estadística clara de los datos operativos de producción, permitiendo identificar ineficiencias, patrones de desempeño y oportunidades de mejora. Este proyecto fue desarrollado como parte de mi formación en la **Especialización en Big Data y Analítica de Datos**, fortaleciendo mis habilidades en R y análisis exploratorio de datos (EDA).

---

## 🚀 ¿Cómo ejecutar el script?

1. Asegúrate de tener R y RStudio instalados.
2. Instala las librerías necesarias:
```r
install.packages(c("readxl", "dplyr", "lubridate", "ggplot2", "moments", "tidyr"))
```
3. Ejecuta el archivo script_R.R ubicado en la carpeta scripts/.

---




