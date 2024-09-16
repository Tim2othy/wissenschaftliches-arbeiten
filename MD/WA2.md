



## INHALT der Hausarbeit


### Abstract


Much of modern economic research is based, in one way or another upon liner regression. One of the most simple statistical methods, do do good economic research it is vital to have a clear understanding where linear regressions strengths and weaknesses lie, where it beats other methods or is beaten my other methods. In this paper I will explore RRTT as an alternative to linear regression. I will explain the theory of regression trees, and compare them to linear regression in a set of simple simulations. Focusing on interaction effects and pruning. I will also highlight some extensions to regression trees that boost their performance. Afterwards I will use both methods on a dataset of student performance. Highlighting the strengths and weaknesses of RRTT, and Tree based methods..

### 1. Introduction

While linear regression, probably the most used method by empirical economist can be useful in many situations, it can be useful to look at where it fails, and different methods excel. Regression trees have been used in many situations serving as a powerful machine learning technique for predictive modelling. with many extension being developed greatly improving their usefulness. Regression trees offer an alternative approach that can be useful in many situations. We will discuss their advantages over traditional linear regression methods, cover the basics of regression trees, compare them with linear regression, address the issue of overfitting, and introduce advanced ensemble methods like Bayesian Additive Regression Trees (BART).

In this paper I will first give a short exposition on Regression Trees, their theory and extensions and applications and contrast them with linear regression. I will perform easily understandable simulations comparing Regression Trees and Linear Regression. Show how Regression Trees can be used on a Dataset of information about students and their test performance.
  

Because linear regression is used so much it is especially important to see where it performs well and where it does not and where other methods can improve upon it. Being very interperable it trees might also serve in educational roles well.

Linear regression performs poorly on many kinds of data, particularly those with non-linear relationships and interaction effects. What might be a better approach for these situations? Regression Trees can be useful in many situations where linear regression falls short.


L. Breiman, J.H. Friedman, R.A. Olshen, and C.J. Stone. Classication and Regression Trees. Chapman & Hall/CRC, Boca Raton, 1984 pdf being the origin of this method developing the algorithm.

Hastie and Tibshirani's an Introduction to Statistical Learning serves as an excelent modern introduction to Regression trees, while while Tan and Roy (2019) can give a deeper dive on BART a powerful ensemble method. 
Random forests, a very popular Tree based ML method are explained very well in A Random Forest Guided Tour Gerard Biau Erwan Scornet.



I found how simulations are good at showcasing model in an ideal setting. The simulations show how regression trees outperform linear regression on datasets with non liner relationships. etc. And how pruning can help find the optimal tradeoff between overfitting and not capturing enought of the signal. While applying the methods to the real world data can showcase how trees capture  interaction effects and how pruning works I discovered. Also the complications of worknig with real world data, as opposed to simulations.

  
In section 2 I will give a brief overview of the theory of regression trees, and where and where not we might expect them to perform will. And will also explain the bias variance trade-off and explain how pruning helps and ensemble methods that are extensions to trees.

In section 3 I will run a number of simulations comparing RRTT and LLRR and showcasing different aspects of RRTT under ideal conditions.

In section 4 I will apply these methods to a dataset of student test performance. Paying special attention to overfitting pruning and test vs validation vs training set. Also showing some of the shortcomings of RRTT and using BART.

Section 5 is the conclusion and will sum up what I have found and further interesting areas where research could be done.
### 2. Regression Trees

Regression Trees are a type of supervised machine learning algorithm that recursively splits the predictor space into smaller rectangular subregions. This process approximates an unknown function $f$ by minimizing a measure of loss at each split. Unlike linear regression, Regression Trees don't make assumptions about linearity or non-interaction between different dimensions, making them particularly useful for complex, non-linear relationships in data.

The core mechanism of Regression Trees involves splitting the predictor space into regions that minimize the residual sum of squares, given by:

\begin{equation}
    \sum_{j=1}^{J} \sum_{i \in R_j} ( y_i- \hat{ y}_{R_j} )^2
\end{equation}

In each region, $\hat{y}$ simply takes on the mean of all observations in that region.
Each branching of the tree divides the predictor space into two regions, for numerical variables typically of the form $\{x \le c\}$ or $\{x > c\}$. In each resulting region, the predicted value $\hat{y}$ is simply the mean of all observations within that region.

The algorithm employs a greedy approach called Recursive binary splitting to find the optimal split at each stagea greedy algorithm called Recursive binary splitting to find the optimal split to minimize prediction error at each stage. This process continues until a specified threshold is reached, such as a minimum number of observations in each leaf node or a maximum tree depth.


  



![[Pasted image 20240912104713.png]]

This is one example of what a regression tree does



Regression Trees offer several advantages over traditional linear regression methods. They can capture non-linear relationships between predictors and the response variable without requiring explicit specification of these relationships. Furthermore, they naturally account for interaction effects. For instance, if being blonde typically increases pay, but only for women, a Regression Tree will often automatically split along gender and then, for women only, along hair color. This ability to model complex interactions without manual specification is a significant strength of the method.




One other major benifit of Trees over Linear Regression is thet they capture interaction effects naturally. If for example being blong typically increases pay, but only for women, a Regression Tree will ofnet naturally split along gender and then, for women only, along haircolor. Whereas in a linear Regression the researcher would have to manually include terms for all interaction effects they want to study.


However, Regression Trees are not without their challenges. One of the primary issues is their tendency to overfit the data, especially when allowed to grow deep. Unlike linear regression, where overfitting primarily occurs with high-dimensional data, regression trees can overfit even with low-dimensional data. This is because they have the flexibility to create very specific rules that may capture noise in the training data rather than true underlying patterns.


  ![[Better overfitting.png]]

#### 2.1. Pruning

To address the issue of overfitting and improve overall performance, researchers have developed methods to "prune" regression trees. One of the most effective techniques is cost complexity pruning. This process involves several steps:

First, a large tree is grown that is likely to overfit the training data. Then, a complexity parameter $\alpha$ is introduced to penalize the tree's size. The pruning process is guided by the following formula:

\begin{equation}
    \sum_{m=1}^{|T|} \sum_{i: x_i \in R_m} (y_i - \hat{y}_{R_j})^2 + \alpha|T|
\end{equation}

Where $|T|$ is the number of terminal nodes in the tree. For each value of $\alpha$, the algorithm finds the subtree that minimizes this cost function. The optimal $\alpha$ is then selected using cross-validation, which helps achieve a good trade-off between bias and variance. The larger the cost complexity paramater $\alpha$ the better each split has to be to justify it's existance. As one prunes a large tree, by increasing \alpha the tree is naturally pruned in a predictable and well behaviud fashion. Allowing one to select the preffered tree. recursively removes least important split

Instead of evaluating a Model on the data we trained it on we evaluate it on a separate set.

in the `rpart` library cross validation is performed. And the error for all different trees are produced right away allowing one to then select the tree that performs best on the cross validation error. And lets one Achieve a good tradeoff between bias and variance.

 A large $\alpha$ results in very small trees, while a small $\alpha$ results in larger trees.
#### 2.2. Ensemble Methods

While pruning can significantly improve the performance of individual regression trees, they often still underperform compared to other advanced machine learning methods. This limitation led to the development of ensemble methods, which combine many regression trees to create more robust and accurate predictions. As Condorcet's jury theorem shows as long as each persion or predictor is better at guessing at answering a question adding more will increase the chance of getting a correct answer. "wisdom of crowds" CITE condorceth here !!!!


Ensemble methods improve results by leveraging the "wisdom of crowds" effect. If each tree has, for example, a 70% chance of being correct, and the errors are uncorrelated, combining many trees will tend to improve overall accuracy. The two main approaches to creating ensembles are:

1. Growing many independent trees and averaging them. Random Forests are a very popular ML method that does this.
2. Growing trees on the residuals of the current tree model, as in boosting methods or Bayesian Additive Regression Trees (BART).

Random Forests creates an ensemble by growing many decorrelated trees. Each tree is trained on a random subset of the training data and is only allowed to consider a random subset of features at each split. The final prediction is then formed by averaging the predictions of all trees (typically around 500). This approach reduces overfitting while maintaining the ability to capture complex patterns in the data. - HERE CITE **A Random Forest Guided Tour**


I will go into slightly more details for the BART method, as that is the extention I used on the dataset. I will go into a little more detail explaining the approach BART takes.

The BART approach models the the data as a sum of many Trees plus noise:

$$
Y_i = \sum_{j=1}^{m} g(X_i; T_j, M_j) + \epsilon_i
$$



Where $m$ is the number of trees, typically around 200. And $g(X_i; T_j, M_j)$ represents the contribution of the $j$-th tree. $T_j$ and $M_j$ represent the trees structure and predictions respectively.  And $\epsilon_i$ is the noise term.


The BART algorithm proceeds first generating e.g. 200 trees, without any splits. For each Tree $j$ it calculates the residual error $R_{-j}$  like taking in all the current trees except $j$
$$R_{-j} = Y - \sum_{t\not=j} g(X,T_j,M_j).$$
Then it proposes a change to that tree's structure, such as pruning a node, growing a node or changing some splitting rule. Then it accepts or rejects this modification based on it's posterior probability???. Which variable will bu uled is randomly selected to serve as the splitting variable, similar to random forests. If one averaged many trees but did not make sure they are uncorellated most of them might make the exact same split. Theirby iliminateng their wisdom of crowds. This process is repeated for all $m$ trees. That constitutes one iteration of the algorithm. Typically, BART uses 1000 burn-in iterations followed by 1000 sampling iterations. An estimate for f(x) can be obtained not by simply taking the final sum of trees the last iteration produced, but by taking the average over all sample iterations. Discarding the burn-in iterations.


A more complete exposition can be found in Chipman et al. (2010). of the BART method and how it's bayesian.

The algorithm then uses Markov Chain Monte Carlo (MCMC) sampling to draw from the posterior distribution of the model parameters.


BART uses a Bayesian approach, specifying priors on the tree structures, terminal node parameters, and error variance. Nodes at depth $d$ are nonterminal with probability $\alpha(1 + d)^{-\beta}$. This prior on shallow trees makes them be weak learners, more suited to being averaged. each tree explains small different part of $f$
 At also has other priors that inform how it assignes estimates to the terminal nodes but not scope of this paper.

Default values for these hyperparameters of = 095 and = 2 are recommended by Chipman et al. (2010). Default values generally provide good performance
	- optimal tuning can be achieved via cross-validation





Ensemble methods like Random Forests and BART have shown remarkable success in various applications, often outperforming individual regression trees and even many other machine learning techniques. They offer a powerful toolset for modeling complex relationships in data, providing both predictive accuracy and, in the case of BART, measures of uncertainty.

In conclusion, while individual regression trees offer interpretability and the ability to capture non-linear relationships, their tendency to overfit can limit their effectiveness. Pruning techniques help mitigate this issue, but ensemble methods take the concept further, leveraging the strengths of multiple trees to create highly accurate and robust models. The choice between these methods depends on the specific problem at hand, the importance of interpretability, and the need for uncertainty quantification in predictions.




### 3. Simulations

Simulations can serve as a testing ground for statistical methods, allowing for easyer repetability and eleminating many of the complications that arise when using datasets. Simulations are especially useful in comparing two different methods. Here I will compare Linear regression and regression trees on linear and non linear data. in this case. 

#### 3.1. Linear Data


This first simulations shows where linear regression excels and trees aren't especially useful. 
The data follows a simple linear relationship, exactly as the normal least squares regression assumes it does.
The data was generated as: $Y = \beta_0 + \beta_1X + \epsilon$, with epsilon of course normally distributed. I ran the simulations 400 times with regression trees, having 4 terminal nodes. And compared the Mean Squared Error (MSE) for both methods. The attached figure quite clearly shows how the linear regression is more suited to this data.
\begin{figure}

    \centering

    \includegraphics[scale=0.50]{OLS vs Tree.png}
![C:\Users\timtj\GitHub\wissenschaftliches-arbeiten\Hausarbeit\Graphics\OLS vs Tree.png](file:///c%3A/Users/timtj/GitHub/wissenschaftliches-arbeiten/Hausarbeit/Graphics/OLS%20vs%20Tree.png)
    \caption{Linear Relation between Variables}

The mean squared error for the Linear regression is: 0.9917
While for the regression tree it is: 1.4935

The linear regression also wins out on intuitivness. The derivative of the line of best fit can be interpreted as the expected increase in variable y as the x variable increases. While the step function of the regression tree doesn't serve any obvious function. It's just a worse regression.


#### 3.2. Non-linear Data

In this second simulation the data have a non linear relationship. In this case I used classification trees instead of regression trees, as this allows using colour as our third dimension instead of having to use a three dimensional plot.

The data was generated using 4 normal distributions with varying variance, in the four corners of the plot. With the North-West and SE being red and the NE and SW distribution producing blue datapoints.

  ![C:\Users\timtj\GitHub\wissenschaftliches-arbeiten\Hausarbeit\Graphics\NLD Pred.png](file:///c%3A/Users/timtj/GitHub/wissenschaftliches-arbeiten/Hausarbeit/Graphics/NLD%20Pred.png)
  
  
Again we ran the simulation 400 times.
In this case the error rate of the Classification Tree is 37,57%. While the linear classifier has an error rate of 51,03%. If this weren't a classification but a regression problem, one can imagine the red data having a high Z value, and the blue data having a low Z value, the result would be much the same. One could imagine a linear regression of the form $Z = x^2 - y^2$ forming a sort of saddle point, but this is not what the typical regression will look like, and especially would this interactin not be captured naturally by the linear model. Wheras the regression trees, because of their recursive nature, can naturally capture interaction effets. By first splitting along one exis and then along a different this will happen automatically.

This simulation also shows how Trees capture interaction effects naturally, the fact that a large X value is only indicative of the observation being Red if the Y value is small is naturally caputerd by the tree.


One could try to showcase more differences between the two methods now, especially on a simulation with more dimensons, seeing how an optimally pruned tree compares against multiple linear regression. But it is more interesting to do this on a real dataset, so we will leave the simulations behind us for now.

### 4. Predicting Student grades using Tree based methods

- exploratory
	- plot of variable importance
- manual pruning
	- Complex tree
	- Small tree
		- ALSO mention how one can see that small tree is subset of complex tree
- real pruning
	- Triple pruning graph
- Comparing all three



Next I will apply Tree based methods and also linear regresson to a dataset to showcase differences in a more realistic situation. This % from when % portugiouse dataset of student performance includes 649 students and looks at 33 variables. . This dataset is available publicly at kaggle or with my code %my github. 

#### 4.1 Exploratory data analysis

One can easily train a large tree on the dataset and find the variable importance, to then be better at further analyses


![](variable_importance.png)



E.g. if one does not remove to variables representing previous test scores practically all the model does is predict final test score based on previous test score and all other variables are practically irrelevant.



#### 4.2 Pruning

The most important thing to do is to use cross validation and prune your regression tree, otherwise nothing of interest will be learned as one will have just overfitted on the dataset.

For this i split the data # Split the data into training (70%) and validation (30%) sets




It can be useful to prune some trees manually by hand to get an intuitive feeling for how Regression Trees overfit. Instead of using the sophisticated inbuild option to automatically perform 10-fold cross validation and select the best performing tree I did it by hand first.


A growing a large with the complexity parameter which only allows splits if they cross a certain thershold in error reduction. cp = 0.01 we get a large tree with treethis large tree gets: with the Training MSE: 4.521407, and the Validation MSE: 9.026646. So clearly this tree is overfitting to a significant degree. This is what the tree looks like.


![](big_manual_tree.pdf)

Growing a small tree with the cp = 0.025,  minsplit = 5 will result in a tree with
and get a Training MSE of 7.840784 and a just slightly higher Validation MSE: 8.651296. 

![](small_manual_tree.pdf)

It's a bit of a shame this this super simple tree outperformes the larger one, but that one is just fitting to the noise of the data, not the real signal.



But to find the the best possible tree one should of course employ real pruning, automatically evaluated by the machine.

This time I first grew a massive tree, that would totally overfit on the training data.

One difficulty here is that even if one is using two datasets to combat overfitting trying to find the optimal `cp` value that will minimize the error on the test set. It may be that by chance one of the many different stages of pruning happens to produce a very good result.  



This plot nicely shows how pruning can find the optimal Tree, that doesn't overfit too much but still captures some of the datas information.

In the  plot one can nicely see how it could happen by chance that one tree is especially good for some number and if one then chooses that as the tree one is going to work with one overfitting still.

To combat this I first trained the complex tree on the training set and found the optimal value for `cp` using cross validation. Also on the training set. And only then evalueted it's performance on the test set. 

Sometimes it's so extreme that the optimal pruned tree using cross validation, once it's evaluated on the test set 
get's a MSE on the training data of 5.27211417154088"
but on the Test set MSE:  11.4923047228304 clearly overfitting and just lucky during cross validation.

Here one can see very well how the Cross validation error clearly helps against overfitting, it doesn't decrease monotonically, but still overfits to a large extent. The optimal tree using cross validation has 9 splits while the optimal one on the test error only has 1.

![](triple_pruning_plot.pdf)


A different problem is that the results can vary quite widley. Different splits in training and test data might lead to MSEs on the test set for the pruned tree between 6.9 and 9. 

And and optimal value for `cp` which in this case is 0.028 and 0.035.


The most typical results will loke something like this:

with the pruned tree performing just one single split. On failures, splitting the 15% of students who have previously failed the exam into one region (Estimate = 8.4) and the 85% of students with 0 failures into a second region (13 = estimate). This seems like something a human could have also done by hand.

```
 "Complex Tree - Training MSE: 1.71463455830232"
[1] "Complex Tree -     Test MSE: 10.813428171376"
[1] "Pruned Tree  - Training MSE: 8.52684386213971"
[1] "Pruned Tree  -     Test MSE: 8.18867861784212
```

The fact that the test error is lower than the training error should not be surprising, with only 1 split the tree couldn't overfit even if it tried. It it will always make the almost exact same split anyways. It's just chance if it will get lower or higher error on the test set.

#### 4.3 Comparing Linear Regression and Regression Trees and BART also

After seeing how the tree has performed it's informative to compare it to the results linear regresson gets.

Again using a 70% 30% split and using a tree that isn't overfitting these are the typicall results one gets for Regression trees and multivariate linear regression. Here the linear regression isn't optimized at all, it's the very first result one gets, no pruning or trying to combat overfitting.

Even without any prunig or anything linear regression beats the tree by a wide margin.

Taining MSE   Tree: 8.526844 
Validation MSE Tree: 8.188679 

Training MSE   Regr: 6.787159 
Validation MSE Regr: 6.865478

Summonig Condorcet to help us out wo can use ensemble methods.

Using bart with the dafault hyperparameters. That is


This is with
A burn-in and sampling period of 2000 iterations each and 200 Trees per iteration. Result in the following MSEs for BART:

Training MSE   BART: 5.777039 
Validation MSE BART: 6.52317

Depending on how the data is split into training and test set, and other random the numbers for all three models can vary quite widly. But almost is the single Tree outperformed by the linear regression and BART outperforms them both.

In return BART is far less easy to interpret then the other two methods. And we made no attempt at improving the performance of the regression model. Presumably it's performance can be increased in some way. But there are of course also other datasets where complicated ensemble methods really outperform lenear methods by a wide margin.



### 5. Conclusion

Regression trees are powerful tools for handling non-linear and interactive effects, often outperforming linear regression in these scenarios. They are also very easy to interpret. However, trees require pruning to combat overfitting. Ensemble methods, by averaging independent trees or fitting trees on the residuals, can significantly improve results. BART, in particular, is a sophisticated method offering good results in many scenarios. While regression trees have their strengths, it's important to choose the right tool for each specific data analysis task. Clearly there is a reason that there are "about188.000 results" on google scolar when one searches "Regression Tree" verses "about 4.320.000 results" searching for "Linear Regression". Although especially random forests are quite popular.

The most obvious problem with simple regression trees is that they overfit immeadiatly without doing anything usefil. It seems unimaginable only to be alble to do one split on a dataset this large, with that many variables. If Students that drink more alcohol score slightly less in the Training set a linear regression could incorperate this slight factor and it might well be that this also applies in the Test set and improves model performance. If it' not a real effect and just noise this slight coefficent won't incease Test error by a lot. Whearas the Regression Tree after having made it's initial useful split can't help find the best optimal split, apparently hyperfocusing on some, most useful seeming area, that mostly turns out to just be noise.

While BART beats linear regression it gives up on interprebility for the most part, while linear regression is very interprable, in a similar way to regression trees. Arguable more. Regression trees 


In conclusion regression trees definitly have their applications, as the simulations show, on very non linear data, even a simple tree can outperform liner regression by a wide margin. But on real life data often linear liner regression will perform better and be more  be more interpretable and useful. Maybe the trees really shine only on data that has very strong interaction effetts more than the single dataset I considered. 


  Of course one can always find better datasets more made for trees to work better than my data, better methods to tell which is the best method to use. 

This is a very important area of research and clearly there are still many open questions.





