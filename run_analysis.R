## Getting and Cleaning Data Course Project
## Dec 13, 2023

## Data have been previously downloaded on drive for ease
## Working folder has been set in R but not shown here for privacy purpose
## data stored in ".\data\UCI HAR Dataset"

## The purpose of this project is to demonstrate ability to collect, work with, and clean a data set.
## The goal is to prepare tidy data that can be used for later analysis.

## loading those 2 libraries for this project
library(data.table)
library(dplyr)

##  From Readme file, the dataset includes the following files:
## 'features_info.txt'- Shows information about the variables used on the feature vector - needed to understand files structures
## 'features.txt'- the complete list of variables of each feature vector - this has to be used when reading test and training files.
## 'activity_labels.txt': Links the class labels with their activity name.
## 'train/X_train.txt': Training set using names from function used.
## 'train/y_train.txt': Training labels using category names.
## 'test/X_test.txt': Test set function using names from function used.
## 'test/y_test.txt': Test labels using category names.
## 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

## Naming DF by name of file - read tables works here on those txt files
features <- read.table("data/UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activity_labels <- read.table("data/UCI HAR Dataset/activity_labels.txt", col.names = c("category", "activity"))
x_train <- read.table("data/UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("data/UCI HAR Dataset/train/y_train.txt", col.names = "category")
x_test <- read.table("data/UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("data/UCI HAR Dataset/test/y_test.txt", col.names = "category")
subject_train <- read.table("data/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
subject_test <- read.table("data/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

## verify if there are duplicates in subject in train and test - will merge after
unique_train <- unique(subject_train)
unique_test <- unique(subject_test)
unique <- rbind(unique_test,unique_train)
if (sum(duplicated(unique)) != 0){
  break
}

## Before merging train and test data set needs to put subject id and category of test with whose file - using cbind
train <- cbind(subject_train,y_train,x_train)
test <- cbind(subject_test,y_test,x_test)

## full data using rbind
data <- rbind(train, test)

## Free some data for space - not using it
## list_to_clear = c("list_to_clear", "subject_test", "subject_train", "test" ,"train", "unique", "unique_test", "unique_train", "x_test", "x_train", "y_test", "y_train")
## rm(list = list_to_clear)

## create smaller data now
## Extracts only the measurements on the mean and standard deviation for each measurement. 
data <- data[, grep("subject|category|mean|std", names(data))]

## creating factor variable for category
data$category <- as.factor(data$category)

## Uses descriptive activity names to name the activities in the data set
data$category <- factor(data$category, labels = activity_labels$activity)

## change variable name from category to activity 
names(data)[2] <- "activity"

## label data with descriptive names 
names(data)<-gsub("Acc", "_Accelerometer", names(data))
names(data)<-gsub("Gyro", "_Gyroscope", names(data))
names(data)<-gsub("Mag", "_Magnitude", names(data))
names(data)<-gsub("angle", "_Angle", names(data))
names(data)<-gsub("gravity", "_Gravity", names(data))
names(data)<-gsub("Jerk", "_Jerk", names(data))

## weird data name
names(data)<-gsub("BodyBody", "Body", names(data))

## Removes dot
names(data) <- gsub("\\.", "", names(data))

## metrics
names(data)<-gsub("mean", "_Mean_", names(data))
names(data)<-gsub("std", "_Standard_deviation_", names(data))
names(data)<-gsub("Freq", "_Frequency_", names(data))

## start of variables
names(data)<-gsub("^t", "Time_", names(data))
names(data)<-gsub("^f", "Frequency_", names(data))

## Remove leading _
names(data)<-gsub("_$", "", names(data))

## Fix this
names(data)<-gsub("Mean__Frequency", "Mean_Frequency", names(data))

## use dplyr to create a second independent tidy data set with the average of each variable for each activity and each subject.
final_data <- data %>% group_by(subject, activity) %>% summarise_all(mean)

## check structure of file
str(final_data)

## Write the table
write.table(final_data, "./data/final_data.txt", row.name=FALSE)
