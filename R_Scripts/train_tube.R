# library(caret)
library(dplyr)
library(rpart)
library(randomForest)
library(Metrics)
library(caret)
set.seed(0)


train_set <- tbl_df(read.csv('./competition_data/train_set.csv'))
tube <- tbl_df(read.csv('./competition_data/tube.csv'))

# train_tube <- dplyr::left_join(train_set, tube, by = 'tube_assembly_id')
train_tube <- tbl_df(merge(train_set, tube))

trainIndex <- createDataPartition(train_tube$cost, p = 0.7, list = FALSE)


fit <- rpart(cost ~ supplier + annual_usage + quantity +
               diameter + wall + length + num_bends + bend_radius +
               end_a + end_x + num_boss + num_bracket,
      data = train_tube)
#
# in_sample <- predict(fit, newdata = train_tube)
# rmsle(train_tube$cost, in_sample)

rf.fit <- randomForest(cost ~ annual_usage + quantity +
                    diameter + wall + length + num_bends + bend_radius +
                    end_a + end_x + num_boss + num_bracket,
                  data = train_tube, subset = trainIndex,
                  ntree = 100, do.trace = 5)
in_sample <- predict(rf.fit, newdata = train_tube[trainIndex, ])
out_sample <- predict(rf.fit, newdata = train_tube[-trainIndex, ])
rmsle(train_tube[trainIndex, 'cost'], in_sample)
rmsle(train_tube[-trainIndex, 'cost'], out_sample)
# fitControl <- trainControl(## 10-fold CV
#   method = "repeatedcv",
#   number = 10,
#   ## repeated ten times
#   repeats = 10)
#
# set.seed(825)
# gbmFit1 <- train(cost ~ supplier + quantity + diameter + wall + length + num_bends + bend_radius,
#                  data = train_tube,
#                  method = "rf",
#                  trControl = fitControl,
#                  ## This last option is actually one
#                  ## for gbm() that passes through
#                  verbose = FALSE)
# gbmFit1
