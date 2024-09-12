# Data-analysis
library(rpart)
library(rpart.plot)
library(dplyr)
library(ggplot2)
library(data.tree) 
library(networkD3)
library(plotly)
library(caret)
library(BART)




# 1. Setting up data ----
sd <- data.frame(student_por)


sd <- sd %>%
  mutate_if(is.character, as.factor)


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


# 2. Simple comparison ----

## 2.1 Basic Regression Tree ----

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




## 2.2 Basic linear regression ----
lm_model <- lm(G3 ~ ., data = sd)

# Summary
summary_lm <- summary(lm_model)
print(summary_lm)



## 2.3 Compare MSE of both models ----

### 2.3.1 Get MSE for both----
sd$lm_pred <- predict(lm_model)
sd$tree_pred <- predict(tree_model)

mse_lm <- mean((sd$G3 - sd$lm_pred)^2)
mse_tree <- mean((sd$G3 - sd$tree_pred)^2)

print(mse_lm)
print(mse_tree)



### 2.3.2 Visualize predictions ----
ggplot(sd, aes(x = G3)) +
  geom_point(aes(y = lm_pred, color = "Linear Regression"), alpha = 0.5) +
  geom_point(aes(y = tree_pred, color = "Regression Tree"), alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  theme_minimal() +
  labs(title = "Predicted vs Actual G3 Scores",
       x = "Actual G3", y = "Predicted G3",
       color = "Model") +
  scale_color_manual(values = c("Linear Regression" = "blue", "Regression Tree" = "red"))








# 3. comparing single tree on test and training data ----



# Split the data into training (70%) and validation (30%) sets
split_index <- createDataPartition(sd$G3, p = 0.7, list = FALSE)
train_data <- sd[split_index, ]
valid_data <- sd[-split_index, ]


# execute this for manual testing

tree_model <- rpart(G3 ~ ., data = train_data, control = rpart.control(cp = 0.025, minsplit = 5))
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







# 4. make Small tree for interactions ----

## 4.1 using the usual method ----

tree_model_2splits <- rpart(G3 ~ ., data = sd, control = rpart.control(maxdepth = 2))

# Plot the tree
rpart.plot(tree_model_2splits, extra = 101, fallen.leaves = TRUE, type = 2, main = "Decision Tree with Two Splits")

sd$tree_pred_2splits <- predict(tree_model_2splits)

mse_tree <- mean((sd$G3 - sd$tree_pred_2splits)^2)

print(mse_tree)

# MSE should be 7.783039





## 4.2 recreating the same tree by hand (I promise this will make sense later) ----

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



## 4.3 Creating the same tree but with swapped splits by hand ----

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








# 5. Pruning ----


# Split the data
split_index <- createDataPartition(sd$G3, p = 0.7, list = FALSE)
train_data <- sd[split_index, ]
test_data <- sd[-split_index, ]

# Function to calculate MSE
calculate_mse <- function(actual, predicted) {
  mean((actual - predicted)^2)
}

## 5.1 make big and small tree ----

# Create a complex tree
complex_tree <- rpart(G3 ~ ., data = train_data, control = rpart.control(cp = 0.001, minsplit = 5))

rpart.plot(complex_tree, main = "Initial Complex Regression Tree")
plotcp(complex_tree)



# Find optimal CP value
opt_cp <- complex_tree$cptable[which.min(complex_tree$cptable[,"xerror"]), "CP"]

print(opt_cp)

# Prune the tree
pruned_tree <- prune(complex_tree, cp = opt_cp)
rpart.plot(pruned_tree, main = "Optimal Pruned Tree")


## 5.2 compare the two trees ----

# Calculate the MSEs
MSE_complex <- function(){
  train_pred_complex <- predict(complex_tree, train_data)
  test_pred_complex <- predict(complex_tree, test_data)
  train_mse_complex <- calculate_mse(train_data$G3, train_pred_complex)
  test_mse_complex <- calculate_mse(test_data$G3, test_pred_complex)
  
  print(paste("Complex Tree - Training MSE:", train_mse_complex))
  print(paste("Complex Tree -     Test MSE:", test_mse_complex))
}
MSE_pruned <- function(){
  train_pred_pruned <- predict(pruned_tree, train_data)
  test_pred_pruned <- predict(pruned_tree, test_data)
  train_mse_pruned <- calculate_mse(train_data$G3, train_pred_pruned)
  test_mse_pruned <- calculate_mse(test_data$G3, test_pred_pruned)

  print(paste("Pruned Tree - Training MSE:", train_mse_pruned))
  print(paste("Pruned Tree - Test MSE:", test_mse_pruned))
}

MSE_complex()
MSE_pruned()



## 5.3 Make nice pruning plot ----
cp_table <- complex_tree$cptable
num_splits <- cp_table[, "nsplit"]

# Calculate MSE for each CP value
mse_values <- sapply(cp_table[, "CP"], function(cp) {
  pruned <- prune(complex_tree, cp = cp)
  train_pred <- predict(pruned, train_data)
  test_pred <- predict(pruned, test_data)
  train_mse <- calculate_mse(train_data$G3, train_pred)
  test_mse <- calculate_mse(test_data$G3, test_pred)
  c(train_mse, test_mse)
})



# Making data for ggplot
mse_data <- data.frame(
  num_splits = rep(num_splits, 2),
  mse = c(mse_values[1,], mse_values[2,]),
  type = rep(c("Training MSE", "Test MSE"), each = length(num_splits))
)
# And for the label
temp_mse_data <- mse_data %>% filter(type == "Test MSE")
opt_splits <- temp_mse_data$num_splits[which.min(temp_mse_data$mse)]
min_mse <- min(temp_mse_data$mse)

opt_splits

ggplot(mse_data, aes(x = num_splits, y = mse, color = type)) +
  geom_line() +
  geom_point() +
  scale_color_manual(values = c("blue", "red")) +
  labs(x = "Number of Splits", y = "Mean Squared Error",
       title = "MSE vs Tree Complexity",
       color = "MSE Type") +
  theme_minimal() +
  geom_vline(xintercept = opt_splits, linetype = "dashed", color = "purple") +
  annotate("text", x = opt_splits +6, y = min_mse +1, label = paste("Optimal number of splits =", opt_splits),
           vjust = -1, color = "purple")




# 6. Making nice plot for basic tree description ----


sd_mini <- sd[, c("Walc", "Dalc", "absences", "G3")]
sd_mini$Walc_plus_Dalc <- sd_mini$Walc + sd_mini$Dalc
sd_mini <- sd_mini[, c("Walc_plus_Dalc", "absences", "G3")]



tree_model <- rpart(G3 ~ Walc_plus_Dalc + absences, data = sd_mini, control = rpart.control(cp = 0.002, minsplit = 40 ))
rpart.plot(tree_model)

Walc_plus_Dalc_seq <- seq(min(sd_mini$Walc_plus_Dalc), max(sd_mini$Walc_plus_Dalc), length.out = 13)
absences_seq <- seq(min(sd_mini$absences), max(sd_mini$absences), length.out = 13)
grid <- expand.grid(Walc_plus_Dalc = Walc_plus_Dalc_seq, absences = absences_seq)

grid$G3_pred <- predict(tree_model, newdata = grid)

ggplot(grid, aes(x = Walc_plus_Dalc, y = absences, fill = G3_pred)) +
  geom_tile() +  
  geom_text(aes(label = round(G3_pred, 1)), size = 3) +  
  scale_fill_gradient(low = "darkred", high = "lightblue", guide = "none") + 
  labs(x = "Alcohol consumption", y = "Absences", title = "Predicting Exam score based on alcohol consumption and Absences") +
  theme_minimal() +
  geom_point(data = sd_mini, aes(x = Walc_plus_Dalc, y = absences), color = "blue", size = 2, inherit.aes = FALSE)# Add blue points for actual data
  






# 66. NOT FIN 3D Scatter Plot with Decision Boundaries, need to fix, worked before not sure why not now ----


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





# 7. BART ----

## 7.1 Fit BART model ----

# Using the BART package

burn = 1000; nd = 1000

y = sd$G3
x = sd[,1:30]
p = ncol(x)

bf = wbart(x,y,nskip=burn,ndpost=nd,printevery=500)


# linear model

lmf = lm(G3~., sd)

plot(bf$sigma,ylim=c(1.5,5),xlab="MCMC iteration",ylab="sigma draw",cex=.5)
abline(h=summary(lmf)$sigma,col="red",lty=2) #least squares estimates
abline(v = burn,col="green")
title(main="sigma draws, green line at burn in, red line at least squares estimate",cex.main=.8)



thin = 20
ii = burn + thin*(1:(nd/thin))
acf(bf$sigma[ii],main="ACF of thinned post burn-in sigma draws")

# making small BART model to compare
bf20 = wbart(x,y,nskip=burn,ndpost=nd, ntree = 20,printevery=500)


fitmat = cbind(y,bf$yhat.train.mean,bf20$yhat.train.mean)
colnames(fitmat) = c("y","yhatBART","yhatBART20")
pairs(fitmat)

print(cor(fitmat))


dim(bf20$varcount)




#compute row percentages
percount20 = bf20$varcount/apply(bf20$varcount,1,sum)
# mean of row percentages
mvp20 =apply(percount20,2,mean)
#quantiles of row percentags
qm = apply(percount20,2,quantile,probs=c(.05,.95))

print(mvp20)



# Assuming qm is a matrix or data frame
p <- ncol(qm)
rgy <- range(qm, na.rm = TRUE)

# Create the plot
plot(c(1, p), rgy, type = "n", xlab = "variable", 
     ylab = "post mean, percent var use", axes = FALSE)

# Add x-axis
axis(1, at = 1:p, labels = colnames(qm), cex.lab = 0.7, cex.axis = 0.7)

# Add y-axis
axis(2, cex.lab = 1.2, cex.axis = 1.2)

# Add lines for mvp20 if it exists and has the correct length
if (exists("mvp20") && length(mvp20) == p) {
  lines(1:p, mvp20, col = "black", lty = 4, pch = 4, type = "b", lwd = 1.5)
}

# Add vertical lines
for (i in 1:p) {
  lines(c(i, i), qm[, i], col = "blue", lty = 3, lwd = 1.0)
}






percount = bf$varcount/apply(bf$varcount,1,sum)
mvp = apply(percount,2,mean)
plot(mvp20,xlab="variable number",ylab="post mean, percent var use",col="blue",type="b")
lines(mvp,type="b",col='red')
legend("topleft",legend=c("BART","BART20"),col=c("red","blue"),lty=c(1,1))



