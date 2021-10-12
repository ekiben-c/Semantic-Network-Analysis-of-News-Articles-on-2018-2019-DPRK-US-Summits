library(arules)
library(data.table)
library(igraph)

text = #put data here
text = text$X0

length(text)

lword = strsplit(text," ")
lword = unique(lword)
lword = sapply(lword, unique)

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

tranrules = apriori(wordtrain, parameter = list(conf = 0.01, minlen = 2, maxlen = 2))
# temp = inspect(tranrules)
# 
# write.csv(as.data.frame(temp),'US_article_3rd_res.csv')

rules = labels(tranrules, ruleSep = " ")
rules = sapply(rules, strsplit, " ",  USE.NAMES=F) 


rulemat = do.call('rbind',rules)
nrow(rulemat)

rulemat = rulemat[rulemat[,1] %in% c('{sanction}', '{peac}', '{denuclear}') | rulemat[,2] %in% c('{sanction}', '{peac}', '{denuclear}'),]
nrow(rulemat)

ruleg = graph.edgelist(rulemat, directed=F)
clust = cluster_louvain(ruleg)
unique(clust$membership)
prettyColors <- c("turquoise4", "azure4", "olivedrab","deeppink4",'royalblue')
communityColors <- prettyColors[membership(clust)]

V(ruleg)$membership <- membership(clust)
V(ruleg)$names = names(V(ruleg))
V(ruleg)$color = "grey"
V(ruleg)$frame = "black"
V(ruleg)$vertexsize = 15
V(ruleg)$labelsize = 0.8

V(ruleg) [ membership == 1 ]$color <- prettyColors[1] 
V(ruleg) [ membership == 2 ]$color <- prettyColors[2]
V(ruleg) [ membership == 3 ]$color <- prettyColors[3]
V(ruleg) [ membership == 4 ]$color <- prettyColors[4]
V(ruleg) [ membership == 5 ]$color <- prettyColors[5]
V(ruleg) [ membership == 6 ]$color <- "red" 
V(ruleg) [ names %in% c('{sanction}', '{peac}', '{denuclear}') ]$frame = 'red'
V(ruleg) [ names %in% c('{sanction}', '{peac}', '{denuclear}') ]$vertexsize = 30
V(ruleg) [ names %in% c('{sanction}', '{peac}', '{denuclear}') ]$labelsize = 2


tkplot(ruleg, vertex.label=V(ruleg)$name,
       vertex.label.cex=V(ruleg)$labelsize, vertex.label.color='black', 
       layout = layout.fruchterman.reingold,
       vertex.size=V(ruleg)$vertexsize, vertex.color=V(ruleg)$color, vertex.frame.color=V(ruleg)$frame,
       edge.arrow.size=0.5)
