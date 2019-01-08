#libraries
library(shiny)
library(shinydashboard)
library(rlist)
library(knitr)
library(RSAGA)
library(pathological)
library(exams)
library(stringi)

#global variables
answersListID <<- NULL
previewString <<- ""
totalQuestionsAdded <<- 0
questionLengths <<- NULL

#UI
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
                                    selected="Multiple Choice")
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
                       actionButton("addq","Add Question")
                     ),
                     
                     box(
                       width = NULL,
                       actionButton("removeq","Delete Last Question")
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
                       fileInput("file_in", "Input Data", accept = c(".pdf",".rnw"))
                     )
              )
            )
    ),
    tabItem(tabName = "analysis",
            fluidRow(
              column(width = 12,
                     box(
                       width = NULL,
                       solidHeader = TRUE,
                       fileInput("data_in", "Import CSV", accept = c(".csv"))
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
  
  #Create directory for the questions
  dir.create(file.path(getwd(), "/survey"), showWarnings = FALSE)
  #Set it as the working directory
  setwd(file.path(getwd(), "/survey"))
  #Clear the directory
  do.call(file.remove, list(list.files(getwd(), full.names = TRUE)))
  
  #Go back to parent directory
  setwd("..")
  
  #Create directory for the questions
  dir.create(file.path(getwd(), "/questions"), showWarnings = FALSE)
  #Set it as the working directory
  setwd(file.path(getwd(), "/questions"))
  #Clear the directory
  do.call(file.remove, list(list.files(getwd(), full.names = TRUE)))
  
  #Keep track of the number of questions
  values <- reactiveValues(num_questions = 0)
  
  
  #Generate survey
  observeEvent(input$generate, ignoreNULL = FALSE, {
    
    ##Create list of all Rmd files from the questions directory
    list.filenames<-list.files(pattern = ".Rmd")
    
    ##Create an empty list for the Rmd files
    survey<-list()
    
    ##Read in every question
    for (i in 1:length(list.filenames))
    {
      survey[i]= list.filenames[i]
    }
    
    ##Do not create survey if no questions were created
    if(length(list.filenames) == 0){
      survey <- NULL
    }
    
    #If questions were added create the survey
    if(!is.null(survey)){
      exams2nops(survey, n = 1, dir = "../survey", name = "survey", date = Sys.Date(),
                 blank = 0, duplex = FALSE)
    }
    
  })
  
  
  
  #Add an answer
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
  
  
  
  #Remove an answer
  observeEvent(input$deleteAnswer, {
    num <- values$num_questions
    # Don't let the user remove the very first question
    if (num == 1) {
      return()
    }
    removeUI(selector = paste0("#question", num))
    values$num_questions <- values$num_questions - 1
  })
  
  
  
  #Create the Rmd file for the question being added and add it to the preview
  observeEvent(input$addq, {

    #question the user typed
    question <- input$qinput
    
    #stores the answers the user typed
    answersListLocal <- NULL
    
    #store all of the answers
    for(x in 1:values$num_questions){
      answersListLocal <- append(answersListLocal,input[[answersListID[x]]])
    }
    
    #Produce the Rmd file
    #Increment the question total
    totalQuestionsAdded <<- totalQuestionsAdded + 1
    
    #Create unquie file name based on the question number so each question has its own file
    fileName = c(paste0("question",totalQuestionsAdded,".txt"))
    
    #clear existing file or create it
    write("",file=fileName)

    #add the question to the file
    write("Question", fileName)
    write("========", fileName, append=TRUE)
    write(question, fileName, append=TRUE)
    write("\n", fileName, append=TRUE)
    
    #add the answers if multiple choice is the type
    if(input$qtype == 'Multiple Choice'){
      write("Answerlist", fileName, append=TRUE)
      write("----------", fileName, append=TRUE)
        
      #add every answer to the file
      for(answer in 1:length(answersListLocal)){
        write(paste("*", answersListLocal[answer]),fileName, append=TRUE)
      }
      write("\n", fileName, append=TRUE)
    }
    
    #solution information
    write("Solution", fileName, append=TRUE)
    write("========", fileName, append=TRUE)
    write("No solution", fileName, append=TRUE)
      
    #meta information at the bottom of the file
    write("\n", fileName, append=TRUE)
    write("Meta-information", fileName, append=TRUE)
    write("================", fileName, append=TRUE)
    write("exname: Survey", fileName, append=TRUE)
    
    #Change meta information based on question type
    if(input$qtype == 'Multiple Choice'){
      write("extype: mchoice", fileName, append=TRUE)
      write("exsolution: 01001", fileName, append=TRUE)
      write("exshuffle: FALSE", fileName, append=TRUE)
    }
    
    else{
      write("extype: num", fileName, append=TRUE)
      write("exsolution: -0.111", fileName, append=TRUE)
      write("extol: 0.01", fileName, append=TRUE)
    }
      
    #Convert to Rmd
    newFilename <- replace_extension(fileName, "Rmd")
    file.rename(fileName, newFilename)
    
    #HTML string of the new question to display it for the preview
    addString = NULL
    #Add question to HTML
    addString = paste("<h4>", question, "</h4><ul>")
    
    #Add the answers if question type is multiple choice
    if(input$qtype == 'Multiple Choice'){
      #Add every answer to HTML
      for(answer in 1:length(answersListLocal)){
        addString = paste0(addString, paste("<li>", answersListLocal[answer], "</li>"))
      }
    }
    
    #Add the length of the question HTML to questionLengths to be used if the question is deleted
    questionLengths <<- append(questionLengths, nchar(paste0(addString, "</ul>")))
    
    #Add new question to the preview
    previewString <<- paste0(previewString, addString, "</ul>")
    
    #Render the new preview
    output$surveyPreview <- renderUI({HTML(previewString)})
  
  })
  
  
  
  #Remove the Rmd file for the question being removed and delete it from the preview
  observeEvent(input$removeq, {
    
    #If no questions have been added, return
    if(totalQuestionsAdded == 0){
      return(NULL)
    }
    
    #Get the file name based of the last question added
    fileName = c(paste0("question",totalQuestionsAdded,".Rmd"))
    #Remove the file
    file.remove(fileName)
    #Decrement the questions count
    totalQuestionsAdded <<- totalQuestionsAdded - 1
    
    #Delete last question from the preview
    previewString <<- substr(previewString, 1, nchar(previewString) - questionLengths[length(questionLengths)]) 
    
    #Remove the question length from questionLengths
    #If not deleting the only question 
    if(length(questionLengths) > 1 ){
      questionLengths <<- questionLengths[1:(length(questionLengths)-1)]
    }
    #If deleting the only question
    else if (length(questionLengths) == 1 ){
      questionLengths <<- NULL
    }
    
    #Render the new preview
    output$surveyPreview <- renderUI({HTML(previewString)})
  })
  
  
  
  #Read in input
  observeEvent(input$file_in, {
    #Read intput file
    infile = input$file_in
    
    #If no file was uploaded, return
    if (is.null(infile)){
      return(NULL)
    }
    else {
      print("LL")
      #img <- dir(infile, pattern = "nops_scan",
      # full.names = TRUE)
      nops_scan(file = infile)
      
      print("MM")
      #Read content
      #res <- nops_scan(infile)
      
      #writeLines(infile)
    }
  })
}

shinyApp(ui = ui, server = server)
