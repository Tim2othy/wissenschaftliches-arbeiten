#Wissenschaftliches Arbeiten

A=matrix(1:4,nrow=4,ncol=4,byrow=1)
A[,2]=5
A

liste = list(1,2)


#for loops
y=c(1,2,3,4,5,6,7)

N= length(y)
N
y_squared = numeric(length = N)
  
for(i in 1:N){
  
  y_squared[i]=y[i]^2
}
y_squared  


y=rnorm(1000)
hist(y)

N = length(y)





#Woche 3 weiter mit Slide von Woche 2

x=c(1:100)
x

for(i in 1:100){
  
  x[i]=log(x[i])
  
  
  
}
x


x=rnorm(100)
y=rnorm(100)
z=rnorm(100)
plot(x,y,z)


# Install and load the rgl package
install.packages("rgl")
library(rgl)

# Sample data
x <- c(1, 2, 3, 4, 5)
y <- c(2, 4, 6, 8, 10)
z <- c(3, 6, 9, 12, 15)

# Create 3D scatter plot
plot3d(x, y, z, type = "s", col = "white", xlab = "X", ylab = "Y", zlab = "Z")

rglwidget()
?plot

#Aufgabe 3

mittelwert <- function(x){
  x.len <- length(x)
  result <- sum(x)/x.len
  return(result)
}
wn <- rnorm(100, mean=2, sd=2)
mittelwert(x=wn)

length(x)
varianz <- function(x){
 
 
 result=sum((x-(sum(x))/length(x))^2)/(length(x)-1)
  return(result)
}


x=c(1,44,5,6,7,8,9,0,4)
varianz(x)
var(x)


#Basic mini simulation

M <- 5000
N <- 1000
emp.mittel <- rep(0,N)
for(k in 1:M){
  data <- rnorm(n,mean=2,sd=100)
  emp.mittel[k] <- mean(data)
}
mean(emp.mittel)
sd(emp.mittel)
hist(emp.mittel)

abline(v=2,col="red")

abline(v=mean(emp.mittel),col="blue")

plot(emp.mittel)




