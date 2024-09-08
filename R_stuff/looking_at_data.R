# Data-analysis
install.packages('rstudioapi')

rstudioapi::addTheme('https://raw.githubusercontent.com/johnnybarrels/rstudio-one-dark-pro-theme/master/OneDarkPro.rstheme', apply=TRUE, force=TRUE)



library(rpart)
library(rpart.plot)
library(dplyr)
library(ggplot2)
library(data.tree) 
library(networkD3)
library(plotly)

# Using this as the Data
sd <- student_por

# Removing these because that would just be cheating
sd$G2 <- NULL
sd$G1 <- NULL

# Removing variables that were least important
# during regression and trees
sd$traveltime <- NULL
sd$Medu <- NULL
sd$guardian <- NULL
sd$reason <- NULL
sd$Mjob <- NULL
sd$address <- NULL




View(sd)



plot(sd$studytime, sd$G3, col = "blue", pch = 19)
grid()



#### this is doing the basic regression trees

tree_model <- rpart(G3 ~ ., data = sd)


# Visualize the tree
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



# Now doing the normal regression
lm_model <- lm(G3 ~ ., data = sd)

# Summary
summary_lm <- summary(lm_model)
print(summary_lm)

# Extract coefficients and p-values
coef_summary <- data.frame(
  Estimate = round(summary_lm$coefficients[, "Estimate"], 4),
  P_value = round(summary_lm$coefficients[, "Pr(>|t|)"], 4)
)
print(coef_summary)


# Compare predictions: Linear Regression vs Regression Tree
sd$lm_pred <- predict(lm_model)
sd$tree_pred <- predict(tree_model)

# Calculate MSE for both models
mse_lm <- mean((sd$G3 - sd$lm_pred)^2)
mse_tree <- mean((sd$G3 - sd$tree_pred)^2)

print(mse_lm)
print(mse_tree)

# Visualize predictions
ggplot(sd, aes(x = G3)) +
  geom_point(aes(y = lm_pred, color = "Linear Regression"), alpha = 0.5) +
  geom_point(aes(y = tree_pred, color = "Regression Tree"), alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  theme_minimal() +
  labs(title = "Predicted vs Actual G3 Scores",
       x = "Actual G3", y = "Predicted G3",
       color = "Model") +
  scale_color_manual(values = c("Linear Regression" = "blue", "Regression Tree" = "red"))











# Assuming 'sd' is your dataset
# Create a tree with just two splits
tree_model_2splits <- rpart(G3 ~ ., data = sd, control = rpart.control(maxdepth = 2))

# Print the tree structure
print(tree_model_2splits)

# Plot the tree
rpart.plot(tree_model_2splits, extra = 101, fallen.leaves = TRUE, type = 4, main = "Decision Tree with Two Splits")






### third try custom split
# Load required libraries
library(rpart)
library(rpart.plot)

# Create the tree model with manual splits
tree_model <- rpart(G3 ~ failures + higher + absences, data = sd,
                    control = rpart.control(maxdepth = 2, minsplit = 2, minbucket = 1, cp = -1),
                    model = TRUE)

# Manually modify the tree structure
tree_model$splits <- tree_model$splits[1:3, ]
tree_model$splits[1, "index"] <- which(names(sd) == "failures")
tree_model$splits[2, "index"] <- which(names(sd) == "higher")
tree_model$splits[3, "index"] <- which(names(sd) == "absences")
tree_model$splits[1, "ncat"] <- 1  # Numeric split
tree_model$splits[2, "ncat"] <- 2  # Categorical split (yes/no)
tree_model$splits[3, "ncat"] <- 1  # Numeric split
tree_model$splits[1, "adj"] <- 0.5  # Split at failures >= 1
tree_model$splits[2, "adj"] <- 1.0  # Split at higher == "yes"
tree_model$splits[3, "adj"] <- 0.5  # Split at absences >= 1

# Recalculate the frame
tree_model$frame$var[2:4] <- c("failures", "higher", "absences")
tree_model$frame$ncompete <- tree_model$frame$nsurrogate <- 0
tree_model$frame$yval <- sapply(split(sd$G3, tree_model$where), mean)

# Plot the modified tree
rpart.plot(tree_model, extra = 101, fallen.leaves = TRUE, type = 4,
           main = "Manual Decision Tree with Specified Splits")

# Print summary of the tree
print(tree_model)
summary(tree_model)










# better custom splitting


# Define custom splitting function
custom_split <- function(x, y, wt, parms, continuous) {
  # First split on failures
  failures_split <- x[, "failures"] >= 1
  
  if (length(unique(failures_split)) == 1) {
    return(NULL)  # No split possible
  }
  
  # For records with failures >= 1, split on higher
  higher_split <- x[, "higher"] == "yes" & failures_split
  
  # For records with failures < 1, split on absences
  absences_split <- x[, "absences"] >= 1 & !failures_split
  
  # Combine splits
  split <- as.integer(failures_split) + 2 * as.integer(higher_split) + 2 * as.integer(absences_split)
  
  # Calculate improvement
  improvement <- var(y) - (sum((split == 0) * wt) * var(y[split == 0]) +
                             sum((split == 1) * wt) * var(y[split == 1]) +
                             sum((split == 2) * wt) * var(y[split == 2]) +
                             sum((split == 3) * wt) * var(y[split == 3])) / sum(wt)
  
  list(goodness = improvement,
       direction = split)
}

# Create the custom tree model
custom_tree <- rpart(G3 ~ failures + higher + absences, data = sd, 
                     method = list(split = custom_split),
                     control = rpart.control(maxdepth = 2, minsplit = 1, minbucket = 1))

# Plot the tree
rpart.plot(custom_tree, extra = 101, fallen.leaves = TRUE, type = 4, 
           main = "Custom Decision Tree with Specified Splits")


































# Define custom splitting function
custom_split <- function(y, wt, x, parms, continuous) {
  # First split on failures
  failures_split <- y$failures >= 1
  
  if (length(unique(failures_split)) == 1) {
    return(NULL)  # No split possible
  }
  
  # For records with failures >= 1, split on higher
  higher_split <- y$higher == "yes" & failures_split
  
  # For records with failures < 1, split on absences
  absences_split <- y$absences >= 1 & !failures_split
  
  # Combine splits
  split <- as.integer(failures_split) + 2 * as.integer(higher_split) + 2 * as.integer(absences_split)
  
  # Calculate improvement
  improvement <- var(y$G3) - (sum((split == 0) * wt) * var(y$G3[split == 0]) +
                                sum((split == 1) * wt) * var(y$G3[split == 1]) +
                                sum((split == 2) * wt) * var(y$G3[split == 2]) +
                                sum((split == 3) * wt) * var(y$G3[split == 3])) / sum(wt)
  
  list(goodness = improvement,
       direction = split)
}

# Create the custom tree model
custom_tree <- rpart(G3 ~ failures + higher + absences, data = sd, 
                     method = list(eval = custom_split),
                     control = rpart.control(maxdepth = 2, minsplit = 1, minbucket = 1))

# Plot the tree
rpart.plot(custom_tree, extra = 101, fallen.leaves = TRUE, type = 4, 
           main = "Custom Decision Tree with Specified Splits")














































# Get the variables used for splitting
split_vars <- tree_model_2splits$frame$var[tree_model_2splits$frame$var != "<leaf>"]
split_vars <- unique(as.character(split_vars))

# If there are fewer than 2 splits, notify the user
if(length(split_vars) < 2) {
  cat("The tree made fewer than 2 splits. Adjust your data or tree parameters.")
} else {
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

