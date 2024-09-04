#Simulations Studie Wissenschaftliches Arbeiten
# Load required packages
library(rpart)
library(randomForest)
library(MASS)
library(caret)
library(tree)

# Simulation 1: Linear data where OLS will outperform a simple tree model

#Generating the Data
n <- 250
x <- rnorm(n)+4
y <- 2.5 * x  + rnorm(n,0,1)
x=(x)*3
plot(x,y)




# OLS model
ols_model <- lm(y ~ x)
summary(ols_model)

# Fit the simple regression tree
tree_model <- tree(y ~ x)
# Prune the tree to have exactly 4 terminal nodes
pruned_tree_model <- prune.tree(tree_model, best=4)
summary(pruned_tree_model)


# Predict using OLS model
ols_pred <- predict(ols_model, data.frame(x=x))

# Calculate MSE for OLS model
mse_ols <- mean((y - ols_pred)^2)

# Predict using the pruned regression tree model
tree_pred_pruned <- predict(pruned_tree_model, data.frame(x=x))

# Calculate MSE for the pruned regression tree model
mse_tree_pruned <- mean((y - tree_pred_pruned)^2)

# Print MSE values
cat("MSE for OLS model:", mse_ols, "\n")
cat("MSE for pruned regression tree model:", mse_tree_pruned, "\n")





plot(
  x, y,
  col = rgb(0.2, 0.6, 1,1),  # Light blue color with 60% opacity
  pch = 19,                     # Solid circle
  cex = 0.8,                    # 1.3 times default size
  xlab = "X", ylab = "Y",

)
grid()





abline(ols_model, col="blue", lwd=2) # makes the line in the plot


# Overlay the regression tree predictions
# To overlay the regression tree, we need to plot its predictions as segments
# We can do this by plotting a step function
ord <- order(x)  # order x to plot the step function correctly
lines(x[ord], tree_pred_pruned[ord], col="red", lwd=2, type="s")

# Add a legend to the plot
legend("topleft", legend=c("OLS", "Regression Tree"), col=c("blue", "red"), lwd=2)






plot(tree_model)
text(tree_model)



plot(pruned_tree_model)
text(pruned_tree_model)






#Running the Simulation a bunch

# Load required library
library(tree)

# Function to run a single simulation
run_simulation <- function() {
  n <- 250
  x <- rnorm(n) + 4
  y <- 2.5 * x + rnorm(n, 0, 1)
  x <- x * 3
  
  # OLS model
  ols_model <- lm(y ~ x)
  
  # Regression tree model
  tree_model <- tree(y ~ x)
  pruned_tree_model <- prune.tree(tree_model, best=4)
  
  # Predict and calculate MSE for OLS
  ols_pred <- predict(ols_model, data.frame(x=x))
  mse_ols <- mean((y - ols_pred)^2)
  
  # Predict and calculate MSE for pruned tree
  tree_pred_pruned <- predict(pruned_tree_model, data.frame(x=x))
  mse_tree_pruned <- mean((y - tree_pred_pruned)^2)
  
  return(c(mse_ols, mse_tree_pruned))
}

# Run simulation 400 times
num_simulations <- 400
results <- replicate(num_simulations, run_simulation())

# Calculate average MSE for both methods
avg_mse_ols <- mean(results[1,])
avg_mse_tree <- mean(results[2,])

# Print results
cat("Average MSE for OLS model after 400 simulations:", avg_mse_ols, "\n")
cat("Average MSE for pruned regression tree model after 400 simulations:", avg_mse_tree, "\n")
