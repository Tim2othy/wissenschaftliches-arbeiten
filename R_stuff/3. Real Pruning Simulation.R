# Load necessary libraries
library(rpart)
library(rpart.plot)



# Step 1: Generate a polynomial function with some noise
n <- 200
x <- runif(n, -10, 35)-rnorm(n,0,3)
y <- (-1-rnorm(1,0,0.1))*x - (0.3-rnorm(1,0,0.002))*x^2 + (0.01-rnorm(1,0,0.0004))*x^3 + rnorm(n, sd=7)
data <- data.frame(x = x, y = y)


plot(data)







# Step 2: Train a regression tree with more complexity
tree_model <- rpart(y ~ x, data = data, control = rpart.control(cp = 0, minsplit = 2))

# Plot the initial complex tree
rpart.plot(tree_model, main = "Initial Complex Regression Tree")

# Calculate initial MSE
initial_pred <- predict(tree_model, data)
initial_mse <- mean((data$y - initial_pred)^2)
cat("Initial MSE: ", initial_mse, "\n")





plot(
  data,
  col = rgb(0.2, 0.7, 1,1),  # Light blue color with 60% opacity
  pch = 19,                     # Solid circle
  cex = 0.7,                    # 1.3 times default size
  xlab = "X-axis",                # X-axis label
  ylab = "Y-axis",                # Y-axis label
  
)
grid()


# Overlay the regression tree predictions
# To overlay the regression tree, we need to plot its predictions as segments
# We can do this by plotting a step function
ord <- order(x)  # order x to plot the step function correctly
lines(x[ord], initial_pred[ord], col="red", lwd=2, type="s")



# Step 3: Prune the tree
# Use cross-validation to find the optimal complexity parameter (cp)
printcp(tree_model)  # Display the CP table

?printcp

# Find the optimal cp value that minimizes the cross-validated error
opt_index <- which.min(tree_model$cptable[,"xerror"])
opt_cp <- tree_model$cptable[opt_index, "CP"]




# Prune the tree using the optimal cp value
pruned_tree <- prune(tree_model, cp = opt_cp)

# Plot the pruned tree
rpart.plot(pruned_tree, main = "Pruned Regression Tree")

# Calculate pruned MSE
pruned_pred <- predict(pruned_tree, data)
pruned_mse <- mean((data$y - pruned_pred)^2)
cat("Pruned MSE: ", pruned_mse, "\n")

# Step 4: Plot how the pruning changes the MSE with respect to tree size
# Extract CP table for plotting
cp_table <- tree_model$cptable

# Calculate the number of terminal nodes for each cp value
num_nodes <- cp_table[, "nsplit"] + 1




plot(
  x, y,
  col = rgb(0.2, 0.7, 1,1),  # Light blue color with 60% opacity
  pch = 19,                     # Solid circle
  cex = 1,                    # 1.3 times default size
  xlab = "X-axis",                # X-axis label
  ylab = "Y-axis",                # Y-axis label
  
)
grid()






# Plot the MSE (xerror) against the number of terminal nodes
plot(num_nodes, cp_table[, "xerror"], pch=20, col = rgb(0.2, 0.7, 1, 1), type = "b", cex = 1, 
     xlab = "Tree Size", ylab = "Error", 
     ylim = c(0, max(cp_table[, "xerror"], cp_table[, "xstd"]) * 1.1),  # Extend y-axis to -1
)

# Add training error (MSE) to the plot
points(num_nodes, cp_table[, "xstd"], pch=20, col = "red", type = "b", cex = 1)

# Add a legend
legend("topright", legend = c("Cross-Validation", "Training"), 
       col = c(rgb(0.2, 0.7, 1, 1), "red"), pch = 20, lty = 1)

# Add grid lines
grid()




# Add a vertical line and text to indicate the optimal number of terminal nodes
abline(v = num_nodes[opt_index], col = "purple", lty = 2)
text(num_nodes[opt_index], min(cp_table[, "xerror"]), 
     labels = paste("Optimal Size =", num_nodes[opt_index]), pos = 4, col = "black")






# Step 5: Summarize the MSE before and after pruning
cat("Summary:\n")
cat("Initial MSE: ", initial_mse, "\n")
cat("Pruned MSE: ", pruned_mse, "\n")



#But with real cross validation

n <- 200
x2 <- runif(n, -10, 35)-rnorm(n,0,3)
y2 <- (-1-rnorm(1,0,0.1))*x2 - (0.3-rnorm(1,0,0.002))*x2^2 + (0.01-rnorm(1,0,0.0004))*x2^3 + rnorm(n, sd=7)
data2 <- data.frame(x = x2, y = y2)


plot(data2)




initial_pred2 <- predict(tree_model, data2)
initial_mse2 <- mean((data2$y - initial_pred2)^2)
print(initial_mse2)

pruned_pred2 <- predict(pruned_tree, data2)
pruned_mse2 <- mean((data2$y - pruned_pred2)^2)
print(pruned_mse2)














# a bunch of times again


library(rpart)
library(rpart.plot)

run_experiment <- function() {
  # Generate data
  n <- 200
  x <- runif(n, -10, 35) - rnorm(n, 0, 3)
  y <- (-1-rnorm(1,0,0.1))*x - (0.3-rnorm(1,0,0.002))*x^2 + (0.01-rnorm(1,0,0.0004))*x^3 + rnorm(n, sd=7)
  train_data <- data.frame(x = x, y = y)
  
  # Train initial tree
  tree_model <- rpart(y ~ x, data = train_data, control = rpart.control(cp = 0, minsplit = 2))
  
  # Prune the tree
  opt_index <- which.min(tree_model$cptable[,"xerror"])
  opt_cp <- tree_model$cptable[opt_index, "CP"]
  pruned_tree <- prune(tree_model, cp = opt_cp)
  
  # Generate test data
  x2 <- runif(n, -10, 35) - rnorm(n, 0, 3)
  y2 <- (-1-rnorm(1,0,0.1))*x2 - (0.3-rnorm(1,0,0.002))*x2^2 + (0.01-rnorm(1,0,0.0004))*x2^3 + rnorm(n, sd=7)
  test_data <- data.frame(x = x2, y = y2)
  
  # Calculate MSE for initial and pruned models
  initial_pred <- predict(tree_model, test_data)
  initial_mse <- mean((test_data$y - initial_pred)^2)
  
  pruned_pred <- predict(pruned_tree, test_data)
  pruned_mse <- mean((test_data$y - pruned_pred)^2)
  
  return(c(initial_mse, pruned_mse))
}

# Run the experiment 400 times
num_runs <- 400
results <- replicate(num_runs, run_experiment())

# Calculate average MSE for both models
avg_initial_mse <- mean(results[1,])
avg_pruned_mse <- mean(results[2,])

# Print results
cat("Average Initial MSE:", avg_initial_mse, "\n")
cat("Average Pruned MSE:", avg_pruned_mse, "\n")
