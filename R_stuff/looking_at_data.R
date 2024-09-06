# Data-analysis
install.packages('...')
library(rpart)
library(rpart.plot)
library(dplyr)
library(ggplot2)
library(data.tree) 
library(networkD3)


sd <- student_por
sd$G2 <- NULL
sd$G1 <- NULL

View(sd)


plot(sd$age, sd$G3, col = "blue", pch = 19)
grid()





tree_model <- rpart(G3 ~ ., data = sd)


# Visualize the tree
rpart.plot(tree_model, shadow.col = "gray")
rpart.plot(tree_model, extra = 101, fallen.leaves = TRUE, type = 4, main = "Decision Tree Visualization")

# Get variable importance
var_importance <- tree_model$variable.importance
print(var_importance)

.C
dq+u~!!



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
