library(reshape2)

filename <- "getdata_datset.zip"

# download dataset and unzip files
if (!file.exists(filename)) {
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename, method = "curl")
}

if (!file.exists("UCI HAR Dataset")) {
    unzip(filename)
}


activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")

# get data on mean and sd
our_features <- grep(".*mean.*|.*std.*", features[, 2])
our_features_names <- features[our_features, 2]
our_features_names = gsub('-mean', 'Mean', our_features_names)
our_features_names = gsub('-std', 'Std', our_features_names)
our_features_names <- gsub('[-()]', '', our_features_names)

# load train data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[our_features]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

# load test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[our_features]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

# create one dataset
all_data <- rbind(train, test)
colnames(all_data) <- c("subject", "activity", our_features_names)

# activity and subjects into factors
all_data$activity <- factor(all_data$activity, levels = activity_labels[,1], 
                            labels = activity_labels[, 2])
all_data$subject <- as.factor(all_data$subject)

all_data_molted <- melt(all_data, id = c("subject", "activity"))
all_data_mean <- dcast(all_data_molted, subject + activity ~ variable, mean)

write.table(all_data_mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)
