# We need a writeable directory, usually /tmp
temporary_directory <- Sys.getenv("TMPDIR", "/tmp")

diamonds <- function(colour) {
  
  outfile <- file.path(
    temporary_directory,
    paste0("diamonds_", colour, "_", as.integer(Sys.time()), ".html")
  )
  on.exit(unlink(outfile)) # delete file when we're done
  
  logger::log_debug("Rendering", outfile)
  rmarkdown::render(
    "/lambda/diamond-report.Rmd",
    params = list(colour = colour),
    envir = new.env(),
    intermediates_dir = temporary_directory,
    output_file = outfile
  )
  logger::log_debug("Rendering complete for", outfile)
  
  html_string <- readChar(outfile, file.info(outfile)$size)
  
  lambdr::html_response(html_string, content_type = "text/html")
}

logger::log_formatter(logger::formatter_paste)
logger::log_threshold(logger::DEBUG)
lambdr::start_lambda()
