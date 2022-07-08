agentless=<your_ec2_instance_for_agentless_app>
sidekick=<your_ec2_instance_with_sidekick_app>
lightrun=<your_ec2_instance_with_lightrun_app>
rookout=<your_ec2_instance_with_rookout_app>
if [ "$AGENT" == "sidekick" ]; then
echo "Sidekick started..."
    if [ ! -z "$SEND_JAR" ]; then
        scp -i ~/.aws/PetclinicKeyPair.pem /Users/gokhansimsek/Desktop/sidekick-load-testing/thundra-sidekick-petclinic-demo/petclinic-app/target/petclinic-app-1.0.0.jar ec2-user@$sidekick:/home/ec2-user
    fi
ssh -i ~/.aws/PetclinicKeyPair.pem ec2-user@$sidekick 'bash -s' <<'ENDSSH'
    sudo yum -y install java-1.8.0
    export MYSQL_DATABASE=PetClinicAppRds
    export MYSQL_USER=petclinic
    export MYSQL_PASS=petclinic
    export MYSQL_URL=jdbc:mysql://petclinic-mysql-instance.cmzl2ojch8c1.us-west-2.rds.amazonaws.com/PetClinicAppRds
    export sidekick_apiKey=<your_sidekick_api_key>
    export sidekick_agent_application_name=petclinic-sidekick-app
    export sidekick_agent_application_version=0.1.1
    export sidekick_agent_application_stage=local
    wget -E -c "https://repo.thundra.io/service/local/artifact/maven/redirect?r=sidekick-releases&g=com.runsidekick.agent&a=sidekick-agent-bootstrap&v=LATEST" -O sidekick-agent-bootstrap.jar
    java -Dspring.profiles.active=sidekick -javaagent:sidekick-agent-bootstrap.jar -verbose:gc -Xloggc:./gc.log -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -jar petclinic-app-1.0.0.jar
ENDSSH
elif [ "$AGENT" == "lightrun" ]; then
echo "Lightrun started..."
    if [ ! -z "$SEND_JAR" ]; then
        scp -i ~/.aws/PetclinicKeyPair.pem /Users/gokhansimsek/Desktop/sidekick-load-testing/thundra-sidekick-petclinic-demo/petclinic-app/target/petclinic-app-1.0.0.jar ec2-user@$lightrun:/home/ec2-user
    fi
ssh -i ~/.aws/PetclinicKeyPair.pem ec2-user@$lightrun 'bash -s' <<'ENDSSH'
    sudo yum -y install java-1.8.0
    export MYSQL_DATABASE=PetClinicAppRds
    export MYSQL_USER=petclinic
    export MYSQL_PASS=petclinic
    export MYSQL_URL=jdbc:mysql://petclinic-mysql-instance.cmzl2ojch8c1.us-west-2.rds.amazonaws.com/PetClinicAppRds
    export LIGHTRUN_KEY=<lightrun_key>
    bash -c "$(curl -L "https://app.lightrun.com/download/company/<lightrun_company_id>/install-agent.sh?platform=openjdk:8")"
    java -agentpath:./agent/lightrun_agent.so -Dspring.profiles.active=lightrun -verbose:gc -Xloggc:./gc.log -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -jar petclinic-app-1.0.0.jar
ENDSSH
elif [ "$AGENT" == "rookout" ]; then
echo "Rookout started..."
    if [ ! -z "$SEND_JAR" ]; then
        scp -i ~/.aws/PetclinicKeyPair.pem /Users/gokhansimsek/Desktop/sidekick-load-testing/thundra-sidekick-petclinic-demo/petclinic-app/target/petclinic-app-1.0.0.jar ec2-user@$rookout:/home/ec2-user
    fi
ssh -i ~/.aws/PetclinicKeyPair.pem ec2-user@$rookout 'bash -s' <<'ENDSSH'
    sudo yum -y install java-1.8.0
    export MYSQL_DATABASE=PetClinicAppRds
    export MYSQL_USER=petclinic
    export MYSQL_PASS=petclinic
    export MYSQL_URL=jdbc:mysql://petclinic-mysql-instance.cmzl2ojch8c1.us-west-2.rds.amazonaws.com/PetClinicAppRds
    bash -c "$(curl -L "https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=com.rookout&a=rook&v=LATEST" -o rook.jar)"
    export JAVA_TOOL_OPTIONS="-javaagent:./rook.jar -DROOKOUT_TOKEN=<rookout_token> -DROOKOUT_LABELS=env:dev"
    java -Dspring.profiles.active=rookout -verbose:gc -Xloggc:./gc.log -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -jar petclinic-app-1.0.0.jar
ENDSSH
elif [ "$AGENT" == "agentless" ]; then
echo "Agentless started..."
    if [ ! -z "$SEND_JAR" ]; then
        scp -i ~/.aws/PetclinicKeyPair.pem /Users/gokhansimsek/Desktop/sidekick-load-testing/thundra-sidekick-petclinic-demo/petclinic-app/target/petclinic-app-1.0.0.jar ec2-user@$agentless:/home/ec2-user
    fi
ssh -i ~/.aws/PetclinicKeyPair.pem ec2-user@$agentless 'bash -s' <<'ENDSSH'
    sudo yum -y install java-1.8.0
    export MYSQL_DATABASE=PetClinicAppRds
    export MYSQL_USER=petclinic
    export MYSQL_PASS=petclinic
    export MYSQL_URL=jdbc:mysql://petclinic-mysql-instance.cmzl2ojch8c1.us-west-2.rds.amazonaws.com/PetClinicAppRds
    java -Dspring.profiles.active=agentless -verbose:gc -Xloggc:./gc.log -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -jar petclinic-app-1.0.0.jar
ENDSSH
else
    echo "Give AGENT parameter from agentless,sidekick,lightrun, rookout"
fi