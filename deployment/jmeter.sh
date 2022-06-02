 #!/bin/bash
path_jlt="/home/ec2-user/$RESULT_PATH/testresult.jlt"
path_visualize="$RESULT_PATH"
host_url="$HOST_URL"
result_path="$RESULT_PATH"
jmeter_url="$JMETER_URL"
echo "$path_jlt"
echo "$path_visualize"
scp -i ~/.aws/PetclinicKeyPair.pem /Users/gokhansimsek/Desktop/sidekick-load-testing/thundra-sidekick-petclinic-demo/petclinic-app/src/test/jmeter/petclinic_test_plan.jmx ec2-user@$jmeter_url:/home/ec2-user
if [ ! -z "$INSTALL" ]; then
ssh -i ~/.aws/PetclinicKeyPair.pem ec2-user@$jmeter_url "bash -s" << ENDSSH
    sudo yum -y install java-1.8.0
    sudo bash -c 'echo 1024 65000 > /proc/sys/net/ipv4/ip_local_port_range'
    sudo sysctl -w net.ipv4.tcp_tw_reuse=1
    wget -c https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.4.3.zip
    unzip apache-jmeter-5.4.3.zip
    wget -c https://jmeter-plugins.org/files/packages/jpgc-casutg-2.10.zip
    sudo yum -y install unzip
    unzip jpgc-casutg-2.10.zip
    cp ./lib/jmeter-plugins-cmn-jmeter-0.6.jar ./apache-jmeter-5.4.3/lib/
    cp ./lib/ext/jmeter-plugins-casutg-2.10.jar ./apache-jmeter-5.4.3/lib/ext/
    cp ./lib/ext/jmeter-plugins-manager-1.6.jar ./apache-jmeter-5.4.3/lib/ext/
    rm -rf lib
    wget -c https://jmeter-plugins.org/files/packages/jpgc-tst-2.5.zip
    unzip jpgc-tst-2.5.zip
    cp ./lib/ext/jmeter-plugins-tst-2.5.jar ./apache-jmeter-5.4.3/lib/ext/
    rm -rf lib
    ./apache-jmeter-5.4.3/bin/jmeter.sh -n -t petclinic_test_plan.jmx -Jhost=$host_url -Jport=8080 -l $path_jlt -e -o $path_visualize
    zip -r $result_path.zip $path_visualize
    exit;
ENDSSH
else
ssh -i ~/.aws/PetclinicKeyPair.pem ec2-user@$jmeter_url "bash -s" << ENDSSH
    sudo bash -c 'echo 1024 65000 > /proc/sys/net/ipv4/ip_local_port_range'
    sudo sysctl -w net.ipv4.tcp_tw_reuse=1
    ./apache-jmeter-5.4.3/bin/jmeter.sh -n -t petclinic_test_plan.jmx -Jhost=$host_url -Jport=8080 -l $path_jlt -e -o $path_visualize
    zip -r $result_path.zip $path_visualize
    exit;
ENDSSH
fi
scp -i ~/.aws/PetclinicKeyPair.pem ec2-user@$jmeter_url:/home/ec2-user/$result_path.zip ~/Desktop
ssh -i ~/.aws/PetclinicKeyPair.pem ec2-user@$jmeter_url "bash -s" << ENDSSH
    rm -rf $result_path.zip
    rm -rf $path_visualize
    exit;
ENDSSH