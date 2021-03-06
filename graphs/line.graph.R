#############################################################################
###"graph/line.graph.R"
## This script does:
# 1. Subset monthly data as preferred;
# 2. Create line graph of data
## DEPENDS ON:
require(ggplot2)
## USED BY:
# Nothing
## CREATES:
# Results may vary
#############################################################################


# 1. Subset monthly data as preferred ----------------------------------------

monthlyData <- droplevels(SACTNmonthly_v4.1[SACTNmonthly_v4.1$src == "UWC",])
monthlyData$date <- as.Date(monthlyData$date) # convert from "POSIXct" to "Date" for plotting

## Create labeler to show site names in the correct order
site.names <- function(sites) {
  sites <- list(sapply(strsplit(as.character(levels(monthlyData$index)), "/"), "[[", 1))
  return(sites)
}


# 2. Create line graph of data --------------------------------------------

# Here is the base code from which one can play around to create new things
lg <- ggplot(data = monthlyData, aes(x = date, y = temp)) + bw_update +
  #geom_line() +
  geom_line(aes(colour = site)) +
  facet_grid(index ~ ., labeller = site.names) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y", expand = c(0.015,0)) +
  ylab(expression(paste("Temperature (", degree~C, ")"))) + xlab("Date") +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5),
        legend.position = "none")
lg
ggsave("graphs/UWCsites.pdf", height = 12, width = 12, limitsize = FALSE)
