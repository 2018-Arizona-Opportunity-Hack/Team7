sudo docker build -t survey_stack .
sudo cp start-survey /bin/start-survey
sudo chmod +x /bin/start-survey
echo "Server built. Run the start-survey command to start the server"

