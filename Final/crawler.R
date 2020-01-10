library(tidyverse)
library(XML);library(rvest)
library(httr);library(jsonlite)
library(RSelenium)

x <- read_csv("/Users/yangyuchen/Desktop/ATM00445_20191213212223.csv")

url <- "https://e-service.cwb.gov.tw/wdps/obs/state.htm"

browseURL(url)
doc <- read_html(url)

station <- data.frame(row.names = 1:563)
station$no <- html_nodes(doc, "tr > td:nth-child(1) > p") %>% 
  html_text() %>% .[which(.=="C0A520"):which(.=="CM0180")]
station$station <- html_nodes(doc, "tr > td:nth-child(2) > p") %>% 
  html_text() %>% .[which(.=="山佳"):which(.=="茂林蝶谷")]
station$height <- html_nodes(doc, "tr > td:nth-child(3) > p") %>% 
  html_text() %>% .[which(.=="48"):which(.=="313")]
station$lat <- html_nodes(doc, "tr > td:nth-child(4) > p") %>% 
  html_text() %>% .[which(.=="121.4020\r\n  "):which(.=="120.6641\r\n  ")]
station$lon <- html_nodes(doc, "tr > td:nth-child(5) > p") %>% 
  html_text() %>% .[which(.=="24.9749\r\n  "):596]
station$startdate <- html_nodes(doc, "tr > td:nth-child(8) > p") %>% 
  html_text() %>% .[34:596]

station <- station %>%
  mutate(lon=unlist(strsplit(lon,"\r\n  ")),
         lat=unlist(strsplit(lat,"\r\n  ")),
         startdate=strptime(startdate,"%Y/%m/%d"))
station$startdate<- strptime(station$startdate,"%Y/%m/%d")
station <- station[station$startdate <= strptime("2010/01/01","%Y/%m/%d"),]

driver <- RSelenium::rsDriver(check = FALSE, browser = "chrome")
month <- c("01","02","03","04","05","06","07","08","09","10","11","12")
for(i in station$no){
  for(j in 2010:2019){
    for(k in month){
      url <- str_c("https://e-service.cwb.gov.tw/HistoryDataQuery/MonthDataController.do?command=viewMain&station=",i,"&stname=%25E9%259E%258D%25E9%2583%25A8&datepicker=",j,"-",k)
      driver$client$navigate(url)
      buttom<- driver$client$findElement("xpath", '//*[@id="downloadCSV"]')
      buttom$clickElement()
    }
  }
}




