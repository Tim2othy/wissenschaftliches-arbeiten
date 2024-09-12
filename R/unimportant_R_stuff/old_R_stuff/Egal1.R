# Load necessary libraries
library(rpart)
library(rpart.plot)

# Step 1: Generate a polynomial function with some noise
n <- 200
x <- runif(n, -10, 35) - rnorm(n, 0, 3)
y <- (-1 - rnorm(1, 0, 0.1)) * x - (0.3 - rnorm(1, 0, 0.002)) * x^2 + (0.01 - rnorm(1, 0, 0.0004)) * x^3 + rnorm(n, sd = 7)
data <- data.frame(x = x, y = y)

# Step 2: Train a regression tree with more complexity
tree_model <- rpart(y ~ x, data = data, control = rpart.control(cp = 0, minsplit = 2))

# Calculate initial MSE (Training error)
initial_pred <- predict(tree_model, data)
initial_mse <- mean((data$y - initial_pred)^2)
cat("Initial MSE: ", initial_mse, "\n")

# Plot the initial complex tree
rpart.plot(tree_model, main = "Initial Complex Regression Tree")

# Step 3: Prune the tree
printcp(tree_model)  # Display the CP table

# Find the optimal cp value that minimizes the cross-validated error
opt_index <- which.min(tree_model$cptable[, "xerror"])
opt_cp <- tree_model$cptable[opt_index, "CP"]

# Prune the tree using the optimal cp value
pruned_tree <- prune(tree_model, cp = opt_cp)

# Plot the pruned tree
rpart.plot(pruned_tree, main = "Pruned Regression Tree")

# Calculate pruned MSE (Training error)
pruned_pred <- predict(pruned_tree, data)
pruned_mse <- mean((data$y - pruned_pred)^2)
cat("Pruned MSE: ", pruned_mse, "\n")

# Step 4: Plot how the pruning changes the MSE with respect to tree size
# Extract CP table for plotting
cp_table <- tree_model$cptable
num_nodes <- cp_table[, "nsplit"] + 1







# Plot the MSE (xerror) against the number of terminal nodes
plot(num_nodes, cp_table[, "xerror"], pch=20, col = rgb(0.2, 0.7, 1, 1), type = "b", cex = 1, 
     xlab = "Tree Size", ylab = "Mean Squared Error", 
     ylim = c(0, max(cp_table[, "xerror"], cp_table[, "xstd"]) * 1.1),  # Extend y-axis to -1
     main = "Error vs Tree Size")

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





