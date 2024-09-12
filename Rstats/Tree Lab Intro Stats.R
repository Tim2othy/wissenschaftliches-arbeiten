
# Lab: Decision Trees


## Fitting Classification Trees

###
library(rpart )
###
library(ISLR2)
attach(Carseats)
High <- factor(ifelse(Sales <= 8, "No", "Yes")) # High is yes if at least 8
###
Carseats <- data.frame(Carseats, High)
###

# does the tree with all but sales

plot(tree.carseats)
text(tree.carseats)

tree.carseats <- tree(High ~ . - Sales, Carseats)
###
summary(tree.carseats) # 27 terminal nodes RMD=0.4575
                      # MER = 0.09
###
plot(tree.carseats)
text(tree.carseats, pretty = 0)
###
tree.carseats
###
set.seed(2)
train <- sample(1:nrow(Carseats), 200)
Carseats.test <- Carseats[-train, ]
High.test <- High[-train]
tree.carseats <- tree(High ~ . - Sales, Carseats,
                      subset = train)
tree.pred <- predict(tree.carseats, Carseats.test,
                     type = "class")
table(tree.pred, High.test)
(104 + 50) / 200
###
set.seed(7)
cv.carseats <- cv.tree(tree.carseats, FUN = prune.misclass)
names(cv.carseats)
cv.carseats
###
par(mfrow = c(1, 2))
plot(cv.carseats$size, cv.carseats$dev, type = "b")
plot(cv.carseats$k, cv.carseats$dev, type = "b")    # Plots the error rates for size and k
###
prune.carseats <- prune.misclass(tree.carseats, best = 9)
plot(prune.carseats)
text(prune.carseats, pretty = 0)
###
tree.pred <- predict(prune.carseats, Carseats.test,
                     type = "class")
table(tree.pred, High.test)
(97 + 58) / 200
###
prune.carseats <- prune.misclass(tree.carseats, best = 14)
plot(prune.carseats)
text(prune.carseats, pretty = 0)
tree.pred <- predict(prune.carseats, Carseats.test,
                     type = "class")
table(tree.pred, High.test)
(102 + 52) / 200

## Fitting Regression Trees#############

###
set.seed(1)
train <- sample(1:nrow(Boston), nrow(Boston) / 2)

tree_control <- tree.control(nobs = 253, mincut = 1, minsize = 2, mindev = 0)



tree.boston <- tree(medv ~ ., Boston, subset = train,control = tree_control)
summary(tree.boston)
###
plot(tree.boston)
text(tree.boston, pretty = 0)
###
cv.boston <- cv.tree(tree.boston)
plot(cv.boston$size, cv.boston$dev, type = "b")

optimal_size <- cv.boston$size[which.min(cv.boston$dev)]
optimal_size

###



prune.boston <- prune.tree(tree.boston, best = 5)
plot(prune.boston)
text(prune.boston, pretty = 0)
###
yhat <- predict(tree.boston, newdata = Boston[-train, ])
boston.test <- Boston[-train, "medv"]
plot(yhat, boston.test)
abline(0, 1)
mean((yhat - boston.test)^2)


### Regression on the Boston Data


# Split the data into training and testing sets
set.seed(1)  # for reproducibility
train <- sample(1:nrow(Boston), nrow(Boston)/2)
boston.train <- Boston[train, ]
boston.test <- Boston[-train, ]

# Fit linear regression model
lm.boston <- lm(medv ~ ., data = boston.train)

# Summary of the model
summary(lm.boston)   #        Adjusted R-squared:  0.7528 

# Plot residuals
plot(lm.boston)

# Make predictions on test set
yhat <- predict(lm.boston, newdata = boston.test)

# Plot predicted vs actual values
plot(yhat, boston.test$medv, main = "Predicted vs Actual Median Value",
     xlab = "Predicted", ylab = "Actual")
abline(0, 1, col = "red")  # Add 45-degree line

# Calculate Mean Squared Error (MSE) # [1] "Mean Squared Error: 35.2868818594623"
mse <- mean((yhat - boston.test$medv)^2)
print(paste("Mean Squared Error:", mse))   # [1] "Mean Squared Error: 35.2868818594623"

# Optional: Stepwise regression for feature selection
step.model <- step(lm.boston, direction = "both")
summary(step.model)




## Bagging and Random Forests

###
library(randomForest)
set.seed(1)
bag.boston <- randomForest(medv ~ ., data = Boston,
                           subset = train, mtry = 12, importance = TRUE)
bag.boston
###
yhat.bag <- predict(bag.boston, newdata = Boston[-train, ])
plot(yhat.bag, boston.test)
abline(0, 1)
mean((yhat.bag - boston.test)^2)
###
bag.boston <- randomForest(medv ~ ., data = Boston,
                           subset = train, mtry = 12, ntree = 25)
yhat.bag <- predict(bag.boston, newdata = Boston[-train, ])
mean((yhat.bag - boston.test)^2)
###
set.seed(1)
rf.boston <- randomForest(medv ~ ., data = Boston,
                          subset = train, mtry = 6, importance = TRUE)
yhat.rf <- predict(rf.boston, newdata = Boston[-train, ])
mean((yhat.rf - boston.test)^2)
###
importance(rf.boston)
###
varImpPlot(rf.boston)

## Boosting

###
library(gbm)
set.seed(1)
boost.boston <- gbm(medv ~ ., data = Boston[train, ],
                    distribution = "gaussian", n.trees = 3000,
                    interaction.depth = 10)
###
summary(boost.boston)
###
plot(boost.boston, i = "rm")
plot(boost.boston, i = "lstat")
###
yhat.boost <- predict(boost.boston,
                      newdata = Boston[-train, ], n.trees = 5000)
mean((yhat.boost - boston.test)^2)
###
boost.boston <- gbm(medv ~ ., data = Boston[train, ],
                    distribution = "gaussian", n.trees = 5000,
                    interaction.depth = 4, shrinkage = 0.2, verbose = F)
yhat.boost <- predict(boost.boston,
                      newdata = Boston[-train, ], n.trees = 5000)
mean((yhat.boost - boston.test)^2)

## Bayesian Additive Regression Trees

###
library(BART)
x <- Boston[, 1:12]
y <- Boston[, "medv"]
xtrain <- x[train, ]
ytrain <- y[train]
xtest <- x[-train, ]
ytest <- y[-train]
set.seed(1)
bartfit <- gbart(xtrain, ytrain, x.test = xtest)
###
yhat.bart <- bartfit$yhat.test.mean
mean((ytest - yhat.bart)^2)
###
ord <- order(bartfit$varcount.mean, decreasing = T)
bartfit$varcount.mean[ord]
###