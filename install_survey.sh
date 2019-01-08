sudo docker build -t survey-stack .
cp start-survey /bin/
chmod +x /bin/start-survey
echo "Server built. Run the `start-survey` command to start the server"
