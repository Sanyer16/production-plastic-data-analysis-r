
######################### --> CARGA DE DATOS <---  #########################

# Instalar paquete readxl si no está instalado
if (!require("readxl")) install.packages("readxl")

library(readxl)

# Leer archivo .xlsx conservando nombres duplicados
df <- read_excel("C:/Users/Usuario/OneDrive/Documentos/Ingeniero Datos/Proyectos/ESTADISTICA DESCRIPTIVA EN RSTUDIO/PLANTA PRODUCCION.xlsx",
                 sheet = "Produccion Plasticos",
                 .name_repair = "minimal")



#CAMPOS REPETIDOS EN EL ARCHIVO: R REEMPLAZA ESTOS NOMBRES Y ADICIONA SUFIJOS (SOLO SE VE EN LA VISTA):
# Motivos de parada de Maquina en el turno
# Cantidad de minutos parada la maquina
# COMENTARIO GENERAL

######################### --> EXPLORACION DE DATOS <---  #########################


# VER PRIMERAS FILAS
head(df)

#VALIDAR TIPO DE DF
class(df)

# MOSTRAR LA FORMA DEL DF(FILAS: 7387, COLUMNAS: 47)
dim(df)

#MOSTRAR NOMBRES DE COLUMNA
colnames(df)

#MOSTRAR ESTADISTICAS DESCRIPTIVAS DE LAS COLUMNAS NUMERICAS
summary(df)

#VER INFORMACION GENERAL(TIPO DE DATOS)
str(df)

#TIPO DE DATOS POR COLUMNAS
sapply(df, class)

#VALIDAR NULOS POR COLUMNAS
colSums(is.na(df))

######################### --> DF PARA ESTADISTICA DESCRIPTIVA RSTUDIO <---  #########################

#CREAR SUBCONJUNTO DF2 CON LAS COLUMNAS SELECCIONAS DESDE EL DF ORIGINAL

# Cargar librerías (si no están cargadas)
if (!require("dplyr")) install.packages("dplyr")
if (!require("lubridate")) install.packages("lubridate")

library(dplyr)
library(lubridate)

# CREAR DF2 SELECCIONANDO LAS COLUMNAS SIN SUFIJOS (YA QUE HAY COLUMNAS CON EL MISMO NOMBRE)

df2 <- df %>%
  select(
    marca_temporal = 1,      # Columna 1: Marca temporal
    fecha = 2,               # Columna 2: Fecha
    hora_inicio = 3,         # Columna 3: HORA INICIO
    hora_final = 14,         # Columna 14: HORA FINAL
    tipo_turno = 5,          # Columna 5: Tipo de turno
    operario = 4,            # Columna 4: Operario
    maquina = 8,             # Columna 8: MAQUINA
    conformes = 9,           # Columna 9: Cantidad producidas CONFORMES en el turno
    no_conformes = 10,       # Columna 10: Cantidad No conformes en el turno
    motivos_parada = 11,     # Columna 11: Motivos de parada de Maquina en el turno
    minutos_parada = 12,     # Columna 12: Cantidad de minutos parada la maquina
    comentario = 13,         # Columna 13: COMENTARIO GENERAL
    semaforo = 33,           # Columna 33: SEMAFORO (verifica posición)
    eficiencia = 34          # Columna 34: % EFICIENCIA... (verifica posición)
  )

#VERIFICACION

head(df2) %>% View()  # Ver las primeras filas
str(df2)              # Confirmar estructura

######################### --> Escoger 4 o 5 variables <---  #########################

#Cuantitativas
#conformes       --> Mide la productividad directa.
#minutos_parada  --> Eficiencia operativa (tiempos muertos).
#eficiencia      --> Efectividad global del turno


#Cualitativas
#tipo_turno      --> Permite comparar rendimiento diurno/nocturno.
#maquina         -->  Identifica diferencias entre maquinas.


######################### --> LIMPIEZA DE DATOS <---  #########################

library(dplyr)

#Eliminar marca_temporal

df2 <- df2 %>% select(-marca_temporal)

#VERIFICACION
colnames(df2)

#########################

# eliminar [tipo_turno] = vacios  || 107 valores vacios
colSums(is.na(df2))

df2 <- df2 %>% filter(!is.na(tipo_turno))

#VERIFICACION
colSums(is.na(df2))

#########################

#cambiar a tipo numerico --> de datos correcto [conformes] [no_conformes] [minutos_parada]

df2 <- df2 %>%
  mutate(                                                    #mutate para modificar columnas dentro de df2
    conformes = as.numeric(conformes),
    no_conformes = as.numeric(no_conformes),
    minutos_parada = ifelse(is.na(minutos_parada), 0, minutos_parada),
    minutos_parada = as.numeric(minutos_parada)
  )

# Reemplaza cualquier valor NA en la columna conformes por 0

df2 <- df2 %>%
  mutate(
    conformes = ifelse(is.na(conformes), 0, conformes),
    no_conformes = ifelse(is.na(no_conformes), 0, no_conformes)
  )

#VERIFICACION
colSums(is.na(df2))

#########################

#eficiencia --> negatitos reemplazar con promedio

sum(df2$eficiencia < 0, na.rm = TRUE) #12 valores negativos

#promedio [eficiencia]
mean(df2$eficiencia, na.rm = TRUE)  #0.69572 --> 69,75% (hace el promedio tomando tambien los negativos)

#calculamos el promedio
  #(hace el promedio solo con positivos) 0.70 --> 70%

prom_eficiencia <- mean(df2$eficiencia[df2$eficiencia >= 0], na.rm = TRUE) 

#Reemplazar los valores negativos con ese promedio

df2 <- df2 %>%
  mutate(eficiencia = ifelse(eficiencia < 0, prom_eficiencia, eficiencia))

#validar eficiencia negativa (ya no hay valores negativos)
sum(df2$eficiencia < 0, na.rm = TRUE)

#########################

#fecha tiene 3 NA || es porque tienen el formato mal 6/12/0024 -- 12/15/0024 -- 6/25/0024

#(validar NA)
df2 %>% filter(is.na(fecha)) %>% View()

#eliminar estos 3 registros || No se puede reemplazar
df2 <- df2 %>% filter(!is.na(fecha))

#validacion de NA (ya no hay)
df2 %>% filter(is.na(fecha)) %>% View()

#adicionar nueva columna de eficiencia (no decimales)

df2 <- df2 %>%
  mutate(eficiencia_pct = eficiencia * 100)

#adicionar nueva columna de eficiencia % (texto --> para reportes)
df2 <- df2 %>%
  mutate(
    eficiencia_pct_label = paste0(round(eficiencia * 100, 2), "%")
  )

#########################

#confirmar si si es posible tener eficiencia superior al 100%
sum(df2$eficiencia > 1, na.rm = TRUE) #valores por encima del 100% --> 1300

#visualizar registros con eficiencia superior al 100%
library(dplyr)

df2 %>%
  filter(eficiencia > 1) %>%
  View()


# MOSTRAR LA FORMA DEL DF(FILAS: 7277, COLUMNAS: 15)
dim(df2)


#eliminar las filas con eficiencia por encima del 200% (ya que digitaron de forma errada || se elimina: 39 refggistros )

library(dplyr)

df2 <- df2 %>%
  filter(eficiencia < 2)

#validar cantidad de columnas y filas (filas: 7238 , columnas: 15)

dim(df2)

#Eliminar valores negativos de conformes (1 registro)

df2 <- df2 %>%
  filter(conformes >= 0 | is.na(conformes))

#validar cantidad de columnas y filas (7237   15)

dim(df2)


######################### --> VISUALIZAR DATOS <---  #########################

# Frecuencia por tipo_turno
tabla_turno <- table(df2$tipo_turno)

# Barplot
barplot(tabla_turno,
        main = "Cantidad de Turnos por Tipo",
        xlab = "Tipo de Turno",
        ylab = "Cantidad de registros",
        col = "skyblue")

# La mayoría de los registros corresponden al Turno 1, seguido por el Turno 12 horas nocturno y Turno 3,
# mientras que el Turno 6 tiene una presencia mínima, mostrando una clara desigualdad en la distribución de turnos.

#/////////////#

#Barplot de frecuencia por máquina

# Frecuencia por máquina
tabla_maquina <- table(df2$maquina)

# Barplot
barplot(tabla_maquina,
        main = "Cantidad de Turnos por Máquina",
        xlab = "Máquina",
        ylab = "Cantidad de registros",
        col = "lightgreen",
        las = 2)  # gira etiquetas


# Cantidad de Turnos por Máquina (Ordenado)
tabla_maquina_ordenada <- sort(tabla_maquina, decreasing = TRUE)

# Barplot ordenado
barplot(tabla_maquina_ordenada,
        main = "Cantidad de Turnos por Máquina (Ordenado)",
        xlab = "Máquina",
        ylab = "Cantidad de registros",
        col = "lightgreen",
        las = 2)

# Las máquinas IMS 680, IMS 400 y TIAN 1000 concentran la mayoría de los registros de turnos, 
# mientras que MR 250 e IMS680 apenas registran actividad, evidenciando una marcada concentración 
# del trabajo en pocas máquinas

#////////////////////////////////////////////////////////////////////#

#Pie Chart de tipo_turno
#Generamos la tabla de frecuencias:

tabla_turno <- table(df2$tipo_turno)

#Generamos etiquetas con porcentaje:

# Porcentajes
porcentajes <- round(prop.table(tabla_turno) * 100, 1)

# Etiquetas con nombre y porcentaje
etiquetas <- paste0(names(tabla_turno), " (", porcentajes, "%)")


#Pie Chart:

pie(tabla_turno,
    labels = etiquetas,
    main = "Distribución de Turnos",
    col = c("lightblue", "lightgreen"))


# Los turnos de 12 horas (diurno y nocturno), Turno 1 y Turno 2 concentran la mayor parte de la actividad,
# siendo el Turno 6 marginal en la distribución.

#////////////////////////////////////////////////////////////////////#

#Barras para datos agrupados:

#Barras agrupadas de frecuencia por turno y máquina
#creamos una tabla de contingencia:

tabla_turno_maquina <- table(df2$tipo_turno, df2$maquina)

#grafica

barplot(tabla_turno_maquina,
        beside = TRUE,      # para agrupar barras
        col = c("skyblue", "lightgreen"),   # colores por turno
        legend = rownames(tabla_turno_maquina),
        main = "Cantidad de Turnos por Máquina",
        xlab = "Máquina",
        ylab = "Cantidad de registros",
        las = 2)   # gira las etiquetas del eje x


# Las máquinas TIAN 1000, IMS 400 e IMS 680 son las más activas en todos los turnos, 
# mientras que IMS680 no registra actividad y MR 250 tiene muy poca, mostrando un uso muy desigual 
# y específico por máquina.


#////////////////////////////////////////////////////////////////////#

#Polígonos de frecuencia de conformes:

hist(df2$minutos_parada,
     freq = FALSE,
     breaks = 20,
     main = "Distribución de Minutos de Parada (Polígono de Frecuencia)",
     xlab = "Minutos de Parada",
     ylab = "Densidad",
     col = "lightgray",
     border = "white")

lines(density(df2$minutos_parada, na.rm = TRUE),
      col = "red",
      lwd = 2)

# La mayoría de las paradas de máquina son de muy corta duración (cercanas a 0 minutos), 
# con una frecuencia que disminuye drásticamente a medida que aumenta la duración de la parada; 
# las paradas prolongadas (más allá de unos pocos cientos de minutos) presentan una incidencia 
# notablemente baja.

####

#comparacion de turnos (dia vs noche)

# Crear subconjuntos con nombres correctos
conformes_dia <- df2$conformes[df2$tipo_turno == "Turno 12 horas diurno"]
conformes_noche <- df2$conformes[df2$tipo_turno == "Turno 12 horas nocturno"]

# Verificar que tengan datos
length(conformes_dia)
length(conformes_noche)

# Histograma vacío
hist(conformes_dia,
     freq = FALSE,
     breaks = 20,
     main = "Distribución de Conformes por Turno",
     xlab = "Cantidad Conformes",
     ylab = "Densidad",
     col = "white",
     border = "white",
     ylim = c(0, 0.02))

# Polígono de frecuencia: Turno Diurno
lines(density(conformes_dia, na.rm = TRUE),
      col = "blue",
      lwd = 2)

# Polígono de frecuencia: Turno Nocturno
lines(density(conformes_noche, na.rm = TRUE),
      col = "red",
      lwd = 2)

# Leyenda
legend("topright",
       legend = c("12h Diurno", "12h Nocturno"),
       col = c("blue", "red"),
       lwd = 2)

# Ambos turnos, diurno y nocturno de 12 horas, exhiben una distribución similar de producción
# de conformes, con la mayor densidad concentrada en bajas cantidades de producción, 
# y una disminución rápida de la frecuencia a medida que aumenta la cantidad de conformes, 
# indicando que las producciones muy altas son poco comunes en ambos turnos.


#////////////////////////////////////////////////////////////////////#

#Medidas de tendencia Central

# MEDIA
mean_conformes <- mean(df2$conformes, na.rm = TRUE)
mean_eficiencia <- mean(df2$eficiencia_pct, na.rm = TRUE)
mean_parada <- mean(df2$minutos_parada, na.rm = TRUE)

# MEDIANA
median_conformes <- median(df2$conformes, na.rm = TRUE)
median_eficiencia <- median(df2$eficiencia_pct, na.rm = TRUE)
median_parada <- median(df2$minutos_parada, na.rm = TRUE)

# Mostrar resultados
mean_conformes
median_conformes

mean_eficiencia
median_eficiencia

mean_parada
median_parada

# En estadística descriptiva, no siempre se grafican las medidas de tendencia central directamente,
# pero sí se pueden mostrar en gráficos de forma ilustrativa y muy informativa.

# indicando que la mayoría de los registros son bajos pero con la presencia de valores muy altos;
# la eficiencia tiene una media ligeramente inferior a su mediana, sugiriendo una distribución 
# más balanceada o con valores atípicos bajos.

### Graficar con Media y Mediana

# Histograma
hist(df2$eficiencia_pct,
     breaks = 20,
     main = "Eficiencia (%) con Media y Mediana",
     xlab = "Eficiencia (%)",
     col = "lightgray",
     border = "black")

# Línea de la media
abline(v = mean(df2$eficiencia_pct, na.rm = TRUE),
       col = "blue",
       lwd = 2,
       lty = 2)

# Línea de la mediana
abline(v = median(df2$eficiencia_pct, na.rm = TRUE),
       col = "red",
       lwd = 2,
       lty = 2)

# Leyenda
legend("topright",
       legend = c("Media", "Mediana"),
       col = c("blue", "red"),
       lwd = 2,
       lty = 2)


# La distribución de la eficiencia muestra que la mayoría de los registros se concentran 
# entre el 60% y el 100%, con una ligera asimetría hacia la izquierda, donde la mediana 
# (74.06%) es marginalmente superior a la media (69.45%), indicando que la eficiencia típica 
# es algo mayor que el promedio general.

#////////////////////////////////////////////////////////////////////#

#Medidas de dispersión

# Rango
range_conformes <- range(df2$conformes, na.rm = TRUE)
range_eficiencia <- range(df2$eficiencia_pct, na.rm = TRUE)
range_parada <- range(df2$minutos_parada, na.rm = TRUE)

# Varianza
var_conformes <- var(df2$conformes, na.rm = TRUE)
var_eficiencia <- var(df2$eficiencia_pct, na.rm = TRUE)
var_parada <- var(df2$minutos_parada, na.rm = TRUE)

# Desviación estándar
sd_conformes <- sd(df2$conformes, na.rm = TRUE)
sd_eficiencia <- sd(df2$eficiencia_pct, na.rm = TRUE)
sd_parada <- sd(df2$minutos_parada, na.rm = TRUE)

# Mostrar resultados por separado
range_conformes
var_conformes
sd_conformes

range_eficiencia
var_eficiencia
sd_eficiencia

range_parada
var_parada
sd_parada


# La producción y los tiempos de parada son altamente variables, con registros muy altos 
# y paradas largas que distorsionan el promedio. La eficiencia también es variable, 
# lo que sugiere inconsistencias que se deban de analizar para estabilizar el rendimiento.


##

#Boxplot Conformes

boxplot(df2$conformes,
        main = "Dispersión de Conformes",
        ylab = "Cantidad Conformes",
        col = "lightblue",
        horizontal = TRUE)

#Histograma Conformes

hist(df2$conformes,
     breaks = 30,
     main = "Distribución de Conformes",
     xlab = "Cantidad Conformes",
     col = "lightgray",
     border = "black")

#Comparativo de Desviación Estándar
#(omparar dispersión de todas las variables)

# Desviaciones que ya calculaste
sd_values <- c(982.85, 34.58, 130.30)
names(sd_values) <- c("Conformes", "Eficiencia (%)", "Minutos Parada")

barplot(sd_values,
        main = "Desviación Estándar por Variable",
        ylab = "Desviación Estándar",
        col = "orange")


# La variable "Conformes" presenta la mayor desviación estándar, indicando una variabilidad 
# muy alta en la producción. "Minutos Parada" también muestra una desviación considerable, 
# mientras que la "Eficiencia (%)" es la variable más estable con la desviación estándar más baja.

#////////// HASTA ACA EL DOCUMENTO ///////////////////////////////////////////////////////#

#cuantiles específicos
quantile(df2$eficiencia_pct, probs = c(0.05, 0.5, 0.87), na.rm = TRUE)

#IQR - Rango intercuartílico
IQR(df2$eficiencia_pct, na.rm = TRUE)

#Boxplot combinados
boxplot(eficiencia_pct ~ tipo_turno, data = df2,
        main="Eficiencia por Turno",
        xlab="Turno", ylab="Eficiencia (%)",
        col="lightblue")


#Correlación y forma

plot(df2$conformes, df2$eficiencia_pct,
     main = "Eficiencia vs Conformes",
     xlab = "Conformes",
     ylab = "Eficiencia (%)",
     col = "blue")
cor(df2$conformes, df2$eficiencia_pct, use="complete.obs")


#Asimetría y curtosis

install.packages("moments")
library(moments)

skewness(df2$eficiencia_pct, na.rm = TRUE)
kurtosis(df2$eficiencia_pct, na.rm = TRUE)


#Gráficos segmentados

boxplot(conformes ~ maquina, data = df2,
        main="Conformes por Máquina",
        xlab="Máquina", ylab="Conformes",
        col=rainbow(5),
        las=2)

################################################################################



# Crear un data frame largo con las 3 variables
df_boxplot <- data.frame(
  Conformes = df2$conformes,
  Eficiencia = df2$eficiencia_pct,
  Minutos_Parada = df2$minutos_parada
)

# Convertir en formato largo
df_boxplot_long <- tidyr::pivot_longer(
  df_boxplot,
  cols = everything(),
  names_to = "Variable",
  values_to = "Valor"
)

# Crear el boxplot
boxplot(Valor ~ Variable,
        data = df_boxplot_long,
        main = "Distribución de Variables Clave",
        ylab = "Valor",
        col = "lightblue")

#/////////////////////////////////////////////////////////



# Cargar librería si no la tienes
if (!require("tidyr")) install.packages("tidyr")
library(tidyr)

# 1. Crear data frame con las 3 variables
df_boxplot <- data.frame(
  Conformes = df2$conformes,
  Eficiencia = df2$eficiencia_pct,
  Minutos_Parada = df2$minutos_parada
)

# 2. Convertir en formato largo
df_boxplot_long <- tidyr::pivot_longer(
  df_boxplot,
  cols = everything(),
  names_to = "Variable",
  values_to = "Valor"
)

# 3. Crear el boxplot
boxplot(Valor ~ Variable,
        data = df_boxplot_long,
        main = "Distribución de Variables Clave con Media",
        ylab = "Valor",
        col = "lightblue")

# 4. Calcular medias de cada variable
media_conformes <- mean(df2$conformes, na.rm = TRUE)
media_eficiencia <- mean(df2$eficiencia_pct, na.rm = TRUE)
media_parada <- mean(df2$minutos_parada, na.rm = TRUE)

# 5. Dibujar puntos de la media
points(
  x = 1:3,                                          # posición de cada boxplot
  y = c(media_conformes, media_eficiencia, media_parada),
  col = "red",
  pch = 18,                                         # símbolo de rombo
  cex = 1.5                                         # tamaño del punto
)

# 6. Añadir leyenda
legend("topright",
       legend = "Media",
       pch = 18,
       col = "red")

#////////////////////////////////////

boxplot(df2$minutos_parada,
        main = "Dispersión de Minutos de Parada",
        xlab = "Minutos",
        ylab = "",
        col = "lightgreen",
        horizontal = TRUE)


boxplot(df2$conformes,
        main = "Dispersión de Conformes",
        xlab = "Cantidad de Conformes",
        ylab = "",
        col = "lightgreen",
        horizontal = TRUE)


#////////////////////////////////////

#cuantiles || Variable numérica

quantile(df2$conformes, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)

quantile(df2$minutos_parada, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)

quantile(df2$eficiencia_pct, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)


#cuantiles categoricas
  #podemos obtener frecuencias:
table(df2$maquina)

#la distribución en forma de conteo acumulado:
sort(table(df2$maquina))


#Cuantiles de tipo_turno
  # es categórica, por tanto se obtienen frecuencias:
table(df2$tipo_turno)

#porcentaje acumulado:
prop.table(table(df2$tipo_turno)) * 100


################################################################################


# Agrupar por máquina y calcular desviación estándar e IQR
library(dplyr)

dispercion_eficiencia_maquina <- df2 %>%
  group_by(maquina) %>%
  summarise(
    Desviacion_Estandar = sd(eficiencia_pct, na.rm = TRUE),
    Rango_Intercuartilico = IQR(eficiencia_pct, na.rm = TRUE)
  )

# Ver resultados
print(dispercion_eficiencia_maquina)



plot(df2$minutos_parada, df2$eficiencia_pct,
     main = "Eficiencia vs Minutos de Parada",
     xlab = "Minutos de Parada",
     ylab = "Eficiencia (%)",
     col = "purple",
     pch = 16)


boxplot(eficiencia_pct ~ maquina,
        data = df2,
        main = "Dispersión de Eficiencia por Máquina",
        xlab = "Máquina",
        ylab = "Eficiencia (%)",
        col = rainbow(length(unique(df2$maquina))),
        las = 2)

################################################################################


