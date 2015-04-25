# Getting-and-Extracting-Data

#1.Download the file and put the file in the data folder
if(!file.exists("./data")){dir.create("./data")} ## check if file already exist, if not yet, data folder will be created.
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" ## URL where the path is linked is passed to URL vector.
dest <- file.path(getwd(), "dataset.zip") ## setting the destination path of the file when downloaded.
download.file(Url, dest, method="curl") ## downloading the file

##2.Unzip the file

unzip(zipfile="./data/Dataset.zip", exdir="./data") ## extracting the files from the zipped file

##3. Unzipped files are in the folderUCI HAR Dataset. Get the list of the files

dataset_path <- file.path("./data" , "UCI HAR Dataset")
files<- list.files(dataset_path, recursive=TRUE)
files

#Read data from the targeted files
#Get the big picture of the structure of the data frame that will be used in this project.

##From the picture and the related files, we can see:
        
#Values of Varible Activity consist of data from “Y_train.txt” and “Y_test.txt”
#values of Varible Subject consist of data from “subject_train.txt” and subject_test.txt"
#Values of Varibles Features consist of data from “X_train.txt” and “X_test.txt”
#Names of Varibles Features come from “features.txt”
#levels of Varible Activity come from “activity_labels.txt”
#So we will use Activity, Subject and Features as part of descriptive variable names for data in data frame.

#2. Read data from the files into the variables

#Read the Activity files

dataActivityTest  <- read.table(file.path(dataset_path, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(dataset_path, "train", "Y_train.txt"),header = FALSE)

#Read the Subject files

dataSubjectTrain <- read.table(file.path(dataset_path, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(dataset_path, "test" , "subject_test.txt"),header = FALSE)

#Read Features files

dataFeaturesTest  <- read.table(file.path(dataset_path, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(dataset_path, "train", "X_train.txt"),header = FALSE)

#3. Look at the properties of the above varibles
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

#Merges the training and the test sets to create one data set
#1.Concatenate the data tables by rows

dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#2.set names to variables

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(dataset_path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#3.Merge columns to get the data frame Data for all data

SubjectActivityComb <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, SubjectActivityComb)

#Extracts only the measurements on the mean and standard deviation for each measurement
#1. Subset Name of Features by measurements on the mean and standard deviation
#i.e taken Names of Features with “mean()” or “std()”

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#2. Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#3. Check the structures of the data frame Data
str(Data)

#Uses descriptive activity names to name the activities in the data set
#1.Read descriptive activity names from “activity_labels.txt”

activityLabels <- read.table(file.path(dataset_path, "activity_labels.txt"),header = FALSE)

#2. factorize Variable activity in the data frame Data using descriptive activity names

#3. check

head(Data$activity,30)

#Appropriately labels the data set with descriptive variable names

#In the former part, variables activity and subject and names of the activities have been labelled using descriptive names.In this part, Names of Feteatures will labelled using descriptive variable names.

#* prefix t is replaced by time
#* Acc is replaced by Accelerometer
#* Gyro is replaced by Gyroscope
#* prefix f is replaced by frequency
#* Mag is replaced by Magnitude
#* BodyBody is replaced by Body

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#check

names(Data)

#Creates a second,independent tidy data set and ouput it

#In this part,a second, independent tidy data set will be created with the average of each variable for each activity and each subject based on the data set from step 4.

library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file="tidydata.txt",row.name=FALSE)

#Produce Codebook

library(knitr)
knit2html("codebook.Rmd");

