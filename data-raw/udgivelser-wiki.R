library(tidyverse)
library(rvest)
library(xml2)
library(spotifyr)

# grabser tabeller fra wikipedia.
# der er behov for en del oprydning

diskografi <- "https://en.wikipedia.org/wiki/David_Bowie_discography"
tabeller <- read_html(diskografi) %>%
  html_table()

primary_studio_albums                  <- tabeller[[2]]
unreleased_studio_albums               <- tabeller[[3]]
re_recorded_studio_albums              <- tabeller[[4]]
studio_albums_as_member_of_tin_machine <- tabeller[[5]]
live_albums                            <- tabeller[[6]]
live_albums_as_member_of_tin_machine   <- tabeller[[7]]
soundtrack_albums                      <- tabeller[[8]]
compilation_albums_1970s               <- tabeller[[9]]
compilation_albums_1980s               <- tabeller[[10]]
compilation_albums_1990s               <- tabeller[[11]]
compilation_albums_2000s               <- tabeller[[12]]
compilation_albums_2010s               <- tabeller[[13]]
era_box_sets                           <- tabeller[[14]]
other_box_sets                         <- tabeller[[15]]
ep                                     <- tabeller[[16]]
singles_1960s                          <- tabeller[[17]]
singles_1970s                          <- tabeller[[18]]
singles_1970s_promotional              <- tabeller[[19]]
singles_1980s                          <- tabeller[[20]]
singles_1990s                          <- tabeller[[21]]
singles_2000s                          <- tabeller[[22]]
singles_2010s                          <- tabeller[[23]]
singles_2020s                          <- tabeller[[24]]
singles_as_member_of_tin_machine       <- tabeller[[25]]
studio_contributions                   <- tabeller[[26]]
live_contributions                     <- tabeller[[27]]
guest_apperances                       <- tabeller[[28]]
remixes_and_alternate_versions         <- tabeller[[29]]


# Primære studie albums.

# Isolerer år og titel mhp at trække data fra spotify
# Manuel redigering af "Toy" som Spotify mener er fra 2022
# Af "Pin Ups" som de kalder for "PinUps" og
# "Let's Dance", der skal søges som "lets dance". Formentlig fordi
# apostroffen giver bøvl.
# Og så er der The Buddha of Suburbia, hvor Spotify ikke anerkender "the"

test <- primary_studio_albums %>%
  select(Title, details=`Album details`) %>%
  filter(str_detect(details, "Released")) %>%
  mutate(year = str_extract(details, "\\d{4}")) %>%
  mutate(year = case_when(
    Title == "Toy" ~ "2022",
    .default = year)) %>%
  mutate(Title = case_when(
    Title == "Pin Ups" ~ "pinups",
    Title == "Let's Dance" ~ "lets dance",
    Title == "The Buddha of Suburbia" ~ "Buddha of Suburbia",
    .default = Title)
    )




# Genererer Spotify søgestreng, og søger i Spotify
test <- test %>%
  mutate(spot_string = str_c("year:",year, " artist:David Bowie album:",Title )) %>%
  mutate(spot_data = map(spot_string, search_spotify, type = "album"))


test %>%
  unnest(spot_data) %>%
  filter(album_type %in% c("album", "compilation")) %>%
  pull(Title)
s
