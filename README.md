# autosys-util

This script is a basic util script to perform some autosys actions in command line for list of jobs.

# Usage

## Subcommand - do

### Get the latest run status of all jobs in input file.
./util.sh do st

### Get the latest run status of all jobs in input file but only for level-0.
./util.sh do stb

### Force start all the jobs in input file.
./util.sh do fs

### On-ice all the jobs in input file.
./util.sh do oi

### Off-ice all the jobs in input file.
./util.sh do ofi

### On-hold all the jobs in input file.
./util.sh do oh

### Off-hold all the jobs in input file.
./util.sh do ofh

### Get JIL of all jobs in input file.
./util.sh do jils

### Get JIL of all jobs in input file but only for level-0.
./util.sh do jilsb

### Mark status as success for all jobs in input file.
./util.sh do cs

### Terminate all the jobs in input file.
./util.sh do kill

## Subcommand - j0 or j1

### Get JIL of jobs in input file but only the specified attributes without job name.
./util.sh j0 attr1,attr2,attr3,attrn

### Get JIL of jobs in input file but only the specified attributes with job name.
./util.sh j1 attr1,attr2,attr3,attrn

## Subcommand - box

### Get specified JIL attribute of all the jobs inside the box, input file should contain only box job.
./util.sh box attr1,attr2,attr3,attrn

## Subcommand - cal

### Get the calendar of all the jobs in input file and their box's calendar.
./util.sh cal -j

### Get the calendar of job and its box's calendar.
./util.sh cal test_job_name

## Subcommand - run

### Get the job run related details for jobs in input file.
./util.sh run -j

### Get the job run related details for job.
./util.sh run test_job_name

## Subcommand - hist

### Get the last nth run of job, here n=3.
./util.sh hist 3

### Get the job runs in given range, here latest to last 5th run.
./util.sh hist 0..5

### Get the specific runs of job
./util.sh hist 0,5,7,8,12
