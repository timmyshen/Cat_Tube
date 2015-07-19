# library(caret)
library(dplyr)
library(rpart)
library(randomForest)
library(Metrics)
library(caret)
library(xgboost)
set.seed(0)


train_set <- tbl_df(read.csv('./competition_data/train_set.csv'))
train_set <- tbl_df(read.csv('./train_set_supplier_dummies.csv'))
train_set <- tbl_df(read.csv('./train_set_no_date_dummies_drop_bracket_n.csv'))
# tube <- tbl_df(read.csv('./competition_data/tube.csv'))
# tube <- tbl_df(read.csv('./tube_material_id_imputed.csv'))
tube <- tbl_df(read.csv('./tube_material_id_imputed_dummies_drop_ns.csv'))

spec_dummies <- tbl_df(read.csv('./spec_dummies.csv'))
comp_type_dummies <- tbl_df(read.csv('./comp_type_dummies.csv'))

# train_tube <- dplyr::left_join(train_set, tube, by = 'tube_assembly_id')
train_tube <- tbl_df(merge(train_set, tube))
train_tube <- tbl_df(merge(train_tube, comp_type_dummies))
train_tube <- tbl_df(merge(train_tube, spec_dummies))

# material_na_mask <- is.na(train_tube$material_id)
# train_tube$material_id <- as.character(train_tube$material_id)
# train_tube$material_id[material_na_mask] <- '0'
# train_tube$material_id <- as.factor(train_tube$material_id)

trainIndex <- createDataPartition(train_tube$cost, p = 0.9, list = FALSE)


fit <- rpart(cost ~ supplier + annual_usage + quantity +
               diameter + wall + length + num_bends + bend_radius +
               end_a + end_x + num_boss + num_bracket,
      data = train_tube)
#
# in_sample <- predict(fit, newdata = train_tube)
# rmsle(train_tube$cost, in_sample)

rf.fit <- randomForest(log1p(cost) ~ . - tube_assembly_id - quote_date,
                  data = train_tube, subset = trainIndex,
                  ntree = 200, do.trace = 5)
in_sample <- predict(rf.fit, newdata = train_tube[trainIndex, ])
out_sample <- predict(rf.fit, newdata = train_tube[-trainIndex, ])
rmsle(train_tube[trainIndex, 'cost'], expm1(in_sample))
rmsle(train_tube[-trainIndex, 'cost'], expm1(out_sample))


train_tube_features <- train_tube %>% select(annual_usage, quantity, material_id,
                        diameter, wall, length, num_bends, bend_radius,
                        end_a_1x, end_a_2x, end_x_1x, end_x_2x,
                        end_a, end_x, num_boss, num_bracket) %>% as.matrix()

train_tube_sub_train <- train_tube[trainIndex, ]
train_tube_sub_test <- train_tube[-trainIndex, ]
train_tube_features <- train_tube_sub_train %>% select(-tube_assembly_id, -cost) %>% as.matrix()
train_tube_features_test <- train_tube_sub_test %>% select(-tube_assembly_id, -cost) %>% as.matrix()
train_tube_response <- train_tube_sub_train$cost

tube_xgboost_fit <- xgboost(data=train_tube_features, label=log1p(train_tube_response),
                            nrounds = 1000, verbose = 0)
train_tube_response_test <- predict(tube_xgboost_fit, train_tube_features_test)
rmsle(train_tube[-trainIndex, 'cost'], expm1(train_tube_response_test))


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
