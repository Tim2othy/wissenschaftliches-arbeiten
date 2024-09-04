library(tree)
library(caret)




# Adjust the number of data points
n <- 80  




# Generate clustered data with non-linear patterns
a <- rnorm(n, mean = 20, sd = 56)-6 -c((1:n) - 5) * 0.3
b <- runif(n, -12, 30)
c <- rnorm(n, mean = 60, sd = 90)-c(((1:n) * 0.1) - 3.3)^3 * 0.08
d <- rnorm(n, mean = -70, sd = 50) - 3
e <- (x3 * 0.06 - 0.5) - 1 + rnorm(n, mean = 0, sd = 8)
f <- 4 + rnorm(n, mean = 100, sd = 100)
g <- rnorm(n, mean = 20, sd = 30)
h <- c((1:n) - 5) * 1.2

# Introduce more complexity and non-linearity
x1 <- (g-b+rnorm(n, mean = 20, sd = 5)-6)*0.01
x2 <- (-(b+c-d+rnorm(n, mean = 20, sd = 50)-6))*0.01
x3 <- (c-a+f+rnorm(n, mean = 20, sd = 50)-6)*0.01
x4 <- (-(e-h-a+rnorm(n, mean = 20, sd = 50)-6))*0.01
y <- (a+b+c+d+e+f+g+h+rnorm(n, mean = 20, sd = 50)-6)*0.01

# Combine into a data frame
pData <- data.frame(x1, x2,x3, x4, y)

cont = tree.control(nobs=80, mincut = 1, minsize = 2, mindev = 0)

?tree.control

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

tree_model_big <- tree(y ~ x1 + x2 + x3 + x4,data=pData, control = cont)


# Make predictions
tree_pred <- predict(tree_model, pData)

mse <- mean((pData$y - tree_pred)^2)

mse

plot(tree_model)
text(tree_model)

#compared the in sample and out of sample training error, they are actually different, this really works : )

plot(tree_model_big)
text(tree_model_big)





# Split data into training and test sets
train_idx <- sample(nrow(pData), 0.5 * nrow(pData))
train_data <- pData[train_idx, ]
test_data <- pData[-train_idx, ]



# Set control parameters to grow a larger tree
tree_control <- tree.control(nobs = 40, mincut = 1, minsize = 2, mindev = 0)



# Grow the tree with the specified control parameters
large_tree <- tree(y ~ x1 + x2 + x3 + x4, data= train_data, control = tree_control)



plot(large_tree)
text(large_tree)
large_tree_pred <- predict(large_tree, newdata = test_data)


# Prune the tree
cv_tree <- cv.tree(large_tree, FUN = prune.tree)

plot(cv_tree$size, (cv_tree$dev), type = "b")


# Get the optimal tree size
optimal_size <- cv_tree$size[which.min(cv_tree$dev)]
pruned_tree <- prune.tree(large_tree, best = optimal_size)

print(optimal_size)

plot(pruned_tree)
text(pruned_tree)

# Make predictions on the test data
pruned_tree_pred <- predict(pruned_tree, newdata = test_data)

# Calculate mean squared error
mse <- mean((test_data$y - pruned_tree_pred)^2)

mse

# Plot MSE vs. alpha
plot(cv_tree$k, cv_tree$dev, type = "b")


mse <- mean((test_data$y - large_tree_pred)^2)

mse








#pruning

# Split data into training and test sets
set.seed(123)  # For reproducibility
train_idx <- sample(nrow(pData), 0.7 * nrow(pData))
train_data <- pData[train_idx, ]
test_data <- pData[-train_idx, ]

# Grow a large tree
large_tree <- tree(y ~ x, data = train_data)

plot(train_data)

plot(large_tree)

# Prune the tree
cv_tree <- cv.tree(large_tree, FUN = prune.misclass)
plot(cv_tree$size, cv_tree$dev, type = "b")

# Get the optimal tree size
optimal_size <- cv_tree$size[which.min(cv_tree$dev)]
pruned_tree <- prune.misclass(large_tree, best = optimal_size)

# Make predictions on the test data
tree_pred <- predict(pruned_tree, newdata = test_data)

# Calculate mean squared error
mse <- mean((test_data$y - tree_pred)^2)

# Plot MSE vs. alpha
plot(cv_tree$k, cv_tree$dev, type = "b", xlab = "Alpha", ylab = "Mean Squared Error")









# Assuming you've already created nonlinear_data and trained the models as before

# Create a grid for prediction
grid <- expand.grid(x = seq(min(nonlinear_data$x), max(nonlinear_data$x), length.out = 200),
                    y = seq(min(nonlinear_data$y), max(nonlinear_data$y), length.out = 200))

# Make predictions on the grid
tree_grid_pred <- predict(tree_model, grid, type = "class")
lm_grid_pred <- ifelse(predict(lm_model, grid, type = "response") > 0.5, "Blue", "Red")

# Define colors
bg_red <- "pink"
bg_blue <- "lightblue"
point_red <- "red"
point_blue <- "blue"

# Plot
par(mfrow = c(1, 2))

# Tree model plot
plot(grid$x, grid$y, col = ifelse(tree_grid_pred == "Red", bg_red, bg_blue), 
     pch = 20, cex = 0.5, main = "Classification Tree", xlab = "X", ylab = "Y")
points(nonlinear_data$x, nonlinear_data$y, 
       col = ifelse(nonlinear_data$group == "Red", point_red, point_blue), 
       pch = 19)

# Add decision boundary for tree
contour(seq(min(nonlinear_data$x), max(nonlinear_data$x), length.out = 200),
        seq(min(nonlinear_data$y), max(nonlinear_data$y), length.out = 200),
        matrix(as.numeric(tree_grid_pred), 200, 200),
        levels = 1.5, add = TRUE, drawlabels = FALSE, lwd = 2)

# Linear regression model plot
plot(grid$x, grid$y, col = ifelse(lm_grid_pred == "Red", bg_red, bg_blue), 
     pch = 20, cex = 0.5, main = "Linear Classification", xlab = "X", ylab = "Y")
points(nonlinear_data$x, nonlinear_data$y, 
       col = ifelse(nonlinear_data$group == "Red", point_red, point_blue), 
       pch = 19)

# Add decision boundary for linear regression
contour(seq(min(nonlinear_data$x), max(nonlinear_data$x), length.out = 200),
        seq(min(nonlinear_data$y), max(nonlinear_data$y), length.out = 200),
        matrix(as.numeric(factor(lm_grid_pred)), 200, 200),
        levels = 1.5, add = TRUE, drawlabels = FALSE, lwd = 2)





plot(tree_model)
text(tree_model)


# Calculate MSE
tree_mse <- mean((actual - tree_pred_num)^2)
lm_mse <- mean((actual - lm_pred_num)^2)

print(paste("Classification Tree MSE:", tree_mse))
print(paste("Linear Regression MSE:", lm_mse))

# Calculate classification error rate
tree_error_rate <- mean(tree_pred != nonlinear_data$group)
lm_error_rate <- mean(lm_pred != nonlinear_data$group)

print(paste("Classification Tree Error Rate:", tree_error_rate))
print(paste("Linear Regression Error Rate:", lm_error_rate))




# Define colors
point_red <- "red"
point_blue <- "blue"

# Plot just the points
par(mfrow = c(1, 2))

# Tree model plot (points only)
plot(nonlinear_data$x, nonlinear_data$y, 
     col = ifelse(nonlinear_data$group == "Red", point_red, point_blue),
     pch = 19,  # Solid circle
     cex = 1,   # Point size
     main = "Classification Tree", 
     xlab = "X", ylab = "Y",
     xlim = c(min(nonlinear_data$x), max(nonlinear_data$x)),
     ylim = c(min(nonlinear_data$y), max(nonlinear_data$y)))

# Linear regression model plot (points only)
plot(nonlinear_data$x, nonlinear_data$y, 
     col = ifelse(nonlinear_data$group == "Red", point_red, point_blue),
     pch = 19,  # Solid circle
     cex = 1,   # Point size
     main = "Linear Classification", 
     xlab = "X", ylab = "Y",
     xlim = c(min(nonlinear_data$x), max(nonlinear_data$x)),
     ylim = c(min(nonlinear_data$y), max(nonlinear_data$y)))




> train <-sample(1:nrow(Carseats), 200)
> Carseats.test <- Carseats[-train, ]
> High.test <- High[-train]
> tree.carseats <-tree(High .- Sales, Carseats,
                       subset = train)
> tree.pred <-predict(tree.carseats, Carseats.test,
                      type = "class")
> table(tree.pred, High.test)
High.test
tree.pred No Yes
No 104 33
Yes 13 50
> (104 + 50) / 200
[1] 0.77




