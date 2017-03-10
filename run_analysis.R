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

# Merging (part 1) -------------------------------------------------------------
## get dimensions
testDim <- dim(testdata)
trainDim <- dim(traindata)

## Combine the `testdata` and `traindata` tables. Then, add the `subjectID`
totalData <- rbind(testdata,traindata)

##Check the dimensions of the final big dataset `totalData`.
dim(totalData)

# Extract the mean and std (part 2) ------------------------------------------------------
## get varInd
varInd <- grep("mean\\(\\)|std\\(\\)", featureNames[,2])
numExtractedVariables <- length(varInd)

## check the variables names
featureNames[varInd,2]


## Extract the corresponding measurements from the merged table `totalData`
meanStd_data <- totalData[,varInd]
head(meanStd_data)

## Combine subject variable from test data and training data into one column `subjectID`.
subjectID <- data.table(rbind(testsubject, trainsubject))
dim(subjectID)


## Create `testFlag` variable
testFlag <- data.table(rep(c(T,F), c(testDim[1],trainDim[1])))
dim(testFlag)


## Combine `subjectID` and `testFlag` variables to `meanStd_data`
meanStd_data <- cbind(meanStd_data, setnames(subjectID,c('subjectID')), 
                      setnames(testFlag,c('testFlag')))

## check the dimensions for the meanStd_data
dim(meanStd_data)



# Name the activities part(3) -----------------------------------------------------------------

## Create a function `replaceNumberWithName` that replace activity number with 
## activity names.Then apply it on the testlabels and the trainlabels.
replaceNumberWithName <- function(x){activityNames[x,2]}

## replace number with names for test data
testlabels_names <- sapply(testlabels,replaceNumberWithName)

## replace number with names for train data
trainlabels_names <- sapply(trainlabels,replaceNumberWithName)


## conmbine activity labels into a single column combinedactivity.
combinedactivity <- data.table(rbind(testlabels_names, trainlabels_names))


## add the label variable to the `meanStd_data`
meanStd_data <- cbind(meanStd_data, setnames(combinedactivity,c('activity')))

## check meanStd_data dimensions
dim(meanStd_data)

## Check the new names
names(meanStd_data)


# label the dataset with descriptive variable names (part 4) --------------

## old column names
names(meanStd_data)

## set the new names. VarInd from step #2
setnames(meanStd_data,colnames(meanStd_data)[1:numExtractedVariables],as.character(featureNames$V2[varInd]))

## new column names
names(meanStd_data)

# Tidy dataset (part 5) -----------------------------------------------------

## take a look at the `trainsubject` and `testsubject` data. 
table(trainsubject)
table(testsubject)

## use `aggregate` to calculate the `mean` for each measurement grouped by 
## `subjectID` and `activity`. The final dataset `TidyData` has dimensions of
## [180x563]. 



TidyData <- aggregate(meanStd_data[,1:numExtractedVariables], by=list("id"=meanStd_data$subjectID, "activity" = meanStd_data$activity), mean)

## check tidyData dimension. The output variables (columns) are id for subject id, 
## activity, testFlag, and the 561 measurements. 
dim(TidyData)

## Save the `TidyData` as a `.txt` file.
write.table(TidyData,"TidyData.txt", row.names = F)

