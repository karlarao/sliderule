# run_analysis.R
# by: Karl Arao
#
# exercise instructions: 
#	1) Merge the training and the test sets to create one data set
#	2) Create variables called ActivityLabel and ActivityName that label all observations with the corresponding activity labels and names respectively
#	3) Extract columns containing mean and standard deviation for each measurement
#	4) From the data set in step 2, creates a second, independent tidy data set with the average of each variable for each activity and each subject
#
# final file: samsung_tidy_data.txt
#
# URL of the data set: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# detailed data set info: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#


# load packages
if (!require(dplyr)) {
  install.packages("dplyr")
  library(dplyr)
}
if (!require(tidyr)) {
  install.packages("tidyr")
  library(tidyr)
}

# set directory
setwd("E:/GitHub/sliderule/samsung_data_wrangling")

# Read in test data
x_test <- read.table("test/X_test.txt")                 # 2947 rows, 561 cols (core data)
y_test <- read.table("test/y_test.txt")                 # 2947 rows, 1 cols (activity labels - 6 distinct values)
subject_test <- read.table("test/subject_test.txt")     # 2947 rows, 1 cols (30% - 9 distinct values)

# Read in train data
x_train <- read.table("train/X_train.txt")              # 7352 rows, 561 cols
y_train <- read.table("train/y_train.txt")              # 7352 rows, 1 cols
subject_train <- read.table("train/subject_train.txt")  # 7352 rows, 1 cols (70% - 21 distinct values)

# Read in names/label 
col_names  <- read.table("features.txt", stringsAsFactors=FALSE)  # 561 rows (column names), 2 cols (List of all features, variables used on the feature vector)
activities <- read.table("activity_labels.txt")                   # 6 rows (activity names), 2 cols (Links the class labels with their "activity name")

# Combine data 
test <- cbind(x_test, y_test, subject_test)             # for some reason bind_cols takes the two V1 as one distinct value, so just use cbind and rbind
train <- cbind(x_train, y_train, subject_train)			
combined <- rbind(test, train)

# Put column names 
col_names <- col_names[[2]]
col_names <- c(col_names, "ActivityLabel","Subject")
col_names <- make.names(col_names,unique=TRUE)          # to avoid the error "found duplicated column name"
names(combined) <- col_names

# Join combined to activities to label the data, join with "ActivityLabel"
act_cols <- c("ActivityLabel","ActivityName")
names(activities) <- act_cols
combined <- full_join(combined, activities)

# Extract mean and std columns 
mean_std <- select(combined, matches("mean|std"))

# Average of each variable for each activity and each subject
summarised_data <- combined %>% group_by(Subject,ActivityName) %>% summarise_each(funs(mean))

# Make it tidy 
tidy_data <- gather(summarised_data, Features, Value, tBodyAcc.mean...X:angle.Z.gravityMean., -ActivityLabel)

# Export tidy data 
write.table(tidy_data, file="samsung_tidy_data.txt")

