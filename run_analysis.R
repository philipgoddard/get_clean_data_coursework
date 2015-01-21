library(dplyr)
rm(list=ls())

## some path names. run this script in the directory that contains
## the UCI HAR Dataset directory
s_test <- "UCI HAR Dataset/test/subject_test.txt"
X_test <- "UCI HAR Dataset/test/X_test.txt"
y_test <- "UCI HAR Dataset/test/y_test.txt"
s_train <- "UCI HAR Dataset/train/subject_train.txt"
X_train <- "UCI HAR Dataset/train/X_train.txt"
y_train <- "UCI HAR Dataset/train/y_train.txt"
col_names <- "UCI HAR Dataset/features.txt"
activity_names <- "UCI HAR Dataset/activity_labels.txt"


## read the raw path
s_test_data <- read.table(s_test)
X_test_data <- read.table(X_test)
y_test_data <- read.table(y_test)
s_train_data <- read.table(s_train)
X_train_data <- read.table(X_train)
y_train_data <- read.table(y_train)
col_names <- read.table(col_names)
activity_names <- read.table(activity_names)


# merge train to single df. use dplyr tbl_df for readability
train_dat <- s_train_data
train_dat <- cbind(train_dat,y_train_data)
train_dat <- cbind(train_dat,X_train_data)
train_dat <- tbl_df(train_dat)
#dimensions of train_dat are 7352 rows, 563 columns

# merge test
test_dat <- s_test_data
test_dat <- cbind(test_dat,y_test_data)
test_dat <- cbind(test_dat,X_test_data)
test_dat <- tbl_df(test_dat)
#dimensions of test_dat are 2947  563

#merge two sets
my_data <- rbind(train_dat,test_dat)
#dimensions of data are 10299 rows, 563 columns

# name column headings
names(my_data)[1:2] <- c("subject","activity")
names(my_data)[3:563] <- as.character(col_names[,2])

# tidy up- remove non-needed junk
rm(s_test,X_test,y_test,s_train,X_train,y_train,
   s_test_data,X_test_data,y_test_data,s_train_data,
   X_train_data,y_train_data,train_dat,test_dat,col_names)

## now seem to have some duplicate column names. just remove.
my_data <- my_data[,unique(colnames(my_data))]

# now have data nicely combined into a data frame
# next step is to extract only those columnswith 'mean' or 'std' in name
my_data <- select(my_data,matches("subject|activity|mean\\(|std\\("))
# my_data now has dimension 10299 rows, 66 columns
# NOTE did not select any of the meanFreq(), only the mean() and std()

#lets tidy up and arrange by subject
my_data <- arrange(my_data,subject)

#now we want to use descriptive name for activity. activity labels.txt
#tells us:
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING

# the labels for activity are integers- convert to factor then
# read in levels from activity_labels.txt
my_data <- mutate(my_data,activity=as.factor(activity))
levels(my_data$activity) <- activity_names[,2]
rm(activity_names)


#convert to character, lower case
my_data <- mutate(my_data,activity=tolower(as.character(activity)))

# now time to tidy up those nasty headings. 
# replace '-' with '.'
names(my_data) <- gsub("\\-","\\.",names(my_data))
# remove parenthesis
names(my_data) <- gsub("\\(\\)","",names(my_data))
# get rid of repeat 'bodybody' in some column names
names(my_data) <- gsub("fbodybody","fbody",names(my_data))
# cast as lower case
names(my_data) <- tolower(names(my_data))

# the above is steps 1:4. Step 5 can be done with a dplyr one-liner
# to make averaged for each subject and each activity:
tidy_avg <- my_data %>% 
    group_by(subject,activity)%>% 
    summarise_each(funs(mean))

#rename relevant columns
names(tidy_avg) <- gsub("fbody","avg\\.fbody",names(tidy_avg))
names(tidy_avg) <- gsub("tbody","avg\\.tbody",names(tidy_avg))
names(tidy_avg) <- gsub("tgravity","avg\\.tgravity",names(tidy_avg))

#write to tidy_avg.txt in current directory
write.table(tidy_avg, "tidy_avg.txt",row.name=FALSE)

#tidy avg contains 180 rows (180 subjects),
#68 columns (66 readings + activity label + subject label)

# to read back in, use the commands
# test_read <- read.table(file="tidy_avg.txt",header=TRUE)
# test_read <- tbl_df(test_read)
# head(test_read,20)