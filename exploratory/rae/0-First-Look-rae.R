# First look at files:  rae_public_noheader.csv

# Massachusetts' 37 Billion Mile Challenge
# http://www.37billionmilechallenge.org/

# efg, 20 March 2014
# Windows 7, R 64-bit 3.0.2, 32 GB memory

##################################################################################

setwd("E:/FOIA/States/Massachusetts/37billion/MassVehicleCensusData_20130313/")
sink("0-First-Look-rae.txt", split=TRUE)

##################################################################################
### rae_public_noheader.csv

Sys.time()
rae <- read.csv("rae_public_noheader.csv", header=FALSE, as.is=TRUE, colClasses="character")
dim(rae)
object.size(rae)
Sys.time()

head(rae)

names(rae) <- c("record_id", "vin_id", "plate_id", "me_id", "owner_type", "start_odom",
                "start_date", "end_date", "insp_match", "ovrlp_days", "daysbtnins",
                "ovrlp_pct", "mi_per_day", "muni_id", "veh_zip", "insp_year",
                "model_year", "make", "model", "veh_type", "mcycle", "hybrid",
                "curbwt", "msrp", "mpg2008", "fuel", "mpg_adj", "gal_perday",
                "co2eqv_day", "q1_2008", "q2_2008", "q3_2008", "q4_2008", "q1_2009",
                "q2_2009", "q3_2009", "q4_2009", "q1_2010", "q2_2010", "q3_2010",
                "q4_2010", "q1_2011", "q2_2011", "q3_2011", "q4_2011")

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
      zeros.count <- 0
      nonzeros.count <- 0
      minvalue <- 0
      maxvalue <- 0

    } else {

      which.zero <- which(as.numeric(as.character(counts[,1])) == 0.0)
      counts.zero <- counts[which.zero,]
      zeros <- paste0(as.character(counts.zero[,1]), ": ", counts.zero[,2], collapse="; ")
      zeros.count <- sum(counts.zero[,2])
      x <- as.numeric(d[,i])

      if (sum(x == 0, na.rm=TRUE) != zeros.count)
      {
        cat("***zeroes: ", sum(x==0), zeros.count, "\n")
      }

      x <- x[x > 0]
      nonzeros.count <- length(x)
      minvalue <- min(x, na.rm=TRUE)
      maxvalue <- max(x, na.rm=TRUE)

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

png("rae%02d.png", width=600, height=800)
reset.par <- par(mfcol=c(1,2))
SELECTOR <- rep(1, ncol(rae))
SELECTOR[c(1:5, 7:9, 18:22, 26, 30:45)] <- 0
create.stats("rae", rae, SELECTOR)
par(reset.par)
dev.off()


##################################################################################

Sys.time()
sink()

