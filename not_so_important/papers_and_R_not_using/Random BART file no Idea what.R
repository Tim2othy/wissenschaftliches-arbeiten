bart(
  x.train, y.train, x.test = matrix(0.0, 0, 0),
  sigest = NA, sigdf = 3, sigquant = 0.90,
  k = 2.0,
  power = 2.0, base = 0.95, splitprobs = 1 / numvars,
  binaryOffset = 0.0, weights = NULL,
  ntree = 200,
  ndpost = 1000, nskip = 100,
  printevery = 100, keepevery = 1, keeptrainfits = TRUE,
  usequants = FALSE, numcut = 100, printcutoffs = 0,
  verbose = TRUE, nchain = 1, nthread = 1, combinechains = TRUE,
  keeptrees = FALSE, keepcall = TRUE, sampleronly = FALSE,
  seed = NA_integer_,
  proposalprobs = NULL,
  keepsampler = keeptrees)
bart2(
  formula, data, test, subset, weights, offset, offset.test = offset,
  sigest = NA_real_, sigdf = 3.0, sigquant = 0.90,
  k = NULL,
  power = 2.0, base = 0.95, split.probs = 1 / num.vars,
  n.trees = 75L,
  n.samples = 500L, n.burn = 500L,
  n.chains = 4L, n.threads = min(dbarts::guessNumCores(), n.chains),
  combineChains = FALSE,
  n.cuts = 100L, useQuantiles = FALSE,
  n.thin = 1L, keepTrainingFits = TRUE,
  printEvery = 100L, printCutoffs = 0L,
  verbose = TRUE, keepTrees = FALSE, 
  keepCall = TRUE, samplerOnly = FALSE,
  seed = NA_integer_,
  proposal.probs = NULL,
  keepSampler = keepTrees,
  ...)

# S3 method for bart
plot(
  x,
  plquants = c(0.05, 0.95), cols = c('blue', 'black'),
  ...)

# S3 method for bart
predict(
  object, newdata, offset, weights,
  type = c("ev", "ppd", "bart"),
  combineChains = TRUE, ...)

extract(object, ...)
# S3 method for bart
extract(
  object,
  type = c("ev", "ppd", "bart", "trees"),
  sample = c("train", "test"),
  combineChains = TRUE, ...)

# S3 method for bart
fitted(
  object,
  type = c("ev", "ppd", "bart"),
  sample = c("train", "test"),
  ...)

# S3 method for bart
residuals(object, ...)