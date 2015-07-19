library(xgboost)

data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test

str(train)
train$data@Dim
train$data@Dimnames

dim(train$data)
str(train$label)
dim(test$data)


class(train$data)[1]
class(train$label)


bstSparse <- xgboost(data = train$data, label = train$label,
                     max.depth = 2, eta = 1, nthread = 2, nround = 2,
                     objective = "binary:logistic")

