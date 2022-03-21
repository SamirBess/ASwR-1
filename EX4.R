library(randomForest)
library(parallel)
data(LetterRecognition, package = "mlbench")
set.seed(seed = 123, "L'Ecuyer-CMRG")

n = nrow(LetterRecognition)
n_test = floor(0.2 * n)
i_test = sample.int(n, n_test)
train = LetterRecognition[-i_test, ]
test = LetterRecognition[i_test, ]

ntree = 200
nfolds = 10
mtry_val = 1:(ncol(train) - 1)
folds = sample( rep_len(1:nfolds, nrow(train)), nrow(train) )
cv_df = data.frame(mtry = mtry_val, incorrect = rep(0, length(mtry_val)))
cv_pars = expand.grid(mtry = mtry_val, f = 1:nfolds)
fold_err = function(i, cv_pars, folds, train) {
  mtry = cv_pars[i, "mtry"]
  fold = (folds == cv_pars[i, "f"])
  rf.all = randomForest(lettr ~ ., train[!fold, ], ntree = ntree,
                        mtry = mtry, norm.votes = FALSE)
  pred = predict(rf.all, train[fold, ])
  sum(pred != train$lettr[fold])
}

nc = as.numeric(commandArgs(TRUE)[1])
nc2 = as.numeric(commandArgs(TRUE)[2])
nc3 = as.numeric(commandArgs(TRUE)[3])
#nc4 = as.numeric(commandArgs(TRUE)[4])

cat("CV running with", nc, "cores, first random forest with ", nc2, "cores and CV opt. random forest with ", nc3, "cores.")
system.time({
  #parallelization 1
  cv_err = parallel::mclapply(1:nrow(cv_pars), fold_err, cv_pars, folds = folds,
                              train = train, mc.cores = nc) 
  err = tapply(unlist(cv_err), cv_pars[, "mtry"], sum)
  pdf(paste0("rf_cv_mc", nc, ".pdf")); plot(mtry_val, err/(n - n_test)); dev.off()
  
  #parallelization 2 -RF 
  ntree1 = lapply(splitIndices(ntree, nc2), length)
  rf = function(x) randomForest(lettr ~ ., train, ntree=x, norm.votes = FALSE)
  rf.out = mclapply(ntree1, rf, mc.cores = nc2)
  rf.all = do.call(combine, rf.out)
  
  #rf.all = randomForest(lettr ~ ., train, ntree = ntree)
  
  
  #parallelization 4 -PREDICTION(here + down below for second forest) <== NOT USED AT THE END
  #crows = splitIndices(nrow(test), nc4) 
  #rfp = function(x) as.vector(predict(rf.all, test[x, ])) 
  #cpred = mclapply(crows, rfp, mc.cores = nc4) 
  #pred = do.call(c, cpred) 
  
  pred = predict(rf.all, test)
  
  correct = sum(pred == test$lettr)
  
  mtry = mtry_val[which.min(err)]
  
  #parallelization 3 -RF
  ntree2 = lapply(splitIndices(ntree, nc3), length)
  rf2 = function(x) randomForest(lettr ~ ., train, ntree=x, mtry = mtry, norm.votes = FALSE)
  rf.out = mclapply(ntree2, rf, mc.cores = nc3)
  rf.all = do.call(combine, rf.out)
  
  
  #cpred = mclapply(crows, rfp, mc.cores = nc4) 
  #pred_cv = do.call(c, cpred)
  pred_cv = predict(rf.all, test)
  correct_cv = sum(pred_cv == test$lettr)
})[3]
cat("Proportion Correct: ", correct/n_test, "(mtry = ", floor((ncol(test) - 1)/3),
    ") with cv:", correct_cv/n_test, "(mtry = ", mtry, ")\n", sep = "")

