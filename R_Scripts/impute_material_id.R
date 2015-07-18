library(readr)
library(dplyr)
library(class)
library(caret)

set.seed(1989)

# tube <- readr::read_csv('./competition_data/tube.csv')
# There are some problems here.

tube <- tbl_df(read.csv('./competition_data/tube.csv'))

material_train <- tube %>% filter(!is.na(material_id))
material_test <- tube %>% filter(is.na(material_id))
material_test_features <- material_test %>% select(-material_id)

material_pred <- knn(material_train, material_test_features, cl = material_id, k = 1)

material_knn3 <- knn3(material_id ~ . , data = material_train)
material_pred <- predict.knn3(material_knn3, newdata = material_test)
# as.numeric(levels(f))[tube]

tube_prep <- caret::preProcess(tube, method = 'knnImpute')
