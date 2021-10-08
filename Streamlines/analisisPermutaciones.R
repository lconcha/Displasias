# Este codigo va a leer caracteristicas indexadas por streamlines de tama?o 150x20,
# con esto se hace PCA local y se toman distancias usando la distancia de Mahalanobis
# a esto se le calcula la d de cohen local, la prueba t de student, la prueba de
# permutaciones, boxplots, entre otros. Cada uno de estos resultados se guarda
# en una carpeta diferente dentro de la carpeta de salida.

# Esto toma las variables de consola. Se tendria que correr algo asi: 
# Rscript analisisCaractetisticas.R nombrePath /path/direcciones.txt /path/out 500 --simulados
# Rscript /home/alonso/Dropbox/datos_estudiantes/aylin/R/analisisPermutaciones.R /home/alonso/NAS/NAS/datos/aylin/displaciasCorticales/derivatives/ /home/alonso/NAS/NAS/datos/aylin/nombresCaracteristicas.txt /home/alonso/NAS/NAS/datos/aylin/analisisBuenoPermutaciones 500


library(rlist)
library(fields)
library(RColorBrewer)

guardarImagenPng <- function(img, titulo, direccionPng, limites){
  png(width = 800, height = 600,filename = direccionPng)
  if(min(img) < 0){
    color <- colorRampPalette(brewer.pal(9,"RdBu"))(100)
  }
  else{
    color <- colorRampPalette(brewer.pal(9,"YlGnBu"))(100)
  }
  image.plot(img, axes = FALSE, main = titulo, zlim = limites, col = color)
  axis(1, at = seq(0,1,0.2), labels = c(1,11,21,30,40,50))
  axis(2, at = seq(0,1,0.11), labels = c(1,2,3,4,5,6,7,8,9,10))
  dev.off()
}

args = commandArgs(trailingOnly=TRUE)

if (length(args)<4) {
  stop("Se esperan al menos 4 argumentos, el path, un txt con el nombre de los txt de las caracteristicas, otro path con la carpeta de salida y el numero de permutaciones que se quieren. Tambien se puede poner la opcion --simulados o --generados", call.=FALSE)
}

direccionRata = args[1]
direccionCaracteristicas = args[2]
direccionSalida = args[3]
nPerm = as.numeric(args[4])

#direccionRata = "/home/alonso/NAS/NAS/datos/aylin/displaciasCorticales/derivatives/" #para ir probando
#direccionCaracteristicas = "/home/alonso/NAS/NAS/datos/aylin/nombresCaracteristicas.txt"
#direccionSalida = "/home/alonso/NAS/NAS/datos/aylin/analisisBuenoPermutaciones"
#nPerm = 500


opcion_simulados = FALSE
opcion_yaGenerados = FALSE

if(length(args)>2){
  for(i in 3:length(args)){
    if(args[i] == "--simulados"){
      opcion_simulados = TRUE
    }
    else if(args[i] == "--generados"){
      opcion_yaGenerados = TRUE
    }
  }
}

nombresCaracteristicas = read.table(direccionCaracteristicas,header = FALSE)
colnames(nombresCaracteristicas)<-NULL

# asi se accede a cada nombre: nombresCaracteristicas[i,1]
# asi se accede a cada nombre del txt: nombresCaracteristicas[i,2]

direccionMediaStreamlines="/ses-P30/mapas-streamlines-20/"
numProfundidad=10

ratas <- c("37A","37C","37D","38F","39A","39B","40A","40D","42A","42F","46A",
           "46B","46E","46G","46H","46I","46J","47A","47B","47C","47D","47E",
           "47I","47J","47K","48A","48G","48H","49G","49H","49I","52A","54D",
           "54E","55A","56B","57B")


caracteristicas <- NULL

##### PARA LEER DATOS REALES #####
if(opcion_simulados == FALSE){
  for(i in 1:length(nombresCaracteristicas[,2])){
    temp <- list()
    txtCaracteristica = nombresCaracteristicas[i,2]
    for(rata in ratas){
      temp <- list.append(temp,as.data.frame(read.table(paste(direccionRata,rata,direccionMediaStreamlines,txtCaracteristica[[1]],sep=""), header = FALSE, sep = "", dec = ".", nrows=150)))
    }
    caracteristicas = rbind(caracteristicas,temp)
  }
}

##### PARA LEER DATOS SIMULADOS #####
if(opcion_simulados == TRUE){
  for(i in 1:length(nombresCaracteristicas[,2])){
    temp <- list()
    txtCaracteristica = nombresCaracteristicas[i,2]
    for(j in 1:length(ratas)){
      temp <- list.append(temp,as.data.frame(read.table(paste(direccionRata,"simulacion_rata",as.character(j),"_",txtCaracteristica[[1]],sep=""), header = FALSE, sep = "", dec = ".", nrows=50)))
    }
    caracteristicas = rbind(caracteristicas,temp)
  }
}


#esto ayuda a recordar las opciones que se tienen en una clase nifti
#slotNames(datos)

colors<- c("#99CC00", "#99FF00", "#33CC33", "#00FFCC", "#00CC99", "#99FF66",
           "#66CC66", "#33FF66", "#66FF66", "#339900", "#00FFFF", "#666600",
           "#669966", "#33FF99", "#009999", "#CCCC00", "#CCCC99", "#0099CC",
           "#CCCC33", "#FFFF00", "#FFCC33", "#996600", "#FFCC99", "#FF9966",
           "#993300", "#996666", "#CC9999", "#CC0066", "#CC3399", "#993366",
           "#990099", "#CC66CC", "#CC33CC", "#330066", "#CC00CC", "#6600FF",
           "#000099")


#estado <- c(0,0,0,0,1,2,0,0,3,4,0,0,0,0,0,0,0,5,6,7,8,9,10,11,12,0,0,0,13,14,15,0,16,17,18,0,0)
estado_binario_bueno <- c(0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,1,1,0,1,1,1,0,0)

if(opcion_simulados == TRUE){ #para datos simulados 
  estado_binario_bueno <- c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1) 
}


num_caract <- length(caracteristicas)/length(ratas)
rownames(caracteristicas) <- NULL
caracteristicas_vector <- NULL
dat <- NULL

if(opcion_simulados == FALSE){
  for (k in 1:length(ratas)){
    for (i in 1:50){
      for (j in 1:10){
        vector_temp <- NULL
        for(l in 1:num_caract){
          vector_temp <- c(vector_temp,caracteristicas[l,k][[1]][i*3,j*2]) #hay que multiplicar la i por 3 cuando es datos reales
        }
        dat <- rbind(dat,vector_temp)
      }
    }
  }
} else {
  for (k in 1:length(ratas)){
    for (i in 1:50){
      for (j in 1:10){
        vector_temp <- NULL
        for(l in 1:num_caract){
          vector_temp <- c(vector_temp,caracteristicas[l,k][[1]][i,j*2])
        }
        dat <- rbind(dat,vector_temp)
      }
    }
  }  
}

rownames(dat) <- NULL
datos <- as.data.frame(dat)

# nombres de los datos
for(i in 1:num_caract){
  names(datos)[i] = nombresCaracteristicas[i,1]
}

control <- NULL
for (i in 1:length(estado_binario_bueno)){
  if (estado_binario_bueno[i] == 0){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    control <- rbind(control,datos[n:m,])
  }
}
bcnu <- NULL
for (i in 1:length(estado_binario_bueno)){
  if (estado_binario_bueno[i] == 1){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    bcnu <- rbind(bcnu,datos[n:m,])
  }
}

#se tienen 19 ratas control y 18 bcnu
#dado un numero de streamline s en la rata k, la matriz del streamline es n=(k*150*10)+(s*10)
#datos[n+1:n+10,]
#el orden es que se tienen separas por rata, luego por streamline

datos_escalados <- as.matrix(as.data.frame(scale(datos)))

control_escalados <- NULL
for (i in 1:length(estado_binario_bueno)){
  if (estado_binario_bueno[i] == 0){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    control_escalados <- rbind(control_escalados,datos_escalados[n:m,])
  }
}

bcnu_escalados <- NULL
for (i in 1:length(estado_binario_bueno)){
  if (estado_binario_bueno[i] == 1){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    bcnu_escalados <- rbind(bcnu_escalados,datos_escalados[n:m,])
  }
}

# Contamos cuantas ratas BCNU y cuantas Control tenemos
numBCNU = sum(estado_binario_bueno)
numControl = length(estado_binario_bueno)-numBCNU


generarPermutacion <- function(){
  nuevaPermutacion = NULL
  for (i in 1:37) {
    nuevaPermutacion = c(nuevaPermutacion,0)
  }
  temp = sample(37,18)
  for (i in 1:18) {
    nuevaPermutacion[temp[i]]=1
  }
  return(nuevaPermutacion)
}

# esta correccion es para la d de cohen cuando N es menor a 50
correccion <- function(N){
  a = ((N-3)/(N-2.25))*sqrt((N-2)/N)
  return(a)
}

# se generan nPerm permutaciones, la primera es la real
if(opcion_yaGenerados == FALSE){
  permutaciones = estado_binario_bueno
  for (permutacionidx in 1:(nPerm-1)) {
    temp = generarPermutacion()
    permutaciones = rbind(permutaciones,temp)
  }
}

# esto define el tama?o de ventana que tomaremos al rededor de cada voxel
ventana_lado=1
ventana=c(0)
for(i in 1:ventana_lado){
  ventana=c(ventana,i,-i)
}


# esta primera iteracion va a ser para guardar la matriz de covarianza y el centroide para cada pixel,
# ambos van a ser guardados en una lista. Esto sera fijo para cada permutacion siguiente.
estado_binario = estado_binario_bueno
matricesCov <- list()
centroidesControl <- list()
dimensiones = NULL
for(streamline in 0:49){
  for(profundidad in 1:10){
    controlestemporal = NULL
    bcnutemporal = NULL
    for (vi in ventana) {
      for(vj in ventana){
        if((((streamline+vi)>=0)&&((streamline+vi)<=49))&&(((profundidad+vj)>=1)&&((profundidad+vj)<=10))){
          for(k in 0:(numControl-1)){
            controlestemporal <- rbind(controlestemporal,control_escalados[(k*50*numProfundidad)+((streamline+vi)*numProfundidad)+profundidad+vj,])
          }
          for(k in 0:(numBCNU-1)){
            bcnutemporal <- rbind(bcnutemporal,bcnu_escalados[(k*50*numProfundidad)+((streamline+vi)*numProfundidad)+profundidad+vj,])
          }
        }
      }
    }
    cuantos = (dim(controlestemporal)[1])/numControl
    todosTemporal = rbind(controlestemporal,bcnutemporal)
    datos_escalados_pca <- prcomp(todosTemporal)
    
    control_proyectados <- predict(datos_escalados_pca,newdata = controlestemporal)
    bcnu_proyectados <- predict(datos_escalados_pca,newdata = bcnutemporal)
    
    summary_datos <- summary(datos_escalados_pca)
    
    PCencontrado = 0
    cualPC = num_caract
    for(i in 1:num_caract){
      if(PCencontrado == 0){
        if(summary_datos$importance[3,i] > 0.99){
          cualPC = i
          PCencontrado = 1
        }
      }
    }
    dimensiones = c(dimensiones,cualPC)
    if(cualPC < num_caract){
      for(i in 0:(num_caract-cualPC-1)){
        j = num_caract-i
        control_proyectados <- control_proyectados[,-j]
        bcnu_proyectados <- bcnu_proyectados[,-j]
      }
    }
    centroide <- NULL
    for(l in 1:dim(control_proyectados)[2]){
      centroide <- c(centroide,mean(control_proyectados[,l]))
    }
    centroidesControl <- list.append(centroidesControl,centroide)
    control_cov = cov(control_proyectados)
    matricesCov <- list.append(matricesCov,control_cov)
  }
}


# para cada permutacion se va a guardar el promedio de las ratas supuestamente control al centoride,
# el promedio de las ratas supuestamente BCNU al centroide, los p valores usando una prueba t de student,
# su valor d de Cohen y la cantidad de ratas supuestamente BCNU que son mayores a 2 veces la desviacion
# estandar de las ratas supuestamente control
# correr esto toma unas 4 horas

permutaciones_promedio_distancia_controles = NULL
permutaciones_promedio_distancia_bcnu = NULL
permutaciones_pvalores = NULL
permutaciones_dcohen = NULL
permutaciones_mayoresQue2sigma = NULL

if(opcion_yaGenerados == FALSE){
  for(permutacionidx in 1:nPerm){
    estado_binario = permutaciones[permutacionidx,]
    
    control_escalados <- NULL
    for (i in 1:length(estado_binario)){
      if (estado_binario[i]==0){
        n=((i-1)*50*numProfundidad)+1
        m=i*50*numProfundidad
        control_escalados <- rbind(control_escalados,datos_escalados[n:m,])
      }
    }
    
    bcnu_escalados <- NULL
    for (i in 1:length(estado_binario)){
      if (estado_binario[i]==1){
        n=((i-1)*50*numProfundidad)+1
        m=i*50*numProfundidad
        bcnu_escalados <- rbind(bcnu_escalados,datos_escalados[n:m,])
      }
    }
    
    #aqui vamos a sacar la distancia de mahalanobis
    distancia_controles<-NULL
    distancia_bcnu <- NULL
    for(streamline in 0:49){
      temp_distancia_controles<-NULL
      temp_distancia_bcnu<-NULL
      for(profundidad in 1:10){
        controlestemporal = NULL
        bcnutemporal = NULL
        for (vi in ventana) {
          for(vj in ventana){
            if((((streamline+vi)>=0)&&((streamline+vi)<=49))&&(((profundidad+vj)>=1)&&((profundidad+vj)<=10))){
              for(k in 0:(numControl-1)){
                controlestemporal <- rbind(controlestemporal,control_escalados[(k*50*numProfundidad)+((streamline+vi)*numProfundidad)+profundidad+vj,])
              }
              for(k in 0:(numBCNU-1)){
                bcnutemporal <- rbind(bcnutemporal,bcnu_escalados[(k*50*numProfundidad)+((streamline+vi)*numProfundidad)+profundidad+vj,])
              }
            }
          }
        }
        cuantos = (dim(controlestemporal)[1])/numControl
        todosTemporal = rbind(controlestemporal,bcnutemporal)
        datos_escalados_pca <- prcomp(todosTemporal)
        
        control_proyectados <- predict(datos_escalados_pca,newdata = controlestemporal)
        bcnu_proyectados <- predict(datos_escalados_pca,newdata = bcnutemporal)
        
        summary_datos <- summary(datos_escalados_pca)
        
        cualPC = dimensiones[(streamline*10)+profundidad]
        if(cualPC < num_caract){
          for(i in 0:(num_caract-cualPC-1)){
            j = num_caract-i
            control_proyectados <- control_proyectados[,-j]
            bcnu_proyectados <- bcnu_proyectados[,-j]
          }
        }
        centroide <- centroidesControl[(streamline*10)+profundidad][[1]]
        control_cov = matricesCov[(streamline*10)+profundidad][[1]]
        temp2_distancia_controles = NULL
        temp2_distancia_bcnu = NULL
        for(k in 1:numControl){
          x = sqrt(t(control_proyectados[k,]-centroide)%*%solve(control_cov)%*%(control_proyectados[k,]-centroide))
          temp2_distancia_controles <- c(temp2_distancia_controles,x)
        }
        for(k in 1:numBCNU){
          x = sqrt(t(bcnu_proyectados[k,]-centroide)%*%solve(control_cov)%*%(bcnu_proyectados[k,]-centroide))
          temp2_distancia_bcnu <- c(temp2_distancia_bcnu,x)
        }
        temp_distancia_controles <- rbind(temp_distancia_controles,temp2_distancia_controles)
        temp_distancia_bcnu <- rbind(temp_distancia_bcnu,temp2_distancia_bcnu)
      }
      distancia_controles <- rbind(distancia_controles,temp_distancia_controles)
      distancia_bcnu <- rbind(distancia_bcnu,temp_distancia_bcnu)
    }
    
    
    pvalores = NULL
    for(streamline in 0:49){
      temp = NULL
      for(profundidad in 1:10){
        temp = c(temp,t.test(distancia_controles[((streamline*10)+profundidad),],distancia_bcnu[((streamline*10)+profundidad),])$p.value)
      }
      pvalores = rbind(pvalores,temp)
    }
    
    #cada renglon va a ser una imagen, donde el orden va a ser 50 veces 10, es decir, bloques de 10
    permutaciones_pvalores = rbind(permutaciones_pvalores,as.vector(t(pvalores)))
    
    promedio_distancia_controles <- NULL
    promedio_distancia_bcnu <- NULL
    for(streamline in 0:49){
      temp_control <- NULL
      temp_bcnu <- NULL
      for (profundidad in 1:10) {
        temp_control <- c(temp_control,mean(distancia_controles[(streamline*10)+profundidad,]))
        temp_bcnu <- c(temp_bcnu,mean(distancia_bcnu[(streamline*10)+profundidad,]))
      }
      promedio_distancia_controles<-rbind(promedio_distancia_controles,temp_control)
      promedio_distancia_bcnu<-rbind(promedio_distancia_bcnu,temp_bcnu)
    }
    
    permutaciones_promedio_distancia_bcnu = rbind(permutaciones_promedio_distancia_bcnu,as.vector(t(promedio_distancia_bcnu)))
    permutaciones_promedio_distancia_controles = rbind(permutaciones_promedio_distancia_controles,as.vector(t(promedio_distancia_controles)))
    
    # Se cuentan la cantidad de ratas BCNU que son mayores a 2 veces la desviacion estandar mas la media de las control
    cuantasMayorA2Sigma <- NULL
    for(s in 0:49){
      temp <- NULL
      for(p in 1:10){
        sig <- sd(distancia_controles[(s*10)+p,])
        m <- (2*sig) + promedio_distancia_controles[(s+1),p]
        t <- 0
        for(k in 1:numBCNU){
          if(distancia_bcnu[((s*10)+p),k] > m){
            t=t+1
          }
        }
        temp <- c(temp,t)
      }
      cuantasMayorA2Sigma=rbind(cuantasMayorA2Sigma,temp)
    }
    permutaciones_mayoresQue2sigma = rbind(permutaciones_mayoresQue2sigma, as.vector(t(cuantasMayorA2Sigma)))
    
    
    dCohen <- NULL
    for(streamline in 0:49){
      temp_vector <- NULL
      for(p in 1:10){
        temp_control <- distancia_controles[((streamline*10)+p),]
        temp_bcnu <- distancia_bcnu[((streamline*10)+p),]
        m1 = promedio_distancia_controles[(streamline+1),p]
        m2 = promedio_distancia_bcnu[(streamline+1),p]
        temp1 <- 0
        for(i in 1:numControl){
          temp1 = temp1 + (temp_control[i]-m1)**2
        }
        temp1 = temp1/(numControl-1)
        temp2 <- 0
        for(i in 1:numBCNU){
          temp2 = temp2 + (temp_bcnu[i]-m2)**2
        }
        temp2 = temp2/(numBCNU-1)
        temp = sqrt((((numControl-1)*temp1)+((numControl-2)*temp2))/(numControl+numBCNU-2))
        corr = max(numControl,numBCNU)
        temp_vector <- c(temp_vector, ((m2-m1)/temp)*correccion(corr))
      }
      dCohen <- rbind(dCohen,temp_vector)
    }
    permutaciones_dcohen = rbind(permutaciones_dcohen,as.vector(t(dCohen)))
  }
}

if(opcion_yaGenerados == FALSE){
  # en esta parte se guardan las matrices de nPerm para no tener que volver a esperar las 4 horas cada vez que se cierra R
  spermutaciones = as.data.frame(permutaciones)
  save(spermutaciones,file = paste(direccionSalida,"/permutaciones.Rda",sep=""))
  
  sDistanciaBCNU = as.data.frame(permutaciones_promedio_distancia_bcnu)
  save(sDistanciaBCNU,file = paste(direccionSalida,"/promedioDistanciaBCNU-sinCambiarCovYCentroide.Rda",sep=""))
  
  sDistanciaControl = as.data.frame(permutaciones_promedio_distancia_controles)
  save(sDistanciaControl,file = paste(direccionSalida,"/promedioDistanciaControles-sinCambiarCovYCentroide.Rda",sep=""))
  
  sCohen =as.data.frame(permutaciones_dcohen)
  save(sCohen,file = paste(direccionSalida,"/dCohen-sinCambiarCovYCentroide.Rda",sep=""))
  
  sSigma = as.data.frame(permutaciones_mayoresQue2sigma)
  save(sSigma,file = paste(direccionSalida,"/mayoresQue2Sigma-sinCambiarCovYCentroide.Rda",sep=""))
  
  sPValores = as.data.frame(permutaciones_pvalores)
  save(sPValores, file = paste(direccionSalida,"/pvalores-sinCambiarCovYCentroide.Rda",sep=""))
} else {
  permutaciones <- get(load(paste(direccionSalida,"/permutaciones.Rda",sep="")))
  permutaciones_dcohen <- get(load(paste(direccionSalida,"/dCohen-sinCambiarCovYCentroide.Rda",sep="")))
  permutaciones_promedio_distancia_bcnu <- get(load(paste(direccionSalida,"/promedioDistanciaBCNU-sinCambiarCovYCentroide.Rda",sep="")))
  permutaciones_promedio_distancia_controles <- get(load(paste(direccionSalida,"/promedioDistanciaControles-sinCambiarCovYCentroide.Rda",sep="")))
  permutaciones_mayoresQue2sigma <- get(load(paste(direccionSalida,"/mayoresQue2Sigma-sinCambiarCovYCentroide.Rda",sep="")))
  #permutaciones_pvalores <- get(load(paste(direccionSalida,"/pvalores-sinCambiarCovYCentroide.Rda",sep="")))
}

# todas las matrices que empiezan con la palabra permutaciones tienen dimension nPerm, cada renglon 
# es una imagen con una permutacion. Tomamos los vectores por columnas para comparar la permutacion que 
# nos interesa contra las otras 499 permutaciones, esto lo hacemos para cada pixel de las imagenes 50x10.
lugarEnCohen = NULL
for(i in 0:49){
  tempLugar = NULL
  for(j in 1:10){
    temp = permutaciones_dcohen[,((i*10)+j)]
    tempLugar = c(tempLugar,(which(sort(temp)==temp[1]))[1]/nPerm)
  }
  lugarEnCohen = rbind(lugarEnCohen,tempLugar)
}

lugarEnSigma = NULL
for(i in 0:49){
  tempLugar = NULL
  for(j in 1:10){
    temp = permutaciones_mayoresQue2sigma[,((i*10)+j)]
    tempLugar = c(tempLugar,(which(sort(temp)==temp[1]))[1]/nPerm)
  }
  lugarEnSigma = rbind(lugarEnSigma,tempLugar)
}

lugarEnDistanciaBCNU = NULL
for(i in 0:49){
  tempLugar = NULL
  for(j in 1:10){
    temp = permutaciones_promedio_distancia_bcnu[,((i*10)+j)]
    tempLugar = c(tempLugar,(which(sort(temp)==temp[1]))[1]/nPerm)
  }
  lugarEnDistanciaBCNU = rbind(lugarEnDistanciaBCNU,tempLugar)
}

pocisionEnDistanciaBCNUmenosControles = NULL
for(i in 0:49){
  tempLugar = NULL
  for(j in 1:10){
    temp = permutaciones_promedio_distancia_bcnu[,((i*10)+j)]-permutaciones_promedio_distancia_controles[,((i*10)+j)]
    tempLugar = c(tempLugar,(which(sort(temp)==temp[1]))[1]/nPerm)
  }
  pocisionEnDistanciaBCNUmenosControles = rbind(pocisionEnDistanciaBCNUmenosControles,tempLugar)
}

#lugarEnpValores = NULL
#for(i in 0:49){
#  tempLugar = NULL
#  for(j in 1:10){
#    temp = permutaciones_pvalores[,((i*10)+j)]
#    tempLugar = c(tempLugar,1-(which(sort(temp)==temp[1]))[1]/nPerm)
#  }
#  lugarEnpValores = rbind(lugarEnpValores,tempLugar)
#}

guardarImagenPng(lugarEnCohen, paste("Lugar de ", as.character(nPerm), " permutaciones de d de Cohen", sep=""),
                 paste(direccionSalida,"/permutaciones_dcohen.png",sep=""), c(0, 1))

#guardarImagenPng(lugarEnpValores, paste("Lugar de ", as.character(nPerm), " permutaciones de 1 - p valores con prueba t de student", sep=""),
#                 paste(direccionSalida,"/permutaciones_tstudent.png",sep=""), c(0, 1))

guardarImagenPng(lugarEnSigma, paste("Lugar de ", as.character(nPerm), " permutaciones de ratas \'BCNU\' mayores a 2 sd de ratas \'Control\' ", sep=""),
                 paste(direccionSalida,"/permutaciones_2sigma.png",sep=""), c(0, 1))

guardarImagenPng(lugarEnDistanciaBCNU, paste("Lugar de ", as.character(nPerm), " permutaciones del promedio de distancias de las ratas \'BCNU\' ", sep=""),
                 paste(direccionSalida,"/permutaciones_distancia_bcnu.png",sep=""), c(0, 1))

guardarImagenPng(pocisionEnDistanciaBCNUmenosControles, paste("Lugar de ", as.character(nPerm), " permutaciones del promedio de diferencia entre distancias de las ratas \'BCNU\' y \'Control\' ", sep=""),
                 paste(direccionSalida,"/permutaciones_distancia_delta_Mahalanobis.png",sep=""), c(0, 1))

# esto es para las matrices que tengo como un vector de 1xnPerm
convertirAMatriz <-function(vect){
  mat = NULL
  for(i in 0:49){
    mat = rbind(mat,vect[((i*10)+1):((i+1)*10)])
  }
  return(mat)
}

is=c(9,10,10,12,13,25,26,24,26,28,27,3,40)  #corre en streammlines
js=c(5,5,6,6,6,5,4,5,4,4,3,8,7)  #corre en profundidad

dir.create(paste(direccionSalida,"/deltaMahalanobis",sep=""))
for(ii in 1:length(is)){
  i = is[ii]
  j = js[ii]
  x = permutaciones_promedio_distancia_bcnu[,(((i-1)*10)+j)]-permutaciones_promedio_distancia_controles[,(((i-1)*10)+j)]
  png(width = 800, height = 600,filename = paste(direccionSalida,"/deltaMahalanobis/pixel (",as.character(i),",",as.character(j),").png",sep=""))
  hist(x,main = paste("Delta Mahalanobis en pixel (",as.character(i),",",as.character(j),")",sep=""),xlab="Delta Mahalanobis",breaks=20)
  abline(v=permutaciones_promedio_distancia_bcnu[1,(((i-1)*10)+j)]-permutaciones_promedio_distancia_controles[1,(((i-1)*10)+j)],col="red")
  dev.off()
}
if(opcion_yaGenerados == FALSE){
  for(ii in 1:length(is)){
    i = is[ii]
    j = js[ii]
    temp = distancia_controles[(((i-1)*10)+j),]
    temp2 = distancia_bcnu[(((i-1)*10)+j),]
    png(width = 800, height = 600,filename = paste(direccionSalida,"/deltaMahalanobis/pixel (",as.character(i),",",as.character(j),")tstudent.png",sep=""))
    boxplot(temp,temp2,names=c("control","bcnu"),ylab="Mahalanobis",main=paste("Pixel (",as.character(i),",",as.character(j),") t student, p = ",as.character(round(permutaciones_pvalores[1,(((i-1)*10)+j)],4)),sep=""))
    dev.off()
  }
}

# para encontrar los mayores cumulos que tienen un valor mayor al 95% en la distribucion mando la informacion a Python
# porque para hacerlo en R deberia de usar raster que solo esta disponible cuando se tiene la version de R mayor a 3.5
# era mas complicado actualizar R por promeblas de administrador y todos los paquetes por tiempo con el riesgo
# de que algunos ya no funcionaran que pasarlo a Python. El archivo de Python que los procesa se llama encontrarMayorCoponenteConectadodeR.py
write.csv(permutaciones_promedio_distancia_bcnu,file = "/home/alonso/aylin/promedioDistanciaBCNUParaPython.csv",row.names=FALSE,col.names=FALSE)
write.csv(permutaciones_promedio_distancia_controles,file = "/home/alonso/aylin/promedioDistanciaControlParaPython.csv",row.names=FALSE,col.names=FALSE)

library(reticulate)

#py_install("scipy")
#py_install("matplotlib")

py_run_file("/home/alonso/Dropbox/datos_estudiantes/aylin/Python/encontrarMayorComponenteConectadodeR.py")

# aqui se leen los archivos resultantes de Python que contienen un vector con 0 y 1 que corresponde
# a una matriz de 50x10 que indica con 1 cuales puntos de la matriz eran pertenecientes a los cumulos importantes
# que son los que tenian un tamaño mayor a 36. Es 36 porque es el tamaño que por probabilidad se puede obtener
# se puede ver mejor esto en el histograma
tempMayorComponente <- read.csv(file = "/home/alonso/aylin/mayorComponente.csv", header = FALSE)
mayorComponente = NULL
for(i in 1:500){
  mayorComponente = c(mayorComponente,tempMayorComponente[i,1])
}

png(width = 800, height = 600,filename = paste(direccionSalida,"/histogramaMayoresComponentes.png",sep=""))
hist(mayorComponente,cex.lab=1.5 ,main = paste("Histograma del tamaño del mayor componente por permutación", sep=""), xlab = "Tamaño de mayor componente",ylab = "Frecuencia")
dev.off()

tempMatrizCuales <- read.csv(file = '/home/alonso/aylin/matrizCuales.csv',header = FALSE)
matrizCuales = NULL
for(i in 1:500){
  matrizCuales = c(matrizCuales,tempMatrizCuales[i,1])
}

posicionBCNUmenosControles = NULL
for (i in 1:50) {
  posicionBCNUmenosControles = c(posicionBCNUmenosControles,pocisionEnDistanciaBCNUmenosControles[i,])  
}


deltamahalanobisBinario = NULL
for(i in 0:49){
  temporal = NULL
  for(j in 1:10){
    if(matrizCuales[(i*10)+j] == 0){
      temporal = c(temporal,0)
    }
    else{
      temporal = c(temporal,posicionBCNUmenosControles[(i*10)+j]*nPerm)
    }
  }
  deltamahalanobisBinario = rbind(deltamahalanobisBinario, temporal)
  deltamahalanobisBinario = rbind(deltamahalanobisBinario, temporal)
  deltamahalanobisBinario = rbind(deltamahalanobisBinario, temporal)
}
deltamahalanobisBinario = deltamahalanobisBinario[-length(deltamahalanobisBinario)]
deltamahalanobisBinario = c(deltamahalanobisBinario, Inf)

guardarImagenPng(pocisionEnDistanciaBCNUmenosControles, paste("Lugar de las ", as.character(nPerm), " permutaciones del promedio de Delta Mahalanobis", sep=""),
                 paste(direccionSalida,"/lugarDeltaMahalanobisAlto.png",sep=""), c(0.95,1))
#guardarImagenPng(convertirAMatriz((permutaciones_pvalores[1,]*matrizCuales)),"p valor en zona de interes",
#                 paste(direccionSalida,"/lugarpvalorZonaInteres.png",sep=""), c(0,0.05))
guardarImagenPng(convertirAMatriz((posicionBCNUmenosControles)*(matrizCuales)),paste("Lugar de las ", as.character(nPerm), " permutaciones del promedio de Delta Mahalanobis en zona de interes", sep=""),
                 paste(direccionSalida,"/lugarDeltaMahalanobisZonaInteres.png",sep=""), c(0.95,1))



towrite = file(paste(direccionSalida, "/deltamahalanobisBinario.dat", sep = ""), "wb")
writeBin(deltamahalanobisBinario, towrite,endian = "little",size=4)
close(towrite)


