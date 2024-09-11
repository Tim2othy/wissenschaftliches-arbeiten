# Data-analysis
library(rpart)
library(rpart.plot)
library(dplyr)
library(ggplot2)
library(data.tree) 
library(networkD3)
library(plotly)
library(caret)

# Setting up data ----
sd <- student_por

# Removing these because that would just be cheating
sd$G2 <- NULL
sd$G1 <- NULL

# Removing variables that were least important during regression and trees
sd$traveltime <- NULL
sd$Medu <- NULL
sd$guardian <- NULL
sd$reason <- NULL
sd$Mjob <- NULL
sd$address <- NULL

# also do basic test if data is working
View(sd)

plot(sd$studytime, sd$G3, col = "blue", pch = 19)
grid()



# Basic Regression Tree ----

tree_model <- rpart(G3 ~ ., data = sd)

rpart.plot(tree_model, shadow.col = "gray")
rpart.plot(tree_model, extra = 101, fallen.leaves = TRUE, type = 4, main = "Regression Tree")

# Get variable importance
var_importance <- tree_model$variable.importance
print(var_importance)

# Variable Importance Plot
var_importance <- data.frame(
  variable = names(tree_model$variable.importance),
  importance = tree_model$variable.importance
)
ggplot(var_importance, aes(x = reorder(variable, importance), y = importance)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Variable Importance", x = "Variables", y = "Importance")




# Basic linear regression ----
lm_model <- lm(G3 ~ ., data = sd)

# Summary
summary_lm <- summary(lm_model)
print(summary_lm)



# Compare MSE of both models ----

## Get MSE for both----
sd$lm_pred <- predict(lm_model)
sd$tree_pred <- predict(tree_model)

mse_lm <- mean((sd$G3 - sd$lm_pred)^2)
mse_tree <- mean((sd$G3 - sd$tree_pred)^2)

print(mse_lm)
print(mse_tree)

> print(mse_lm)
[1] 6.794648
> print(mse_tree)
[1] 6.385807


## Visualize predictions ----
ggplot(sd, aes(x = G3)) +
  geom_point(aes(y = lm_pred, color = "Linear Regression"), alpha = 0.5) +
  geom_point(aes(y = tree_pred, color = "Regression Tree"), alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  theme_minimal() +
  labs(title = "Predicted vs Actual G3 Scores",
       x = "Actual G3", y = "Predicted G3",
       color = "Model") +
  scale_color_manual(values = c("Linear Regression" = "blue", "Regression Tree" = "red"))





# make Small tree for interactions ----

tree_model_2splits <- rpart(G3 ~ ., data = sd, control = rpart.control(maxdepth = 2))

# Plot the tree
rpart.plot(tree_model_2splits, extra = 101, fallen.leaves = TRUE, type = 2, main = "Decision Tree with Two Splits")

sd$tree_pred_2splits <- predict(tree_model_2splits)

mse_tree <- mean((sd$G3 - sd$tree_pred_2splits)^2)

print(mse_tree)

# MSE should be 7.783039





# recreating the same tree by hand (I promise this will make sense later) ----

# Split the data based on failures
failures_yes <- subset(sd, failures >= 1)
failures_no <- subset(sd, failures == 0)

# Further split the data
failures_yes_absences_yes <- subset(failures_yes, absences < 1)
failures_yes_absences_no <- subset(failures_yes, absences >= 1)

failures_no_higher_yes <- subset(failures_no, higher == "no")
failures_no_higher_no <- subset(failures_no, higher == "yes")

# Calculate the mean of G3 for each subset
mean_failures_yes_absences_yes <- mean(failures_yes_absences_yes$G3)
mean_failures_yes_absences_no <- mean(failures_yes_absences_no$G3)

mean_failures_no_higher_yes <- mean(failures_no_higher_yes$G3)
mean_failures_no_higher_no <- mean(failures_no_higher_no$G3)

# Calculate the MSE for each subset
mse_failures_yes_absences_yes <- mean((failures_yes_absences_yes$G3 - mean_failures_yes_absences_yes)^2)
mse_failures_yes_absences_no <- mean((failures_yes_absences_no$G3 - mean_failures_yes_absences_no)^2)

mse_failures_no_higher_yes <- mean((failures_no_higher_yes$G3 - mean_failures_no_higher_yes)^2)
mse_failures_no_higher_no <- mean((failures_no_higher_no$G3 - mean_failures_no_higher_no)^2)

# Calculate the total MSE
total_mse <- (mse_failures_yes_absences_yes * nrow(failures_yes_absences_yes) +
                mse_failures_yes_absences_no * nrow(failures_yes_absences_no) +
                mse_failures_no_higher_yes * nrow(failures_no_higher_yes) +
                mse_failures_no_higher_no * nrow(failures_no_higher_no)) / nrow(sd)

total_mse

# MSE should also be 7.783039



# Creating the same tree but with swapped splits by hand ----

# Split the data based on failures
failures_yes <- subset(sd, failures >= 1)
failures_no <- subset(sd, failures == 0)

# Further split the data, swapping the splits
# For failures_yes, split by 'higher' instead of 'absences'
failures_yes_higher_yes <- subset(failures_yes, higher == "yes")
failures_yes_higher_no <- subset(failures_yes, higher == "no")

# For failures_no, split by 'absences' instead of 'higher'
failures_no_absences_yes <- subset(failures_no, absences < 12)
failures_no_absences_no <- subset(failures_no, absences >= 12)

# Calculate the mean of G3 for each subset
mean_failures_yes_higher_yes <- mean(failures_yes_higher_yes$G3)
mean_failures_yes_higher_no <- mean(failures_yes_higher_no$G3)

mean_failures_no_absences_yes <- mean(failures_no_absences_yes$G3)
mean_failures_no_absences_no <- mean(failures_no_absences_no$G3)

# Calculate the MSE for each subset
mse_failures_yes_higher_yes <- mean((failures_yes_higher_yes$G3 - mean_failures_yes_higher_yes)^2)
mse_failures_yes_higher_no <- mean((failures_yes_higher_no$G3 - mean_failures_yes_higher_no)^2)

mse_failures_no_absences_yes <- mean((failures_no_absences_yes$G3 - mean_failures_no_absences_yes)^2)
mse_failures_no_absences_no <- mean((failures_no_absences_no$G3 - mean_failures_no_absences_no)^2)

# Calculate the total MSE
total_mse_swapped <- (mse_failures_yes_higher_yes * nrow(failures_yes_higher_yes) +
                        mse_failures_yes_higher_no * nrow(failures_yes_higher_no) +
                        mse_failures_no_absences_yes * nrow(failures_no_absences_yes) +
                        mse_failures_no_absences_no * nrow(failures_no_absences_no)) / nrow(sd)

total_mse_swapped

# MSE should be 8.309893


8.299081
8.298891

8.299081



8.283893













# 3D Scatter Plot with Decision Boundaries, need to fix, worked before not sure why not now ----


# Get the variables used for splitting
split_vars <- tree_model_2splits$frame$var[tree_model_2splits$frame$var != "<leaf>"]
split_vars <- unique(as.character(split_vars))

# If there are fewer than 2 splits, notify the user
if(1==1) {

  # Create a 3D scatter plot with decision boundaries
  plot_ly(sd, x = ~get(split_vars[1]), y = ~get(split_vars[2]), z = ~G3, 
          type = "scatter3d", mode = "markers", 
          marker = list(size = 3, color = ~G3, colorscale = "Viridis", opacity = 0.8)) %>%
    add_markers() %>%
    layout(scene = list(xaxis = list(title = split_vars[1]),
                        yaxis = list(title = split_vars[2]),
                        zaxis = list(title = "G3")))
  
  # Function to add a plane to the plot
  add_plane <- function(p, split_var, split_value, color) {
    var_range <- range(sd[[split_var]])
    other_var <- setdiff(split_vars, split_var)[1]
    other_range <- range(sd[[other_var]])
    
    if(split_var == split_vars[1]) {
      x <- rep(split_value, 2)
      y <- other_range
    } else {
      x <- var_range
      y <- rep(split_value, 2)
    }
    
    z <- matrix(rep(range(sd$G3), each = 2), nrow = 2)
    
    add_surface(p, x = x, y = y, z = z, opacity = 0.3, colorscale = list(c(0, 1), c(color, color)))
  }
  
  # Get split points
  splits <- tree_model_2splits$splits
  split_points <- splits[splits[,"count"] > 0, "index"]
  
  # Create the plot with decision boundaries
  p <- plot_ly(sd, x = ~get(split_vars[1]), y = ~get(split_vars[2]), z = ~G3, 
               type = "scatter3d", mode = "markers", 
               marker = list(size = 3, color = ~G3, colorscale = "Viridis", opacity = 0.8)) %>%
    layout(scene = list(xaxis = list(title = split_vars[1]),
                        yaxis = list(title = split_vars[2]),
                        zaxis = list(title = "G3")))
  
  # Add planes for each split
  for(i in 1:length(split_points)) {
    p <- add_plane(p, split_vars[i], split_points[i], color = c("red", "blue")[i])
  }
  
  # Display the plot
  p
}

















# Pruning ----







# Step 2: Train a regression tree with more complexity
tree_model_complex <- rpart(G3 ~ ., data = sd, control = rpart.control(cp = 0.002, minsplit = 5))

# Plot the initial complex tree
rpart.plot(tree_model_complex, main = "Initial Complex Regression Tree")

# Calculate initial MSE
initial_pred_complex <- predict(tree_model_complex, sd)
initial_mse <- mean((sd$G3 - initial_pred_complex)^2)

print(initial_mse)






# Find the optimal cp value that minimizes the cross-validated error
opt_index <- which.min(tree_model_complex$cptable[,"xerror"])
opt_cp <- tree_model_complex$cptable[opt_index, "CP"]


print(opt_cp)

# Prune the tree using the optimal cp value
pruned_tree <- prune(tree_model_complex, cp = opt_cp)

# Plot the pruned tree
rpart.plot(pruned_tree, main = "Pruned Regression Tree")

# Calculate pruned MSE
pruned_pred <- predict(pruned_tree, sd)
pruned_mse <- mean((sd$G3 - pruned_pred)^2)



print(pruned_mse) # should be  8.010319 depending on parameters





# Step 4: Plot how the pruning changes the MSE with respect to tree size
# Extract CP table for plotting
cp_table <- tree_model_complex$cptable

# Calculate the number of terminal nodes for each cp value
num_nodes <- cp_table[, "nsplit"] + 1








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






# new improvend pruning ----




# Calculate pruned MSE
pruned_pred <- predict(pruned_tree, sd)
pruned_mse <- mean((sd$G3 - pruned_pred)^2)
print(paste("Pruned MSE:", pruned_mse))

# Step 4: Plot how the pruning changes the MSE with respect to tree size
# Calculate MSE for each CP value
mse_values <- sapply(cp_table[, "CP"], function(cp) {
  pruned <- prune(tree_model_complex, cp = cp)
  pred <- predict(pruned, sd)
  mean((sd$G3 - pred)^2)
})

# Calculate the number of terminal nodes for each cp value
num_nodes <- cp_table[, "nsplit"] + 1

# Plot the MSE against the number of terminal nodes
plot(num_nodes, mse_values, pch=20, col = rgb(0.2, 0.7, 1, 1), type = "b", cex = 1, 
     xlab = "Tree Size", ylab = "Mean Squared Error", 
     main = "MSE vs Tree Size",
     ylim = c(min(mse_values) * 0.9, max(mse_values) * 1.1))

# Add grid lines
grid()

# Add a vertical line and text to indicate the optimal number of terminal nodes
abline(v = num_nodes[opt_index], col = "purple", lty = 2)
text(num_nodes[opt_index], min(mse_values), 
     labels = paste("Optimal Size =", num_nodes[opt_index]), pos = 4, col = "black")

# Step 5: Summarize the MSE before and after pruning
cat("Summary:\n")
cat("Initial MSE: ", initial_mse, "\n")
cat("Pruned MSE: ", pruned_mse, "\n")





# comparing single tree on test and training data ----



# Split the data into training (70%) and validation (30%) sets
split_index <- createDataPartition(sd$G3, p = 0.7, list = FALSE)
train_data <- sd[split_index, ]
valid_data <- sd[-split_index, ]


# execute this for manual testing

tree_model <- rpart(G3 ~ ., data = train_data, control = rpart.control(cp = 0.002, minsplit = 5))
rpart.plot(tree_model, main = "Tree for manual comparison")


# Calculate MSE for training set
train_pred <- predict(tree_model, train_data)
train_mse <- mean((train_data$G3 - train_pred)^2)
  
# Calculate MSE for validation set
valid_pred <- predict(tree_model, valid_data)
valid_mse <- mean((valid_data$G3 - valid_pred)^2)
  
# Print results
cat("Training MSE:", train_mse, "\n")
cat("Validation MSE:", valid_mse, "\n\n")
  



