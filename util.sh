#!/bin/sh

# autosys aliases
alias jils="autorep -q -J"
alias jilsb="autorep -q -L0 -J"
alias fs="sendevent -E FORCE_STARTJOB -J"
alias st="autorep -J"
alias stbox="autorep -L0 -J"
alias jd="job_depends -c -J"
alias oi="sendevent -E JOB_ON_ICE -J"
alias ofi="sendevent -E JOB_OFF_ICE -J"
alias oh="sendevent -E JOB_ON_HOLD -J"
alias ofh="sendevent -E JOB_OFF_HOLD -J"
alias kill="sendevent -E KILLJOB -J"

# File which contains input job list
job_list = "util_jobs"

dashes="------------------------------------------"
calendar_attributes="exclude_calendar:\|run_calendar:"
run_attributes="days_of_week:\|date_conditions:\|start_times:\|max_run_alarm:\|exclude_calendar:\|run_calendar:\|"

# Args count checker
check_args_count() {
	n=$1
	if [[ $n -ne $main_arg_count ]]; then
		echo "Invalid argument count"
		exit 1
	fi
}

# Performs the requested job action for jobs in the input file
do_action() {
	check_args_count 2

	action=$1
	while read job_name; do
		if [[ $action == "st" ]]; then 
			st $job_name | tail -1
		elif [[ $action == "stbox" ]]; then 
			stbox $job_name | tail -1
		elif [[ $action == "fs" ]]; then 
			st $job_name
		elif [[ $action == "oi" ]]; then 
			oi $job_name
		elif [[ $action == "ofi" ]]; then 
			ofi $job_name
		elif [[ $action == "oh" ]]; then 
			oh $job_name
		elif [[ $action == "ofh" ]]; then 
			ofh $job_name
		elif [[ $action == "jils" ]]; then 
			jils $job_name
		elif [[ $action == "jilsb" ]]; then 
			jilsb $job_name
		elif [[ $action == "cs" ]]; then 
			cs $job_name
		elif [[ $action == "kill" ]]; then 
			kill $job_name
		else
			echo "invalid subcommand"
			exit 1
		fi
	done < $job_list
	exit 0
}

# Prints requested JIL attributes only for jobs in the input file
print_job_attributes() {
	check_args_count 2

	attributes=$1
	echo $attributes | awk '{ n=split($0, arr, ",") }; { for(i=1; i<=n; i++) { print arr[i] } }' > tmp_attributes
	while read job_name; do
		if [[ $action == "j1" ]]; then
			echo $job_name
		fi
		jilsb $job_name | grep -f tmp_attributes
		echo
	done < $job_list

	rm -f tmp_attributes
	exit 0
}

# Prints requested JIL attributes for all the jobs inside the box job
print_box_jobs_attributes() {
	check_args_count 2

	attributes=$1
	echo "insert_job" > tmp_attributes
	echo $attributes | awk '{ n=split($0, arr, ",") }; { for(i=1; i<=n; i++) { print arr[i] } }' >> tmp_attributes

	while read box_job_name; do
		jils $box_job_name | grep -f tmp_attributes
		echo $dashes
	done < $job_list

	rm -f tmp_attributes
	exit 0
}

# Prints calendar of the job (helper func)
print_cal_helper() {
	job_name=$1
	job_type=$(jilsb $job_name | grep "job_type" | cut -d':' -f3 | sed 's/ //g')
	box_name=$1

	if [[  "$job_type" != "BOX" ]]; then
		calendar=$(jils $job_name | grep $calendar_attributes)
		if [[ -n "$calendar" ]]; then
			echo "job: $job_name"
			echo $calendar
		fi
		box_name=$(jils $job_name | grep 'box_name:' | cut -d' ' -f2)
	fi

	if [[ -n $box_name ]]; then
		box_calendar=$(jilsb $box_name | grep $calendar_attributes)
		if [[ -n $box_calendar ]]; then
			echo "box: $box_name"
			echo $box_calendar
		else
			echo "No calendar for box job $box_name"
		fi
	fi
	echo
}

# Prints calendar for jobs in input file
print_cal() {
	check_args_count 2

	flag=$1
	if [[ $flag == "-j" ]]; then
		while read job_name; do
			print_cal_helper $job_name
		done < $job_list
	else
		job_name=$1
		print_cal_helper $job_name
	fi
	exit 0
}

# Prints only job run related details (helper func)
print_run_details_helper() {
	job_name=$1
	job_type=$(jilsb $job_name | grep 'job_type' | cut -d':' -f3 | sed 's/ //g')

	if [[ "$job_type" == "BOX" ]]; then
		echo "box_job_name:" $job_name
		jilsb $job_name | grep $run_attributes
	else
		echo "job_name:" $job_name
		jils $job_name } grep $run_attributes
		echo
		box_job_name=$(jils $job_name | grep "box_name:" | cut -d' ' -f2)
		if [[ -n $box_job_name ]]; then
			echo "box_job_name: " $box_job_name
			jilsb $box_job_name | grep $run_attributes
		fi
	fi

	echo $dashes
}

# Prints only job run related details for jobs in input file
print_run_details() {
	check_args_count 2

	flag=$1
	if [[ $flag == "-j" ]]; then
		while read job_name; do
			print_run_details_helper $job_name
		done < $job_list
	else
		job_name=$1
		print_run_details_helper $job_name
	fi
	exit 0
}

print_run_history() {
	check_args_count 3

	job_name=$1
	days=$2
	job_type=$(jilsb $job_name | grep 'job_type:' | cut -d':' -f3 | sed 's/ //g')

	num_regex='^[0-9]+$'
	commma_sep_regex='[0-9]+(,[0-9]+)*'
	range_regex='[0-9]+..[0-9]+'

	if [[ $days =~ $num_regex ]]; then
		if [[ $job_type == "BOX" ]]; then
			autorep -J $job_name -r -$days
		else
			autorep -J $job_name -r -$days | tail -1
		fi
	elif [[ $days =~ $range_regex ]] || [[ $days =~ $commma_sep_regex ]]; then
		for day in $(eval echo "{$days}"); do
			if [[ $job_type == "BOX" ]]; then
				autorep -J $job_name -r -$day
			else
				autorep -J $job_name -r -$day | tail -1
			fi
		done
	else
		echo "invalid format"
		echo "usage: <sub_command=hist> <Job name> <days>"
		echo "days can be either number as 5 or range as 2..7 or specific values as 2,5,9,10 as many"
		exit 1
	fi
	exit 0
}

##### Main func #####

sub_command=$1
main_arg_count=$#

if [[ $sub_command == "j0"]] || [[ $sub_command == "j1" ]]; then
	print_job_attributes $2
fi

if [[ $sub_command == "box" ]]; then
	print_box_jobs_attributes $2
fi

if [[ $sub_command == "cal" ]]; then
	print_cal $2
fi

if [[ $sub_command == "run" ]]; then
	print_run_details $2
fi

if [[ $sub_command == "do" ]]; then
	do_action $2
fi

if [[ $sub_command == "hist" ]]; then
	print_run_history $2 $3
fi

echo "invalid subcommand"
exit 1
