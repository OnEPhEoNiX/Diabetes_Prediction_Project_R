#LIBRARIES
#These libraries are commonly used for data manipulation and splitting data sets.
library(caret)
library(dplyr)
library(tidyr)
library(caTools)
library(zoo)
library(e1071)
library(ggplot2)
library(reshape2)

theme_set(theme_classic())

# loading the diabetes dataset to a dataframe
diabetes.dataset <- read.csv("C:\\Users\\Mohak\\Desktop\\diabetes.csv")

#Plotting the data distribution plots before removing null values
ggplot(melt(diabetes.dataset), aes(value)) + 
  geom_histogram(aes(fill = variable), alpha = 0.5, binwidth = 5) + 
  facet_wrap(~ variable, scales = "free") + 
  ggtitle("Histogram of all features before cleaning") + 
  xlab("Value") + ylab("Frequency")

#DATA CLEANING
# Remove duplicates
diabetes.cleaned <- distinct(diabetes.dataset)
# Impute missing values using mean imputation
diabetes.cleaned <- na.aggregate(diabetes.dataset, FUN = mean)

#Plotting the data distribution plots after cleaning
ggplot(melt(diabetes.cleaned), aes(value)) + 
  geom_histogram(aes(fill = variable), alpha = 0.5, binwidth = 5) + 
  facet_wrap(~ variable, scales = "free") + 
  ggtitle("Histogram of all features after cleaning") + 
  xlab("Value") + ylab("Frequency")

# compute the correlation matrix
cor_mat <- cor(diabetes.cleaned)

# plot the correlation matrix using ggplot2 and corrplot libraries
ggplot(melt(cor_mat), aes(x = Var1, y = Var2, fill = value)) + 
  geom_tile() + 
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1,1), space = "Lab", name = "Correlation") + 
  theme_minimal() + 
  coord_fixed() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 10, hjust = 1)) + 
  ggtitle("Correlation plot of all features")

# convert Outcome to a factor
diabetes.cleaned$Outcome <- as.factor(diabetes.cleaned$Outcome)

# number of rows and columns in the dataset
dim(diabetes.cleaned)

# getting the statistical measures of the data
summary(diabetes.cleaned)

# value counts of 'Outcome' column
table(diabetes.cleaned$Outcome)

# mean of 'Outcome' column based on diabetes status
diabetes.cleaned %>% 
  group_by(Outcome) %>% 
  summarize_all(mean)

# separating the data and labels
X <- diabetes.cleaned %>% 
select(-Outcome)

Y <- diabetes.cleaned$Outcome

# standardizing the data
scaler <- preProcess(X, method = c("center", "scale"))
standardized_data <- predict(scaler, X)

# splitting the dataset into training and testing sets
set.seed(2)
index <- createDataPartition(Y, p = 0.8, list = FALSE)
train_X <- standardized_data[index, ]
test_X <- standardized_data[-index, ]
train_Y <- Y[index]
test_Y <- Y[-index, drop = TRUE]  # drop = TRUE to keep the class as a factor

# training the SVM classifier
classifier <- svm(train_X, train_Y, kernel = "linear")

# accuracy score on the training data
train_pred <- predict(classifier, train_X)
train_accuracy <- confusionMatrix(train_pred, train_Y)$overall["Accuracy"]
cat("Accuracy score of the training data:", train_accuracy*100,0,"%", "\n")

# accuracy score on the test data
test_pred <- predict(classifier, test_X)
test_accuracy <- confusionMatrix(test_pred, test_Y)$overall["Accuracy"]
cat("Accuracy score of the test data:", test_accuracy*100,"%", "\n")

# input data for prediction
input_data <- data.frame(
  Pregnancies = 5,
  Glucose = 150,
  BloodPressure = 72,
  SkinThickness = 19,
  Insulin = 175,
  BMI = 50,
  DiabetesPedigreeFunction = 0.587,
  Age =40
)

# standardize the input data
std_input_data <- predict(scaler, input_data)

# predict diabetes status for input data
prediction <- predict(classifier, std_input_data)

if (prediction == 0) {
  cat("The person is not diabetic\n")
} else {
  cat("The person is diabetic\n")
}

