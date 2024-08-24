library(tree)
library(caret)




# Adjust the number of data points
n <- 200  

plot(g)


# Generate clustered data with non-linear patterns
a <- rnorm(n, mean = 20, sd = 56)-6 -c((1:n) - 5) * 2.3
b <- runif(n, -12, 30)-c(1:n)*0.5
c <- rnorm(n, mean = 60, sd = 90)-c(((1:n) * 0.1) - 3.3)^3 * 3
d <- rnorm(n, mean = -70, sd = 50) - 3-c(((1:n) * 0.05) - 3.3)^5 * 0.6
e <- (x3 * 0.06 - 0.5) - 1 + rnorm(n, mean = 0, sd = 8)
f <- 4 + rnorm(n, mean = 100, sd = 100)
g <- (rnorm(n, mean = 0, sd = 3) -c((1:n)+5) * 0.3)^2
h <- c((1:n) - 5) * 1.2

# Introduce more complexity and non-linearity
x1 <- (g-b+rnorm(n, mean = 20, sd = 5)-6)*0.01
x2 <- (-(b+c-d+rnorm(n, mean = 20, sd = 50)-6))*0.01
x3 <- (c-a+f+rnorm(n, mean = 20, sd = 5000)-6)*0.01
x4 <- (-(e-h-a+rnorm(n, mean = 20, sd = 50)-6))*0.01
y <- (a+b+c+d+e+f+g+h+rnorm(n, mean = 20, sd = 50)-6)*0.01

# Combine into a data frame
pData <- data.frame(x1, x2,x3, x4, y)

plot(
  pData,
  col = rgb(0.2, 0.7, 1,1),  # Light blue color with 60% opacity
  pch = 19,                     # Solid circle
  cex = 1,                    # 1.3 times default size
  #xlab = "X-axis",                # X-axis label
  #ylab = "Y-axis",                # Y-axis label
  
)

# Train  tree
tree_model <- tree(y ~ x1 + x2 + x3 + x4, data=pData)

# Make predictions
tree_pred <- predict(tree_model, pData)

mse <- mean((pData$y - tree_pred)^2)

mse

plot(tree_model)
text(tree_model)





# Split data into training and test sets
train_idx <- sample(nrow(pData), 0.5 * nrow(pData))
train_data <- pData[train_idx, ]
test_data <- pData[-train_idx, ]



# Set control parameters to grow a larger tree
tree_control <- tree.control(nobs = 100, mincut = 1, minsize = 2, mindev = 0)



# Grow the tree with the specified control parameters
large_tree <- tree(y ~ x1 + x2 + x3 + x4, data= train_data, control = tree_control)



plot(large_tree)
text(large_tree)
large_tree_pred <- predict(large_tree, newdata = test_data)


# Prune the tree
cv_tree <- cv.tree(large_tree, FUN = prune.tree)

plot(cv_tree$size, (cv_tree$mse), type = "b")


# Get the optimal tree size
optimal_size <- cv_tree$size[which.min(cv_tree$mse)]
pruned_tree <- prune.tree(large_tree, best = optimal_size)

print(optimal_size)

plot(pruned_tree)

text(pruned_tree)

# Make predictions on the test data
pruned_tree_pred <- predict(pruned_tree, newdata = test_data)

# Calculate mean squared error
mseP <- mean((test_data$y - pruned_tree_pred)^2)

mseP

mseB = mean((test_data$y - large_tree_pred)^2)

mseB




