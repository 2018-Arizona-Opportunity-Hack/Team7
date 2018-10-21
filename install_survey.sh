if [ $(dpkg-query -W -f='${Status}' docker 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get -y install docker;
fi
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get -y install git;
fi
git clone https://github.com/2018-Arizona-Opportunity-Hack/Team7.git
##
docker build --rm -t survey-stack Team7/
#cp Team7/start_survey /bin
#chmod +x /bin/start_survey
rm -rf Team7
echo "Server built."
