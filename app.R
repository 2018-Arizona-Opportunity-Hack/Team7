#libraries
library(shiny)
library(shinydashboard)
library(rlist)
library(knitr)
library(RSAGA)
library(pathological)
library(exams)
library(DT)
library(pdftools)
library(utils)

Sys.setenv(R_ZIPCMD="/usr/bin/zip")

#global variables
answersListID <<- NULL
previewString <<- ""
totalQuestionsAdded <<- 0
shortAnswerQuestionsAdded <<- 0
shortAnswerQuestionsNums <<- NULL
questionLengths <<- NULL
questionsListGlobal <<- c()
answersListGlobal <<- list()
seed <<- NULL

#UI
header <- dashboardHeader(title = "Survey Manager")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Create Survey", tabName = "create", icon = icon("pencil",lib="glyphicon")),
    menuItem("Upload Survey", tabName = "upload", icon = icon("upload")),
    menuItem("Analyze Results", tabName = "analysis", icon = icon("equalizer",lib="glyphicon")),
    menuItem("Logout", tabName = "logout", icon = icon("sign-out-alt",lib="font-awesome"))
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "create",
            fluidRow(
              column(width = 4,
                     box(
                       width = NULL,
                       textAreaInput("surveynameinput", 
                                     label="What is your survey called?:",
                                     value = "",
                                     width = NULL,
                                     placeholder = "Survey")
                     ),
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
                         h5(align = "center","Add or Take Away Answers:")
                       ),
                       
                       actionButton("addAnswer", "+"),
                       
                       actionButton("deleteAnswer", "-"),
                       
                       div(id = "questions",
                           style = "border: 1px solid silver;")
                       
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
                     ),
                     
                     box(
                       width = NULL,
                       downloadButton("downloadSurvey", label = "Download Survey")
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
                       fileInput("pdfInput", "Upload ZIP file", accept = c(".zip"))
                     ),                      
                     box(
                       width = NULL,
                       downloadButton("downloadResults", label = "Download Results")
                     )
              )
            )
    ),
    tabItem(tabName = "analysis",
            fluidRow(
              tags$head(tags$style(".leftAlign{float:left;}")),
              column(
                width = 6, align = 'center',
                box(
                  title = paste("Upload CSV Report"),
                  width = NULL,
                  solidHeader = F,
                  fileInput("csv_in", label=NULL, accept = c(".csv"))
                ),
                box(
                  title = paste("Summary Statistics"),
                  width = NULL,
                  solidHeader = F,
                  tableOutput("sumStatsTable")
                ),
                box(
                  title = paste("Question Table"),
                  width = NULL,
                  solidHeader = F,
                  dataTableOutput("questionTable")
                )
              ),
              column(
                width = 6, align = 'center',
                selectInput(
                  inputId = "questions",
                  label = "Questions",
                  choices = c("test","test1")
                ),
                box(
                  title = "Pie Chart",
                  width = NULL,
                  solidHeader = F,
                  plotOutput("pieChart")
                )
              )
            )
    ),
    tabItem(tabName = "logout",
            fluidRow(
              column(width = 12,
                     box(
                       a("Click to Logout", href="/auth/logout", target="_blank")
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

getSummaryStats <- function(data){
  # Extract the summary statistics from the data
  totalPeople <- length(unique(data$userID))
  totalQuestions <- length(unique(data$questionID))
  completedQuestions <- sum(complete.cases(data))
  incompleteQuestions <- (totalQuestions * totalPeople) - completedQuestions
  
  goodPeople <- 0
  for(i in 1:totalPeople){
    if(sum(table(data[,c("userID","questionID")])[i,]) == totalQuestions)
      goodPeople <- goodPeople + 1
  }
  
  badPeople <- totalPeople - goodPeople
  
  # Question with lowest variance
  # Question with greatest variance
  
  names <- c(
    "Total Participants",
    "Total Questions on Survey",
    "Total Answered Questions",
    "Total Unanswered Questions",
    "Total Participants who answered every question",
    "Total Participants who did not answer every question"
  )
  
  values <- c(
    paste0(prettyNum(totalPeople, big.mark = ",", scientific=FALSE)),
    paste0(prettyNum(totalQuestions, big.mark = ",", scientific=FALSE)),
    paste0(prettyNum(completedQuestions, big.mark = ",", scientific=FALSE)),
    paste0(prettyNum(incompleteQuestions, big.mark = ",", scientific=FALSE)),
    paste0(prettyNum(goodPeople, big.mark = ",", scientific=FALSE)),
    paste0(prettyNum(badPeople, big.mark = ",", scientific=FALSE))
  )
  
  sumStats = data.frame(names = names, values = values)
  colnames(sumStats) = NULL
  return(sumStats)
}

# Converts the nops_eval() csv to a csv usable in the analyze results section
formatCSV <- function(nops_csv, qa_csv){
  # Give this the path to the csv that is generated by nops_eval()
  nops_data <- read.csv(nops_csv,stringsAsFactors=F,header=T,sep=";")
  #nops_data <- read.csv("/Users/Tommy/Documents/Git/Hackathon/unzippedPDFS1548739604.12689/results.csv",stringsAsFactors=F,header=T,sep=";")
  
  # Set up the data
  info <- nops_data[,c("registration","name","id","scan")]
  answers <- as.data.frame(nops_data[,grep("answer",colnames(nops_data))])
  data <- cbind(info, answers)
  user     <- c()
  question <- c()
  answer   <- c()
  index    <- 1
  
  # Parse through each "binary" answer and extract relevant information
  for(i in 1:nrow(data)){
    for(j in 1:length(answers)){
      for(k in 1:nchar(as.character(answers[i,j]))){
        if(substr(formatC(as.character(answers[i,j]), width = 5, format = "d", flag = "0"),start=k,stop=k) == 1){
          user[index] <- i
          question[index] <- j
          answer[index] <- k
          index <- index + 1
        }
      }
    }
  }
  # Save relevant information as a dataframe
  formatted_data <- as.data.frame(cbind(user,question,answer))
  
  qa_data <- read.csv(qa_csv)
  #qa_data <- read.csv("/Users/Tommy/Documents/Git/Hackathon/unzippedPDFS1548739604.12689/QuestionData.csv")
  qa_data[,1] <- as.numeric(qa_data[,2])
  
  questions_list <- unique(qa_data[,2])
  answers_list <- split(qa_data,qa_data[,2])
  for(i in 1:length(answers_list)){
    answers_list[[i]] <- unique(as.character(answers_list[[i]][,3]))
  }
  names(answers_list) <- c(1:length(questions_list))

  # Replace the question + answer numbers with the stored question texts + answers
  for(i in 1:nrow(formatted_data)){
    question_index <- as.numeric(formatted_data[i,2])
    formatted_data[i,2] <- as.character(questions_list[question_index])
    formatted_data[i,3] <- answers_list[[question_index]][as.numeric(formatted_data[i,3])]
  }
  row.names(formatted_data) <- NULL
  formatted_data <- cbind(formatted_data,question)
  names(formatted_data) <- c("userID","question_text","response","questionID")
  return(formatted_data)
}

# Gets the questions and answers csv generated by creating the survey
getQAdf <- function(){
  if(!is.null(questionsListGlobal)){
    questions <- c()
    answers <- unlist(answersListGlobal)
    for(i in 1:length(questionsListGlobal)){
      questions <- append(questions,rep(questionsListGlobal[i],times=length(answersListGlobal[[i]])))
    }
    qadf <- as.data.frame(cbind(questions,answers))
    
    # Save the dataframe as a csv
    fp <- paste0("../survey",seed)
    setwd(file.path(getwd(), fp))
    write.csv(qadf, "QuestionData.csv")
    setwd(file.path(getwd(), paste0("../questions",seed)))
  }
}

server <- function(input, output) {

  #Reset Global Vars
  answersListID <<- NULL
  previewString <<- ""
  totalQuestionsAdded <<- 0
  shortAnswerQuestionsAdded <<- 0
  shortAnswerQuestionsNums <<- NULL
  questionLengths <<- NULL
  questionsListGlobal <<- c()
  answersListGlobal <<- list()
  seed <<- as.numeric(Sys.time())
  
  #set working directory to the shiny server
  #setwd("/srv/shiny-server")
  #setwd("C:/Users/scrol_000/Documents/Hackathon 2018/December")
  
  #Generate unique number based upon system time
  seed <<- as.numeric(Sys.time())
  
  #Create directory for the questions
  dir.create(file.path(getwd(), paste0("/survey",seed)), showWarnings = FALSE)
  #Set it as the working directory
  setwd(file.path(getwd(),  paste0("/survey",seed)))
  #Clear the directory
  do.call(file.remove, list(list.files(getwd(), full.names = TRUE)))
  
  #Go back to parent directory
  setwd("..")
  
  #Create directory for the questions
  dir.create(file.path(getwd(), paste0("/questions",seed)), showWarnings = FALSE)
  #Set it as the working directory
  setwd(file.path(getwd(), paste0("/questions",seed)))
  #Clear the directory
  do.call(file.remove, list(list.files(getwd(), full.names = TRUE)))
  
  #Keep track of the number of questions
  values <- reactiveValues(num_questions = 0)
  
  #Generate survey
  observeEvent(input$generate, ignoreNULL = FALSE, {
    
    withProgress(message = 'Generating Survey', {
    
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
      exams2nops(survey, n = 1, dir = paste0("../survey",seed), name = "survey", date = Sys.Date(),
                 blank = 0, institution = input$surveynameinput, duplex = FALSE)
    }
    
    # Get the questions and answers csv
    getQAdf()
    
    incProgress(0.1)
    })
    
  })
  
  #Download survey
  output$downloadSurvey <- downloadHandler(
    
    filename = function() {
      paste0("surveyZip", ".zip")
    },
    
    content = function(file) {
      setwd(paste0("../survey", seed))
      files2zip <- dir(".", full.names=TRUE)
      zip(zipfile = file, files = files2zip)
      setwd(paste0("../questions", seed))
    },
    #contentType = "application/pdf"
    contentType = "application/zip"
  )
  
  #Add an answer
  observeEvent(input$addAnswer, ignoreNULL = FALSE, {
    
    #Test to see if 5 answers have already been added for a question
    if(values$num_questions == 5){
      showModal(modalDialog(
        "You can only have a max of 5 answers per question."
      ))
      
      return()
    }
    
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
    
    #Test to see if 45 questions have been added
    if(totalQuestionsAdded == 45){
      showModal(modalDialog(
        "You can only have a max of 45 questions."
      ))
      
      return()
    }
    
    #Test to see if three short answer questions have already been added
    else{
      if(input$qtype == 'Short Answer' && shortAnswerQuestionsAdded < 3){
        shortAnswerQuestionsAdded <<- shortAnswerQuestionsAdded + 1
      }
      else if (input$qtype == 'Short Answer'){
          showModal(modalDialog(
            "You can only have a max of 3 short answer questions."
          ))
          return()
      }
    }

    #question the user typed
    question <- input$qinput
    questionsListGlobal <<- append(questionsListGlobal,question)
    
    #stores the answers the user typed
    answersListLocal <- NULL
    
    #store all of the answers
    for(x in 1:values$num_questions){
      answersListLocal <- append(answersListLocal,input[[answersListID[x]]])
    }
    
    #Produce the Rmd file
    #Increment the question total
    totalQuestionsAdded <<- totalQuestionsAdded + 1
    
    # Store the answers for the question
    answersListGlobal[[totalQuestionsAdded]] <<- answersListLocal
    
    #If adding short answer question
    if(input$qtype == 'Short Answer'){
      shortAnswerQuestionsNums <<- append(shortAnswerQuestionsNums,totalQuestionsAdded)
    }
    
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
    
    #If removing a short answer question
    if(totalQuestionsAdded %in% shortAnswerQuestionsNums ){
      shortAnswerQuestionsNums <<- setdiff(shortAnswerQuestionsNums,c(totalQuestionsAdded))
      shortAnswerQuestionsAdded <<- shortAnswerQuestionsAdded - 1
    }
    
    #Get the file name based of the last question added
    fileName = c(paste0("question",totalQuestionsAdded,".Rmd"))
    #Remove the file
    file.remove(fileName)
    
    # Remove the question that was saved
    questionsListGlobal <<- questionsListGlobal[-totalQuestionsAdded]
    
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
  
  
  
  #Handle the PDF/PNG input
  observeEvent(input$pdfInput, {
    #Read input file
    infile = input$pdfInput
    
    #If no file was uploaded, return
    if (is.null(infile)){
      return(NULL)
    }
    else {
      
      withProgress(message = 'Analyzing Survey Results and Producing csv File', {
      
      #Unzip the file
      unzip(infile$datapath, exdir = paste0("../unzippedPDFS", seed))
      
      #filepath to the unzipped pdfs
      fp <- paste0("/unzippedPDFS", seed)
      
      #Set it as the working directory
      setwd(file.path(getwd(),".."))
      setwd(file.path(getwd(), fp))
      
      #Read in all of the pdfs
      files <- list.files(path=getwd(), pattern="*.pdf", full.names=TRUE, recursive=FALSE)

      #Convert all the pdfs into pngs
      for(file in files){
        pdf_convert(file, format = "png", pages = NULL, filenames = NULL, dpi = 300, opw = "", upw = "", verbose = TRUE)
        
      }
      
      ##Pass the png files into nops_scan
      files1 <- list.files(path=getwd(), pattern="*1.png", full.names=TRUE, recursive=FALSE)
      
      nops_scan(files1)
      
      #create the csv file of student data in the wd
      student_df <- data.frame(
        registration = c(0:(length(files)-1)),
        name = c(rep("e", length(files))),
        id = as.numeric(c(1:length(files)))
      )
      
      write.table(student_df, 
                  file = "studentData.csv", 
                  sep = ";", 
                  quote = FALSE, 
                  row.names = FALSE)
      #print(read.csv("studentData.csv",stringsAsFactors=F,header=T,sep=";"))
      
      #call nops_eval() to evaluate the surveys
      nops_eval(register = "studentData.csv")
      
      #rename the results csv file
      setwd(paste0("../unzippedPDFS", seed))
      file.rename("nops_eval.csv", "results.csv")
      #setwd("..")
      
      # Generate the cleaned csv file
      #print(getwd())
      clean_data <- formatCSV(nops_csv = paste0("results.csv"), qa_csv = paste0("QuestionData.csv"))
      #write.csv(clean_data)
      write.csv(clean_data, file = "finalResults.csv")
      
      setwd(paste0("../questions",seed))
      
      #edit csv file
      
      
      incProgress(0.1)
      })
    }
  })
  
  #Download the survey results csv
  output$downloadResults <- downloadHandler(
    filename <- function() {
      #print(paste0("unzippedPDFS", seed))
      setwd(paste0("../unzippedPDFS", seed))
      paste0("finalResults", ".csv")
    },
    
    content <- function(file) {
      #print(file)
      file.copy("finalResults.csv", file)
      setwd(paste0("../questions",seed))
      
    },
    contentType = "application/csv"
  )
  
  csv_file <- reactive({
    # User has not uploaded a file yet
    if (is.null(input$csv_in))
      return(NULL)
    read.csv(input$csv_in$datapath)
  })
  
  output$sumStatsTable = renderTable({
    if (is.null(csv_file()))
      return(NULL)
    getSummaryStats(csv_file())
  })
  
  output$questionTable = renderDataTable({
    if (is.null(csv_file()))
      return(NULL)
    # Prepare question table and make it global
    data <- as.data.frame.matrix(table(csv_file()[,c("question_text","response")]))
    data <- data.frame(question = row.names(data), data)
    rownames(data) <- c()
    questionTableData <<- data
    
    # Render the datatable
    datatable(questionTableData,selection='single')
  })
  
  questionSelected <- reactive({
    if (is.null(input$questionTable_rows_selected))
      return(NULL)
    questionTableData[input$questionTable_rows_selected,]
  })
  
  output$pieChart <- renderPlot({
    if (is.null(input$questionTable_rows_selected))
      return(NULL)
    
    question_text <- as.character(questionSelected()[,1])
    responses <- c(names(questionSelected())[-1])
    response_vals <- unlist(unname(questionSelected()[1,][-1]))
    
    pie(x=response_vals,
        labels=responses,
        main=question_text,
        col = rainbow(length(response_vals)))
  })
  
}

shinyApp(ui = ui, server = server)
