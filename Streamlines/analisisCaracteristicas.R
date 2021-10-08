# Este codigo va a leer caracteristicas indexadas por streamlines de tama?o 150x20,
# con esto se hace PCA local y se toman distancias usando la distancia de Mahalanobis
# a esto se le calcula la d de cohen local, la prueba t de student, la prueba de
# permutaciones, boxplots, entre otros. Cada uno de estos resultados se guarda
# en una carpeta diferente dentro de la carpeta de salida.

# Esto toma las variables de consola. Se tendria que correr algo asi: 
# Rscript analisisCaractetisticas.R nombrePath /path/direcciones.txt /path/out --valorenpc1 --boxplots --simulados

library(rlist)
library(fields)
library(RColorBrewer)

guardarImagenPng <- function(img, titulo, direccionPng, limites){
  png(width = 800, height = 600,filename = direccionPng)
  if(min(img) < 0){
    color <- colorRampPalette(brewer.pal(9,"RdBu"))(100)
    if(is.null(limites)==TRUE){
      m = max(abs(img))
      limites = c(-m,m)
    }
  }
  else{
    color <- colorRampPalette(brewer.pal(9,"YlGnBu"))(100)
  }
  image.plot(img, axes = FALSE, main = titulo, zlim = limites, col = color, cex=1.5)
  axis(1, at = seq(0,1,0.2), labels = c(1,11,21,30,40,50))
  axis(2, at = seq(0,1,0.11), labels = c(1,2,3,4,5,6,7,8,9,10))
  dev.off()
}

guardarComoTxt <- function(img, direccionTxt){
  salida = NULL
  for(i in 1:50){
    salida = rbind(salida, img[i,])
    salida = rbind(salida, img[i,])
    salida = rbind(salida, img[i,])
  }
  write.table(salida, file = direccionTxt, row.names = FALSE, col.names = FALSE) # guarda un archivo txt
}

args = commandArgs(trailingOnly=TRUE)

if (length(args)<3) {
  stop("Se esperan al menos 3 argumentos, el path, un txt con el nombre de los txt de las caracteristicas y otro path con la carpeta de salida. Tambien se puede poner la opcion --boxplots, --valorenpc1, --porCaracteristica y --simulados", call.=FALSE)
}

direccionRata = args[1]
direccionCaracteristicas = args[2]
direccionSalida = args[3]

#direccionRata = "/home/alonso/NAS/NAS/datos/aylin/displaciasCorticales/derivatives/" #para ir probando
#direccionCaracteristicas = "/home/alonso/NAS/NAS/datos/aylin/nombresCaracteristicas2.txt"
#direccionSalida = "/home/alonso/NAS/NAS/datos/aylin/analisisBuenoAntiguo"



opcion_boxplots = TRUE
opcion_simulados = FALSE
opcion_valorEnPC1 = TRUE
opcion_por_caracteristica = TRUE

if(length(args)>2){
  for(i in 3:length(args)){
    if(args[i] == "--boxplots"){
      opcion_boxplots = TRUE
    }
    else if(args[i] == "--simulados"){
      opcion_simulados = TRUE
    }
    else if(args[i] == "--valorenpc1"){
      opcion_valorEnPC1 = TRUE
    }
    else if(args[i] == "--porCaracteristica"){
      opcion_por_caracteristica = TRUE
    }
  }
}

dir.create(paste(direccionSalida,"/enTXT",sep=""))
dir.create(paste(direccionSalida,"/enTXT/promedio_valores",sep=""))
dir.create(paste(direccionSalida,"/enTXT/distancia_mahalanobis",sep=""))
dir.create(paste(direccionSalida,"/enTXT/loadings",sep=""))
dir.create(paste(direccionSalida,"/enTXT/dcohen",sep=""))
dir.create(paste(direccionSalida,"/enTXT/pvalores",sep=""))

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
estado_binario <- c(0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1,1,1,0,1,1,1,0,0)

if(opcion_simulados == TRUE){ #para datos simulados 
  estado_binario <- c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1) 
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
  names(datos)[i] = as.character(nombresCaracteristicas[i,1][[1]])
}

control <- NULL
for (i in 1:length(estado_binario)){
  if (estado_binario[i] == 0){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    control <- rbind(control,datos[n:m,])
  }
}
bcnu <- NULL
for (i in 1:length(estado_binario)){
  if (estado_binario[i] == 1){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    bcnu <- rbind(bcnu,datos[n:m,])
  }
}

#se tienen 19 ratas sanas y 18 enfermas
#dado un numero de streamline s en la rata k, la matriz del streamline es n=(k*150*10)+(s*10)
#datos[n+1:n+10,]
#el orden es que se tienen separas por rata, luego por streamline

datos_escalados <- as.matrix(as.data.frame(scale(datos)))

control_escalados <- NULL
for (i in 1:length(estado_binario)){
  if (estado_binario[i] == 0){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    control_escalados <- rbind(control_escalados,datos_escalados[n:m,])
  }
}

bcnu_escalados <- NULL
for (i in 1:length(estado_binario)){
  if (estado_binario[i] == 1){
    n = ((i-1)*50*numProfundidad)+1
    m = i*50*numProfundidad
    bcnu_escalados <- rbind(bcnu_escalados,datos_escalados[n:m,])
  }
}

# Contamos cuantas ratas BCNU y cuantas Control tenemos
numBCNU = sum(estado_binario)
numControl = length(estado_binario)-numBCNU


# esto define el tama?o de ventana que tomaremos al rededor de cada voxel
ventana_lado=1
ventana=c(0)
for(i in 1:ventana_lado){
  ventana=c(ventana,i,-i)
}


# hacemos PCA y luego con summary podemos ver la cantidad de caracteristicas que se necesitan para tener el 99% de varianza
# y nos quedamos con solo esa cantidad de direcciones

# aqui vamos a sacar la distancia de mahalanobis para controles y bcnu asi como el porcentaje de ayuda para el primer coponente
# de cada caracteristica
distancia_controles<-NULL
distancia_bcnu <- NULL
primeros3lugares <- NULL
lugarEnPCA <- NULL

for(streamline in 0:49){
  temp_distancia_controles<-NULL
  temp_distancia_bcnu<-NULL
  tempLugarEnPCA <- NULL
  
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
    
    lugarEnPCA <- rbind(lugarEnPCA, datos_escalados_pca$rotation[,1])
    
    control_proyectados <- predict(datos_escalados_pca,newdata = controlestemporal)
    bcnu_proyectados <- predict(datos_escalados_pca,newdata = bcnutemporal)
    
    summary_datos <- summary(datos_escalados_pca)
    temporal = NULL
    for(i in 1:num_caract){
      temporal = c(temporal,0)
    }
    temp_vector = abs(datos_escalados_pca$rotation[,1])
    for(i in 1:3){
      temp_cual = which.max(temp_vector)
      temp_vector[temp_cual] = 0
      temporal[temp_cual] = 1
    }
    primeros3lugares = rbind(primeros3lugares,temporal)
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
    control_cov = cov(control_proyectados)
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

ctrl_i=0
bcnu_i=0
for (k in 1:length(ratas)) {
  temp = NULL
  if(estado_binario[k] == 1){
    bcnu_i = bcnu_i + 1
    for(i in 0:49){
      temp2 = NULL
      for (j in 1:10) {
        temp2 = c(temp2,distancia_bcnu[((i*10)+j),bcnu_i])
      }
      temp = rbind(temp, temp2)
    }
  } else {
    ctrl_i = ctrl_i + 1
    for(i in 0:49){
      temp2 = NULL
      for (j in 1:10) {
        temp2 = c(temp2,distancia_controles[((i*10)+j),ctrl_i])
      }
      temp = rbind(temp, temp2)
    }
  }
  guardarComoTxt(temp, paste(direccionSalida,"/enTXT/distancia_mahalanobis/",ratas[k],".txt",sep=""))
}

# esto guarda todas las imagenes de cada caracteristica con el valor de cuanto contribuyeron al componente principal
if(opcion_valorEnPC1 == TRUE){
  dir.create(paste(direccionSalida,"/valorEnPC1",sep=""))
  for(tempCaract in 1:num_caract){
    tempImg = NULL
    for(s in 0:49){
      x = s*10
      tempVect = lugarEnPCA[((x+1):(x+10)),tempCaract]
      tempImg = rbind(tempImg, tempVect)
    }
    guardarImagenPng(tempImg, paste("Lugar dentro del PC1 de ",names(datos)[tempCaract],sep=""), 
                     paste(direccionSalida,"/valorEnPC1/",as.character(tempCaract),".png",sep=""), c(-1,1))
    
    guardarComoTxt(tempImg, paste(direccionSalida,"/enTXT/loadings/",names(datos)[tempCaract],".txt",sep=""))
  }
}

# Prueba t de student
pvalores = NULL
for(streamline in 0:49){
  temp = NULL
  for(profundidad in 1:10){
    temp = c(temp,t.test(distancia_controles[((streamline*10)+profundidad),],distancia_bcnu[((streamline*10)+profundidad),])$p.value)
  }
  pvalores = rbind(pvalores,temp)
}
guardarImagenPng(pvalores, "p valores usando la prueba t de student", 
                 paste(direccionSalida,"/pvalores_pruebatstudent.png",sep=""), NULL)

guardarComoTxt(pvalores, paste(direccionSalida,"/pvalores_pruebatstudent.txt",sep=""))

# Prueba t de student con los p-valores acotados en 0.05
png(width = 800, height = 600,filename = paste(direccionSalida,"/pvalores_pruebatstudent_acotados.png",sep=""))
if(min(pvalores) < 0){
  color <- colorRampPalette(rev(brewer.pal(9,"RdBu")))(100)
} else{
  color <- colorRampPalette(rev(brewer.pal(9,"YlGnBu")))(100)
}
image.plot(pvalores, axes = FALSE, main = "p-valores usando la prueba t de student acotado en 0.05", zlim = c(0,0.5), col = color)
axis(1, at = seq(0,1,0.2), labels = c(1,11,21,30,40,50))
axis(2, at = seq(0,1,0.11), labels = c(1,2,3,4,5,6,7,8,9,10))
dev.off()



# Mapas de calor del promedio de las ratas control y las ratas bcnu al centroide de las ratas control usando la distancia de Mahalanobis
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

minimo = min(promedio_distancia_bcnu,promedio_distancia_controles)
maximo = max(promedio_distancia_bcnu,promedio_distancia_controles)

guardarImagenPng(promedio_distancia_controles, "Distancia promedio de ratas Control al centroide de ratas Control utilizando la distancia de Mahalanobis",
                 paste(direccionSalida,"/distancia_control.png",sep=""), c(minimo, maximo))
guardarImagenPng(promedio_distancia_bcnu, "Distancia promedio de ratas BCNU al centroide de ratas Control utilizando la distancia de Mahalanobis",
                 paste(direccionSalida,"/distancia_bcnu.png",sep=""), c(minimo, maximo))
guardarImagenPng(promedio_distancia_bcnu-promedio_distancia_controles, "Diferencia del promedio de la distancia al centroide entre las ratas BCNU y Control",
                 paste(direccionSalida,"/distancia_diferencia.png",sep=""), NULL)

guardarComoTxt(promedio_distancia_bcnu-promedio_distancia_controles, paste(direccionSalida,"/distancia_diferencia.txt",sep=""))
guardarComoTxt(promedio_distancia_bcnu, paste(direccionSalida,"/promedio_distancia_bcnu.txt",sep=""))
guardarComoTxt(promedio_distancia_controles, paste(direccionSalida,"/promedo_distancia_control.txt",sep=""))

diferencia_distancia_ratas = promedio_distancia_bcnu-promedio_distancia_controles
promedio_distancias_bn = NULL
for(streamline in 1:50){
  temp=NULL
  for(profundidad in 1:10){
    if(diferencia_distancia_ratas[streamline,profundidad]>0){
      temp<-c(temp,1)
    }
    else{
      temp<-c(temp,-1)
    }
  }
  promedio_distancias_bn<-rbind(promedio_distancias_bn,temp)
}
guardarImagenPng(promedio_distancias_bn, "Voxeles en donde en promedio las ratas BCNU tuvieron una distancia mayor a las ratas Control",
                 paste(direccionSalida,"/distancias_promedio_bn.png",sep=""), NULL)


# Se cuentan la cantidad de ratas bcnu que tienen una distancia mayor a la media de las control mas 2 veces su desviacion estandar
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
guardarImagenPng(cuantasMayorA2Sigma, "Numero de ratas bcnu con distancia mayor a la media de la distancia de las ratas Control mas 2 veces su desviacion estandar",
                 paste(direccionSalida,"/cuantas_mayores_2_sigma.png",sep=""), NULL)

# esta correccion sirve para calcular la d de Cohen
correccion <- function(N){
  a = ((N-3)/(N-2.25))*sqrt((N-2)/N)
  return(a)
}

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
guardarImagenPng(dCohen, "d de Cohen entre ratas Control y BCNU",
                 paste(direccionSalida,"/dCohen.png",sep=""), NULL)

guardarComoTxt(dCohen, paste(direccionSalida,"/dCohen.txt",sep=""))

png(width = 800, height = 600,filename = paste(direccionSalida,"/dCohen_vs_2sd.png",sep=""))
plot(as.vector(dCohen),as.vector(cuantasMayorA2Sigma),xlab="d de Cohen",ylab="cantidad de ratas enfermas mayores a 2 sigma de sanas",main="d de Cohen vs numero de ratas BCNU mayores a 2 sd en ratas Control")
dev.off()
png(width = 800, height = 600,filename = paste(direccionSalida,"/dCohen_vs_diferencia_distancia.png",sep=""))
plot(as.vector(dCohen),as.vector(promedio_distancia_bcnu-promedio_distancia_controles),xlab="d de Cohen",ylab="Diferencia de distancia entre ratas Control y BCNU",main="d de Cohen vs diferencia de promedio de distancias entre ratas control y BCNU")
dev.off()
png(width = 800, height = 600,filename = paste(direccionSalida,"/dCohen_vs_pvalores_tstudent.png",sep=""))
plot(as.vector(dCohen),as.vector(pvalores),xlab="d de Cohen",ylab="p valores",main="d de Cohen vs p-valores de prueba t de student entre ratas Control y BCNU")
dev.off()


cualMenor = NULL
for(i in 0:49){
  temp = NULL
  for(j in 1:10){
    x = (i*10)+j
    temp = c(temp, which.min(distancia_controles[x,]))
  }
  cualMenor = rbind(cualMenor,temp)
}
guardarImagenPng(cualMenor, "Rata Control con menor distancia al centroide de las ratas Control",
                 paste(direccionSalida,"/rata_control_mas_cercana_centroide.png",sep=""), NULL)


distanciaSumadaControles = NULL
for(i in 1:numControl){
  distanciaSumadaControles = c(distanciaSumadaControles,sum(distancia_controles[,i]))
}
nombresControles = NULL
for(i in 1:length(estado_binario)){
  if(estado_binario[i]==0){
    nombresControles = c(nombresControles,ratas[i])
  }
}
png(width = 800, height = 600,filename = paste(direccionSalida,"/promedio_distancia_ratas_control_con_nombre.png",sep=""))
plot(seq(1,19),distanciaSumadaControles/500,ylab="promedio de distancia al centroide",xlab="ratas control",main="Promedio de distancia al centroide por rata Control")
text(seq(1,19),distanciaSumadaControles/500,  nombresControles,
     cex=0.65, pos=4,col="red") 
dev.off()

if(opcion_boxplots == TRUE){
  is=c(9,10,11,10,11,12,13,14,25,26,24,26,26,27,28,27)  #corre en streammlines
  js=c(5,5,5,6,6,6,6,6,5,4,5,5,4,4,4,3)  #corre en profundidad
  
  dir.create(paste(direccionSalida,"/boxplots",sep=""))
  
  for(ii in 1:length(is)){
    controltemp  = NULL
    bcnutemp = NULL
    
    cuali = is[ii]
    cualj = js[ii]
    x = ((cuali-1)*10)+cualj
    for(k in 1:numControl){
      y = (k-1)*500
      y = y + x
      controltemp = rbind(controltemp, control[y,])
    }
    for(k in 1:numBCNU){
      y = (k-1)*500
      y = y + x
      bcnutemp = rbind(bcnutemp, bcnu[y,])
    }
    
    for(l in 1:num_caract){
      png(file=paste(direccionSalida,"/boxplots/","(",is[ii],",",js[ii],")","plot",l,".png",sep=""))
      boxplot(controltemp[,l],bcnutemp[,l],names=c("Control","BCNU"),main=names(datos)[l])
      dev.off()
    }
  }
}


if(opcion_por_caracteristica == TRUE){
  dir.create(paste(direccionSalida,"/dCohen_por_caracteristica",sep=""))
  for(tempCaract in 1:num_caract){
    temporalCaract = NULL
    dCohen <- NULL
    for(streamline in 0:49){
      temp_vector <- NULL
      temp_vector_caract <- NULL
      for(p in 1:10){
        temp_control <- NULL
        temp_bcnu <- NULL
        for(i in 0:(numControl-1)){
          x = ((i*500)+(streamline*10)+p)
          temp_control <- c(temp_control,control[x,tempCaract])
        }
        for(i in 0:(numBCNU-1)){
          x = ((i*500)+(streamline*10)+p)
          temp_bcnu <- c(temp_bcnu,bcnu[x,tempCaract])
        }
        m1 = mean(temp_control)
        m2 = mean(temp_bcnu)
        temp_vector_caract <- c(temp_vector_caract,m1)
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
      temporalCaract <- rbind(temporalCaract, temp_vector_caract)
      dCohen <- rbind(dCohen,temp_vector)
    }
    guardarImagenPng(dCohen, paste("d de Cohen entre ratas control y BCNU para ",names(datos)[tempCaract],sep=""),
                     paste(direccionSalida,"/dCohen_por_caracteristica/",as.character(tempCaract),".png",sep=""), c(-1.5,1.5))
    
    guardarComoTxt(dCohen, paste(direccionSalida,"/enTXT/dcohen/",names(datos)[tempCaract],".txt",sep=""))
    
  }
  
  dir.create(paste(direccionSalida,"/pvalores_por_caracteristica",sep=""))
  dir.create(paste(direccionSalida,"/pvalores_por_caracteristica_acotados",sep=""))
  dir.create(paste(direccionSalida,"/promedio_valores",sep=""))
  
  for(tempCaract in 1:num_caract){
    # Prueba t de student
    pvalores = NULL
    
    promedioControl = NULL
    promedioBCNU = NULL
    
    for(streamline in 0:49){
      temp = NULL
      temp_promedio_control = NULL
      temp_promedio_bcnu = NULL
      for(profundidad in 1:10){
        tempControl = NULL
        tempBCNU = NULL
        for(k in 0:(numControl-1)){
          tempControl = c(tempControl,control[((k*50*numProfundidad) + (streamline*numProfundidad) + profundidad),tempCaract])
        }
        for(k in 0:(numBCNU-1)){
          tempBCNU = c(tempBCNU,bcnu[((k*50*numProfundidad) + (streamline*numProfundidad) + profundidad),tempCaract])
        }
        if(!((max(tempControl)==min(tempControl)) && (max(tempBCNU)==min(tempBCNU)) && (min(tempBCNU) == min(tempControl)))){
          temp = c(temp,t.test(tempControl,tempBCNU)$p.value)
        }
        else{
          temp = c(temp,NULL)
        }
        temp_promedio_control = c(temp_promedio_control, mean(tempControl))
        temp_promedio_bcnu = c(temp_promedio_bcnu, mean(tempBCNU))
      }
      pvalores = rbind(pvalores,temp)
      promedioControl = rbind(promedioControl, temp_promedio_control)
      promedioBCNU = rbind(promedioBCNU, temp_promedio_bcnu)
    }
    png(width = 800, height = 600,filename = paste(direccionSalida,"/pvalores_por_caracteristica_acotados/",as.character(tempCaract),".png",sep=""))
    if(min(pvalores) < 0){
      color <- colorRampPalette(rev(brewer.pal(9,"RdBu")))(100)
    } else{
      color <- colorRampPalette(rev(brewer.pal(9,"YlGnBu")))(100)
    }
    image.plot(pvalores, axes = FALSE, main = paste("p valores usando la prueba t de student para ", names(datos)[tempCaract],sep=""), zlim = c(0,0.5), col = color)
    axis(1, at = seq(0,1,0.2), labels = c(1,11,21,30,40,50))
    axis(2, at = seq(0,1,0.11), labels = c(1,2,3,4,5,6,7,8,9,10))
    dev.off()
    
    guardarImagenPng(pvalores, paste("p valores usando la prueba t de student para ", names(datos)[tempCaract],sep=""),
                     paste(direccionSalida,"/pvalores_por_caracteristica/",as.character(tempCaract),".png",sep=""), c(0,1))
    guardarImagenPng(promedioControl, paste("promedio de valores en ratas control para ", names(datos)[tempCaract],sep=""),
                     paste(direccionSalida,"/promedio_valores/",as.character(tempCaract),"_control.png",sep=""), NULL)
    guardarImagenPng(promedioBCNU, paste("promedio de valores en ratas BCNU para ", names(datos)[tempCaract],sep=""),
                     paste(direccionSalida,"/promedio_valores/",as.character(tempCaract),"_bcnu.png",sep=""), NULL)
    
    guardarComoTxt(promedioControl,paste(direccionSalida,"/enTXT/promedio_valores/",names(datos)[tempCaract],"_control.txt",sep=""))
    guardarComoTxt(promedioBCNU,paste(direccionSalida,"/enTXT/promedio_valores/",names(datos)[tempCaract],"_bcnu.txt",sep=""))
    guardarComoTxt(pvalores, paste(direccionSalida,"/enTXT/pvalores/",names(datos)[tempCaract],".txt",sep=""))
  }

}

