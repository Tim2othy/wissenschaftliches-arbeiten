# Set seed for reproducibility

# Generate synthetic data
n <- 1000
x1 <- rnorm(n)
x2 <- runif(n, -2, 2)
x3 <- rbinom(n, 1, 0.3)
noise <- rnorm(n, 0, 0.05)
y <- 2 * x1 + 3 * x2^2 + 5 * x3 + noise

# Create data frame
data <- data.frame(x1, x2, x3, y)

# Split data into train and test
train_idx <- sample(nrow(data), 0.5 * nrow(data))
train_data <- data[train_idx, ]
test_data <- data[-train_idx, ]

# Train a regression tree on the training data
library(tree)
tree_model <- tree(y ~ ., data = train_data)

# Grow a large tree with relaxed control parameters
tree_control <- tree.control(nobs = nrow(train_data), mincut = 1, minsize = 2, mindev = 0)
large_tree <- tree(y ~ ., data = train_data, control = tree_control)

# Make predictions on the test data with the large tree
large_tree_pred <- predict(large_tree, newdata = test_data)
mse_large <- mean((test_data$y - large_tree_pred)^2)

# Prune the tree using MSE as the pruning criterion
cv_tree <- cv.tree(large_tree, FUN = prune.tree, K = 10)

# Get the optimal tree size
optimal_size <- cv_tree$size[which.min(cv_tree$dev)]
pruned_tree <- prune.tree(large_tree, best = optimal_size)

# Make predictions on the test data with the pruned tree
pruned_tree_pred <- predict(pruned_tree, newdata = test_data)
mse_pruned <- mean((test_data$y - pruned_tree_pred)^2)

# Compare MSE
cat("MSE of the large tree:", mse_large, "\n")
cat("MSE of the pruned tree:", mse_pruned, "\n")


# Plot the pruned tree
plot(large_tree)
plot(pruned_tree)
text(pruned_tree, pretty = 0)

# Plot cross-validation results
plot(cv_tree$size, cv_tree$dev, type = "b", xlab = "Tree Size", ylab = "Deviance")
abline(v = optimal_size, col = "red", lty = 2)
title(main = "Cross-Validation Results for Tree Pruning")



print(optimal_size)

