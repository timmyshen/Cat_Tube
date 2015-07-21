library(dplyr)
library(rpart)
library(randomForest)
library(Metrics)
library(caret)
library(gbm)

set.seed(0)


train_set <- tbl_df(read.csv('./competition_data/train_set.csv'))
train_set <- tbl_df(read.csv('./train_set_supplier_dummies.csv'))
train_set <- tbl_df(read.csv('./train_set_no_date_dummies_drop_bracket_n.csv'))
tube <- tbl_df(read.csv('./tube_material_id_imputed_dummies_drop_ns.csv'))

spec_dummies <- tbl_df(read.csv('./spec_dummies.csv'))
comp_type_dummies <- tbl_df(read.csv('./comp_type_dummies.csv'))

train_tube <- tbl_df(merge(train_set, tube))
train_tube <- tbl_df(merge(train_tube, comp_type_dummies))
train_tube <- tbl_df(merge(train_tube, spec_dummies))


trainIndex <- createDataPartition(train_tube$cost, p = 0.7, list = FALSE)


gbm.fit <- gbm(cost ~ . - tube_assembly_id, interaction.depth = 5,
                       data = train_tube[trainIndex, ],
                       n.trees = 2500)
in_sample <- predict(gbm.fit, newdata = train_tube[trainIndex, ], n.trees = 2500)
out_sample <- predict(gbm.fit, newdata = train_tube[-trainIndex, ], n.trees = 50)
rmsle(train_tube[trainIndex, 'cost'], (in_sample))
rmsle(train_tube[-trainIndex, 'cost'], (out_sample))
