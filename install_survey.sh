if [ $(dpkg-query -W -f='${Status}' docker 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get update -y
  apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  apt-get update -y
  apt-get install -y docker-ce
  apt-get install
  apt-get -y install docker-ce;
fi
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get -y install git;
fi
git clone https://github.com/2018-Arizona-Opportunity-Hack/Team7.git
cd Team7/
git checkout additional
cd ../
##
docker build --rm -t survey-stack Team7/
cp Team7/start-survey /bin/
chmod +x /bin/start-survey
rm -rf Team7
echo "Server built. Run the start-survey command to start the server"
