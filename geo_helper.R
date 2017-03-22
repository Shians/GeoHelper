str_detect <- function(x, pattern) {
    grepl(pattern, x)
}

get_raw_files_info <- function() {

    get_fastq_files <- function() {
        filter <- function(x, f) {
            x[f(x)]
        }

        filter(dir(), function(x) str_detect(x, ".fastq"))
    }

    guess_read_len <- function(x) {
        mode <- function(x) {
            tab <- table(x)
            names(tab)[which(tab == max(tab))]
        }

        reads <- get_reads(x, n = 200)
        mode(nchar(reads))
    }

    get_reads <- function(x, n = 100) {
        is_gzipped <- function(x) str_detect(x, ".fastq.gz")

        if (is_gzipped(x)) {
            # -q in gzip to suppress broken pipe error
            cmd <- paste("gzip -cdq", x, "| head -n", n * 4)
            output <- system(cmd, intern = TRUE, ignore.stderr = TRUE)
        } else {
            output <- readLines(x, n = n * 4)
        }

        output[(1:n)*4 - 2]
    }

    fastq_files <- get_fastq_files()
    read_lengths <- sapply(fastq_files, guess_read_len)
    md5sums <- tools::md5sum(fastq_files)

    df <- data.frame(file.name = fastq_files,
                     file.type = "fastq",
                     file.checksum = md5sums,
                     instrument = " ",
                     read.length = read_lengths)

    paste(apply(df, 1, function(x) paste(x, collapse = "\t")), collapse = "\n")
}
