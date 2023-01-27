library(ggplot2)

all_date <- unique(df$createdAt)
count <- sapply(all_date, function(d)
  sum(df$createdAt == d))

data <-
  data.frame(day = as.Date(all_date, format = "%Y-%m-%d"),
             value = count)


# generate time series graph
p <-
  ggplot(data, aes(x = day, y = value)) +
  geom_line() +
  xlab('時間') +
  ylab('照片數') +
  scale_x_date(date_breaks = "1 week", date_labels = "%m-%d")
p

print('3_output.R done :)')