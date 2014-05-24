
## Prerequisites ----
suppressPackageStartupMessages(library("ggplot2"))
#suppressPackageStartupMessages(library("grid"))
#suppressPackageStartupMessages(library("gridExtra"))
suppressPackageStartupMessages(library("reshape2"))
suppressPackageStartupMessages(library("tools"))
#suppressPackageStartupMessages(library("parallel"))
#suppressPackageStartupMessages(library("foreach"))
#suppressPackageStartupMessages(library("iterators"))
#suppressPackageStartupMessages(library("doParallel"))

## Preparations ----
printf <- function(format, ...) print(sprintf(format, ...))

rename <- function(v) {
  result <- vector(length=length(v))
  for ( ii in 1:length(v)) {
    name <- v[ii]
    if (name == "Empty") result[ii] <- "Empty"
    else if (name == "Identity") result[ii] <- "JNIF Identity"
    else if (name == "Compute") result[ii] <- "JNIF Frames"
    else if (name == "ClientServer") result[ii] <- "ASM Frames"
    else result[ii] <- name
  }
  return (result)
}

## Arguments and output file ----
argv <- commandArgs(trailingOnly = TRUE)
csvfilename <- '../build/eval.prof'
csvfilename <- argv[1]

path <- file_path_sans_ext(csvfilename)
save <- function(p, d, s, w=1400, h=800) {
  path <- sprintf('%s-chart-%s.png', d, s)
  #png(file = path, paper = 'special', width = w, height = h, pointsize = 12)
  png(file = path, width=w, height=h, pointsize=24)
  print(p)
  null <- dev.off()
}

instrs <- c('Empty', 'Identity', 'Compute', 'ClientServer')

printf('Loading table from %s...', csvfilename);
csv <- read.csv(csvfilename, strip.white=TRUE, sep=':', header=FALSE);
colnames(csv) <- c('run', 'bench', 'instr', 'stage', 'time');
csv$instr <- factor(csv$instr, levels=instrs)
levels(csv$instr) <- rename(levels(csv$instr))

# Instrumentation
csv.instrumentation <- subset(csv, !(stage %in% '@total'))
csv.instrumentation <- dcast(csv.instrumentation, run+bench+instr~'time', value.var='time', fun.aggregate=sum)
colnames(csv.instrumentation) <- c('run', 'bench', 'instr', 'instrumentation');

csv.total <- subset(csv, stage %in% '@total')
csv.total$stage <- NULL
colnames(csv.total) <- c('run', 'bench', 'instr', 'total');

csv.all <- merge(csv.instrumentation, csv.total, by=c('run', 'bench', 'instr'))
csv.all <- melt(csv.all, id.vars=c('run', 'bench', 'instr'), variable.name='stage', value.name='time')

# Instrumentation
p <-
  ggplot(csv.instrumentation)+facet_wrap(~bench, scales="free")+
  geom_boxplot(aes(instr, instrumentation, color=instr))+
  labs(x="Library", y = "Instrumentation time (in seconds)", title='Instrumentation time')+
  theme(legend.position="top")
save(p, path, "instr")

# Instrumentation with total
p <-
  ggplot(csv.all)+facet_wrap(~bench, scales="free")+
  geom_boxplot(aes(instr, time, color=stage))+
  labs(x="Library", y = "Instrumentation and total time (in seconds)", title='Instrumentation and total time')+
  theme(legend.position="top")
save(p, path, "all")

#geom_bar(aes(instr, instrumentation, fill=instr), stat="identity")+
#geom_bar(aes(instr, time, fill=stage), stat="identity")+
