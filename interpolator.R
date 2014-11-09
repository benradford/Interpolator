library(fields)
library(reshape2)

random.colors <- function(row.n, col.n, n)
{
  
  random.r <- sample(0:255, n, replace=T)/255
  random.g <- sample(0:255, n, replace=T)/255
  random.b <- sample(0:255, n, replace=T)/255
  random.row <- sample(1:row.n, n, replace=T)
  random.col <- sample(1:col.n, n, replace=T)
  
  dedup <- !duplicated(paste(random.row,random.col,sep=" - "))
  
  starting.colors <- data.frame(row=random.row, col=random.col, red=random.r, green=random.g, blue=random.b) 
  starting.colors <- starting.colors[dedup,]
  starting.colors$color <- rgb(red=starting.colors$red, green=starting.colors$green, blue=starting.colors$blue)
  
  return(starting.colors)
}

random.picture <- function(row.n=10, col.n=10, starting.colors, exponent=1, interpolate=F, highlight=F)
{
  
  starting.matrix <- data.frame(row=rep(1:row.n, times=col.n), col=sort(rep(1:col.n, times=row.n)))
  starting.matrix <- merge(starting.matrix, starting.colors[,c("row","col","color")], by=c("row","col"), all.x=T, all.y=F)
  starting.matrix <- acast(starting.matrix, row~col, value.var="color")
  
  image <- data.frame(row=rep(1:row.n, times=col.n), col=sort(rep(1:col.n, times=row.n)))
  image <- image[!paste(image$row,image$col,sep="-")%in%paste(starting.colors$row,starting.colors$col,sep="-"),]
  
  dist.matrix <- as.matrix(rdist(image[,c("col","row")],starting.colors[,c("col","row")]))
  dist.matrix <- 1/(dist.matrix^exponent)
  dist.matrix <- (dist.matrix)/rowSums(dist.matrix)
  
  image$red.new <- (dist.matrix %*% starting.colors$red)
  image$green.new <- (dist.matrix %*% starting.colors$green)
  image$blue.new <- (dist.matrix %*% starting.colors$blue)
  
  image$color <- rgb(red=image$red.new, green=image$green.new, blue=image$blue.new, alpha=1, maxColorValue=1)
  image.matrix <- acast(image, row~col, value.var="color", interpolate=F)
  
  par(mar=c(0,0,0,0))
  plot(0,0,type="n",xlim=c(0,col.n),ylim=c(0,row.n), xlab="", ylab="", xaxt="n", yaxt="n", frame=F, xaxs="i", yaxs="i")
  rasterImage(image.matrix, xleft=0, ybottom=row.n, xright=col.n, ytop=0, interpolate=interpolate)
  rasterImage(starting.matrix, xleft=0, ybottom=row.n, xright=col.n, ytop=0, interpolate=F)
  
  if(highlight==T)
  {
    starting.colors$border <- ifelse((0.299*starting.colors$red + 0.587*starting.colors$green + 0.114*starting.colors$blue)>0.5,"#000000","#FFFFFF")
    rect(starting.colors$col-1, starting.colors$row-1, starting.colors$col, starting.colors$row, col=NA, border=starting.colors$border)
  }
}

row.n <- 1
col.n <- 25
n.col <- 2
my.colors <- random.colors(row.n, col.n, n.col)
par(mfrow=c(col.n,1),mar=c(0,0,0,0))
for(ii in seq(-5,5,length.out=col.n))
  random.picture(row.n=row.n, col.n=col.n, starting.colors=my.colors, exponent=ii, interpolate=F, highlight=F)

par(mfrow=c(1,1))
row.n <- 6
col.n <- 16
n.col <- 3
my.colors <- random.colors(row.n, col.n, n.col)
random.picture(row.n=row.n, col.n=col.n, starting.colors=my.colors, exponent=2, interpolate=F, highlight=F)