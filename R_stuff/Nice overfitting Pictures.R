# Load required packages
library(rpart)
library(randomForest)
library(MASS)
library(caret)
library(tree)

# Simulation 1: Linear data where OLS will outperform a simple tree model

n <- 40
x <- rnorm(n)+4
y <- 4 * x  + rnorm(n,0,100)


x=(x)*3

tree_model <- tree(y ~ x)


plot(tree_model)
text(tree_model)


plot(pruned_tree_model)
text(pruned_tree_model)

# Fit the simple regression tree
tree_model <- tree(y ~ x)
# Prune the tree to have exactly 4 terminal nodes
pruned_tree_model <- prune.tree(tree_model, best=4)
summary(pruned_tree_model)


# OLS model
ols_model <- lm(y ~ x)
summary(ols_model)

# Fit the simple regression tree
tree_model <- tree(y ~ x)
summary(tree_model)




plot(tree_model)
text(tree_model)



# Predict using OLS model
ols_pred <- predict(ols_model, data.frame(x=x))

# Predict using regression tree model
tree_pred <- predict(tree_model, data.frame(x=x))

# Calculate MSE for OLS model
mse_ols <- mean((y - ols_pred)^2)

# Calculate MSE for regression tree model
mse_tree <- mean((y - tree_pred)^2)

# Print MSE values
cat("MSE for OLS model:", mse_ols, "\n")
cat("MSE for regression tree model:", mse_tree, "\n")


# Plot the data




plot(
  x, y,
  col = rgb(0.2, 0.6, 1 ,1),  # Light blue color with 60% opacity
  pch = 19,                     # Solid circle
  cex = 1,                    # 1.3 times default size
  xlab = "X-axis",                # X-axis label
  ylab = "Y-axis",                # Y-axis label
)
grid()


abline(ols_model, col="blue", lwd=2) # makes the line in the plot



# Overlay the regression tree predictions
# To overlay the regression tree, we need to plot its predictions as segments
# We can do this by plotting a step function
ord <- order(x)  # order x to plot the step function correctly
lines(x[ord], tree_pred[ord], col="red", lwd=2, type="s")

# Add a legend to the plot
legend("topleft", legend=c("OLS", "Regression Tree"), col=c("blue", "red"), lwd=2)


# Exacetly 4 terminal nodes





# Fit the initial regression tree
tree_model <- tree(y ~ x)

plot(tree_model)
text(tree_model)

# Prune the tree to have exactly 4 terminal nodes
pruned_tree_model <- prune.tree(tree_model, best=4)

plot(pruned_tree_model)
text(pruned_tree_model)

# Summary of the pruned tree
summary(pruned_tree_model)



# Predict using the pruned regression tree model
tree_pred_pruned <- predict(pruned_tree_model, data.frame(x=x))

# Calculate MSE for the pruned regression tree model
mse_tree_pruned <- mean((y - tree_pred_pruned)^2)

# Print the MSE for the pruned regression tree model
cat("MSE for pruned regression tree model:", mse_tree_pruned, "\n")

# Plot the data again with pruned regression tree predictions
plot(x, y, main="Data with OLS and Pruned Regression Tree Predictions", xlab="x", ylab="y", pch=19, col=rgb(0, 0, 0, 0.5))
abline(ols_model, col="blue", lwd=2)

# Overlay the pruned regression tree predictions
lines(x[ord], tree_pred_pruned[ord], col="green", lwd=2, type="s")

# Add a legend to the plot
legend("topright", legend=c("OLS", "Pruned Regression Tree"), col=c("blue", "red"), lwd=2)




