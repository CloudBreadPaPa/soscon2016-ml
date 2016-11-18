###################################
#디에스이트레이드 이성희 박사님과 강희재 소장님이 공유해 주신 R 코드 파일
###################################

###################################
########## 군 집 분 석 ############
###################################
# install.packages("caret")
# install.packages("fastcluster")
library(caret)
library(fastcluster)

# 표준화
training_data <- scale(iris[ ,-5]) #Species 데이터 제거(숫자형변수x)
summary(training_data)


# 군집수 결정 
## 패키지 사용 (최적의 combination을 통해 선택)
# install.packages("NbClust")
# library(NbClust)
# 
# nc <- NbClust(training_data, min.nc=2, max.nc=15, method="kmeans")
# barplot(table(nc$Best.n[1,]),  xlab="Numer of Clusters", ylab="Number of Criteria", main="Number of Clusters Chosen")

## sum of squares 제일 작아 지는 지점 탐색
# wss <- NULL
# for(i in 1:7){
#   wss[i] = kmeans(training_data, centers=i)$tot.withinss
# }
# i=1:7
# plot(i,wss);lines(i,wss);


set.seed(100)
##### k-means (비계층적) 군집분석 ######
# 모델링 (군집개수-3개분류)
iris_kmeans <- kmeans(training_data, centers=3, iter.max=10000)
iris_kmeans$cluster <- as.factor(iris_kmeans$cluster) #Rownumber별 군집 매핑 값

table(iris_kmeans$cluster)
table(iris$Species, iris_kmeans$cluster) #virginica는 잘 분류해 내지만, 그 외는 변별력 약함.

plot(iris[c("Sepal.Length", "Sepal.Width")], col=iris_kmeans$cluster)


set.seed(0)
##### Hierarchical - hcluster (계층적) 군집분석 ######
# 모델링
hc <- hclust(dist(training_data), method="ave") #Row간 거리 계산

# plot(hc, hang=-1, labels=iris$Species)
# rect.hclust(hc, k=3)  #3개의 클러스터 표현

groups <- cutree(hc, k=3) #3개의 클러스터로 표현
table(groups)

table(iris$Species, groups) #setosa는 잘 분류해 내지만, 그 외는 변별력 약함.



###################################
########## D-TREE 분 석 ###########
###################################
# install.packages("party")
library(party)

set.seed(2)
# train / test 분할
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.7,0.3))
trainData <- iris[ind==1, ]
testData <- iris[ind==2, ]

# 모델링
formula <- Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
iris_ctree <- ctree(formula, data=trainData)

plot(iris_ctree)

# test 예측
ctreepred <- predict(iris_ctree, newdata=testData)
table(testData$Species, ctreepred)



###################################
##### 로 지 스 틱 회 귀 분 석 #####
###################################
# install.packages("glm2")
library(glm2)

# target 변수 2개 범주로만 선택 (범주형변수로변환)
adj_iris <- iris
adj_iris$Species <- as.character(adj_iris$Species)
adj_iris <- subset(adj_iris, Species %in% c('versicolor', 'virginica'))
adj_iris$Species <- as.factor(adj_iris$Species)

set.seed(10)
# train / test 분할
ind <- sample(2, nrow(adj_iris), replace=TRUE, prob=c(0.7,0.3))
trainData <- adj_iris[ind==1, ]
testData <- adj_iris[ind==2, ]

# 모델링
formula <- Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
iris_logit <- glm(formula, data=trainData, family=binomial()) 
#일반선형모형(GLM)이 아닌 로지스틱 회귀를 실행하기 위해, R 프로그램에 family=binomial 이란 옵션을 설정해야 하는 것

# test 예측
#data.frame(adj_iris$Species, as.numeric(adj_iris$Species)-1) #versicolor=0, virginica=1

logitpred_a <- predict(iris_logit, newdata=testData, type="response")
logitpred <- ifelse(logitpred_a>=0.5, "virginica", "versicolor")

table(testData$Species , logitpred)



###################################
##### H2O Deeplearning 분 석 ######
###################################
# install.packages("h2o")
library(h2o)

h2o.init()

set.seed(4)
iris.hex <- as.h2o(iris)

# 모델링
iris_dl <- h2o.deeplearning(x = 1:4, y = 5, training_frame = iris.hex, activation = "Tanh", hidden = c(10, 10)) #x:인풋변수, y:타겟변수

# 예측
predictions <- h2o.predict(iris_dl, iris.hex)
predictions <- as.data.frame(predictions)

table(iris$Species, predictions$predict)







# ###################################
# ##### ANN (인공신경망) 분 석 ######
# ###################################
# # install.packages("nnet")
# library(nnet)
# 
# set.seed(3)
# # train / test 분할
# ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.7,0.3))
# trainData <- iris[ind==1, ]
# testData <- iris[ind==2, ]
# 
# # 모델링
# formula <- Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
# iris_nnet <- nnet(formula, data=trainData, size=3) #size : hidden layer
# 
# # test 예측
# nnetpred <- predict(iris_nnet, newdata=testData, type="class")
