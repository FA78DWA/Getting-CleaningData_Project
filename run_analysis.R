## 
#library(data.table)


# Read the feature names and activity labels --------------------------------------------------
featureNames <- read.table("./UCI HAR Dataset/features.txt")
activityNames <- read.table("./UCI HAR Dataset/activity_labels.txt")

# Reading the test and train sets ----------------------------------------------------
testdata <- read.table("./UCI HAR Dataset/test/X_test.txt")
testlabels <- read.table("./UCI HAR Dataset/test/y_test.txt")
testsubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")

traindata <- read.table("./UCI HAR Dataset/train/X_train.txt")
trainlabels <- read.table("./UCI HAR Dataset/train/y_train.txt")
trainsubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")

oldVariableNames <- names(traindata)

# Merging (part 1) -------------------------------------------------------------
## get dimensions
testDim <- dim(testdata)
trainDim <- dim(traindata)

## conmbine subject variable
subjectID <- rbind(testsubject, trainsubject)

## add testFlag variable which is TRUE if the observation from the testdata and FALSE otherwise
## add to the test table
testdata$testFlag <- rep(TRUE,testDim[1])
## add to the train table
traindata$testFlag <- rep(FALSE,trainDim[1])

## Combine the train and test tables, add the subjectID
totalData <- rbind(testdata,traindata)
totalData$subjectID <- subjectID

# Extract the mean and std (part 2) ------------------------------------------------------

## get the indices for the required variable
varInd <- grep("mean|std", featureNames[,2])

## Extract the corresponding measurements
meanStd_data <- totalData[,varInd]


# Name the activities part(3) -----------------------------------------------------------------

## create a function that replace number with names
replaceNumberWithName <- function(x){activityNames[x,2]}
## replace number with names for test data
testlabels_names <- sapply(testlabels,replaceNumberWithName)
## replace number with names for train data
trainlabels_names <- sapply(trainlabels,replaceNumberWithName)

## conmbine activity labels
combinedactivity <- rbind(testlabels_names, trainlabels_names)

## add the label variable to the totalData
totalData$activity <- combinedactivity


# labels the data set with descriptive variable names (part 4) --------------------------

setnames(totalData,colnames(totalData)[1:561],as.character(featureNames[,2]))

# 3D dataset (part 5) -----------------------------------------------------

#From the data set in step 4, creates a second, independent tidy data set with the 
#average of each variable for each activity and each subject.

library(abind)

## take a look at the trainsubject and testsubject data
table(trainsubject)
table(testsubject)

## subj#1 data
subjects = 1:3
final <- data.frame()
getAverageAndBind <- function(x){
        subj <- totalData[totalData$subjectID == x,]
        subjAvgData <- aggregate(subj[,2:561], list("activity" = subj$activity), mean)
        rownames(subjAvgData) <- activityNames[,2]
        subjAvgData
}
output <- sapply(subjects, getAverageAndBind)

for(i in subjects){
        if(i == 1)
        TidyData <- data.frame(output[,i])        
        else
        TidyData <- abind(df,data.frame(output[,i]) ,along = 3)
}



