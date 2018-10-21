library(shiny)
library(shinydashboard)
library(rlist)
library(knitr)
library(RSAGA)
library(pathological)
library(ECharts2Shiny)

questionsList <<- NULL 
answersList <<- NULL
answersListID <<- NULL
combineList <<- NULL
answerAmountList <<- NULL
previewString <<- ""

header <- dashboardHeader(title = "Survey Manager")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Create Survey", tabName = "create", icon = icon("pencil",lib="glyphicon")),
    menuItem("Upload Survey", tabName = "upload", icon = icon("upload")),
    menuItem("Analyze Results", tabName = "analysis", icon = icon("equalizer",lib="glyphicon"))
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "create",
            fluidRow(
              column(width = 4,
                     box(
                       width = NULL,
                       textAreaInput("qinput", 
                                     label="Enter your question below:",
                                     value = "",
                                     width = NULL,
                                     placeholder = NULL)
                     ),
                     box(
                       width = NULL,
                       radioButtons("qtype","Question Type:",
                                    c("Multiple Choice","Short Answer"),
                                    selected="")
                     ),
                     conditionalPanel(
                       condition = "input.qtype == 'Multiple Choice'",
                       
                       box(
                         width = NULL,
                         solidHeader = TRUE,
                         h5(align = "center","Add or Take Away Questions:")
                       ),
                       
                       actionButton("addAnswer", "+"),
                       
                       actionButton("deleteAnswer", "-"),
                       
                       div(id = "questions",
                           style = "border: 1px solid silver;")
                       
                       #uiOutput("inputs")                         
                     ),
                     
                     box(
                       width = NULL,
                       actionButton("addq","Add Question to Survey")
                     ),
                     
                     box(
                       width = NULL,
                       actionButton("generate","Generate Survey")
                     )
                     
              ),
              
              column(width = 8,
                     box(
                       width = NULL,
                       solidHeader = TRUE,
                       h3(align = "center","Survey Preview"),
                       htmlOutput("surveyPreview")
                     )
              )
            )
    ),
    tabItem(tabName = "upload",
            fluidRow(
              column(width = 12,
                     box(
                       width = NULL,
                       solidHeader = TRUE,
                       fileInput("file_in", "Import PDF", accept = c(".pdf",".rnw"))
                     )
              )
            )
    ),
    tabItem(tabName = "analysis",
            fluidRow(
              column(width = 4,
                     box(
                       width = NULL,
                       solidHeader = TRUE,
                       fileInput("data_in", "Import CSV", accept = c(".csv"))
                     )
              ),
              column(width = 8,
                     box(
                       width = NULL,
                       solidHeader = TRUE,
                       plotOutput("piechart")
                       #tags$div(id="test"),
                       #deliverChart(div_id="test")
                        )
                     )
            )
    )
  )
)

ui <- dashboardPage(
  skin = "green",
  header,
  sidebar,
  body
)

server <- function(input, output) {
  
  completeQuestions <- c()
  answers <- c()
  stitchToRMD <- function(){
    for(i in 1:length(questionsList)){
      question <- paste("Question\n","========\n",questionsList[i])
      solution <- paste("Answerlist\n","----------\n")
      #   for(j in 1:length(answerAmountList[i])){
      #      answers <- c("", paste("* ",answersList[j] + i,"\n"))
      #    }
      #    questionsList[i] <- paste(question,solution,answers)
      #   answers <- c()
    }
    toStitch <- paste(questionsList, collapse = '')
    stitch_rmd(script=toStitch,envir = globalenv())
  }
  
  observeEvent(input$generate, ignoreNULL = FALSE, {
    #Produce the Rmd file
    print(previewString)
    rmdString <<- previewString
    
    #Replace html strings
    rmdString <<- gsub("</h4><ul><li>", "\n", rmdString)
    rmdString <<- gsub("</li><li>", "\n", rmdString)
    rmdString <<- gsub("</li></ul><br/><h4>", "\n", rmdString)
    rmdString <<- gsub("<h4>", "\n", rmdString)
    rmdString <<- gsub("</li></ul><br/>", "\n", rmdString)
    print(rmdString)
    
    #Add to Rmd file
    sink("output.txt")
    cat("Question\n")
    cat("========\n")
    cat("Answerlist\n")
    cat("----------\n")
    cat(rmdString)
    sink()
    
    
    #Convert to Rmd
    fileName = c("output.txt")
    
    newFilename <- replace_extension(fileName, "Rmd")
    file.rename(fileName, newFilename)
    
  })
  
  #Keep track of the number of questions
  values <- reactiveValues(num_questions = 0)
  
  #Add a question
  observeEvent(input$addAnswer, ignoreNULL = FALSE, {
    values$num_questions <- values$num_questions + 1
    num <- values$num_questions
    insertUI(
      selector = "#questions", where = "beforeEnd",
      splitLayout(
        cellArgs = list(style = "padding: 3px"),
        id = paste0("question", num),
        textInput(inputId = paste0("Who", num),
                  label = paste0("Answer ",num),
                  placeholder = "Type answer here")
      )
    )
    answersListID <<- append(answersListID,paste("Who",num, sep = ""))
  })
  
  #Remove a question
  observeEvent(input$deleteAnswer, {
    num <- values$num_questions
    # Don't let the user remove the very first question
    if (num == 1) {
      return()
    }
    removeUI(selector = paste0("#question", num))
    values$num_questions <- values$num_questions - 1
  })
  
  #Preview all of the questions and answers
  observeEvent(input$addq, {
    
    questionsList <<- append(questionsList, input$qinput)
    
    for(x in 1:values$num_questions){
      answersList <<- append(answersList,input[[answersListID[x]]])
    }
    
    answerAmountList <<- append(answerAmountList,values$num_questions)
    
    combineList <<- append(combineList, tail(questionsList, n=1))
    combineList <<- append(combineList, tail(answersList,tail(answerAmountList, n = 1)))
    
    previewString = NULL
    
    i = 1
    j = 1
    #for(i in length(answerAmountList)){
    # answerAmountList[y]
    #}
    
    #print(length(combineList))
    #print(answerAmountList[j] + 1)
    
    while(i < length(combineList)){
      for(x in i:(answerAmountList[j]+ i)){
        modStr <- combineList[x]
        if (x == i) {
          modStr <- paste("<h4>", modStr, "</h4><ul>")
        } else if (x == answerAmountList[j]+ i) {
          modStr <- paste("<li>", modStr, "</li></ul>")
        } else {
          modStr <- paste("<li>", modStr, "</li>")
        }
        previewString = paste(previewString, modStr, sep = "")
      }
      previewString = paste(previewString, "<br/>", sep = "")
      i = i + (answerAmountList[j] + 1)
      j = j + 1
    }
    
    previewString <<- previewString
    
    #    print(length(combineList))
    # start = 1
    # sum = 0
    # for(y in 1:length(answerAmountList)){
    #   sum = sum + answerAmountList[y]
    #   #print(sum + 1)
    #   for(i in start:(sum+1)){
    #    # print(i)
    #     previewString = paste(previewString, combineList[i], sep = "")
    #     #print(previewString)
    #   }
    #   start = sum + answerAmountList[y] + 1
    # }
    
    output$surveyPreview <- renderUI({HTML(previewString)})
  })
  
  observeEvent(input$file_in, {
    infile = input$file_in
    if (is.null(infile)){
      return(NULL)
    } else {
      exams2nops(infile, n = 1, language = "en",
                 institution = "R University")
    }
  })
  
  filedata <- reactive({
    #data_in <- input$data_in
    if (is.null(input$data_in)) {
      # User has not uploaded a file yet
      return(NULL)
    } else {
      read.csv(input$data_in$datapath)
      #return(data)
    }
  })
  
  output$piechart <- renderPlot({ #div_id="test", 
    #data <- data.frame(filedata())
    res <- table(filedata()$Response)
    pieData <- c(res[names(res)=="Disagree"],res[names(res)=="Neutral"],res[names(res)=="Agree"],res[names(res)=="Strongly Agree"])

    pie(pieData, labels=pieData, main="Survey Feedback", col = rainbow(length(pieData)))

    legend("topright", c("Disagree", "Neutral", "Agree", "Strongly Agree"), cex=0.7, fill=rainbow(length(pieData)))
  })
  
}

shinyApp(ui = ui, server = server)