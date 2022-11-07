library(tidyverse)
library(readxl)
library(data.table)

# library(reticulate)
# pd <- import("pandas")
# pickle_data <- pd$read_pickle("dataset.pickle")


# 1 Import dictionary ----------------------------------------------------------


# dictionary from postcode to lsoa, msoa, district, etc
dictionary <- read.csv("data/NSPL_NOV_2019_UK/Data/NSPL_NOV_2019_UK.csv") %>%
  select(-usertype,
         -oseast1m,
         -osnrth1m,
         -osgrdind,
         -dointr,
         -doterm)%>%
  mutate(district = str_extract(pcds,"[^ ]+"),
         sector = substr(district, start = 1, stop = 2),
         sector = sub("^([[:alpha:]]*).*", "\\1", sector)) %>%
  filter(ctry == 'E92000001') # only for England

districts = dictionary %>%
  group_by(district, sector) %>%
  summarise(count = n()) %>%
  ungroup()

lsoas = dictionary %>%
  group_by(lsoa11) %>%
  summarise(count = n()) %>%
  ungroup()

# 2 Cleaning data ---------------------------------------------------------


# 2.1 pets ----------------------------------------------------------------

cats <- read.csv('data/cat-population-per-postcode-district-1.csv')
dogs <- read.csv('data/dogs-per-household-per-postcode-district-lower-95th-percentile-1.csv')


pets_districts = districts %>%
  left_join(cats,
            by = c("district" = "PostcodeDistrict"))%>%
  left_join(dogs,
            by = c("district" = "PostcodeDistrict")) %>%
  mutate(
    EstimatedCatPopulation = as.numeric(gsub(",","",EstimatedCatPopulation))
  )

pets_existing = pets_districts %>%
  filter(!is.na(EstimatedCatPopulation)) %>%
  mutate(pets_value_from = "raw_district")

pets_sector = pets_existing %>%
  group_by(sector) %>%
  summarise(EstimatedCatPopulation = mean(EstimatedCatPopulation),
            DogsPerHousehold_lower95 = mean(DogsPerHousehold_lower95)) %>%
  ungroup()

pets_missing = pets_districts %>%
  filter(is.na(EstimatedCatPopulation)) %>%
  select(-EstimatedCatPopulation, -DogsPerHousehold_lower95) %>%
  left_join(pets_sector,
            by = "sector")%>%
  mutate(pets_value_from = "average_sector")

pets_final <- rbind(pets_existing ,
                    pets_missing) %>%
  rename(cats_by_district = EstimatedCatPopulation,
          dogs_by_household = DogsPerHousehold_lower95) %>%
  select(-count,-sector)

# check we do not have any missing value!
dim(filter(pets_final,is.na(cats_by_district)))[1] == 0

remove(cats,dogs,pets_districts,pets_existing,pets_sector,pets_missing)


# 2.2 IMD -----------------------------------------------------------------

imd <- read_excel("data/File_2_-_IoD2019_Domains_of_Deprivation.xlsx",
                   sheet = 'IoD2019 Domains') %>%
  select(lsoa, contains("imd"))

imd_final <- lsoas %>%
  inner_join(imd,
             by = c('lsoa11' = 'lsoa')) %>%
  select(-count)

remove(imd)


# 2.3 flood ---------------------------------------------------------------

flood_pcd <- read.csv('data/open_flood_risk_by_postcode.csv')

names(flood_pcd) <- c('postcode', 'id','flood_risk','suitability','date','risk_for_insurance','easting','northing','latitude','longitude')

flood_pcd <- select(flood_pcd,
                postcode,
                flood_risk,
                risk_for_insurance)

flood_pcd <- dictionary %>%
  select(pcds) %>%
  left_join(flood_pcd,
            by = c('pcds'='postcode'))

# #flood risk:
# None - 0
# Very Low - 1
# Low - 2
# Medium - 3
# High - 4

flood_dst <- flood_pcd %>%
  #filter(flood_risk != 'None') %>%
  mutate(flood_risk = case_when(flood_risk == "None" ~ 0,
                                flood_risk == "Very Low" ~ 1,
                                flood_risk == "Low" ~ 2,
                                flood_risk == "Medium" ~ 3,
                                TRUE ~ 4),
         risk_for_insurance = case_when(risk_for_insurance == 'No' ~ 0,
                                        TRUE ~ 1)) %>%
  mutate(district = str_extract(pcds,"[^ ]+")) %>%
  group_by(district) %>%
  summarize(flood_risk = round(mean(flood_risk),0),
            risk_for_insurance = round(mean(risk_for_insurance),0)) %>%
  mutate(flood_risk = case_when(flood_risk == 0 ~ "None",
                                flood_risk == 1 ~ "Very Low",
                                flood_risk == 2 ~ "Low",
                                flood_risk == 3 ~ "Medium",
                                TRUE ~ 'High'),
         risk_for_insurance = case_when(risk_for_insurance == 0 ~ 'No',
                                        TRUE ~ "Yes"))%>%
  mutate(flood_value_from = "average_district")

flood_sct <- flood_pcd %>%
  #filter(flood_risk != 'None') %>%
  mutate(flood_risk = case_when(flood_risk == "None" ~ 0,
                                flood_risk == "Very Low" ~ 1,
                                flood_risk == "Low" ~ 2,
                                flood_risk == "Medium" ~ 3,
                                TRUE ~ 4),
         risk_for_insurance = case_when(risk_for_insurance == 'No' ~ 0,
                                        TRUE ~ 1)) %>%
  mutate(district = str_extract(pcds,"[^ ]+"),
         sector = substr(district, start = 1, stop = 2),
         sector = sub("^([[:alpha:]]*).*", "\\1", sector)) %>%
  group_by(sector) %>%
  summarize(flood_risk = round(mean(flood_risk),0),
            risk_for_insurance = round(mean(risk_for_insurance),0)) %>%
  mutate(flood_risk = case_when(flood_risk == 0 ~ "None",
                                flood_risk == 1 ~ "Very Low",
                                flood_risk == 2 ~ "Low",
                                flood_risk == 3 ~ "Medium",
                                TRUE ~ 'High'),
         risk_for_insurance = case_when(risk_for_insurance == 0 ~ 'No',
                                        TRUE ~ "Yes"))%>%
  mutate(flood_value_from = "average_sector")

flood_ctr <- flood_pcd %>%
  filter(flood_risk != 'None') %>%
  mutate(flood_risk = case_when(flood_risk == "None" ~ 0,
                                flood_risk == "Very Low" ~ 1,
                                flood_risk == "Low" ~ 2,
                                flood_risk == "Medium" ~ 3,
                                TRUE ~ 4),
         risk_for_insurance = case_when(risk_for_insurance == 'No' ~ 0,
                                        TRUE ~ 1)) %>% 
  mutate(ctr = 'E') %>%
  group_by(ctr) %>%
  summarize(flood_risk = round(mean(flood_risk),0),
            risk_for_insurance = round(mean(risk_for_insurance),0)) %>%
  mutate(flood_risk = case_when(flood_risk == 0 ~ "None",
                                flood_risk == 1 ~ "Very Low",
                                flood_risk == 2 ~ "Low",
                                flood_risk == 3 ~ "Medium",
                                TRUE ~ 'High'),
         risk_for_insurance = case_when(risk_for_insurance == 0 ~ 'No',
                                        TRUE ~ "Yes"))%>%
  mutate(flood_value_from = "average_country")


flood_pcd_e <- flood_pcd %>%
  filter(!is.na(flood_risk)) %>%
  mutate(flood_value_from = "raw_postcode")

flood_pcd_m_dst = flood_pcd %>%
  filter(is.na(flood_risk) ) %>%
  mutate(district = str_extract(pcds,"[^ ]+")) %>%
  select(pcds, district) %>%
  left_join(flood_dst,
            by = 'district')

flood_pcd_m_dst_e <- flood_pcd_m_dst %>%
  filter(!is.na(flood_risk)) %>%
  select(-district)

flood_pcd_m_dst_m <- flood_pcd_m_dst %>%
  filter(is.na(flood_risk))


flood_pcd_m_dst_m_sct <- flood_pcd_m_dst_m %>%
  mutate(district = str_extract(pcds,"[^ ]+"),
         sector = substr(district, start = 1, stop = 2),
         sector = sub("^([[:alpha:]]*).*", "\\1", sector)) %>%
  select(pcds, sector) %>%
  left_join(flood_sct,
            by = 'sector')

flood_pcd_m_dst_m_sct_e <- flood_pcd_m_dst_m_sct %>%
  filter(!is.na(flood_risk)) %>%
  select(-sector)

flood_pcd_m_dst_m_sct_m <- flood_pcd_m_dst_m_sct %>%
  filter(is.na(flood_risk))

flood_final = rbind(
  flood_pcd_e,
  flood_pcd_m_dst_e,
  flood_pcd_m_dst_m_sct_e
)

# check we do not have any missing value!
dim(filter(flood_final,is.na(flood_risk)))[1] == 0

remove(flood_ctr,flood_dst,flood_pcd,flood_pcd_e,flood_sct,
       flood_pcd_m_dst, flood_pcd_m_dst_e, flood_pcd_m_dst_m,
       flood_pcd_m_dst_m_sct,flood_pcd_m_dst_m_sct_e,flood_pcd_m_dst_m_sct_m)

# 2.4 Elevation -----------------------------------------------------------


elevation <- read.csv('data/open_postcode_elevation.csv')
names(elevation) <- c("postcode","elevation") 


elevation_pcd <- dictionary %>%
  select(pcds) %>%
  left_join(elevation,
            by = c('pcds'='postcode'))



elevation_dst <- elevation_pcd %>%
  filter(!is.na(elevation) ) %>%
  mutate(district = str_extract(pcds,"[^ ]+")) %>%
  group_by(district) %>%
  summarize(elevation = round(mean(elevation),0)) %>%
  mutate(elevation_value_from = "average_district")

elevation_sct <- elevation_pcd %>%
  filter(!is.na(elevation) ) %>%
  mutate(district = str_extract(pcds,"[^ ]+"),
         sector = substr(district, start = 1, stop = 2),
         sector = sub("^([[:alpha:]]*).*", "\\1", sector)) %>%
  group_by(sector) %>%
  summarize(elevation = round(mean(elevation),0)) %>%
  mutate(elevation_value_from = "average_sector")

elevation_ctr <- elevation_pcd %>%
  filter(!is.na(elevation) ) %>%
  mutate(ctr = 'E') %>%
  group_by(ctr) %>%
  summarize(elevation = round(mean(elevation),0)) %>%
  mutate(elevation_value_from = "average_country")


elevation_pcd_e <- elevation_pcd %>%
  filter(!is.na(elevation)) %>%
  mutate(elevation_value_from = "raw_postcode")

elevation_pcd_m_dst = elevation_pcd %>%
  filter(is.na(elevation) ) %>%
  mutate(district = str_extract(pcds,"[^ ]+")) %>%
  select(pcds, district) %>%
  left_join(elevation_dst,
            by = 'district')

elevation_pcd_m_dst_e <- elevation_pcd_m_dst %>%
  filter(!is.na(elevation)) %>%
  select(-district)

elevation_pcd_m_dst_m <- elevation_pcd_m_dst %>%
  filter(is.na(elevation))


elevation_pcd_m_dst_m_sct <- elevation_pcd_m_dst_m %>%
  mutate(district = str_extract(pcds,"[^ ]+"),
         sector = substr(district, start = 1, stop = 2),
         sector = sub("^([[:alpha:]]*).*", "\\1", sector)) %>%
  select(pcds, sector) %>%
  left_join(elevation_sct,
            by = 'sector')

elevation_pcd_m_dst_m_sct_e <- elevation_pcd_m_dst_m_sct %>%
  filter(!is.na(elevation)) %>%
  select(-sector)

elevation_pcd_m_dst_m_sct_m <- elevation_pcd_m_dst_m_sct %>%
  filter(is.na(elevation))

elevation_final = rbind(
  elevation_pcd_e,
  elevation_pcd_m_dst_e,
  elevation_pcd_m_dst_m_sct_e
)

# check we do not have any missing value!
dim(filter(elevation_final,is.na(elevation)))[1] == 0

remove(elevation,elevation_ctr,elevation_dst,elevation_pcd,elevation_sct,
       elevation_pcd_e,elevation_pcd_m_dst,
       elevation_pcd_m_dst_e,elevation_pcd_m_dst_m,elevation_pcd_m_dst_m_sct,
       elevation_pcd_m_dst_m_sct_e, elevation_pcd_m_dst_m_sct_m)


# 3 GROUPING ALL TOGETHER -------------------------------------------------

data <- dictionary %>%
  select(
    pcds,
    lsoa11,
    district,
    sector,
    lat,
    long,
    imd
  ) %>%
  left_join(
    pets_final,
    by = "district"
  ) %>%
  left_join(
    imd_final,
    by = "lsoa11"
  ) %>%
  left_join(
    flood_final,
    by = "pcds"
  ) %>%
  left_join(
    elevation_final,
    by = "pcds"
  )

save(data,
     file = "cleaned_data.RData")

data.table::fwrite(data,
                   "cleaned_data.csv")
