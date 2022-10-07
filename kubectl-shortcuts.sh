alias k='kubectl'
alias kn='kubectl -n $ns'
alias kl='kubectl -n $ns logs'
alias klf='kubectl -n $ns logs --tail=200  -f'
alias kgs='kubectl -n $ns get service -o wide'
alias kgd='kubectl -n $ns get deployment -o wide'
alias kgp='kubectl -n $ns get pod -o wide'
alias kgn='kubectl -n $ns get node -o wide'
alias kdp='kubectl -n $ns describe pod'
alias kds='kubectl -n $ns describe service'
alias kdd='kubectl -n $ns describe deployment'
alias kdf='kubectl -n $ns delete -f'
alias kaf='kubectl -n $ns apply -f'
alias kci='kubectl -n $ns cluster-info'
alias kbad='kubectl -n $ns get pod | grep "0\/"'
alias kre='kubectl -n $ns get pod | sort -nk 4 | grep -v "Running   0"'
alias krey='kubectl -n $ns get pod  | sort -nk 4 | grep -v "Running   0\|NAME" | cut -d" " -f1 | xargs -i kubectl -n $ns describe pod {} | grep "Reason\|^Name:\|Finished"'
alias kall='kubectl -n $ns get nodes --no-headers | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''echo {} ; kubectl -n $ns describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo '\'''
alias hd='helm list --deployed | grep -v "NAME" | awk '\''{print $1}'\'' | sort | uniq -c  | awk '\''{print $1,$2}'\'' | grep -v  "^1 "'

function hl() { helm list $@; }
function hh() { helm history $(helm list -q $@); }
function gcm() { kubectl -n $ns get configmap $@ -o yaml; }
function klfl() { kubectl -n $ns logs --tail=$@  -f; }
function kpf() { 
	result=$(kubectl -n $ns get pod | grep -m1 $@)
        exitCode=$?
        if [ ! "$exitCode" -eq 0 ]; then
	 	echo "Could not find pod matching [$@]."
	 	return 1;	
	fi
        podName=$(echo $result | awk '{print $1}')
	echo "Forwarding port 8080 of $podName to local port 8080"
	kubectl -n $ns port-forward $podName 8080:8080
}
function klfa() {
	result=($(kubectl -n $ns get pod | grep $@))
	exitCode=$?
        if [ ! "$exitCode" -eq 0 ]; then
                echo "Could not find pod matching [$@]."
                return 1;       
        fi
	read -n 1 -p "Press any key for logs of ${result[0]} and ${result[5]}"
	(kubectl -n $ns logs --tail=10 -f ${result[0]} & kubectl -n $ns logs --tail=10 -f ${result[5]} &) | tee
}
function klff(){
	result=($(kubectl -n $ns get pod | grep $1))
        exitCode=$?
        if [ ! "$exitCode" -eq 0 ]; then
                echo "Could not find pod matching [$@]."
                return 1;
        fi
	echo "Showing logs for ${result[0]}"
	kubectl -n $ns logs --tail=200 -f ${result[0]}
}
function kops(){
	kubectl -n $ns proxy &
	docker run -it --net=host hjacobs/kube-ops-view &
	xdg-open http://localhost:8080 &
} 
function kfp() { kubectl -n $ns get pod -o wide| grep $@; }
function kfs() { kubectl -n $ns get service -o wide| grep $@; } 
function kfd() { kubectl -n $ns get deployment -o wide | grep $@; }
function kxsh() { kubectl -n $ns exec -ti $@ -- sh; }
function kxbash() { kubectl -n $ns exec -ti $@ -- bash; }
function kph() { kubectl -n $ns exec -ti $@ -- sh -c 'apk -q update; apk add -q curl jq; curl localhost:8080/__health | jq'; }
function kstop() {
	echo "Stopping $1"
	desired_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].spec.replicas}');
	kubectl -n $ns scale --replicas=0 deployments/$1;
	current_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].status.availableReplicas}')
	while [ ! -z "$current_replicas" ]; do
                sleep 1;
                current_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].status.availableReplicas}')
        done;
	echo "Stopped [$desired_replicas] instances of $1."
	return $desiredReplicas
}
function kstart() {
	echo "Scaling deployment $1 up to $2 replicas...";
        kubectl -n $ns scale --replicas=$2 deployments/$1;
        if [ "$3" == "skipCheck" ]; then
                echo "Skipping healthchecks"
                return
        fi
        default_sleep=10
        initial_sleep=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}')
        initial_sleep=${initial_sleep:-10}
        echo "Waiting $initial_sleep seconds for the first readiness probe check..."
        sleep $initial_sleep
        period_sleep=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].spec.template.spec.containers[0].readinessProbe.periodSeconds}')
        period_sleep=${period_sleep:-10}
        while [ "$current_replicas" != "$2" ]; do
                echo "Waiting $period_sleep seconds until checking the node count"
                sleep $period_sleep
                current_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].status.availableReplicas}')
                current_replicas=${current_replicas:-0}
                echo "Current nr of replicas: $current_replicas"
        done;
        echo "$1 restarted"
}
function kres() {
	echo "Scaling $1"
	desired_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].spec.replicas}');
	echo "Desired nf or replicas: $desired_replicas";
        echo "Scaling deployment $1 down to 0 replicas...";
        kubectl -n $ns scale --replicas=0 deployments/$1;
	current_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].status.availableReplicas}')
	while [ ! -z "$current_replicas" ]; do
		sleep 1;
	        current_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].status.availableReplicas}')
	done;
	echo "Scaling deployment $1 up to $desired_replicas replicas...";
	kubectl -n $ns scale --replicas=$desired_replicas deployments/$1;
	if [ "$2" == "skipCheck" ]; then
		echo "Skipping healthchecks"
		return
	fi

	default_sleep=10
	initial_sleep=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}')
	initial_sleep=${initial_sleep:-10}
	echo "Waiting $initial_sleep seconds for the first readiness probe check..."
        sleep $initial_sleep
  	period_sleep=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].spec.template.spec.containers[0].readinessProbe.periodSeconds}')
	period_sleep=${period_sleep:-10}
	while [ "$current_replicas" != "$desired_replicas" ]; do
		echo "Waiting $period_sleep seconds until checking the node count"
		sleep $period_sleep
		current_replicas=$(kubectl -n $ns get deployments --selector=app=$1 -o jsonpath='{$.items[0].status.availableReplicas}')
                current_replicas=${current_replicas:-0}
                echo "Current nr of replicas: $current_replicas"
        done;
	echo "$1 restarted"
}
function kgnt() { for machine in $(kgn | tail -n +2 | awk '{ print $1 }' ); do echo -n "${machine}: "; echo $(k describe node $machine | grep -i "node-role\|role="); done | sort -k 2; }
function kstat() {
	for node in  $(kubectl -n $ns get nodes | tail -n +2 | awk '{print $1}'); do 
		echo $node
		echo -e "$(kubectl -n $ns describe node $node | grep -A 4 "Allocated resources")\n";
	done
}
function kready() {
        for node in  $(kubectl -n $ns get nodes | tail -n +2 | awk '{print $1}'); do
                echo $node
                echo -e "$(kubectl -n $ns describe node $node | grep  "Ready")\n";
        done
}
