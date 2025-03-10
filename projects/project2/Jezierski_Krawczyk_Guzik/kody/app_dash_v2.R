library(shiny)
library(thematic)
library(shinythemes)
library(jsonlite)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(lubridate)
library(forcats)
library(plotly)
library(bslib)
library(shinydashboard)
library(dashboardthemes)
library(tm)
library(wordcloud)
## BARTEK

# Importujemy i zamieniamy jsona na ramkę danych
raw_json <- read_json("../dane/Historia_Bartek.json")
df_Bartek <- tibble(history = raw_json[["Browser History"]])
df_Bartek <- df_Bartek %>% unnest_wider(history)

# Ekstraktujemy same nazwy stron
df_Bartek <- df_Bartek %>%
  mutate(url = str_replace(url, "https://", "")) %>%
  mutate(url = str_replace(url, "www\\.", "")) %>%
  mutate(url = str_replace(url, "\\.(com|net|org|pl)", "")) %>%
  mutate(url = str_to_lower(url)) %>%
  mutate(website = str_extract(url, "[a-z.]{1,}"))

# Zamieniamy czas unixowy na posix
df_Bartek <- df_Bartek %>% 
  mutate(time = time_usec/1e6) %>%
  mutate(time = as.POSIXct(time, origin = "1970-01-01")) %>%
  mutate(time = with_tz(time, tz = "Europe/Warsaw")) %>%
  select(-favicon_url, -ptoken, -time_usec, -title)

# Dodajemy daytime i weekday i month
df_Bartek <- df_Bartek %>% 
  mutate(daytime = strftime(time, "%H:%M:%S")) %>%
  mutate(daytime = as.POSIXct(daytime, format="%H:%M:%S"))

df_Bartek <- df_Bartek %>%
  mutate(weekday = strftime(time, "%A")) %>%
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))

df_Bartek <- df_Bartek %>%
  mutate(month = strftime(time, "%m"))

# Tworzymy website frequency do sliderów
website_frequency_Bartek <- df_Bartek %>% 
  group_by(website) %>%
  summarize(count = n()) %>%
  arrange(-count)

# WYSZUKANIA

search_Bartek <- fromJSON("../dane/Wyszukania_Bartek.json")
search_Bartek$time <- as.POSIXct(search_Bartek$time, format = "%Y-%m-%dT%H:%M:%S", tz="UTC")

search_Bartek <- search_Bartek %>%
  mutate(category = case_when(
    grepl("Odwiedzono:", title) ~ "Odwiedzono",
    grepl("Szukano:", title) ~ "Szukano",
    grepl("Używane:", title) ~ "Używane",
    grepl("Obejrzano:", title) ~ "Obejrzano",
    TRUE ~ NA_character_
  ))

search_Bartek <- search_Bartek %>%
  mutate(title = sub("^Odwiedzono: |^Szukano: |^Używane: |^Obejrzano: ", "", title))

most_search_Bartek <- search_Bartek %>%
  filter(category == "Szukano") %>%
  group_by(title) %>%
  summarise(count = n()) %>%
  arrange(-count)


## MIKOLAJ

# Importujemy i zamieniamy jsona na ramkę danych
raw_json <- read_json("../dane/Historia_Mikolaj.json")
df_Mikolaj <- tibble(history = raw_json[["Browser History"]])
df_Mikolaj <- df_Mikolaj %>% unnest_wider(history)

# Ekstraktujemy same nazwy stron
df_Mikolaj <- df_Mikolaj %>%
  mutate(url = str_replace(url, "https://", "")) %>%
  mutate(url = str_replace(url, "www\\.", "")) %>%
  mutate(url = str_replace(url, "\\.(com|net|org|pl)", "")) %>%
  mutate(url = str_to_lower(url)) %>%
  mutate(website = str_extract(url, "[a-z.]{1,}"))

# Zamieniamy czas unixowy na posix
df_Mikolaj <- df_Mikolaj %>% 
  mutate(time = time_usec/1e6) %>%
  mutate(time = as.POSIXct(time, origin = "1970-01-01")) %>%
  mutate(time = with_tz(time, tz = "Europe/Warsaw")) %>%
  select(-favicon_url, -ptoken, -time_usec, -title)

# Możemy spróbować zobaczyć czy da się odczytać jakie strony najczęściej przeglądam
website_frequency_Mikolaj <- df_Mikolaj %>% 
  mutate(website = str_extract(url, "[a-z.]{1,}")) %>%
  group_by(website) %>%
  summarize(count = n()) %>%
  arrange(-count)

# Dodajemy daytime i weekday
df_Mikolaj <- df_Mikolaj %>% 
  mutate(daytime = strftime(time, "%H:%M:%S")) %>%
  mutate(daytime = as.POSIXct(daytime, format="%H:%M:%S"))

df_Mikolaj <- df_Mikolaj %>%
  mutate(weekday = strftime(time, "%A")) %>%
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))

df_Mikolaj <- df_Mikolaj %>%
  mutate(month = strftime(time, "%m"))

# WYSZUKANIA

search_Mikolaj <- fromJSON("../dane/Wyszukania_Mikolaj.json")
search_Mikolaj$time <- as.POSIXct(search_Mikolaj$time, format = "%Y-%m-%dT%H:%M:%S", tz="UTC")

search_Mikolaj <- search_Mikolaj %>%
  mutate(category = case_when(
    grepl("Odwiedzono:", title) ~ "Odwiedzono",
    grepl("Szukano:", title) ~ "Szukano",
    grepl("Używane:", title) ~ "Używane",
    grepl("Obejrzano:", title) ~ "Obejrzano",
    TRUE ~ NA_character_
  ))

search_Mikolaj <- search_Mikolaj %>%
  mutate(title = sub("^Odwiedzono: |^Szukano: |^Używane: |^Obejrzano: ", "", title))

most_search_Mikolaj <- search_Mikolaj %>% 
  filter(category == "Szukano") %>% 
  group_by(title) %>% 
  summarise(count = n()) %>% 
  arrange(-count)


##AGATA
raw_json <- read_json("../dane/Historia_Agata.json")
df_Agata <- tibble(history = raw_json[["Browser History"]])
df_Agata <- df_Agata %>% unnest_wider(history)


# Ekstraktujemy same nazwy stron
df_Agata <- df_Agata %>%
  mutate(url = str_replace(url, "https://", "")) %>%
  mutate(url = str_replace(url, "www\\.", "")) %>%
  mutate(url = str_replace(url, "\\.(com|net|org|pl)", "")) %>%
  mutate(url = str_to_lower(url)) %>%
  mutate(website = str_extract(url, "[a-z.]{1,}"))

# Zamieniamy czas unixowy na posix
df_Agata <- df_Agata %>% 
  mutate(time = time_usec/1e6) %>%
  mutate(time = as.POSIXct(time, origin = "1970-01-01")) %>%
  mutate(time = with_tz(time, tz = "Europe/Warsaw")) %>%
  select(-favicon_url, -ptoken, -time_usec, -title)

# Możemy spróbować zobaczyć czy da się odczytać jakie strony najczęściej przeglądam
website_frequency_Agata <- df_Agata %>% 
  mutate(website = str_extract(url, "[a-z.]{1,}")) %>%
  group_by(website) %>%
  summarize(count = n()) %>%
  arrange(-count)

# Dodajemy daytime i weekday
df_Agata <- df_Agata %>% 
  mutate(daytime = strftime(time, "%H:%M:%S")) %>%
  mutate(daytime = as.POSIXct(daytime, format="%H:%M:%S"))

df_Agata <- df_Agata %>%
  mutate(weekday = strftime(time, "%A")) %>%
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))

df_Agata <- df_Agata %>%
  mutate(month = strftime(time, "%m"))

# WYSZUKANIA

search_Agata <- fromJSON("../dane/Wyszukania_Agata.json")
search_Agata$time <- as.POSIXct(search_Agata$time, format = "%Y-%m-%dT%H:%M:%S", tz="UTC")

# Utwórz nową kolumnę "category" na podstawie kolumny "title"
search_Agata <- search_Agata %>%
  mutate(category = case_when(
    grepl("Odwiedzono:", title) ~ "Odwiedzono",
    grepl("Szukano:", title) ~ "Szukano",
    grepl("Używane:", title) ~ "Używane",
    grepl("Obejrzano:", title) ~ "Obejrzano",
    TRUE ~ NA_character_
  ))

search_Agata <- search_Agata %>%
  mutate(title = sub("^Odwiedzono: |^Szukano: |^Używane: |^Obejrzano: ", "", title))

most_search_Agata <- search_Agata %>%
  filter(category == "Szukano") %>%
  group_by(title) %>%
  summarise(count = n()) %>%
  arrange(-count)


##############  MAIN DF   ###############
df_Mikolaj <- df_Mikolaj %>% mutate(person = "Mikolaj")
website_frequency_Mikolaj <- website_frequency_Mikolaj %>% mutate(person = "Mikolaj")

df_Bartek <- df_Bartek %>% mutate(person = "Bartek")
website_frequency_Bartek <- website_frequency_Bartek %>% mutate(person = "Bartek")

df_Agata <- df_Agata %>% mutate(person = "Agata")
website_frequency_Agata <- website_frequency_Agata %>% mutate(person = "Agata")

main_df <- rbind(df_Bartek, df_Mikolaj,df_Agata) %>% select(-url, -client_id) %>%
  mutate(month = factor(month, 
                        levels = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"), 
                        labels = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
  ))
main_website_freq <- rbind(website_frequency_Bartek, website_frequency_Mikolaj, website_frequency_Agata) %>%
  arrange(-count)

# WYSZUKANIA

search_Bartek <- search_Bartek %>% mutate(person = "Bartek")
most_search_Bartek <- most_search_Bartek %>% mutate(person = "Bartek")

search_Mikolaj <- search_Mikolaj %>% mutate(person = "Mikolaj")
most_search_Mikolaj <- most_search_Mikolaj %>% mutate(person = "Mikolaj")

search_Agata <- search_Agata %>% mutate(person = "Agata")
most_search_Agata <- most_search_Agata %>% mutate(person = "Agata")

main_most_search <- rbind(most_search_Mikolaj)
main_most_search <- rbind(most_search_Mikolaj, most_search_Agata, most_search_Bartek)

#############################
customTheme <- shinyDashboardThemeDIY(
  
  ### general
  appFontFamily = "Verdana"
  ,appFontColor = "rgb(0,0,0)"
  ,primaryFontColor = "rgb(0,0,0)"
  ,infoFontColor = "rgb(0,0,0)"
  ,successFontColor = "rgb(0,0,0)"
  ,warningFontColor = "rgb(0,0,0)"
  ,dangerFontColor = "rgb(0,0,0)"
  ,bodyBackColor = "white"
  
  ### header
  ,logoBackColor = "#F4F4F4"
  
  ,headerButtonBackColor = "rgb(238,238,238)"
  ,headerButtonIconColor = "rgb(75,75,75)"
  ,headerButtonBackColorHover = "rgb(210,210,210)"
  ,headerButtonIconColorHover = "rgb(0,0,0)"
  
  ,headerBackColor = "#F4F4F4"
  ,headerBoxShadowColor = "#F4F4F4"
  ,headerBoxShadowSize = "2px 2px 2px"
  
  ### sidebar
  ,sidebarBackColor = cssGradientThreeColors(
    direction = "down"
    ,colorStart = "#427EE8"
    ,colorMiddle = "#5A92F6"
    ,colorEnd = "#73A1F1"
    ,colorStartPos = 0
    ,colorMiddlePos = 50
    ,colorEndPos = 100
  )
  ,sidebarPadding = 0
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = 0
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = "3px 5px 5px"
  ,sidebarShadowColor = "#F4F4F4"
  
  ,sidebarUserTextColor = "rgb(255,255,255)"
  
  ,sidebarSearchBackColor = "rgb(55,72,80)"
  ,sidebarSearchIconColor = "rgb(153,153,153)"
  ,sidebarSearchBorderColor = "rgb(55,72,80)"
  
  ,sidebarTabTextColor = "rgb(255,255,255)"
  ,sidebarTabTextSize = 20
  ,sidebarTabBorderStyle = "none none none none"
  ,sidebarTabBorderColor = "rgb(35,106,135)"
  ,sidebarTabBorderWidth = 1
  
  ,sidebarTabBackColorSelected = cssGradientThreeColors(
    direction = "right"
    ,colorStart = "#73A1F1"
    ,colorMiddle = "#73A1F1"
    ,colorEnd = "#73A1F1"
    ,colorStartPos = 0
    ,colorMiddlePos = 30
    ,colorEndPos = 100
  )
  ,sidebarTabTextColorSelected = "white"
  ,sidebarTabRadiusSelected = "0px 20px 20px 0px"
  
  ,sidebarTabBackColorHover = "#73A1F1"
  ,sidebarTabTextColorHover = "white"
  ,sidebarTabBorderStyleHover = "none none solid none"
  ,sidebarTabBorderColorHover = "white"
  ,sidebarTabBorderWidthHover = 0
  ,sidebarTabRadiusHover = "0px 20px 20px 0px"
  
  ### boxes
  ,boxBackColor = "#F4F4F4"
  ,boxBorderRadius = 5
  ,boxShadowSize = "0px 0px 0px"
  ,boxShadowColor = "#F4F4F4"
  ,boxTitleSize = 30
  ,boxDefaultColor = "#F4F4F4"
  ,boxPrimaryColor = "blue"
  ,boxInfoColor = "pink"
  ,boxSuccessColor = "purple"
  ,boxWarningColor = "rgb(244,156,104)"
  ,boxDangerColor = "rgb(255,88,55)"
  
  ,tabBoxTabColor = "red"
  ,tabBoxTabTextSize = 14
  ,tabBoxTabTextColor = "red"
  ,tabBoxTabTextColorSelected = "rgb(0,0,0)"
  ,tabBoxBackColor = "red"
  ,tabBoxHighlightColor = "red"
  ,tabBoxBorderRadius = 5
  
  ### inputs
  ,buttonBackColor = "#C8DCFF"
  ,buttonTextColor = "#F4F4F4"
  ,buttonBorderColor = "#C8DCFF"
  ,buttonBorderRadius = 20
  
  ,buttonBackColorHover = "#73A1F1"
  ,buttonTextColorHover = "#C8DCFF"
  ,buttonBorderColorHover = "#C8DCFF"
  
  ,textboxBackColor = "#F4F4F4"
  ,textboxBorderColor = "#F4F4F4"
  ,textboxBorderRadius = 5
  ,textboxBackColorSelect = "rgb(245,245,245)"
  ,textboxBorderColorSelect = "rgb(200,200,200)"
  
  ### tables
  ,tableBackColor = "rgb(255,255,255)"
  ,tableBorderColor = "rgb(240,240,240)"
  ,tableBorderTopSize = 1
  ,tableBorderRowSize = 1
  
)



os <- c("Agata","Bartek","Mikolaj")
main_ui <- dashboardPage(
 
  dashboardHeader(title=img(src="logo.png", height="100%", width="100%", align = "center")),
  
  
  dashboardSidebar(
    width=150,
    sidebarMenu(menuItem("Home",tabName = "home"),
                menuItem("Ogólne",tabName = "ogolne"),
                menuItem("Strony",tabName = "strony"),
                menuItem("Wyszukania",tabName = "wyszukania"))
  ),
  dashboardBody(
  customTheme,
    
    tabItems(
      ####HOME
      tabItem(tabName = "home",
              fluidRow(box(width="100%",h2("O NAS"),align="center")),
              fluidRow(
                column(4,box(width="32%",
                             title="Agata",
                             h5("Nałogowo sprawdza USOS"),
                             img(src="ia.png", height="100%", width="100%", align = "center"))
                            ),
                column(4, box(title="Bartek",width="32%",
                              h5("Ogląda za dużo YouTube"),
                              img(src="ib.png", height="100%", width="100%", align = "center"))),
                column(4,box(title="Mikołaj",width="32%",
                             h5("Pilnie śledzi Twitch.tv"),
                             img(src="im.png", height="100%", width="100%", align = "center")
                             ))
                
              )),
      ####OGOLNE
      tabItem(tabName = "ogolne",
              fluidRow(class = "row1",
                       column(3,
                              selectInput("generalPerson",
                                          "Wybierz użytkownika:",
                                          choices = c("Wszyscy"="wszyscy",
                                                      "Agata" = "Agata",
                                                      "Bartek" = "Bartek",
                                                      "Mikołaj" = "Mikolaj")),
                              dateRangeInput("generalDateRange",
                                             label = "Wybierz, z kiedy mają pochodzić dane",
                                             start = min(main_df %>% filter(person %in% os) %>% .$time),
                                             end = max(main_df %>% filter(person %in% os) %>% .$time),
                                             min = min(main_df %>% filter(person %in% os) %>% .$time),
                                             max = max(main_df %>% filter(person %in% os) %>% .$time)
                              )
                       ),
                       column(9,
                              plotlyOutput("generalDensity")
                       )
              ),
              fluidRow(class = "row2",
                       column(12,
                              plotlyOutput("generalBenchmark")
                       )
              ),
              ),
      
      ####STRONY
      tabItem(tabName = "strony",
              
              fluidRow(
                column(4,
                       selectInput("pagesPerson",
                                   "Wybierz użytkownika:",
                                   choices = c("Wszyscy"="wszyscy",
                                               "Agata" = "Agata",
                                               "Bartek" = "Bartek",
                                               "Mikołaj" = "Mikolaj")
                       ),
                       dateRangeInput("pagesDateRange",
                                      label = "Wybierz, z kiedy mają pochodzić dane",
                                      start = min(main_df %>% filter(person %in% os) %>% .$time),
                                      end = max(main_df %>% filter(person %in% os) %>% .$time),
                                      min = min(main_df %>% filter(person %in% os) %>% .$time),
                                      max = max(main_df %>% filter(person %in% os) %>% .$time)
                       ),
                       selectInput("pagesChoice",
                                   label = "Wybierz stronę:",
                                   choices = main_df %>%
                                     filter(person %in% os) %>%
                                     filter(time >= min(main_df %>% filter(person %in% os) %>% .$time), 
                                            time <= max(main_df %>% filter(person %in% os) %>% .$time)) %>%
                                     group_by(website) %>%
                                     summarise(count = n()) %>%
                                     arrange(-count) %>% .$website,
                       ),
                       selectInput("pagesTypeChoice",
                                   "Wybierz typ wykresu",
                                   choices = c("Rozkład" = "rozklad",
                                               "Zliczenie" = "zliczenie"),
                                   selected = "Rozkład"
                       ),
                       selectInput("pagesVariableChoice",
                                   label = "Rozklad po:",
                                   choices = c("Całym okresie" = "time",
                                               "Chwili w dniu" = "daytime",
                                               "Dniu tygodnia" = "weekday",
                                               "Miesiącu" = "month"
                                   )
                       )
                ),
                column(8,
                       plotlyOutput("pagesPlot")
                )
              )
      )
      ,
      ####WYSZUKANIA
      tabItem(tabName = "wyszukania",
              
              fluidRow(
                column(4,
                       selectInput("searchPerson",
                                   "Wybierz użytkownika:",
                                   choices = c("Wszyscy"="wszyscy",
                                               "Agata" = "Agata",
                                               "Bartek" = "Bartek",
                                               "Mikołaj" = "Mikolaj")
                       )
                ),
                column(8,
                       plotOutput("searchWordcloud")
                )
              )
              
      )
    )
  )
  
  
)
  
server <- function(input, output, session) {
  #### DO OGÓLNE ####
  observe({
    os <- if(input$generalPerson=="wszyscy") c("Agata","Bartek","Mikolaj") else input$generalPerson
    updateDateRangeInput(session = session, inputId = "generalDateRange",
                   label = "Wybierz, z kiedy mają pochodzić dane",
                   start = min(main_df %>% filter(person %in% os) %>% .$time),
                   end = max(main_df %>% filter(person %in% os) %>% .$time),
                   min = min(main_df %>% filter(person %in% os) %>% .$time),
                   max = max(main_df %>% filter(person %in% os) %>% .$time)
    )
  })
  
  output$generalDensity <- renderPlotly({
    os <- if(input$generalPerson=="wszyscy") c("Agata","Bartek","Mikolaj") else input$generalPerson
    kolor <- switch(input$generalPerson,
                    "Agata"="#C30000",
                    "Mikolaj"="#EEB430",
                    "Bartek"="#427EE8",
                    "wszyscy"="#3BA251"
    )

    options(scipen = 999)
    ggfig <- main_df %>%
      filter(person  %in% os) %>%
      filter(time >= input$generalDateRange[1], time <= input$generalDateRange[2]) %>%
      ggplot() +
      geom_density(aes(x = daytime), alpha = 0.8, fill=kolor, color = kolor) +
      theme_minimal() +
      scale_x_datetime(date_label = "%H:%M")
    
    ggplotly(ggfig, height = 350) %>%
      config(displayModeBar = F)
    
  })
  
  output$generalBenchmark <- renderPlotly({
    os <- if(input$generalPerson=="wszyscy") c("Agata","Bartek","Mikolaj") else input$generalPerson
    kolor <- switch(input$generalPerson,
                    "Agata"="#C30000",
                    "Mikolaj"="#EEB430",
                    "Bartek"="#427EE8",
                    "wszyscy"="#3BA251"
    )
    df <- main_df %>%
      filter(person %in% os) %>%
      filter(time >= input$generalDateRange[1], time <= input$generalDateRange[2]) %>%
      mutate(website = fct_infreq(website)) %>%
      group_by(website) %>%
      summarise(count = n()) %>%
      arrange(-count) %>%
      head(10) %>%
      mutate(website = fct_rev(website))
    
    ggfig <- ggplot(df, aes(y = website, x = count)) +
      geom_segment(aes(y = website, yend = website, x = 0, xend = count)) +
      geom_point(size = 5, color = kolor, fill = alpha(kolor, 0.3), alpha = 0.7, shape = 21, stroke = 2) +
      labs(
        y = element_blank(),
        x = "Number of entries"
      ) +
      theme_minimal() +
      theme(
        legend.position = "none"
      )
    
    ggfig <- ggfig + geom_vline(xintercept = 0, color = "black", linetype = "solid", size = 1)
    
    ggplotly(ggfig, height = 350) %>%
      config(displayModeBar = F)
  })
  
  output$searchWordcloud <- renderPlot({
    os <- if(input$searchPerson=="wszyscy") c("Agata","Bartek","Mikolaj") else input$searchPerson

    mms <- main_most_search %>%
      filter(person %in% os) %>% 
      arrange(-count) %>% 
      head(200)

    words <- rep(mms$title, mms$count)

    wordcloud(words = words, scale=c(3,0.5), min.freq = 1, colors=brewer.pal(8, "Dark2"))
    
  })
  
  
  
  
  
  
  
  
  
  
  
  #### DO STRONY ####
  
  observe({
    os <- if(input$pagesPerson=="wszyscy") c("Agata","Bartek","Mikolaj") else input$pagesPerson
    updateDateRangeInput(session = session, inputId = "pagesDateRange",
                   label = "Wybierz, z kiedy mają pochodzić dane",
                   start = min(main_df %>% filter(person %in% os) %>% .$time),
                   end = max(main_df %>% filter(person %in% os) %>% .$time),
                   min = min(main_df %>% filter(person %in% os) %>% .$time),
                   max = max(main_df %>% filter(person %in% os) %>% .$time)
    )
  })
  
  observe({
    os <- if(input$pagesPerson=="wszyscy") c("Agata","Bartek","Mikolaj") else input$pagesPerson
    choices <- main_df %>%
      filter(person %in% os) %>%
      filter(time >= input$pagesDateRange[1], time <= input$pagesDateRange[2]) %>%
      group_by(website) %>%
      summarise(count = n()) %>%
      arrange(-count) %>% .$website
    
    updateSelectInput(session = session, inputId = "pagesChoice",
                label = "Wybierz stronę:",
                choices = choices,
    )
  })
  
  observe({
    if(input$pagesTypeChoice == "rozklad"){
      updateSelectInput(session = session, inputId = "pagesVariableChoice",
                  label = "Rozklad po:",
                  choices = c("Całym okresie" = "time",
                              "Chwili w dniu" = "daytime",
                              "Dniu tygodnia" = "weekday",
                              "Miesiącu" = "month"
                  )
      )
    } else{
      updateSelectInput(session = session, inputId = "pagesVariableChoice",
                  label = "Zliczanie w:",
                  choices = c("Miesiącach" = "month",
                              "Dniach tygodnia" = "weekday")
      )
    }
  })
  
  observe({
    output$pagesPlot <- renderPlotly({
    os <- if(input$pagesPerson=="wszyscy") c("Agata","Bartek","Mikolaj") else input$pagesPerson
    kolor <- switch(input$pagesPerson,
                    "Agata"="#C30000",
                    "Mikolaj"="#EEB430",
                    "Bartek"="#427EE8",
                    "wszyscy"="#3BA251"
    )
    df <- main_df %>%
      filter(person %in% os) %>%
      filter(time >= input$pagesDateRange[1], time <= input$pagesDateRange[2]) %>%
      filter(website == input$pagesChoice)
    
    if(input$pagesTypeChoice == "rozklad"){
      if(input$pagesVariableChoice %in% c("time", "daytime")){
        ggfig <- ggplot(df) +
          geom_density(aes_string(x = input$pagesVariableChoice), alpha = 0.8, fill=kolor, color = kolor) +
          theme_minimal()
        
        if(input$pagesVariableChoice == "daytime"){
          ggfig <- ggfig + scale_x_datetime(date_label = "%H:%M")
        } else{
          
        }
      } else{
        ggfig <- ggplot(df) +
          geom_violin(aes_string(x = input$pagesVariableChoice, y = "daytime"), alpha = 0.4, fill=kolor, color = kolor) +
          geom_boxplot(aes_string(x = input$pagesVariableChoice, y = "daytime"), fill=kolor, color = kolor) +
          theme_minimal() +
          scale_y_datetime(date_label = "%H:%M") +
          coord_flip()
      }
    }else{
      if(input$pagesVariableChoice == "weekday"){
        df <- df %>%
          group_by(weekday) %>%
          summarise(count = n())
      } else {
        df <- df %>%
          group_by(month) %>%
          summarise(count = n())
      }
      ggfig <- ggplot(df, aes_string(y = input$pagesVariableChoice, x = "count")) +
        geom_segment(aes_string(y = input$pagesVariableChoice, yend = input$pagesVariableChoice, x = 0, xend = "count")) +
        geom_point(size = 5, color = kolor, fill = alpha(kolor, 0.3), alpha = 0.7, shape = 21, stroke = 2) +
        labs(
          y = element_blank(),
          x = "Number of entries"
        ) +
        theme_minimal() +
        theme(
          legend.position = "none"
        )
      
      ggfig <- ggfig + geom_vline(xintercept = 0, color = kolor, linetype = "solid", size = 1)
    }
    ggplotly(ggfig, height = 700) %>%
      config(displayModeBar = F)
  })
  })
  
  
  ####
  output$a <- renderImage({
    
    list(src = "ia.png",
         height = 300,
         width=300)
    
  }, deleteFile = F)
  
  
  output$b <- renderImage({
    
    list(src = "ib.png",
         height = 300,
         width=300)
    
  }, deleteFile = F)
  
  output$m <- renderImage({
    
    list(src = "im.png",
         height = 300,
         width=300)
    
  }, deleteFile = F)
  output$logo <- renderImage({
    list(src = "logo.png",
         width = "100%",
         height = "100%")
    
  }, deleteFile = F)
  
  output$choice <- renderImage({
    name=switch(input$person,
                "Agata" = "ia.png",
                "Mikolaj" = "im.png",
                "Bartek" = "ib.png",
                "wszyscy"="ic.png")
    
    list(src = name,
         height = 100,
         width=100)
    
  }, deleteFile = F)
  
}

# Run the application 
shinyApp(ui = main_ui, server = server)




