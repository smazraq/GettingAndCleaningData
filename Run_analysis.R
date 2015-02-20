
#Working directory should have the zip file data in it.
# If the data has been unzipped already, the script will skip to the processing

#Check for the unzipped directory.  Download and extract if dir doesn't exist.
if(!file.exists("./UCI HAR Dataset")){
  zipurl <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
  download.file(zipurl,destfile="./UCI HAR Dataset.zip",mode="wb",method="curl")
  unzip("./UCI HAR Dataset.zip")
}

#X_train(test) has 561 variable, which are the "features".  Need mean and stdev columns only from that.
#y_train(test) are the labels of the activities (need to use the real names)
#  maybe need to colapse these down also?
#subject_train(test) are the people in the study (aparently unused for this excercise, but good to have for analysis)
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt") 

X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt") 

#six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) 
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

#the 561 "features"
features <- read.table("./UCI HAR Dataset/features.txt")

#join up the test and train
X_comb <- rbind(X_train,X_test)
y_comb <- rbind(y_train,y_test)
subject_comb <- rbind(subject_train,subject_test)

#put the "features" on the columns
colnames(X_comb) = features$V2

#extract only the mean and stdev columns
X_comb_mean_std <- X_comb[,grepl("*Mean*|*mean*|*std*", colnames(X_comb))]

#Resolve the numerical activities into the descriptive names into y_comb
for(i in 1:dim(activity_labels)[1]){
  y_comb[which(y_comb==i),] <- as.character(activity_labels$V2[i])
}

#Prepend the data with the Activites
X_comb_mean_std <- cbind(y_comb,X_comb_mean_std)
#Rename to "Activities"
X_comb_mean_std <- rename(X_comb_mean_std,Activities=V1)


#Prepend the data with the subjects
X_comb_mean_std <- cbind(subject_comb,X_comb_mean_std)
#Rename to "Subject"
X_comb_mean_std <- rename(X_comb_mean_std,Subjects=V1)

#Need the means of each subject and activity now
# ex...all of subject 1's walking.  All of subject 3's walking_upstairs
suppressWarnings(X_final <- aggregate(X_comb_mean_std, by=list(X_comb_mean_std$Subjects,X_comb_mean_std$Activities), FUN=mean, na.rm=TRUE))
#Aggregate Creates "Group" variables so rename those and get rid of the originals
X_final$Subjects <- NULL
X_final$Activities <- NULL
X_final <- rename(X_final,Subjects=Group.1)
X_final <- rename(X_final,Activities=Group.2)

#Finally, write the data to a file for submission
write.table(X_final,file="GandCData.txt",row.name=FALSE)


#To read that data right back in, run the following
#X_final_readin <- read.table("./GandCData.txt",header=TRUE)

#To further test you could run this command to do a subset of one of the Subject/Activity combos
#try <- subset(X_comb_mean_std,X_comb_mean_std$Subjects==17 & X_comb_mean_std$Activities=="STANDING")
#take the mean of one of the rows (20 is tBodyAccJerk-std()-Z)
#mean(try[,20])
#[1] -0.991217.  Check the answer to see that the Subject/Activiy combo has that mean

