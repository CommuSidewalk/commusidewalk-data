# Load purrr library
library(purrr)

# Example data frame
df <- data.frame(a = c("apple", "banana", "mango"), b = c("chocolate", "spaghetti", "pizza"))

# Example lookup table
l <- list(
  a = list("apple" = 1, "banana" = 2, "mango" = 3),
  b = list("chocolate" = 5, "spaghetti" = 3, "pizza" = 9)
)


for (col in names(l)) {
  df[[col]] <- sapply(df[[col]], \(x) l[[col]][[x]])
}
       