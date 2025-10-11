if [[ -z "$1" ]]; then
	echo "Usage: $0 <start or stop>"
	exit 1
fi

jiraUser="tanner@seedcode.com"
jiraAccessToken="aZEWnl7lka5lAO47Nr0jBtit1dD3B6mx"
timerUrl="https://seedcoder-time.seedcode.com/timer"

typePropertyKey="lgn88sny"
typePropertyValue="Development"


branchName=$(ssh dbk-dev "cd ~/projects/dayback; git branch --show-current")
issueKey=$(echo "$branchName" | awk -F'-' '{print $1 "-" $2}')
if [[ "$1" == "stop" ]]; then
	response=$(curl -X POST -H "Content-Type: application/json" -d "{\"issueKey\":\"$issueKey\", \"jiraUser\":\"$jiraUser\", \"type\": \"$typePropertyValue\"}" $timerUrl/stop?accessToken=$jiraAccessToken)
	notifyLabel="Stop"
elif [[ "$1" == "start" ]]; then
	response=$(curl -X POST -H "Content-Type: application/json" -d "{\"issueKey\":\"$issueKey\", \"jiraUser\":\"$jiraUser\"}" $timerUrl/start?accessToken=$jiraAccessToken)
	notifyLabel="Start"
fi

summary=$(echo "$response" | jq -r '.fields.summary')

notify-send -a "Timelog" "$notifyLabel: $summary"


