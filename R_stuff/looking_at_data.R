# Data-analysis
library(rpart)
library(rpart.plot)
library(dplyr)
library(ggplot2)
library(data.tree) 
library(networkD3)
library(plotly)


get_data <- function() {
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
  
  # also do basic test if data is working
  View(sd)
  
  plot(sd$studytime, sd$G3, col = "blue", pch = 19)
  grid()
  return(sd)
  
}

get_data()




# Basic Regression Tree ----

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



# Basic linear regression ----
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


# Compare MSE of both models ----

## Get MSE for both----
sd$lm_pred <- predict(lm_model)
sd$tree_pred <- predict(tree_model)

mse_lm <- mean((sd$G3 - sd$lm_pred)^2)
mse_tree <- mean((sd$G3 - sd$tree_pred)^2)

print(mse_lm)
print(mse_tree)


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










# Small tree for interactions ----


tree_model_2splits <- rpart(G3 ~ ., data = sd, control = rpart.control(maxdepth = 2))


# Plot the tree
rpart.plot(tree_model_2splits, extra = 101, fallen.leaves = TRUE, type = 2, main = "Decision Tree with Two Splits")


## making smaller data set ----
sd_small <- sd
#removing all variables except, falures, higher, absences


sd_small <- sd_small %>% 
  select(
    failures, higher, absences, G3
    
  )

View(sd_small)


# test to see if this results in the same tree as before, yes it does
tree_model_2splits <- rpart(G3 ~ ., data = sd_small, control = rpart.control(maxdepth = 2))


rpart.plot(tree_model_2splits, extra = 101, fallen.leaves = TRUE, type = 2, main = "Decision Tree with Two Splits")


plot(tree_model_2splits) # basic plot works fine
text(tree_model_2splits)


tree_model_2splits









# different approach doing it by hand ----








# Create a new variable that captures the first split on 'failures'
sd$failures_split <- ifelse(sd$failures >= 1, "yes", "no")

# Create a new variable for 'higher' split for those with failures
sd$higher_split <- ifelse(sd$failures_split == "yes" & sd$higher == "yes", "yes", 
                          ifelse(sd$failures_split == "yes", "no", NA))

# Create a new variable for 'absences' split for those without failures
sd$absences_split <- ifelse(sd$failures_split == "no" & sd$absences < 1, "high", 
                            ifelse(sd$failures_split == "no", "low", NA))

# Build the tree model using the new variables
tree_model_swapped_splits <- rpart(G3 ~ failures_split + higher_split + absences_split, 
                                   data = sd, 
                                   control = rpart.control(maxdepth = 3))

# Print the tree structure
print(tree_model_swapped_splits)

# Plot the tree
rpart.plot(tree_model_swapped_splits, extra = 101, fallen.leaves = TRUE, type = 2, 
           main = "Decision Tree with Swapped Splits")



print(tree_model_2splits)
print(tree_model_swapped_splits)



rpart.plot(tree_model_2splits, extra = 101, fallen.leaves = TRUE, type = 2, main = "Decision Tree with Two Splits")








# Create interaction terms to capture the combined conditions
sd$failures_higher_interaction <- interaction(sd$failures_split, sd$higher)
sd$failures_absences_interaction <- interaction(sd$failures_split, sd$absences < 1)

# Build the tree model using the interaction terms
tree_model_swapped_splits <- rpart(G3 ~ failures_split + failures_higher_interaction + failures_absences_interaction, 
                                   data = sd, 
                                   control = rpart.control(maxdepth = 3))

# Print the tree structure
print(tree_model_swapped_splits)

# Plot the tree
rpart.plot(tree_model_swapped_splits, extra = 101, fallen.leaves = TRUE, type = 4, 
           main = "Decision Tree with Swapped Splits")




































# 3D Scatter Plot with Decision Boundaries ----






if(!requireNamespace("plotly", quietly = TRUE)) {
  install.packages("plotly")
}else{
  library(plotly)
}






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

