## Group-Level Analysis
# Procedure: 
# 1. Take 1-correlations for each subject, z transform
# 2. Sample 200 times with replacement from all participant's matrices for each within vs. across category; subsample arrays to make them equal in length.
# 3. Compute wilcoxon
# For each test, we look at the correlation between items in each category vs. items outside that category.
# I'm a little unsure about the stability of this measure, so do each analysis 100 times and record the results.


set.seed(42)

meta_table <- data.frame(data = as.factor(0),
                         test = as.factor(0),
                         n = as.double(0),
                         w = as.double(0),
                         CI.low = as.double(0),
                         CI.hi = as.double(0),
                         p = as.double(0))

loss_table <- data.frame(anal = as.character(0),
                        run = as.double(0),
                        test = as.character(0),
                        length = as.double(0),
                        nNAs = as.double(0))

possible.analyses <- list('diss' = all.cor.diss.list,
                          'diss_z'= all.cor.diss.z.list,
                          'corr' = all.cor.list,
                          'corr_z' = all.cor.z.list)

for (a.loop in 2:length(possible.analyses)) {
  
  group.analysis <- unname(possible.analyses[a.loop][[1]])
  name <- names(possible.analyses[a.loop])
  if (a.loop == 1) {label <- 'dissimilarity (1-'
  } else if (a.loop == 2) {label <- 'dissimilarity z(1-'
  } else if (a.loop == 3) {label <- 'similarity ('
  } else if (a.loop == 4) {label <- 'similarity z('}
  for (rep.loop in 1:50) {
    
### -------------------------------------- Ordinal Position
# Within: 
# 1s: (all ones vs. all other ones) nu vs. ro, nu vs. mi, etc.  
# 2s: (all 2s vs. all other twos) ga vs. ki, etc. 
# 3s: (all threes vs. all other threes) di vs. se, etc. 
# ... together 
# 
# Across:
# 1-2s, 2-3s: (crossed positions within words) nu vs. ga, ga vs. di, nu vs. di | basically, word identity

# indices for each matrix
wn.OP <- list(c(1,4),c(1,7),c(1,10),c(4,7),c(4,10),c(7,10), # 1s
             c(2,5),c(2,8),c(2,11),c(5,8),c(5,11),c(8,11), #2s
             c(3,6),c(3,9),c(3,12),c(6,9),c(6,12),c(9,12)) #3s
ac.OP <- list(c(1,2),c(2,3),c(1,3),
              c(4,5),c(5,6),c(4,6), 
             c(7,8),c(7,9),c(8,9),
             c(10,11),c(11,12),c(10,12)) 

# collect values for each of these boxes from all participants (all matrices in the list)
# You can check what's happening here like so: group.analysis[[1]][wn.OP[[i]][1],wn.OP[[i]][2]]
wn.arr <- list()
for (i in 1:length(wn.OP)) {wn.arr <- append(wn.arr, mapply(function(x, y) x[y][2], group.analysis, wn.OP[i], SIMPLIFY = FALSE))} 
ac.arr <- list()
for (i in 1:length(ac.OP)) {ac.arr <- append(ac.arr, mapply(function(x, y) x[y][2], group.analysis, ac.OP[i], SIMPLIFY = FALSE))} 

within.OP <- cbind(wn.arr) %>% as.numeric()
within.OP[mapply(is.infinite, within.OP)] <- NA # clean, in case using z-transform
loss <- length(within.OP[is.na(within.OP)])/length(within.OP)
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                    run = rep.loop,
                                    test = 'within.OP',
                                    length = length(within.OP),
                                    nNAs = length(within.OP[is.na(within.OP)])))
  #stop("Within OP loss too high.")
  }
within.OP <- within.OP[!is.na(within.OP)] # remove NA

across.OP <- cbind(ac.arr) %>% as.numeric()
across.OP[mapply(is.infinite, across.OP)] <- NA
loss <- length(across.OP[is.na(across.OP)])/length(across.OP) 
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                             run = rep.loop,
                                             test = 'across.OP',
                                             length = length(across.OP),
                                             nNAs = length(across.OP[is.na(across.OP)])))
  #stop("Across OP loss too high.")
}
across.OP <- across.OP[!is.na(across.OP)] # remove NA

# compute maximum length
(n.op <- round(min(length(within.OP),length(across.OP))*(4/5)))

# sample & bootstrap to produce a matrix and bootstrapped means
within.OP.samp <- as.numeric(replicate(200, sample(within.OP, size = n.op, replace = TRUE)))
within.OP.means <- replicate(200, mean(sample(within.OP, size = n.op, replace = TRUE), na.rm = TRUE)) 
#length(within.OP.samp)

across.OP.samp <- as.numeric(replicate(200, sample(across.OP, size = n.op, replace = TRUE)))
across.OP.means <- replicate(200, mean(sample(across.OP, size = n.op, replace = TRUE), na.rm = TRUE)) 
#length(across.OP.samp)

(wt.OP <- wilcox.test(within.OP.samp,across.OP.samp, conf.int = TRUE, conf.level = 0.95, paired = TRUE))

meta_table <- rbind(meta_table, 
                    data.frame(data = name, 
                               n = n.op,
                               test = 'ordinal position',
                               w = wt.OP$statistic,
                               CI.low = wt.OP$conf.int[1],
                               CI.hi = wt.OP$conf.int[2],
                               p = wt.OP$p.value))

### ------------------------------------- Transitional Probability
#.33s vs. 1s...

# indices for each matrix
wn.TP <- list(c(1,4),c(1,7),c(1,10),c(4,7),c(4,10),c(7,10)) # low TP
ac.TP <- list(c(2,5),c(2,8),c(2,11),c(5,8),c(5,11),c(8,11), # high TP
             c(3,6),c(3,9),c(3,12),c(6,9),c(6,12),c(9,12))

wn.tp.arr <- list()
for (i in 1:length(wn.TP)) {
  # group.analysis[[1]][wn.OP[[i]][1],wn.OP[[i]][2]]
    wn.tp.arr <- append(wn.tp.arr, mapply(function(x, y) x[y][2], group.analysis, wn.TP[i], SIMPLIFY = FALSE))
} 

ac.tp.arr <- list()
for (i in 1:length(ac.TP)) {
  # group.analysis[[1]][wn.OP[[i]][1],wn.OP[[i]][2]]
    ac.tp.arr <- append(ac.tp.arr, mapply(function(x, y) x[y][2], group.analysis, ac.TP[i], SIMPLIFY = FALSE))
} 

within.TP <- cbind(wn.tp.arr) %>% as.numeric()
within.TP[mapply(is.infinite, within.TP)] <- NA
loss <- length(within.TP[is.na(within.TP)])/length(within.TP)
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                             run = rep.loop,
                                             test = 'within.TP',
                                             length = length(within.TP),
                                             nNAs = length(within.TP[is.na(within.TP)])))
  #stop("Within TP loss too high.")
  }
within.TP <- within.TP[!is.na(within.TP)] # remove NA

across.TP <- cbind(ac.tp.arr) %>% as.numeric()
across.TP[mapply(is.infinite, across.TP)] <- NA
loss <- length(across.TP[is.na(across.TP)])/length(across.TP)
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                             run = rep.loop,
                                             test = 'across.TP',
                                             length = length(across.TP),
                                             nNAs = length(across.TP[is.na(across.TP)])))
  #stop("Across TP loss too high.")
  }
across.TP <- across.TP[!is.na(across.TP)] # remove NA

(n.tp <- round(min(length(within.TP),length(across.TP))*(4/5)))

within.TP.samp <- replicate(200, sample(within.TP, size = n.tp, replace = TRUE)) 
within.TP.means <- replicate(200, mean(sample(within.TP, size = n.tp, replace = TRUE), na.rm = TRUE)) 

across.TP.samp <- replicate(200, sample(across.TP, size = n.tp, replace = TRUE)) 
across.TP.means <- replicate(200, mean(sample(across.TP, size = n.tp, replace = TRUE), na.rm = TRUE)) 

(wt.TP <- wilcox.test(within.TP.samp,across.TP.samp, conf.int = TRUE, conf.level = 0.95, paired = TRUE))

meta_table <- rbind(meta_table, 
                    data.frame(data = name, 
                     n = n.tp,
                     test = 'transitional probability',
                     w = wt.TP$statistic,
                     CI.low = wt.TP$conf.int[1],
                     CI.hi = wt.TP$conf.int[2],
                     p = wt.TP$p.value))

### -------------------------------------------- Triplet Identity
# Within: all comparisons within a words of the form 1-2, 2-3, 1-3
# nu-ga, ga-di, nu-di
# across: "phantom word" comparisons of the form 1-2,2-3,1-3, but only across words
# nu-ki, nu-se

wn.WI <- list(c(1,2),c(2,3),c(1,3),# nugadi
              c(4,5),c(5,6),c(4,6),# rokise
             c(7,8),c(7,9),c(8,9),# mipola
             c(10,11),c(11,12),c(10,12))# zabetu
ac.WI <- list(c(1,5),c(2,6),c(1,6),c(1,8),c(2,9),c(1,9),c(1,11),c(2,12),c(1,12),# nu-ki, ga-se, nu-se, nu-po, ga-la, nu-la, nu-be, ga-tu, nu-tu 
              c(4,2),c(5,3),c(4,3),c(4,8),c(5,9),c(4,9),c(4,11),c(5,12),c(4,12), # ro-ga, ki-di, ro-di, ro-po, ki-la, ro-la, ro-be, ki-tu, ro-tu 
              c(7,2),c(8,3),c(7,3),c(7,5),c(8,6),c(7,6),c(7,11),c(8,12),c(7,12), # mi-ga, po-di, mi-di, mi-ki, po-se, mi-se, mi-be, po-tu, mi-tu
              c(10,2),c(11,3),c(10,3),c(11,5),c(10,6),c(11,6),c(10,8),c(11,9),c(10,9)) # za-ga, be-di, za-di, za-ki, be-ki, za-se, za-po, be-la, za-la 

wn.WI.arr <- list()
for (i in 1:length(wn.WI)) {
    wn.WI.arr <- append(wn.WI.arr, mapply(function(x, y) x[y][2], group.analysis, wn.WI[i], SIMPLIFY = FALSE))
} 

ac.WI.arr <- list()
for (i in 1:length(ac.WI)) {
    ac.WI.arr <- append(ac.WI.arr, mapply(function(x, y) x[y][2], group.analysis, ac.WI[i], SIMPLIFY = FALSE))
} 

within.WI <- cbind(wn.WI.arr) %>% as.numeric()
within.WI[mapply(is.infinite, within.WI)] <- NA
loss <- length(within.WI[is.na(within.WI)])/length(within.WI)
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                             run = rep.loop,
                                             test = 'within.WI',
                                             length = length(within.WI),
                                             nNAs = length(within.WI[is.na(within.WI)])))
  #stop("Within WI loss too high.")
  }
within.WI <- within.WI[!is.na(within.WI)] # remove NA

across.WI <- cbind(ac.WI.arr) %>% as.numeric()
across.WI[mapply(is.infinite, across.WI)] <- NA
loss <- length(across.WI[is.na(across.WI)])/length(across.WI)
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                             run = rep.loop,
                                             test = 'across.WI',
                                             length = length(across.WI),
                                             nNAs = length(across.WI[is.na(across.WI)])))
  #stop("Across WI loss too high.")
  }
across.WI <- across.WI[!is.na(across.WI)] # remove NA

(n.wi <- round(min(length(within.WI),length(across.WI))*(4/5)))

within.WI.samp <- replicate(200, sample(within.WI, size = n.wi, replace = TRUE)) 
within.WI.means <- replicate(200, mean(sample(within.WI, size = n.wi, replace = TRUE), na.rm = TRUE)) 

across.WI.samp <- replicate(200, sample(across.WI, size = n.wi, replace = TRUE)) 
across.WI.means <- replicate(200, mean(sample(across.WI, size = n.wi, replace = TRUE), na.rm = TRUE)) 

(wt.WI <- wilcox.test(within.WI.samp,across.WI.samp, conf.int = TRUE, conf.level = 0.95, paired = TRUE))

meta_table <- rbind(meta_table, 
                    data.frame(data = name,   
                      n = n.wi,
                     test = 'word identity',
                     w = wt.WI$statistic,
                     CI.low = wt.WI$conf.int[1],
                     CI.hi = wt.WI$conf.int[2],
                     p = wt.WI$p.value))


### -------------------------------------------- Duplet Identity
# Within: All proper duplets, 1-2s, 2-3s
# Across: 1-3's

wn.di <- list(c(1,2),c(2,3),
              c(4,5),c(5,6),
              c(7,8),c(7,9),
              c(10,11),c(11,12))
ac.di <- list(c(1,3),c(4,6),c(8,9),c(10,12))


wn.di.arr <- list()
for (i in 1:length(wn.di)) {
  wn.di.arr <- append(wn.di.arr, mapply(function(x, y) x[y][2], group.analysis, wn.di[i], SIMPLIFY = FALSE))
} 

ac.di.arr <- list()
for (i in 1:length(ac.di)) {
  ac.di.arr <- append(ac.di.arr, mapply(function(x, y) x[y][2], group.analysis, ac.di[i], SIMPLIFY = FALSE))
} 

within.di <- cbind(wn.di.arr) %>% as.numeric()
within.di[mapply(is.infinite, within.di)] <- NA
loss <- length(within.di[is.na(within.di)])/length(within.di)
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                             run = rep.loop,
                                             test = 'within.di',
                                             length = length(within.di),
                                             nNAs = length(within.di[is.na(within.di)])))
  #stop("Within DI loss too high.")
  }
within.di <- within.di[!is.na(within.di)] # remove NA

across.di <- cbind(ac.di.arr) %>% as.numeric()
across.di[mapply(is.infinite, across.di)] <- NA
loss <- length(across.di[is.na(across.di)])/length(across.di)
if (loss > 0.1) {
  loss_table <- rbind(loss_table, data.frame(anal = name,
                                             run = rep.loop,
                                             test = 'across.di',
                                             length = length(across.di),
                                             nNAs = length(across.di[is.na(across.di)])))
  #stop("Across DI loss too high.")
  }
across.di <- across.di[!is.na(across.di)] # remove NA

(n.di <- round(min(length(within.di),length(across.di))*(4/5)))

within.di.samp <- replicate(200, sample(within.di, size = n.di, replace = TRUE))
within.di.means <- replicate(200, mean(sample(within.di, size = n.di, replace = TRUE), na.rm = TRUE))

across.di.samp <- replicate(200, sample(across.di, size = n.di, replace = TRUE))
across.di.means <- replicate(200, mean(sample(across.di, size = n.di, replace = TRUE), na.rm = TRUE))

(wt.DI <- wilcox.test(within.di.samp,across.di.samp, conf.int = TRUE, conf.level = 0.95, paired = TRUE))

meta_table <- rbind(meta_table, 
                    data.frame(data = name, 
                               n = n.di,  
                               test = 'duplet identity',
                               w = wt.DI$statistic,
                               CI.low = wt.DI$conf.int[1],
                               CI.hi = wt.DI$conf.int[2],
                               p = wt.DI$p.value))

# --------------------------------------------------
WA.wilcox <- data.frame(test = factor(c(
  "ordinal position",
  "transitional probability",
  "word identity",
  "duplets"), levels = c("ordinal position","transitional probability","word identity","duplets")),
  mean = as.numeric(c(mean(within.OP.means)-mean(across.OP.means),
                      mean(within.TP.means)-mean(across.TP.means),
                      mean(within.WI.means)-mean(across.WI.means),
                      mean(within.di.means)-mean(across.di.means))),
  w = as.numeric(c(
    wt.OP$statistic,
    wt.TP$statistic,
    wt.WI$statistic,
    wt.DI$statistic)),
  "CI low" = as.numeric(c(
    wt.OP$conf.int[1],
    wt.TP$conf.int[1],
    wt.WI$conf.int[1],
    wt.DI$conf.int[1])),
  "CI hi" = as.numeric(c(
    wt.OP$conf.int[2],
    wt.TP$conf.int[2],
    wt.WI$conf.int[2],
    wt.DI$conf.int[2])),
  p = as.numeric(c(
    wt.OP$p.value,
    wt.TP$p.value,
    wt.WI$p.value,
    wt.DI$p.value)))

write.csv(WA.wilcox,file.path(res_path,paste0('/paired_wilcoxon_100runs/wilcox_',name,'_run',rep.loop,'.csv')), row.names = FALSE)



### --------------------------------------------------------------- Plot

ggplot(WA.wilcox) + 
  geom_col(aes(test,mean), fill = "grey", color = "black") + 
  geom_hline(yintercept = 0, color = "black", linetype="dashed") + 
  scale_x_discrete(name = NULL) + 
  scale_y_continuous(name = paste0("within - across ", label ,"Pearson's r)")) +
  # annotate(geom = "text", x = 1, y = -0.015, size = 4, label = "***") +
  # annotate(geom = "text", x = 2, y = 0.0135, size = 4, label = "***") +
  # annotate(geom = "text", x = 4, y = -0.064, size = 4, label = "***") +
  theme_classic() + 
  theme(text = element_text(family = "LM Roman 10", face="bold")) #+
ggsave(file.path(fig_path, paste0('/paired_wilcoxon_100runs/fig9_',name,'_run',rep.loop,'.png')), width = 7, height = 5)  

    
  } # end rep.loop
} # end a.loop

# ------------------------------------------------------------


meta_table <- meta_table[-1,]
write_csv(meta_table,file.path(fig_path, paste0('paired_wilcoxon_100runs/meta_table_allruns.csv')))



loss_table <- loss_table[-1,]
write_csv(loss_table,file.path(fig_path,paste0('paired_wilcoxon_100runs/loss_table_allruns.csv')))



