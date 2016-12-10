#!/bin/bash
# set -x
api_path='/api/v1/query?query=container_last_seen'
echo $PROMETHEUS_URL
container_list=($(curl $PROMETHEUS_URL$api_path | jq '.data.result[].metric.container_label_com_amazonaws_ecs_task_definition_family' | grep -v null | sort | uniq | sed 's/"//g'))
for job in "${container_list[@]}";
do
	cat >> containerss.rules <<- EOL
	ALERT "$job ContainerStopped"
	IF time() - container_last_seen{container_label_com_amazonaws_ecs_task_definition_family=${job}} > 60 * 5
	LABELS { severity = "page" }
	ANNOTATIONS {
		summary = "Container {{\$labels.image}} stopped",
		description = "Container ${job} has been stopped on {{\$labels.host}}"
	}
	
	EOL
done
