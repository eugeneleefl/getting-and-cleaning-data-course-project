##load dplyr package
library(dplyr)

##read subject data from training set and read x_train and y_train data sets
subject_train<-read.table('./train/subject_train.txt')
subject_train<-rename(subject_train,subject=V1)
x_train<-read.table('./train/X_train.txt')
y_train<-read.table('./train/y_train.txt')

##read activity labels and label the columns with label 1-6 and the corresponding activity
activity_labels<-read.table('./activity_labels.txt')
activity_labels<-rename(activity_labels,label=V1,activity=V2)

##read feature labels
feature<-read.table('./features.txt')
##insert column names for x_train and y_train
colnames(x_train)<-feature$V2
y_train<-rename(y_train,label=V1)

##subset the means and std from x_train dataset
x_train_mean<-x_train[,grepl('-mean()',colnames(x_train))]
x_train_std<-x_train[,grepl('-std()',colnames(x_train))]

##create data frame
data_train<-data.frame(subject_train,x_train_mean,x_train_std,y_train)

##repeat above process for test data
subject_test<-read.table('./test/subject_test.txt')
subject_test<-rename(subject_test,subject=V1)
x_test<-read.table('./test/X_test.txt')
y_test<-read.table('./test/y_test.txt')
colnames(x_test)<-feature$V2
y_test<-rename(y_test,label=V1)
x_test_mean<-x_test[,grepl('-mean()',colnames(x_test))]
x_test_std<-x_test[,grepl('-std()',colnames(x_test))]
data_test<-data.frame(subject_test,x_test_mean,x_test_std,y_test)

##merge data to form final tidy data set
tidy_data<-rbind(data_train,data_test)

##replace activity label with activity
tidy_data2 <- merge(x = tidy_data, y = activity_labels, by = 'label', all = TRUE)
tidy_data3<-tidy_data2[,-1]
tidy_data4<-arrange(tidy_data3,subject)

library(reshape2)
tidy_data_melt <- melt(tidy_data4, id = c('subject', 'activity'), measure.vars = colnames(tidy_data4)[2:80])
tidy_data_melt <- tidy_data_melt[order(tidy_data_melt$subject, tidy_data_melt$activity), ]

library(plyr)
final_tidy_data<- ddply(tidy_data_melt, .(subject, activity, variable), summarize, mean = mean(value))

##output txt file
write.table(final_tidy_data,'tidy_data.txt',row.name=FALSE)
