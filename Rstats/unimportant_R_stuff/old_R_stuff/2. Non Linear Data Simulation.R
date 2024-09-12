
#creating non linear data

library(rpart)
library(caret)

n <- 60
x1 <- rnorm(n, mean = -2.9, sd = 1.1)
y1 <- rnorm(n, mean = 2.6, sd = 1.5)
x2 <- rnorm(n, mean = 2.6, sd = 1.2)
y2 <- rnorm(n, mean = -2.7, sd = 1.2)
x3 <- rnorm(n, mean = 3, sd = 1.6)
y3 <- rnorm(n, mean = 2.5, sd = 2)
x4 <- rnorm(n, mean = -2.5, sd = 1.3)
y4 <- rnorm(n, mean = -2.7, sd = 1.2)

# Combine into a data frame
nonlinear_data <- data.frame(
  x = c(x1, x2, x3, x4)+6,
  y = c(y1, y2, y3, y4)+6,
  group = factor(rep(c("Red", "Blue"), each = 2 * n))
)




plot(
  nonlinear_data$x, nonlinear_data$y, 
  col = as.character(nonlinear_data$group),
  pch = 19,                     # Solid circle
  cex = 1,                    # 1.3 times default size
  xlab = "X-axis",                # X-axis label
  ylab = "Y-axis",                # Y-axis label
  
)
grid()






# Train classification tree
tree_model <- rpart(group ~ x + y, data = nonlinear_data, method = "class", control = rpart.control(mindepth = 2, maxdepth = 2))

# Train linear regression model
lm_model <- glm(group ~ x + y, data = nonlinear_data, family = binomial)

# Make predictions
tree_pred <- predict(tree_model, nonlinear_data, type = "class")
lm_pred <- ifelse(predict(lm_model, nonlinear_data, type = "response") > 0.5, "Blue", "Red")




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
     cex = 0.8,   # Point size
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

















# do it a bunch


library(rpart)
library(caret)

run_model_comparison <- function(n_runs = 400, n_points = 60) {
  tree_errors <- numeric(n_runs)
  lm_errors <- numeric(n_runs)
  
  for (i in 1:n_runs) {
    # Generate non-linear data
    x1 <- rnorm(n_points, mean = -2.9, sd = 1.1)
    y1 <- rnorm(n_points, mean = 2.6, sd = 1.5)
    x2 <- rnorm(n_points, mean = 2.6, sd = 1.2)
    y2 <- rnorm(n_points, mean = -2.7, sd = 1.2)
    x3 <- rnorm(n_points, mean = 3, sd = 1.6)
    y3 <- rnorm(n_points, mean = 2.5, sd = 2)
    x4 <- rnorm(n_points, mean = -2.5, sd = 1.3)
    y4 <- rnorm(n_points, mean = -2.7, sd = 1.2)
    
    nonlinear_data <- data.frame(
      x = c(x1, x2, x3, x4) + 6,
      y = c(y1, y2, y3, y4) + 6,
      group = factor(rep(c("Red", "Blue"), each = 2 * n_points))
    )
    
    # Train classification tree
    tree_model <- rpart(group ~ x + y, data = nonlinear_data, method = "class", 
                        control = rpart.control(mindepth = 2, maxdepth = 2))
    
    # Train linear regression model
    lm_model <- glm(group ~ x + y, data = nonlinear_data, family = binomial)
    
    # Make predictions
    tree_pred <- predict(tree_model, nonlinear_data, type = "class")
    lm_pred <- ifelse(predict(lm_model, nonlinear_data, type = "response") > 0.5, "Blue", "Red")
    
    # Calculate classification error rate
    tree_errors[i] <- mean(tree_pred != nonlinear_data$group)
    lm_errors[i] <- mean(lm_pred != nonlinear_data$group)
  }
  
  # Calculate average error rates
  avg_tree_error <- mean(tree_errors)
  avg_lm_error <- mean(lm_errors)
  
  # Return results
  list(
    avg_tree_error = avg_tree_error,
    avg_lm_error = avg_lm_error,
    tree_errors = tree_errors,
    lm_errors = lm_errors
  )
}

# Run the function
results <- run_model_comparison(n_runs = 400, n_points = 60)

# Print average error rates
print(paste("Average Classification Tree Error Rate:", results$avg_tree_error))
print(paste("Average Linear Regression Error Rate:", results$avg_lm_error))

