# Load necessary libraries
library(rpart)
library(rpart.plot)

# Set seed for reproducibility
set.seed(42)

# Step 1: Generate a polynomial function with some noise
n <- 200
x <- runif(n, -10, 35) - rnorm(n, 0, 3)
y <- (-1 - rnorm(1, 0, 0.1)) * x - (0.3 - rnorm(1, 0, 0.002)) * x^2 + 
  (0.01 - rnorm(1, 0, 0.0004)) * x^3 + rnorm(n, sd=7)
data <- data.frame(x = x, y = y)

plot(data)

# Split the data into training and validation sets
set.seed(42)  # Ensures reproducibility
train_indices <- sample(1:n, size = 0.7*n)
train_data <- data[train_indices, ]
valid_data <- data[-train_indices, ]

# Step 2: Train a regression tree with more complexity
tree_model <- rpart(y ~ x, data = train_data, control = rpart.control(cp = 0, minsplit = 2))

# Plot the initial complex tree
rpart.plot(tree_model, main = "Initial Complex Regression Tree")

# Calculate initial MSE using the validation set
initial_pred <- predict(tree_model, valid_data)
initial_mse <- mean((valid_data$y - initial_pred)^2)
cat("Initial MSE: ", initial_mse, "\n")

# Plot the training data
plot(train_data, main = "Training Data with Initial Regression Tree Predictions")
# Overlay the regression tree predictions
# To overlay the regression tree, we need to plot its predictions as segments
# We can do this by plotting a step function
ord <- order(train_data$x)  # order x to plot the step function correctly
lines(train_data$x[ord], predict(tree_model, train_data)[ord], col="red", lwd=2, type="s")

# Step 3: Prune the tree
# Use cross-validation to find the optimal complexity parameter (cp)
printcp(tree_model)  # Display the CP table

# Cross-validation happens here automatically. 
# The `rpart` function performs cross-validation to generate the CP table.
# It does this by partitioning the training data into folds, 
# fitting the model on each fold, and calculating the average error.

# Find the optimal cp value that minimizes the cross-validated error
opt_index <- which.min(tree_model$cptable[,"xerror"])
opt_cp <- tree_model$cptable[opt_index, "CP"]

# Prune the tree using the optimal cp value
pruned_tree <- prune(tree_model, cp = opt_cp)

# Plot the pruned tree
rpart.plot(pruned_tree, main = "Pruned Regression Tree")

# Calculate pruned MSE using the validation set
pruned_pred <- predict(pruned_tree, valid_data)
pruned_mse <- mean((valid_data$y - pruned_pred)^2)
cat("Pruned MSE: ", pruned_mse, "\n")

# Step 4: Plot how the pruning changes the MSE with respect to tree size
# Extract CP table for plotting
cp_table <- tree_model$cptable

# Calculate the number of terminal nodes for each cp value
num_nodes <- cp_table[, "nsplit"] + 1

# Plot the MSE (xerror) against the number of terminal nodes
plot(num_nodes, cp_table[, "xerror"], type = "b",
     xlab = "Number of Terminal Nodes", ylab = "Cross-validated Error (MSE)",
     main = "MSE vs. Number of Terminal Nodes")
abline(v = num_nodes[opt_index], col = "red", lty = 2)
text(num_nodes[opt_index], min(cp_table[, "xerror"]), 
     labels = paste("Optimal Size =", num_nodes[opt_index]), pos = 4, col = "red")

# Step 5: Summarize the MSE before and after pruning
cat("Summary:\n")
cat("Initial MSE: ", initial_mse, "\n")
cat("Pruned MSE: ", pruned_mse, "\n")
