agentless=ec2-35-85-45-221.us-west-2.compute.amazonaws.com
sidekick=ec2-35-88-156-197.us-west-2.compute.amazonaws.com
lightrun=ec2-52-41-162-123.us-west-2.compute.amazonaws.com
rookout=ec2-54-189-145-80.us-west-2.compute.amazonaws.com
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
    export sidekick_apiKey=ec92d67a-03d0-459e-8f9c-70411d66957c
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
    export LIGHTRUN_KEY=6f8e9878-fe56-4f19-acd1-44e9d5b298d9
    bash -c "$(curl -L "https://app.lightrun.com/download/company/d067f4eb-3bb0-4fe4-9bd7-900bc0e996ef/install-agent.sh?platform=openjdk:8")"
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
    export JAVA_TOOL_OPTIONS="-javaagent:./rook.jar -DROOKOUT_TOKEN=48030070e9910fc49821ce11d8f2bdc54e4ef1688618666d514eb3920a2de07a -DROOKOUT_LABELS=env:dev"
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