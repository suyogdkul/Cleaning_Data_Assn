## This code creates an R script called run_analysis.R that performs the following tasks as mentioned in the assignment:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Step 1 : Load Activity Labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Step 2 : Load data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Step 3 : Extract only the measurements on the mean and standard deviation for each measurement from the record
extract_features <- grepl("mean|std", features)

# Step 4 : Read and process X_test & Y_test data 
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

# Step 5 : Extract only the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

# Step 6: Load activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Step 7 : Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Step 8 : Read and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Step 9: Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,extract_features]

# Step 10 : Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Step 11 : Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Step 12 : Merge test and train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Step 13 : Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Step 14 : Write this final data set to a file 
write.table(tidy_data, file = "./tidy_data.txt",row.names = FALSE)
