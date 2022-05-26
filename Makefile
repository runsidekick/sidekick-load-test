usage: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

all: agentless lightrun rookout sidekick

agentless: ##Agentless petclinic
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.agentless.yml up --build --detach;
	echo "Waiting petclinic to launch on 8080...";
	until curl -s localhost:8080 >/dev/null 2>&1; do sleep 0.1; done;
	echo "Petclinic launched";
	jmeter -n -t ./petclinic-app/src/test/jmeter/petclinic_test_plan.jmx -l ./visualize_agentless/testresult.jlt -e -o ./visualize_agentless;
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.agentless.yml down --volumes;

sidekick: ## sidekick petclinic
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.sidekick.yml up --build --detach;
	echo "Waiting petclinic to launch on 8080...";
	until curl -s localhost:8080 >/dev/null 2>&1; do sleep 0.1; done;
	echo "Petclinic launched";
	jmeter -n -t ./petclinic-app/src/test/jmeter/petclinic_test_plan.jmx -l ./visualize_sidekick/testresult.jlt -e -o ./visualize_sidekick;
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.sidekick.yml down --volumes;

lightrun: ## lightrun petclinic
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.lightrun.yml up --build --detach;
	echo "Waiting petclinic to launch on 8080...";
	until curl -s localhost:8080 >/dev/null 2>&1; do sleep 0.1; done;
	echo "Petclinic launched";
	jmeter -n -t ./petclinic-app/src/test/jmeter/petclinic_test_plan.jmx -l ./visualize_lightrun/testresult.jlt -e -o ./visualize_lightrun;
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.lightrun.yml down --volumes;

rookout: ## rookout petclinic
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.rookout.yml up --build --detach;
	echo "Waiting petclinic to launch on 8080...";
	until curl -s localhost:8080 >/dev/null 2>&1; do sleep 0.1; done;
	echo "Petclinic launched";
	jmeter -n -t ./petclinic-app/src/test/jmeter/petclinic_test_plan.jmx -l ./visualize_rookout/testresult.jlt -e -o ./visualize_rookout;
	docker-compose -f ./petclinic-app/dockercomposes/docker-compose.rookout.yml down --volumes;

.PHONY: usage default sidekick lightrun rookout