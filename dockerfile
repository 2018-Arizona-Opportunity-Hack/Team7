if [ $(dpkg-query -W -f='${Status}' docker 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get -y install docker;
fi
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get -y install git;
fi
git clone [repo!!!!]
##
docker build -t survey-stack .
cp start_survey /bin
chmod +x /bin/start_survey
rm -rf /
@echo "Server built."
