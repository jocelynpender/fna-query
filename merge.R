# https://www.r-bloggers.com/merging-multiple-data-files-into-one-data-frame/
multmerge = function(mypath) {
  filenames = list.files(path = mypath, full.names = TRUE)
  datalist = lapply(filenames, function(x) {
    read.csv(file = x, header = T)
  })
  Reduce(function(x, y) {
    merge(x, y)
  }, datalist)
}

# Open an R console and run:
trait_matrix <- multmerge("csv_result_files") # Path where CSV files are stored
write.csv(trait_matrix, file = "trait_matrix.csv", na = "")
