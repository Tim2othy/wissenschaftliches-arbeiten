
# Definition von Vektoren und Matrizen
x <- 2 + 2

y <- c(2, 7, 4, 1)


z <- 1:10


z2 <- seq(from=1, to=20, by=2)


A <- matrix(data = 1:16, ncol = 4, nrow=4)

B <- matrix(1:4, ncol = 2)
C <- matrix(5:8, ncol = 2)


D <- B %*% C

# Matrix Multiplikation
A %*% y


# Dot Product
t(y) %*% y

# Outer Product
y %*% t(y)


# Matrix Invertieren
solve(D)

# Größe der Matrix
dimA <- dim(A)

# Für Vektoren
dimy <- length(y)


# Conditioning
A[,1][A[,1] > 2]


# Lösung: Aufgabe 1

A <- matrix(1:4, nrow = 4, ncol = 4, byrow=TRUE)

A[,2] <- 5

# Listen

list1 <- list("Some Numbers" = c(1, 2, 3, 4),
              "Animals" = c("Rabbit", "Cat", "Elefant"),
              "My_Series"=  c(30:1))

# Data Frame
myFirst_df <- data.frame("Credit Default" = c(0, 0, 1, 0, 1, 1),
                         "Age" = c(35, 41, 55, 36, 44, 26),
                         "Loan_in_1000_EUR" = c(55, 65, 23, 12, 98, 76))


# For-Schleifen/if-Conditions

# For Loops

y <- c(1:1000)

N <- length(y)

# Preallocation
y_squared <- numeric(length = N)

for(i in 1:N){
  
  y_squared[i] <- y[i]^2
  
}

# If-Conditions

# Simuliere Daten
y <- rnorm(100)

N <- length(y)

z <- numeric(length = N)

for(i in 1:N){
  
  if(y[i] < 0){
    z[i] <- 0
  }
  if(y[i] > 0){
    z[i] <- 1
  } 
  
}
