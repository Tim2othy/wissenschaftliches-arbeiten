###############################################
##### TEIL 2: Simulationen
###############################################

# Globales Simulationssetting
T <- 100
beta0 <- 1
beta1 <- 2
beta2 <- -3
betas <- c(beta0, beta1, beta2)

# Datengenerierender Prozess
X1 <- rnorm(T,1,2)
X2 <- rnorm(T,1,2)
u <- rnorm(T,0,1)
Y <- beta0 + beta1*X1 + beta2*X2 + u

plot(Y)

# Schätzung des Modells
lm(Y~X1+X2)
lm(Y~X1+X2)$coeff

# Funktion für Simulation und Schätzung
sim.ols <- function(...){
  X1 <- rnorm(T,1,2)
  X2 <- rnorm(T,1,2)
  u <- rnorm(T,0,1)
  Y <- beta0 + beta1*X1 + beta2*X2 + u
  return(lm(Y~X1+X2)$coeff)
}

sim.ols()

# Anzahl der Simulationswiederholungen
M <- 100

# Wir schätzen M-mal beta0, beta1 und beta2:
BetaDach <- matrix(nrow = 3, ncol=M)
for(i in 1:M){
  BetaDach[,i] <- sim.ols()
}
BetaDach

# Oder schneller mit diesem Befehl:
BetaDach <- sapply(1:M, sim.ols)
BetaDach

# Mittelwert der geschätzten betas:
mean(BetaDach[1,])
mean(BetaDach[2,])
mean(BetaDach[3,])

# Bias der geschätzten betas:
beta0 - mean(BetaDach[1,])
beta1 - mean(BetaDach[2,])
beta2 - mean(BetaDach[3,])

# Varianz der geschätzten betas:
var(BetaDach[1,])
var(BetaDach[2,])
var(BetaDach[3,])

# MSE:
mean((beta0 - BetaDach[1,])^2)
mean((beta1 - BetaDach[2,])^2)
mean((beta2 - BetaDach[3,])^2)


# Alles in einer Matrix:
zeilennamen = c("beta0", "beta1", "beta2")
spaltennamen = c("Bias", "Varianz", "MSE")
Tabelle <- matrix(nrow = 3, ncol = 3, dimnames = list(zeilennamen, spaltennamen))
for(i in 1:3){
  Tabelle[i,1] <- betas[i] - mean(BetaDach[i,])
  Tabelle[i,2] <- var(BetaDach[i,])
  Tabelle[i,3] <- mean((betas[i] - BetaDach[i,])^2)
}
Tabelle


# Besser noch: Eine Fuktion schreiben, die diese Matrix erzeugt:
ergebnistabelle <- function(BetaDach){
  zeilennamen = c("beta0", "beta1", "beta2")
  spaltennamen = c("Bias", "Varianz", "MSE")
  betas <- c(beta0, beta1, beta2) 
  Tabelle <- matrix(nrow = 3, ncol = 3, dimnames = list(zeilennamen, spaltennamen))
  for(i in 1:3){
    Tabelle[i,1] <- betas[i] - mean(BetaDach[i,])
    Tabelle[i,2] <- var(BetaDach[i,])
    Tabelle[i,3] <- mean((betas[i] - BetaDach[i,])^2)
  }
  return(Tabelle)
}

ergebnistabelle(BetaDach)


M <- 1000

# Simulationen für verschiedene Stichprobengrößen T

T <- 100
BetaDach <- sapply(1:M, sim.ols)
ergebnistabelle(BetaDach)

T <- 1000
BetaDach <- sapply(1:M, sim.ols)
ergebnistabelle(BetaDach)

T <- 10
BetaDach <- sapply(1:M, sim.ols)
ergebnistabelle(BetaDach)




######### Vergleich Prognose ############


sim.ols.outofsample <- function(...){
  X1 <- rnorm(T,1,2)
  X2 <- rnorm(T,1,2)
  u <- rnorm(T,0,1)
  Y <- beta0 + beta1*X1 + beta2*X2 + u
  beta.ols <- lm(Y~X1+X2)$coeff
  T.eval <- 1000
  X1.eval <- rnorm(T.eval,1,2)
  X2.eval<- rnorm(T.eval,1,2)
  u.eval <- rnorm(T.eval,0,1)
  Y.eval <- beta0 + beta1*X1.eval + beta2*X2.eval + u.eval
  Ydach <- cbind(rep(1,T.eval), X1.eval, X2.eval) %*% beta.ols
  MSE <- mean((Y.eval - Ydach)^2)
  return(MSE)
}

sim.ols.outofsample()

T<-100
MSEs <- sapply(1:M, sim.ols.outofsample)
mean(MSEs)

T<-1000
MSEs <- sapply(1:M, sim.ols.outofsample)
mean(MSEs)

T<-10
MSEs <- sapply(1:M, sim.ols.outofsample)
mean(MSEs)





        