library(shiny)
library(shinyMobile)
# library(apexcharter)
library(shinyWidgets)
#library(data.table)
library(tidyverse)

# for maps
library(leaflet)
library(leaflet.extras)

# library(reticulate)
# pd <- import("pandas")
# pickle_data <- pd$read_pickle("dataset.pickle")

data = fread('cleaned_data.csv')
data = data.frame(data)

shinyApp(
  ui = f7Page(
    title = "Postcode Filter",
    f7TabLayout(
      # panels = tagList(
      #   f7Panel(title = "Left Panel", side = "left", theme = "light", "Blabla", effect = "cover"),
      #   f7Panel(title = "Right Panel", side = "right", theme = "dark", "Blabla", effect = "cover")
      # ),
      navbar = f7Navbar(
        title = "Postcode Filter",
        hairline = TRUE,
        shadow = TRUE,
        leftPanel = FALSE,
        rightPanel = FALSE
      ),
      f7Tabs(
        animated = TRUE,
        
        f7Tab(
          tabName = "Input",
          icon = f7Icon("keyboard"),
          active = TRUE,
          
          f7Flex(
            prettyRadioButtons(
              inputId = "theme",
              label = "Select a theme:",
              thick = TRUE,
              inline = TRUE,
              selected = "md",
              choices = c("ios", "md"),
              animation = "pulse",
              status = "info"
            ),
            
            prettyRadioButtons(
              inputId = "color",
              label = "Select a color:",
              thick = TRUE,
              inline = TRUE,
              selected = "dark",
              choices = c("light", "dark"),
              animation = "pulse",
              status = "info"
            )
          ),
          
          tags$head(
            tags$script(
              'Shiny.addCustomMessageHandler("ui-tweak", function(message) {
                var os = message.os;
                var skin = message.skin;
                if (os === "md") {
                  $("html").addClass("md");
                  $("html").removeClass("ios");
                  $(".tab-link-highlight").show();
                } else if (os === "ios") {
                  $("html").addClass("ios");
                  $("html").removeClass("md");
                  $(".tab-link-highlight").hide();
                }

                if (skin === "dark") {
                 $("html").addClass("theme-dark");
                } else {
                  $("html").removeClass("theme-dark");
                }

               });
              '
            )
          ),
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Input postcode",
              f7Text(inputId = 'postcode',
                     label = h3('Postcode'),
                     value = 'PE2 6SX')
            )
          ),
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Press on the button to update outputs",
              f7Button(
                inputId = "action",
                label = "Action",
                color = "purple",
                outline = FALSE,
                fill = TRUE,
                shadow = TRUE,
                rounded = TRUE,
                size = 'small')
            )
          )
          
        ),
        
        
        f7Tab(
          tabName = "General",
          icon = f7Icon("info_circle"),
          active = FALSE,
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = textOutput("general_pcds"),
              htmlOutput('info_pcds')
            )
          ),
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Map",
              textOutput("latlong"),
              leafletOutput(outputId = "mymap"),
              f7Checkbox("district", "District", FALSE)
            )
          )
          
          
        ),
        
        
        f7Tab(
          tabName = "Flood and Elevation",
          icon = f7Icon("drop"),
          active = FALSE,
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = textOutput("flood_elevation_pcd")
            )
          ),
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Flood Risks",
              htmlOutput("flood_risk")
            )
          ),
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Elevation",
              htmlOutput("elevation_details")
            )
          )
        ),
        
        
        f7Tab(
          tabName = "Pets",
          icon = f7Icon("cat"),
          active = FALSE,
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = textOutput("pets_pcd")
            )
          ),
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Cats",
              htmlOutput('cats_details'),
              plotOutput("cats_hist")
            )
          ),
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Dogs",
              htmlOutput('dogs_details'),
              plotOutput("dogs_hist")
            )
          )
        ),
        
        
        f7Tab(
          tabName = "Deprivation",
          icon = f7Icon("layers_alt"),
          active = FALSE,
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = textOutput("imd_pcd")
            )
          ),
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Card(
              title = "Summary",
              htmlOutput('imd_details')
            )
          ),
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Align(
              f7Card(
                f7Gauge(
                  id = "imd_global",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#2196f3",
                  borderWidth = 10,
                  valueTextColor = "#2196f3",
                  labelText = "IMD Global"
                )
              ),
              side = 'center')
          ),
          
          
          f7Shadow(
            intensity = 10,
            hover = TRUE,
            f7Align(
              f7Card(
                f7Gauge(
                  id = "imd_income",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#3fac32",
                  borderWidth = 10,
                  valueTextColor = "#3fac32",
                  labelText = "IMD Income"
                ),
                f7Gauge(
                  id = "imd_employment",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#3fac32",
                  borderWidth = 10,
                  valueTextColor = "#3fac32",
                  labelText = "IMD Employment"
                ),
                f7Gauge(
                  id = "imd_education",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#3fac32",
                  borderWidth = 10,
                  valueTextColor = "#3fac32",
                  labelText = "IMD Education"
                ),
                f7Gauge(
                  id = "imd_health",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#3fac32",
                  borderWidth = 10,
                  valueTextColor = "#3fac32",
                  labelText = "IMD Health"
                ),
                f7Gauge(
                  id = "imd_crime",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#3fac32",
                  borderWidth = 10,
                  valueTextColor = "#3fac32",
                  labelText = "IMD Crime"
                ),
                f7Gauge(
                  id = "imd_services",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#3fac32",
                  borderWidth = 10,
                  valueTextColor = "#3fac32",
                  labelText = "IMD Services"
                ),
                f7Gauge(
                  id = "imd_living_environment",
                  type  = "semicircle",
                  value = 0,
                  borderColor = "#3fac32",
                  borderWidth = 10,
                  valueTextColor = "#3fac32",
                  labelText = "IMD Living Environment"
                )
              ),
              side = 'center')
          ),
          
          
        )
      )
    )
  ),
  server = function(input, output, session) {
    
    get_data = eventReactive(input$action, {
      mypostcode = input$postcode
      data_output = data[data['pcds'] == mypostcode,]
      return(data_output)
    })
    
    get_district = eventReactive(input$action, {
      my_district = data[data['pcds'] == input$postcode,][["district"]]
      data_output = data[data['district'] == my_district,
                         c('district','lat','long',
                           'cats_by_district','dogs_by_household')]
      return(data_output)
    })
    
    output$general_pcds <- renderText(
      paste0("General info for ",
             get_data()[['pcds']],":"))
    
    output$info_pcds <- renderUI({
      lsoa = paste0( "The LSOA is ", get_data()[['lsoa11']] )
      district = paste0(   "The district is ", get_data()[['district']])
      sector = paste0(   "The sector is ", get_data()[['sector']])
      HTML(paste(
        lsoa, district, sector, sep = '<br/>'))
    })
    
    output$latlong <- renderText(paste0( "Latitude ",
                                         get_data()[['lat']],
                                         " - Longitude ",
                                         get_data()[['long']]))
    
    # map output
    output$mymap <- renderLeaflet({
      leaflet(get_data()) %>% 
        setView(lng = -1.77,
                lat = 53, 
                zoom = 6)  %>%
        addTiles() %>%
        addMarkers(data = get_data(), 
                   popup = ~as.character(pcds),
                   lng = ~long,
                   lat = ~lat
        )
    })
    
    observe({
      proxy <- leafletProxy("mymap",
                            data = get_district())
      
      if (input$district) {
        proxy %>%
          addCircles(
            radius = 2,
            color = 'orange',
            fillOpacity = 0.2,
            label = paste0("District")) %>%
          addLegend("bottomright",
                    colors = 'orange',
                    values = unique(get_district()[['district']]),
                    labels = "District",
                    opacity = 0.4)}
      else {
        proxy %>% clearShapes() %>% clearControls()
      }
    })
    
    # flood risk and elevation
    output$flood_elevation_pcd <- renderText(
      paste0("Info on flood and elevation for ",
             get_data()[['pcds']],":"))
    
    output$flood_risk <- renderUI({
      risk = paste0( 
        "The risk on Flooding is set to '", 
        get_data()[['flood_risk']] ,
        "'")
      risk_for_insurance = paste0( 
        "The risk on insurance is set to '", 
        get_data()[['risk_for_insurance']],
        "'")
      
      if(get_data()[['flood_value_from']] == "raw_postcode"){
        flood_value_from = "(value found from raw data)"
      }else if(get_data()[['flood_value_from']] == "average_district"){
        flood_value_from = "(value calculated by taking the average in the district)"
      }else{
        flood_value_from = "(value calculated by taking the average in the sector)"
      }
      
      HTML(paste(
        risk, risk_for_insurance, flood_value_from, sep = '<br/><br/>'))
    })
    
    
    output$elevation_details <- renderUI({
      elevation = paste0( 
        "The postcode is at ", 
        get_data()[['elevation']] ,
        "m above the sea level.")
      
      if(get_data()[['elevation_value_from']] == "raw_postcode"){
        elevation_value_from = "(value found from raw data)"
      }else if(get_data()[['elevation_value_from']] == "average_district"){
        elevation_value_from = "(value calculated by taking the average in the district)"
      }else{
        elevation_value_from = "(value calculated by taking the average in the sector)"
      }
      
      HTML(paste(
        elevation, 
        elevation_value_from, sep = '<br/><br/>'))
    })
    
    
    # pets
    
    output$pets_pcd <- renderText(
      paste0("Info on cats and pets for ",
             get_data()[['pcds']],":"))
    
    output$cats_details <- renderUI({
      cats = paste0( 
        "We have ", 
        get_data()[['cats_by_district']] ,
        " cats in the district.")
      
      if(get_data()[['pets_value_from']] == "raw_district"){
        cats_value_from = "(value found from raw data)"
      }else{
        cats_value_from = "(value calculated by taking the average in the sector)"
      }
      
      cats_quantile <- ecdf(data[['cats_by_district']])
      
      cat_q <- paste0("This value is the ",
                      round(100*cats_quantile(get_data()[['cats_by_district']]),2),
                      "% quantile")
      
      HTML(paste(
        cats, 
        cat_q,
        cats_value_from, sep = '<br/><br/>'))
    })
    
    output$cats_hist <- renderPlot({
      
      data %>%
        ggplot()+
        geom_histogram(aes(x = cats_by_district),
                       binwidth = 500,
                       fill = '#2196f3',
                       color = '#1c89df'
        ) +
        geom_vline(xintercept = get_data()[['cats_by_district']],
                   colour = 'red',
                   size = 1        )+
        theme_light()+
        labs(title = "Distribution of cats per district",
             x = "cats",
             y = "nb of postcodes")+
        theme(plot.title = element_text(hjust = 0.5,
                                        size = 14))
      
    })
    
    
    output$dogs_details <- renderUI({
      dogs = paste0( 
        "We have ", 
        round(get_data()[['dogs_by_household']],4) ,
        " dogs by house in the district.")
      
      if(get_data()[['pets_value_from']] == "raw_district"){
        dogs_value_from = "(value found from raw data)"
      }else{
        dogs_value_from = "(value calculated by taking the average in the sector)"
      }
      
      dogs_quantile <- ecdf(data[['dogs_by_household']])
      
      dog_q <- paste0("This value is the ",
                      round(100*dogs_quantile(get_data()[['dogs_by_household']]),2),
                      "% quantile")
      
      HTML(paste(
        dogs, 
        dog_q,
        dogs_value_from, sep = '<br/><br/>'))
    })
    
    output$dogs_hist <- renderPlot({
      
      data %>%
        ggplot()+
        geom_histogram(aes(x = dogs_by_household),
                       binwidth = 0.1,
                       fill = '#5bd724',
                       color = '#4bb41d'
        ) +
        geom_vline(xintercept = get_data()[['dogs_by_household']],
                   colour = 'red',
                   size = 1        )+
        theme_light()+
        labs(title = "Distribution of dogs per district",
             x = "dogs",
             y = "nb of postcodes")+
        theme(plot.title = element_text(hjust = 0.5,
                                        size = 14))
      
    })
    
    # IMD
    output$imd_pcd <- renderText(
      paste0("Info on deprivation for ",
             get_data()[['pcds']],":"))
    
    
    output$imd_details <- renderUI({
      
      HTML(paste0(
        'Since the 1970s the Ministry of Housing, ',
        'Communities and Local Government and its predecessors ',
        'have calculated local measures of deprivation in England.<br/>',
        'There are 32844 areas in England, all listed from 1 (worst) to ',
        '32844 (best).<br/>',
        'There are 7 domains of deprivation, which combine to create the Global one:<br/>',
        '- Income<br/>',
        '- Employment <br/>',
        '- Education <br/>',
        '- Health <br/>',
        '- Crime <br/>',
        '- Barriers to Housing and Services <br/>',
        '- Living Environment <br/>'
      ))
    })
    
    observeEvent(input$action, {
      updateF7Gauge(id = "imd_global", 
                    value = round(get_data()[['imd_global_rank']]/32844*100,2))
    
      updateF7Gauge(id = "imd_income", 
                    value = round(get_data()[['imd_income_rank']]/32844*100,2))
    
      updateF7Gauge(id = "imd_employment", 
                    value = round(get_data()[['imd_employment_rank']]/32844*100,2))
    
      updateF7Gauge(id = "imd_education", 
                    value = round(get_data()[['imd_education_rank']]/32844*100,2))
    
      updateF7Gauge(id = "imd_health", 
                    value = round(get_data()[['imd_health_rank']]/32844*100,2))
    
      updateF7Gauge(id = "imd_crime", 
                    value = round(get_data()[['imd_crime_rank']]/32844*100,2))
    
      updateF7Gauge(id = "imd_services", 
                    value = round(get_data()[['imd_services_rank']]/32844*100,2))
    
      updateF7Gauge(id = "imd_living_environment", 
                    value = round(get_data()[['imd_living_environment_rank']]/32844*100,2))
    })
    
    
    # send the theme to javascript
    observe({
      session$sendCustomMessage(
        type = "ui-tweak",
        message = list(os = input$theme, skin = input$color)
      )
    })
    
  }
)
