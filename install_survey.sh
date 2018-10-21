if [ $(dpkg-query -W -f='${Status}' docker 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get -y install docker-ce;
fi
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get -y install git;
fi
git clone https://github.com/2018-Arizona-Opportunity-Hack/Team7.git
##
docker build --rm -t survey-stack Team7/
cp Team7/start-survey /bin/
chmod +x /bin/start-survey
rm -rf Team7
echo "Server built. Run the start-survey command to start the server"
