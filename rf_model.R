library(dplyr)
# library(rpart)
library(randomForest)
library(Metrics)
library(caret)
# library(xgboost)
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


test_set <- tbl_df(read.csv('./test_dummies_adjusted.csv'))

test_tube <- tbl_df(merge(test_set, tube))
test_tube <- tbl_df(merge(test_tube, comp_type_dummies))
test_tube <- tbl_df(merge(test_tube, spec_dummies))


trainIndex <- createDataPartition(train_tube$cost, p = 0.7, list = FALSE)

rf.fit <- randomForest(log1p(cost) ~ . - tube_assembly_id - quote_date - quantity_rep,
                       data = train_tube, subset = trainIndex,
                       ntree = 20, do.trace = 5)
in_sample <- predict(rf.fit, newdata = train_tube[trainIndex, ])
out_sample <- predict(rf.fit, newdata = train_tube[-trainIndex, ])
rmsle(train_tube[trainIndex, 'cost'], expm1(in_sample))
rmsle(train_tube[-trainIndex, 'cost'], expm1(out_sample))
