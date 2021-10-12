library(arules)
library(data.table)
library(igraph)

files_list = list.files(pattern = '*.csv')

quiet <- function(x) { 
  sink(tempfile()) 
  on.exit(sink()) 
  invisible(force(x)) 
} 

iter = 1

cs_out = c()

for (iter in 1:length(files_list)){
  
  text = read.csv(files_list[iter],stringsAsFactors = F)
  text = text$X0
  
  text = gsub('조선중앙',"",text)
  text = gsub("통신","",text)
  
  
  lword = strsplit(text," ")
  lword = unique(lword)
  lword = sapply(lword, unique)
  lword_df = data.frame(table(unlist(lword)),stringsAsFactors = F)
  filter1 = function(x){
    nchar(x) >= 2
  }
  
  filter2 = function(x){
    Filter(filter1, x)
  }
  
  lword = sapply(lword, filter2)
  
  wordtrain = as(lword, 'transactions')
  
  #inspect(wordtrain)
  
  wordtable = crossTable(wordtrain)
  
  tranrules = quiet(apriori(wordtrain, parameter = list(conf = 0.95, minlen = 2, maxlen = 2)))
  temp = quiet(inspect(tranrules))
  #write.csv(as.data.frame(temp),'NK_article_3rd_chosun_res.csv')
  
  rules = labels(tranrules, ruleSep = " ")
  rules = sapply(rules, strsplit, " ",  USE.NAMES=F) 
  
  
  rulemat = do.call('rbind',rules)
  nrow(rulemat)
  
  #rulemat = rulemat[rulemat[,1] %in% c('{제재}', '{평화}', '{비핵화}') | rulemat[,2] %in% c('{제재}', '{평화}', '{비핵화}'),]
  nrow(rulemat)
  
  ruleg = graph.edgelist(rulemat, directed=F)
  # clust = cluster_louvain(ruleg)
  # unique(clust$membership)
  prettyColors <- c("turquoise4", "azure4", "olivedrab","deeppink4",'royalblue')
  # communityColors <- prettyColors[membership(clust)]
  
  # V(ruleg)$membership <- membership(clust)
  V(ruleg)$names = names(V(ruleg))
  V(ruleg)$color = "grey"
  V(ruleg)$frame = "black"
  V(ruleg)$vertexsize = 2.5
  V(ruleg)$labelsize = 0.5
  
  closeness_out = betweenness(ruleg, v = V(ruleg),normalized = T)
  closeness_out = data.frame(sort(closeness_out, decreasing = T))
  
  closeness_out$word = rownames(closeness_out)
  rownames(closeness_out) = NULL
  
  lword_df$Var1 = as.character(lword_df$Var1)
  colnames(lword_df)[1] = 'word'
  colnames(closeness_out)[1] = 'betweenness_normalized'
  closeness_out$word = gsub('\\{','',closeness_out$word)
  closeness_out$word = gsub('}','',closeness_out$word)
  
  df_out = merge(lword_df, closeness_out, by = 'word')
  df_out = df_out[order(df_out$betweenness_normalized, decreasing = T),]
  
  V(ruleg) [ names %in% c('{제재}', '{평화}', '{비핵화}') ]$frame = 'red'
  V(ruleg) [ names %in% c('{제재}', '{평화}', '{비핵화}') ]$vertexsize = 20
  V(ruleg) [ names %in% c('{제재}', '{평화}', '{비핵화}') ]$labelsize = 3
  
  
  V(ruleg) [ names %in% '{제재}']$color = prettyColors[1] 
  V(ruleg) [ names  %in% '{평화}']$color = prettyColors[4] 
  V(ruleg) [ names  %in% '{비핵화}']$color = prettyColors[3] 
  
  sum(temp$lhs == '{제재}')
  sum(temp$lhs == '{평화}')
  sum(temp$lhs == '{비핵화}')
  
  
  par(family = 'AppleGothic')
  
  png(paste(files_list[iter],'.png',sep=''), width = 2000, height =1500)
  layout = layout.fruchterman.reingold(ruleg)
  plot(ruleg, vertex.label=V(ruleg)$name,
       vertex.label.cex=V(ruleg)$labelsize, vertex.label.color='black', 
       layout = layout,
       vertex.size=V(ruleg)$vertexsize, vertex.color=V(ruleg)$color, vertex.frame.color=V(ruleg)$frame,
       edge.arrow.size=0.5)

  dev.off()
  
  write.csv(df_out,paste(files_list[iter],'_CS.csv',sep=''))
  
  cs_out = c(cs_out,
             closeness_out[names(closeness_out) == '{제재}'],
             closeness_out[names(closeness_out) == '{평화}'],
             closeness_out[names(closeness_out) == '{비핵화}'])
  
}

temp_mat = matrix(cs_out, byrow = T, ncol = 3)
rownames(temp_mat) = files_list
temp_mat
  