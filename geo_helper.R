str_detect <- function(x, pattern) {
    grepl(pattern, x)
}

get_fastq_files <- function(verbose = FALSE) {
    filter <- function(x, f) {
        x[f(x)]
    }
    
    if (verbose) {
        cat("Getting fastq files...\n")
    }

    filter(dir(), function(x) str_detect(x, "(.fastq.gz$|.fastq$)"))
}

get_reads <- function(x, n = 200, verbose = FALSE) {
    if (verbose) {
        cat("Getting ", n, " reads from: ", x, "...\n", sep = "")
    }
    output <- readLines(x, n = n * 4)

    output[(1:n)*4 - 2]
}

# instrument information taken from https://github.com/10XGenomics/supernova/blob/master/tenkit/lib/python/tenkit/illumina_instrument.py#L12-L45
get_instrument <- function(x, verbose = FALSE) {
    guess_instrument <- function(x) {
        instruments_df <- data.frame(
            rbind(
                c("HWI-M[0-9]{4}$", "MiSeq"),
                c("HWUSI", "Genome Analyzer IIx"),
                c("M[0-9]{5}$", "MiSeq"),
                c("HWI-C[0-9]{5}$", "HiSeq 1500"),
                c("C[0-9]{5}$", "HiSeq 1500"),
                c("HWI-D[0-9]{5}$", "HiSeq 2500"),
                c("D[0-9]{5}$", "HiSeq 2500"),
                c("J[0-9]{5}$", "HiSeq 3000"),
                c("K[0-9]{5}$", "HiSeq 3000 or HiSeq 4000"),
                c("E[0-9]{5}$", "HiSeq X"),
                c("NB[0-9]{6}$", "NextSeq"),
                c("NS[0-9]{6}$", "NextSeq"),
                c("MN[0-9]{5}$", "MiniSeq")
            )
        )
        colnames(instruments_df) <- c("pattern", "instrument")

        for (i in seq_len(nrow(instruments_df))) {
            if (grepl(instruments_df$pattern[i], x)) {
                return(as.character(instruments_df$instrument[i]))
            }
        }

        return("Unknown")
    }


    header <- readLines(x, n = 1)

    if (substr(header, 1, 1) != "@") {
        # header should start with "@"
        return("Unknown")
    }

    fields <- unlist(strsplit(header, ":"))
    instrument_id <- fields[1]
    flowcell_id <- fields[3]

    guess_instrument(instrument_id)
}

guess_read_len <- function(x, verbose = FALSE) {
    if (verbose) {
        cat("Guessing read length...\n")
    }

    mode <- function(x) {
        tab <- table(x)
        names(tab)[which(tab == max(tab))]
    }

    reads <- get_reads(x, n = 200, verbose = verbose)
    mode(nchar(reads))
}

guess_paired_status <- function(x, verbose = FALSE) {
    if (verbose) {
        cat("Guessing if paired end...\n")
    }

    guess_func <- function(fname) {
        if (str_detect(fname, "R1.fastq")) {
            partner <- gsub("R1.fastq", "R2.fastq", fname)
            if (partner %in% x) {
                return("paired")
            }
        } else if (str_detect(fname, "R2.fastq")) {
            partner <- gsub("R2.fastq", "R1.fastq", fname)
            if (partner %in% x) {
                return("paired")
            }
        }
        return("single")
    }

    sapply(x, guess_func)
}

get_raw_files_info <- function(verbose = FALSE) {
    if (verbose) {
        cat("Guessing instrument...\n")
    }
    fastq_files <- get_fastq_files(verbose = verbose)
    md5sums <- unlist(
        parallel::mclapply(
            X = fastq_files,
            FUN = tools::md5sum,
            mc.cores = parallel::detectCores()
        )
    )
    instrument <- sapply(
        fastq_files,
        function(x) get_instrument(x, verbose = verbose)
    )
    read_lengths <- sapply(
        fastq_files,
        function(x) guess_read_len(x, verbose = verbose)
    )
    paired_status <- guess_paired_status(fastq_files, verbose = verbose)

    df <- data.frame(
        file.name = fastq_files,
        file.type = "fastq",
        file.checksum = md5sums,
        instrument = instrument,
        read.length = read_lengths,
        paired.status = paired_status
    )

    paste(apply(df, 1, function(x) paste(x, collapse = "\t")), collapse = "\n")
}
