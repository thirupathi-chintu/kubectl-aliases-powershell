Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme pixelrobots
Set-Alias -Name k kubectl
Set-Alias -Name d docker
Set-Alias -Name dc docker-compose
Set-Alias -Name hl helm

# Kubernetes short cuts
function kcg([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl config get-contexts $params }
function kc([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl config use-context $params }

#kubectl get
function kg([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl get $params }
function kdpo([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl describe pods $params }
function kgdep([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl get deployment $params }
function kgoyaml([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl get -o=yaml $params }

#kubectl describe
function kd([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl describe $params }
function kddep([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl describe deployment $params }

#kubectl edit
function kepo([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl edit pod $params }
function kedep([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl edit deployment $params }

#kubectl log
function klo([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl logs -f $params }
function kex([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl exec -i -t $params }
