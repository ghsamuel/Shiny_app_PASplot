library(shiny)
library(ggplot2)
library(ggrepel)
library(dplyr)
library(DT)

# UI
ui <- fluidPage(
  titlePanel("🧬 PAS Bubble Plot Generator"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      h3("📁 Input Data"),
      
      # Input method
      radioButtons("input_method", "Choose input method:",
                   choices = c("Paste Data" = "paste",
                               "Upload CSV Files" = "upload",
                               "Use Example Data" = "example"),
                   selected = "example"),
      
      # Conditional inputs based on method
      conditionalPanel(
        condition = "input.input_method == 'upload'",
        fileInput("pas_file", "1. PAS Sites CSV", accept = ".csv"),
        fileInput("tx_file", "2. Transcript Info CSV", accept = ".csv"),
        fileInput("expr_file", "3. Expression Data CSV", accept = ".csv")
      ),
      
      conditionalPanel(
        condition = "input.input_method == 'paste'",
        p("See Instructions tab for format"),
        textAreaInput("pas_text", "1. PAS Sites (CSV)", 
                      value = "pas,coord\nlong,40624962\nmedium,40627710\nshort,40628724",
                      rows = 4),
        textAreaInput("tx_text", "2. Transcript Info (CSV)",
                      value = "tx_id,start\nTX1,40628980\nTX2,40627710\nTX3,40624962",
                      rows = 4),
        textAreaInput("expr_text", "3. Expression Data (CSV)",
                      value = "tx_id,WT,KD\nTX1,52.98,55.12\nTX2,24.56,17.89\nTX3,29.34,11.28",
                      rows = 4)
      ),
      
      hr(),
      
      h3("⚙️ Settings"),
      numericInput("pas_window", "PAS Window (bp)", value = 100, min = 10, step = 10),
      textInput("plot_title", "Plot Title", value = "Transcript 3' ends relative to PAS sites"),
      textInput("x_axis_label", "X-axis Label", value = "Genomic coordinate"),
      checkboxInput("show_labels", "Show transcript labels", value = TRUE),
      
      hr(),
      
      actionButton("generate", "🎨 Generate Plot", class = "btn-primary btn-lg btn-block"),
      
      hr(),
      
      downloadButton("download_png", "Download PNG (600 DPI)", class = "btn-block"),
      downloadButton("download_pdf", "Download PDF (Vector)", class = "btn-block")
    ),
    
    mainPanel(
      width = 9,
      
      tabsetPanel(
        tabPanel("Plot",
                 plotOutput("plot", height = "600px")),
        
        tabPanel("Preview Data",
                 h4("PAS Sites"),
                 DTOutput("preview_pas"),
                 h4("Transcript Info"),
                 DTOutput("preview_tx"),
                 h4("Expression Data"),
                 DTOutput("preview_expr")),
        
        tabPanel("Instructions",
                 h3("How to Use"),
                 p("This app creates publication-quality bubble plots showing transcript 3' ends relative to polyadenylation sites."),
                 
                 h4("Required Data Format"),
                 
                 h5("1. PAS Sites"),
                 pre("pas,coord\nlong,40624962\nmedium,40627710\nshort,40628724"),
                 
                 h5("2. Transcript Info"),
                 pre("tx_id,start\nENST001,40628980\nENST002,40627710\nENST003,40624962"),
                 p(strong("Important:"), "Use 'start' column for minus-strand genes, 'end' for plus-strand genes"),
                 
                 h5("3. Expression Data"),
                 pre("tx_id,WT,KD\nENST001,52.98,55.12\nENST002,24.56,17.89\nENST003,29.34,11.28"),
                 p("For 3+ conditions, just add more columns: Control,Treatment_1h,Treatment_6h,Treatment_24h"),
                 
                 h4("Features"),
                 tags$ul(
                   tags$li("Auto PAS assignment - transcripts assigned to nearest PAS within window"),
                   tags$li("Multiple conditions - handles 2, 3, 4+ conditions automatically"),
                   tags$li("Multiple PAS sites - works with any number of sites"),
                   tags$li("Publication quality - ggplot2 rendering, high-res output")
                 ),
                 
                 h4("Tips"),
                 tags$ul(
                   tags$li("Use 'Example Data' to see the format"),
                   tags$li("Paste data for quick testing (<10 transcripts)"),
                   tags$li("Upload CSV for larger datasets"),
                   tags$li("Adjust PAS window if transcripts aren't assigned (try 200bp or 500bp)")
                 ))
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Color palette
  color_palette <- c(
    long = "#2A9D8F",
    medium = "#E76F51",
    short = "#4A90D9",
    unassigned = "grey50"
  )
  
  # Reactive data
  pas_data <- reactive({
    if (input$input_method == "example") {
      data.frame(
        pas = c("long", "medium", "short"),
        coord = c(40624962, 40627710, 40628724)
      )
    } else if (input$input_method == "paste") {
      req(input$pas_text)
      read.csv(text = input$pas_text, stringsAsFactors = FALSE)
    } else {
      req(input$pas_file)
      read.csv(input$pas_file$datapath, stringsAsFactors = FALSE)
    }
  })
  
  tx_data <- reactive({
    if (input$input_method == "example") {
      data.frame(
        tx_id = c("ENST00000431889.6", "ENST00000646448.1", "ENST00000450046.7",
                  "ENST00000618765.5", "ENST00000494549.5", "ENST00000482308.5"),
        start = c(40628980, 40628724, 40627710, 40627652, 40625006, 40624962)
      )
    } else if (input$input_method == "paste") {
      req(input$tx_text)
      read.csv(text = input$tx_text, stringsAsFactors = FALSE)
    } else {
      req(input$tx_file)
      read.csv(input$tx_file$datapath, stringsAsFactors = FALSE)
    }
  })
  
  expr_data <- reactive({
    if (input$input_method == "example") {
      data.frame(
        tx_id = c("ENST00000431889.6", "ENST00000646448.1", "ENST00000450046.7",
                  "ENST00000618765.5", "ENST00000494549.5", "ENST00000482308.5"),
        WT = c(52.98, 14.75, 24.56, 19.87, 29.34, 27.65),
        KD = c(55.12, 16.23, 17.89, 13.45, 11.28, 9.87)
      )
    } else if (input$input_method == "paste") {
      req(input$expr_text)
      read.csv(text = input$expr_text, stringsAsFactors = FALSE)
    } else {
      req(input$expr_file)
      read.csv(input$expr_file$datapath, stringsAsFactors = FALSE)
    }
  })
  
  # Preview tables
  output$preview_pas <- renderDT({
    datatable(pas_data(), options = list(pageLength = 5))
  })
  
  output$preview_tx <- renderDT({
    datatable(tx_data(), options = list(pageLength = 5))
  })
  
  output$preview_expr <- renderDT({
    datatable(expr_data(), options = list(pageLength = 5))
  })
  
  # Generate plot
  plot_obj <- eventReactive(input$generate, {
    
    pas_df <- pas_data()
    tx_df <- tx_data()
    expr_df <- expr_data()
    
    # Auto-assign PAS
    tx_df$nearest_pas <- "unassigned"
    tx_df$min_dist <- Inf
    
    for (i in 1:nrow(tx_df)) {
      for (j in 1:nrow(pas_df)) {
        dist <- abs(tx_df$start[i] - pas_df$coord[j])
        if (dist < tx_df$min_dist[i]) {
          tx_df$min_dist[i] <- dist
          if (dist <= input$pas_window) {
            tx_df$nearest_pas[i] <- as.character(pas_df$pas[j])
          }
        }
      }
    }
    
    # Merge data
    plot_data <- merge(tx_df, expr_df, by = "tx_id")
    
    # Get conditions
    conditions <- setdiff(colnames(expr_df), "tx_id")
    
    # Reshape to long format
    plot_data_long <- reshape2::melt(
      plot_data,
      id.vars = c("tx_id", "start", "nearest_pas"),
      measure.vars = conditions,
      variable.name = "condition",
      value.name = "TPM"
    )
    
    # Add y position
    plot_data_long$condition <- factor(plot_data_long$condition, levels = conditions)
    plot_data_long$y_pos <- as.numeric(plot_data_long$condition) - 1
    
    # Create ggplot
    p <- ggplot() +
      # Shaded regions
      geom_rect(
        data = pas_df,
        aes(xmin = coord - input$pas_window, xmax = coord + input$pas_window,
            ymin = -Inf, ymax = Inf, fill = pas),
        alpha = 0.08
      ) +
      # Vertical lines
      geom_vline(
        data = pas_df,
        aes(xintercept = coord, color = pas),
        linetype = "dashed", linewidth = 0.8, alpha = 0.8
      ) +
      # PAS labels
      geom_text(
        data = pas_df,
        aes(x = coord, y = length(conditions) - 0.35, label = pas, color = pas),
        fontface = "bold", size = 4, vjust = 0
      ) +
      # Bubbles
      geom_point(
        data = plot_data_long,
        aes(x = start, y = y_pos, size = TPM, fill = nearest_pas),
        alpha = 0.85,
        shape = 21,
        color = "white",
        stroke = 0.5
      )
    
    # Add labels if requested
    if (input$show_labels) {
      label_data <- plot_data_long %>% filter(condition == conditions[1])
      p <- p + geom_text_repel(
        data = label_data,
        aes(x = start, y = y_pos, label = tx_id, color = nearest_pas),
        size = 2.5, nudge_y = 0.08, segment.size = 0.3,
        segment.alpha = 0.5, segment.color = "grey60",
        box.padding = 0.3, point.padding = 0.2,
        max.overlaps = 20, show.legend = FALSE
      )
    }
    
    # Scales and theme
    p <- p +
      scale_color_manual(values = color_palette, name = NULL) +
      scale_fill_manual(values = color_palette, name = "PAS assignment") +
      scale_size_continuous(range = c(1, 14), name = "TPM") +
      scale_x_continuous(labels = scales::comma) +
      scale_y_continuous(
        breaks = 0:(length(conditions) - 1),
        labels = conditions,
        limits = c(-0.5, length(conditions) - 0.5 + 0.7)
      ) +
      labs(
        title = input$plot_title,
        subtitle = paste0("Bubble size = TPM | Shaded = ", input$pas_window, "nt window"),
        x = input$x_axis_label,
        y = NULL
      ) +
      guides(
        fill = guide_legend(override.aes = list(size = 4), order = 1),
        color = "none",
        size = guide_legend(order = 2)
      ) +
      theme_bw(base_size = 12) +
      theme(
        panel.grid.minor = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position = "right",
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 10, color = "grey30")
      )
    
    return(p)
  })
  
  # Display plot with dynamic height
  output$plot <- renderPlot({
    plot_obj()
  }, height = function() {
    # Dynamic height based on number of conditions
    n_conditions <- length(setdiff(colnames(expr_data()), "tx_id"))
    base_height <- 250
    height_per_condition <- 100
    total_height <- base_height + (n_conditions * height_per_condition)
    return(total_height)
  })
  
  # Download PNG
  output$download_png <- downloadHandler(
    filename = function() {
      paste0("pas_bubble_plot_", Sys.Date(), ".png")
    },
    content = function(file) {
      ggsave(file, plot_obj(), width = 12, height = 6, dpi = 600)
    }
  )
  
  # Download PDF
  output$download_pdf <- downloadHandler(
    filename = function() {
      paste0("pas_bubble_plot_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ggsave(file, plot_obj(), width = 12, height = 6)
    }
  )
}

# Run app
shinyApp(ui = ui, server = server)
