#Bootstrap Jenkins installation and start  
  user_data = <<-EOF

#!/bin/bash
#update all packages
sudo yum update -y

#Get Latest Updates
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

#Install Java and Jenkins
sudo amazon-linux-extras install java-openjdk11 -y && sudo yum install jenkins -y

#Enable and Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
EOF

 user_data_replace_on_change = true
