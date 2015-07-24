library(dplyr)
# library(rpart)
library(randomForest)
library(Metrics)
library(caret)
library(xgboost)
set.seed(0)


train_set <- tbl_df(read.csv('./train_set_adjusted.csv'))

tube <- tbl_df(read.csv('./tube_material_id_imputed_dummies_drop_ns.csv'))
spec_dummies <- tbl_df(read.csv('./spec_dummies.csv'))
comp_type_dummies <- tbl_df(read.csv('./comp_type_dummies.csv'))
comp_weight <- tbl_df(read.csv('./comp_weight.csv'))


train_tube <- tbl_df(merge(train_set, tube))
train_tube <- tbl_df(merge(train_tube, comp_type_dummies))
train_tube <- tbl_df(merge(train_tube, spec_dummies))
train_tube <- tbl_df(merge(train_tube, comp_weight))

trainIndex <- createDataPartition(train_tube$cost, p = 0.7, list = FALSE)

train_tube_sub_train <- train_tube[trainIndex, ]
train_tube_sub_test <- train_tube[-trainIndex, ]
train_tube_features <- train_tube_sub_train %>%
  select(-tube_assembly_id, -quote_date, -cost, -quantity_rep) %>%
  as.matrix()
train_tube_features_test <- train_tube_sub_test %>%
  select(-tube_assembly_id, -quote_date, -cost, -quantity_rep) %>%
  as.matrix()
train_tube_response <- log1p(train_tube_sub_train$cost)


test_set <- tbl_df(read.csv('./test_dummies_adjusted.csv'))

test_tube <- tbl_df(merge(test_set, tube))
test_tube <- tbl_df(merge(test_tube, comp_type_dummies))
test_tube <- tbl_df(merge(test_tube, spec_dummies))
test_tube <- tbl_df(merge(test_tube, comp_weight))

test_tube_features <- test_tube %>%
  select(-tube_assembly_id, -quote_date, -id, -quantity_rep) %>%
  as.matrix()


xgb.params <- list(objective = "reg:linear", eta = 0.02, min_child_weight = 5,
                   subsample = 0.7, colsample_bytree = 0.6, scale_pos_weight = 0.8,
                   silent = 1, max_depth = 9, max_delta_step = 2)

tube_xgboost_fit <- xgboost(data=train_tube_features, label=train_tube_response,
                            nrounds = 2000, verbose = 1, params = xgb.params)
train_tube_response_test <- predict(tube_xgboost_fit, train_tube_features_test)
rmsle(train_tube[-trainIndex, 'cost'], expm1(train_tube_response_test))



test_tube_response <- predict(tube_xgboost_fit, test_tube_features)
submit <- test_set %>% select(id) %>% mutate(cost = expm1(test_tube_response))
write.csv(submit, 'submit_xgb.csv', quote = FALSE, row.names = FALSE)
