# getting and cleaning data coursework
## coursework for coursera getting and cleaning data
## note: package dplyr MUST be installed to run script
## refer to the codebook for description of data and analysis performed

The script run_analysis.R should be run after setting the working
directory to the directory that contains the (unzipped) UCI
HAR Dataset directory

One file, tidy_avg.txt will be written after running the script, which 
contains the average of each reading for each subject for each activity.
This can be easily read back into R (ensuring that header=TRUE when read)

After running the R script, the only data frames which exists is my_data, which
is the data set produced from following steps 1-4, and tidy_avg, which contains the data set from step 5. The codebook applies to the data frame tidy_avg

The code works by:

- clean up global environment, load dplyr
- loading the files of interest
- cbinding the training data and test data seperately to two single data frames (use dplyr tbl_df)
- rbinding the test and train data frames to have one complete data frame, my_data
- add the names to the column headings (from features.txt)
- remove duplicate columns
- select only column headings containing 'subject', 'activity', 'mean(' and 'std('
- arrange the data frame by subject
- put a descriptive activity name in activity column- use activity_labels.txt for definition
- clean up column headings
- my_data is now complete, and is retained. this is steps 1-4 in instructions
- to do step 5, set up a dplyr chain
- this chain uses group_by to group by subject and activity, then uses summarise_each to find the mean of the columns for the group. assigns to data frame tidy_avg
- rename the columns to reflect they are now an average, then write to file tidy_avg.txt
