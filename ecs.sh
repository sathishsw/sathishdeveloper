#!/bin/zsh

#input="athena-primary-559fb46cfc-4wvbz"
#input="${input##*( )}"   # Trim leading whitespace
#input="${input%%*( )}"   # Trim trailing whitespace


# Doc
# ecs <option> <pod>
# options: flux, get, event

# Using separator logic

if [[ -z "$1" ]];then
    echo "ecs get|event|scale|image|term|cron|cp <pod>"
    echo "ecs cp <src> <dest> -c <container>"
    return
fi

local pod=${2}
local option=${1}

#echo "Option: ${option} on Pod: ${pod}"

if [[ ${option} = "flux" ]];then
    echo "running flux"
    oc get ks xpp-deployments -n flux-system
    return
fi

if [[ ${option} == "get" ]];then
    # get pods
    oc get pods | grep ${pod}
    return
fi

if [[ ${option} == "event" ]];then
    # event
    oc get event | grep ${pod}
    return
fi

if [[ ${option} == "scale" ]];then
    oc scale deployment/${pod} --replicas=$3
    return
fi

if [[ ${option} == "image" ]];then
    # event
    oc describe helmrelease ${pod} | grep -A2 -B2 -e "image:" -e "Image:" -e "Tag:"
    return
fi

if [[ ${option} == "cron" ]];then
    local job_cmd="oc create job --from=cronjob/${pod} ${pod}-${3:-manual}-`date +%Y%m%d-%H%M` -n xpp"
    echo "Running command: ${job_cmd}"
    #eval ${job_cmd}
    return
fi

if [[ ${option} == "cp" ]];then
    oc cp --request-timeout=5h --retries=70 ${2} ${3} -c ${4}
    return
fi

# Find container name
local parts=("${(s:-:)pod}")

container=""

for part in "${parts[@]}"; do
  #echo "$part"
  if [[ $part =~ [^a-zA-Z] ]] || [[ $part == "primary" ]]; then
    #echo "Avoidable characters. : ${part}"
    break
  else
    #echo "Valid characters. : ${part}"
    container+="${part}-"
  fi
done

container=${container%-}

echo "result: ${container}"


if [[ ${option} == "term" ]];then
    # terminal
    oc exec -it ${pod} -c ${container} -- /bin/sh
    return
fi
