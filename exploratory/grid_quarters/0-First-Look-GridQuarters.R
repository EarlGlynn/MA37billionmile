# First look at file:  grid_quarters_public_noheader.csv

# Massachusetts' 37 Billion Mile Challenge
# http://www.37billionmilechallenge.org/

# efg, 20 March 2014
# Windows 7, R 64-bit 3.0.2, 32 GB memory

##################################################################################

setwd("E:/FOIA/States/Massachusetts/37billion/MassVehicleCensusData_20130313/")
sink("0-First-Look-GridQuarters.txt", split=TRUE)

##################################################################################
### grid_quarters_public_noheader.csv

Sys.time()
gq <- read.csv("grid_quarters_public_noheader.csv", header=FALSE, colClasses="character")
names(gq) <- c("seq_id", "g250m_id", "hh10", "quarter", "veh_tot", "pass_veh",
               "ovrlp_pct", "pass_geo", "best_geo", "pass_zip", "pass_muni",
               "veh_phh", "mipdaypass", "mipday_phh", "mipdaybest", "veh_lo",
               "veh_medlo", "veh_medhi", "veh_hi", "veh_vhi", "comm_veh",
               "comm_geo", "comm_zip", "comm_muni", "mipdaycomm", "mpg_eff",
               "glpdaypass", "co2eqv_day")
dim(gq)
object.size(gq)
Sys.time()

head(gq)

################################################################################
### Create stats for global dataset and most recent release
COUNTS <- "Counts"  # Directory name for frequency count files

create.stats <- function(VERSION, d, SELECTOR)
{
  ### Create COUNTS directory if it does not exist.
  COUNTS.dir <- paste(COUNTS, VERSION, sep="-")
  if (! file.exists(COUNTS.dir))
  {
    dir.create(COUNTS.dir)
  }

  ### Descriptive stats for each field

  char.summary <- NULL
  for (i in 1:length(colnames(d)))
  {
    column <- colnames(d)[i]
    field <- tolower(d[,i])

    counts <- table(field)

    counts <-  data.frame(as.table(counts))
    colnames(counts) <- c(column,"Count")

    # Sort in decreasing order by frequency count
    counts <- counts[order(counts[,2], counts[,1], decreasing=TRUE),]

    filename <- paste(COUNTS.dir, "/", sprintf("%02d",i),"-", column,
                      ".csv",sep="")
    write.csv(counts, file=filename, row.names=FALSE)
    cat(i, column, "\n")
    flush.console()

    zero.length.field <- (nchar(field) == 0)  # trim char strings?
    Missing <-  sum(zero.length.field)
    N <- length(field) - Missing
    NUnique <- length(unique(field))

    if (SELECTOR[i] == 0)
    {
      zeros <- ""
      zero.count <- 0
      nonzeros.count <- 0
      minvalue <- 0
      maxvalue <- 0

    } else {

      which.zero <- which(as.numeric(as.character(counts[,1])) == 0.0)
      counts.zero <- counts[which.zero,]
      zeros <- paste0(as.character(counts.zero[,1]), ": ", counts.zero[,2], collapse="; ")
      zeros.count <- sum(counts.zero[,2])
      x <- as.numeric(d[,i])
      stopifnot(sum(x == 0) == zeros.count)  # double check float zero comparison
      x <- x[x > 0]
      nonzeros.count <- length(x)
      minvalue <- min(x)
      maxvalue <- max(x)

      boxplot(x, main=paste0(i, ". ", column), col="gray", col.main="blue")
        mtext(paste0("Excluding ", zeros.count, " zeroes"))
        mtext(paste0("37 Billion Mile Challenge:  File ", VERSION), BOTTOM<-1,
          adj=0.025, line=-1.5, cex=0.80, col="blue", outer=TRUE)
      boxplot(log10(x), main=paste0("log10(", column, ")"), col="gray", col.main="blue")
        mtext(paste0("Excluding ", zeros.count, " zeroes"))
        mtext(format(Sys.time(), "%Y-%m-%d %H:%M"), BOTTOM,
          adj=0.975, line=-1.5, cex=0.8, col="blue", outer=TRUE)
    }

    char.summary <- rbind(char.summary,
                           c(i, column,
                             as.vector(summary( nchar(field[!zero.length.field]) ) ),
                             N, Missing, NUnique,
                             zeros, zeros.count, nonzeros.count, minvalue, maxvalue) )
  }

  colnames(char.summary) <- c("No", "Field", "cMin", "Q1", "Median", "Mean",
                              "Q3", "cMax", "N", "Missing", "NUnique",
                              "ZeroVariation", "Zero", "NonZero", "Min", "Max")
  filename <- paste("Field-Summary-", VERSION, ".csv", sep="")
  write.csv(char.summary, file=filename, row.names=FALSE)

}

png("GridQuarters%02d.png", width=600, height=800)
reset.par <- par(mfcol=c(1,2))
SELECTOR <- rep(1, ncol(gq))
SELECTOR[4] <- 0
create.stats("GridQuarters",  gq, SELECTOR)
par(reset.par)
dev.off()

##################################################################################

Sys.time()
sink()

