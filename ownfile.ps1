Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme pixelrobots
Set-Alias -Name k kubectl
Set-Alias -Name d docker
Set-Alias -Name dc docker-compose
Set-Alias -Name hl helm

# Kubernetes short cuts
function klo([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl logs -f $params }
function kex([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl exec -i -t $params }
function kg([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl get $params }
function kd([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl describe $params }
function kdpo([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl describe pods $params }
function kgdep([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl get deployment $params }
function kddep([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl describe deployment $params }
function kgoyaml([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl get -o=yaml $params }
function kepo([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl edit pod $params }
function kedep([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl edit deployment $params }
