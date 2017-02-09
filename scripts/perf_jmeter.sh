#!/bin/bash

# ===========================
#
# ===========================
FILENAME=`basename ${0}`
VERSION="v0.0.1" # Needs fixing!

# ==============================================================
# 
# ==============================================================
function check_test_results_dir () {
local TEST_RUN=${1}	
	if [ ! -d ${JMETER_LOGS}/${TEST_RUN} ]
	then
		# Directory doesn't exist, create it
		echo "mkdir -p ${JMETER_LOGS}/${TEST_RUN}"
		mkdir -p ${JMETER_LOGS}/${TEST_RUN}
	else 
		echo "${JMETER_LOGS}/${TEST_RUN} already exists"
	fi
}

# ==============================================================
# 
# ==============================================================
function check_jmeter_gui () {

	if [ -z ${JMETER_GUI} ]
	then
		echo "Launch Jmeter GUI"
	else
		echo "Mode set to ${JMETER_GUI}"
	fi
}
# ==============================================================
# 
# ==============================================================
function check_jmeter_test_script () {
	echo -n "Checking test script ... "
	JMETER_TEST_FILE="${JMETER_TEST_FILE:?ERROR: No test script specified, use --jmeter-test-file=<filename>}"
	# Check test script exists

	if [ ! -e ${JMETER_TEST_CASES}/${JMETER_TEST_FILE} ]
	then
		echo "${JMETER_TEST_CASES}/${JMETER_TEST_FILE} NOT found"
		exit 1;
	fi
	
	if [ -f ${JMETER_TEST_CASES}/${JMETER_TEST_FILE} ] && [ -s ${JMETER_TEST_CASES}/${JMETER_TEST_FILE} ] && [ -r ${JMETER_TEST_CASES}/${JMETER_TEST_FILE} ]
	then
		echo "${JMETER_TEST_CASES}/${JMETER_TEST_FILE} appears to be readable :-)";
	else
		echo "Please check ${JMETER_TEST_CASES}/${JMETER_TEST_FILE} is a regular, readable, non-zero length file."
		exit 1;
	fi
}

# ==============================================================
# Check command line args.
# ==============================================================
function check_cmdline_vars () {

	# ======================================================
	if [ -z "${JMETER_BIN}" ]
	then
		echo "ERROR : JMETER_BIN not set"	
		exit 1;
	fi

	# ======================================================
	if [ -z "${JMETER_HOME}" ]
	then
		echo "ERROR : JMETER_HOME not set"	
		exit 1;
	else
		export JMETER_HOME=${JMETER_HOME}
		export JMETER_SCRIPTS="${JMETER_HOME}/scripts"
		export JMETER_TEST_CASES="${JMETER_HOME}/test-cases"
		export JMETER_LOGS="${JMETER_HOME}/logs"
	fi

	# ======================================================
	if [  -z "${SERVER_REGION}" ]
	then
		export SERVER_REGION="eu-west-1"
	else
		export SERVER_REGION=${SERVER_REGION}
	fi

	# ======================================================
	if [  -z "${SUBSCRIPTION_PREFIX}" ]
	then
		export SUBSCRIPTION_PREFIX="prefix_text"
	else
		export SUBSCRIPTION_PREFIX=${SUBSCRIPTION_PREFIX}
	fi

	# ======================================================
	if [  -z "${PRODUCT}" ]
	then
		export PRODUCT="prd_text"
	else
		export PRODUCT=${PRODUCT}
	fi

	# ======================================================
	if [  -z "${TAG}" ]
	then
		export TAG="tag"
	else
		export TAG=${TAG}
	fi

	# ======================================================
	if [  -z "${URL}" ]
	then
		export URL="foobar.com"
	else
		export URL=${URL}
	fi

	# ======================================================
	# TEST_RUN is merely here to help uniquely identify each test run with a descriptive text.
	DATE_TIME_STAMP=`date +%Y%m%d_%H%M%S`
	if [  -z "${TEST_RUN}" ]
	then
		# if not set, don't bother prepending date stamp
		export TEST_RUN="jmeter"
	else
		# Remove/Substitute white space, appstrophe and slashes
		TEST_RUN=`echo ${TEST_RUN} | sed "s/ /_/g" | sed "s/\'//g"`
		export TEST_RUN="${DATE_TIME_STAMP}_${TEST_RUN}"
	fi

	# ======================================================
	if [  -z "${COLOUR}" ]
	then
		export COLOUR="black"
	else
		export COLOUR="${COLOUR}"
	fi

	# ======================================================
	if [  -z "${STACK_TYPE}" ]
	then
		export STACK_TYPE="tall"
	else
		export STACK_TYPE="${STACK_TYPE}"
	fi

	# ======================================================
	if [  -z "${JMETER_THREADS}" ]
	then
		# Setup default values depending on stack type
		if [ "${STACK_TYPE}" == "tiny_stack" ]
		then
			JMETER_THREADS=1
		elif [ "${STACK_TYPE}" == "big_stack" ]
		then
			JMETER_THREADS=5
		elif [ "${STACK_TYPE}" == "huge_stack" ]
		then
			JMETER_THREADS=10
		fi
		export JMETER_THREADS=${JMETER_THREADS}
		
	else
		export JMETER_THREADS=${JMETER_THREADS}
	fi

	# ======================================================
	if [  -z "${JMETER_USERS}" ]
	then
		# Setup default values depending on stack type
		if [ "${STACK_TYPE}" ==  "tiny_stack" ]
		then
			JMETER_USERS=1
		elif [ "${STACK_TYPE}" == "big_stack" ]
		then
			JMETER_USERS=5
		elif [ "${STACK_TYPE}" == "huge_stack" ]
		then
			JMETER_USERS=10
		fi
		export JMETER_USERS=${JMETER_USERS}
	else
		export JMETER_USERS=${JMETER_USERS}
	fi

	# ======================================================
	if [  -z "${JMETER_SLEEP}" ]
	then
		export JMETER_SLEEP=30
	else
		export JMETER_SLEEP=${JMETER_SLEEP}
	fi
}

# ==============================================================
# Setup env 
# ==============================================================
function setup_environment () {


if [ "${ENVIRONMENT}" == "aws_test" ]
then
	export SERVER_SUBSCRIPTION="test"
	export SERVER_ENV="testing"
	export environment="aws_cloud"

elif [ "${ENVIRONMENT}" == "aws_dev" ]
then
	export SERVER_SUBSCRIPTION="dev"
	export SERVER_ENV="unstable"
	export environment="aws_cloud"

elif [ "${ENVIRONMENT}" == "int" ]
then
	export SERVER_SUBSCRIPTION=""
	export SERVER_ENV=""
	export environment="int"

elif [ "${ENVIRONMENT}" == "pp" ]
then
	export SERVER_SUBSCRIPTION=""
	export SERVER_ENV=""
	export environment="preprod"

elif [ "${ENVIRONMENT}" == "akamai" ]
then
	export SERVER_SUBSCRIPTION=""
	export SERVER_ENV=""
	export environment="akamai"
else
	# Default to safe Development environment
	export ENVIRONMENT="aws_dev"
	export SERVER_SUBSCRIPTION="dev"
	export SERVER_ENV="unstable"
	export environment="aws_cloud"
fi

check_cmdline_vars
TEST_RUN=${TEST_RUN}_${ENVIRONMENT}_${STACK_TYPE}_${JMETER_THREADS}_${JMETER_USERS}
check_test_results_dir ${TEST_RUN}
check_jmeter_test_script
check_jmeter_gui
COLOUR="${COLOUR:?ERROR: Stack colour not specified, use --colour=<colour_of_stack>}"
TARGET_URL="${PRODUCT}-${TAG}-${SERVER_ENV}-${COLOUR}.${SERVER_REGION}.${SUBSCRIPTION_PREFIX}-${SERVER_SUBSCRIPTION}.aws.${URL}"
# TODO : Support for other enironments.
}

# ==============================================================
# Setup env 
# ==============================================================
function launch_test () {

export JVM_ARGS="-Xms2048M -Xmx6144M"
setup_environment
JMETER_LOGS="${JMETER_LOGS}/${TEST_RUN}"

echo "
TARGET_URL =        ${TARGET_URL}
JMETER_BIN =        ${JMETER_BIN}
JMETER_HOME =       ${JMETER_HOME}
JMETER_SCRIPTS =    ${JMETER_SCRIPTS}
JMETER_TEST_CASES = ${JMETER_TEST_CASES}
JMETER_LOGS =       ${JMETER_LOGS}
TEST_RUN = 	    ${TEST_RUN}
JMETER_THREADS =    ${JMETER_THREADS}
JMETER_USERS =      ${JMETER_USERS} 
JMETER_SLEEP =	    ${JMETER_SLEEP}
STACK_TYPE =	    ${STACK_TYPE}

JMETER_TEST_FILE =  ${JMETER_TEST_FILE}" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log

START_TIME=`date`
						# for j in 100 200 300 400 500 600 700 
for total_num_of_threads in ${JMETER_THREADS} 	# 500 600 700 
do
	for num_of_users in ${JMETER_USERS} 	# 00 200 300 400 500	# AWS Cloud, Venti
						# for i in 50 75 100 150 175 200 250 # -- preprod
						# for i in 75 100 150 175 200 # -- preprod
						# for i in 10 25 50 75 100 150 175 200 250 # -- All
	do  
		echo " ===================================================================================" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		echo "(${START_TIME}) Starting ${num_of_users} threads, ${total_num_of_threads} requests/second" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		echo " ===================================================================================" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		echo " ${JMETER_BIN}/jmeter.sh -p ${JMETER_BIN}/jmeter.properties -t ${JMETER_TEST_CASES}/${JMETER_TEST_FILE} -Jjmeter_home=${JMETER_HOME} -Jtotal_num_of_threads=${total_num_of_threads} -Jlaunch_num_of_threads=2 -Joutputdir=${JMETER_LOGS}/ -Jenvironment=${environment} -Jtest_duration=12 -Jtest_users=${num_of_users} -Jregion_label=DEFAULT -Jsearch_timeout=180000  -Jactivate_standard_test=true -JSERVER_REGION=eu-west-1 -JSERVER_SUBSCRIPTION=${SERVER_SUBSCRIPTION} -JSUBSCRIPTION_PREFIX=${SUBSCRIPTION_PREFIX} -JPRODUCT=${PRODUCT} -JTAG=${TAG} -JSERVER_ENV=${SERVER_ENV} -JURL=${URL} -Jcolour=${COLOUR} ${JMETER_GUI} " | tee -a ${JMETER_LOGS}/${TEST_RUN}.log

		if [ ${DRY_RUN} == 0 ]
		then
		${JMETER_BIN}/jmeter.sh -p ${JMETER_BIN}/jmeter.properties -t ${JMETER_TEST_CASES}/${JMETER_TEST_FILE} -j ${JMETER_LOGS}/jmeter.log -Jjmeter_home=${JMETER_HOME} -Jtotal_num_of_threads=${total_num_of_threads} -Jlaunch_num_of_threads=2 -Joutputdir=${JMETER_LOGS}/ -Jenvironment=${environment} -Jtest_duration=5 -Jtest_users=${num_of_users} -Jregion_label=DEFAULT -Jsearch_timeout=180000  -Jactivate_standard_test=true -JSERVER_REGION=eu-west-1 -JSERVER_SUBSCRIPTION=${SERVER_SUBSCRIPTION} -JSUBSCRIPTION_PREFIX=${SUBSCRIPTION_PREFIX} -JPRODUCT=${PRODUCT} -JTAG=${TAG} -JSERVER_ENV=${SERVER_ENV} -JURL=${URL} -Jjmeter.save.saveservice.output_format=xml -Jcolour=${COLOUR} ${JMETER_GUI}  | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		fi
		echo "Sleep ${JMETER_SLEEP}, `date`" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		sleep ${JMETER_SLEEP}
	done
echo "Sleep ${JMETER_SLEEP}, `date`" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
sleep ${JMETER_SLEEP}
done
END_TIME=`date`
		echo " ===================================================================================" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		echo "Start (${START_TIME}) " | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		echo "End   (${END_TIME}) " | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		echo " ===================================================================================" | tee -a ${JMETER_LOGS}/${TEST_RUN}.log
		
		${JMETER_SCRIPTS}/jtlmin.sh ${JMETER_LOGS}/${total_num_of_threads}-output.csv
		cat ${JMETER_LOGS}/${total_num_of_threads}-output.csv.jtlmin.*.OUT

}


# ===========================
#
# ===========================
function version () {
	echo "${FILENAME} ${VERSION}"
}
# ===========================
#
# ===========================
function usage () {

echo -e "Oh dear, did you get it wrong? Do you need help?!";

USAGE="
Description:
 Front end script for launching jmeter tests.

Commands:
  --help                        Show help
  --version                     Show version
  --env                         Show environment info
  --perf-test                   Run test 

Arguments:
  --jmeter-test-file=		Name of Jmeter (jmx) test file (located in scripts folder).

Optional flags:
  --test-run=            	default=jmeter    ; Short, succinct description of test, also serves as dirname of logs 
  --env=			default=aws_dev   ; Target test environment [aws_dev|aws_test|int|pp|akamai]
  --stack-colour=		default=black     ; Colour of AWS stack
  --region=			default=eu-west-1 ; AWS Region 		
  --prefix=			default=prefix    ; Prefix for AWS stacks 	
  --product=			default=product   ; Product code 		
  --tag-id=			default=tag       ; tag 	
  --site-url=			default=foobar.com; url site 	

Example:
        Launch tests : 
                ${FILENAME} --perf-test --jmeter-test-file=hum_bug.jmx
                ${FILENAME} --perf-test --stack-colour=blue --env=aws_test --jmeter-test-file=humbug.jmx 
                ${FILENAME} --perf-test --test-run=foo --stack-colour=black --env=aws_test --jmeter-test-file=humbug.jmx --region=eu-east-2 --prefix=prefix_txt --product=prd_text --tag-id=tag --site-url=foobar.com 
"
        echo "${FILENAME:?} ${VERSION:?}"
        echo -e "${USAGE:?}"
}

# ==============================================================
# Parse command line arguments and execute command.
# ==============================================================
command=none
DRY_RUN=0;
JMETER_GUI="-n"
while getopts "vgh:e:S:u:r:-:" arg; do
  case $arg in
    h )  usage ; exit 0;;
    v )  version ; exit 0;;
    g )  JMETER_GUI="" ;;
    - )  LONG_OPTARG="${OPTARG#*=}"
         case $OPTARG in
           test-run=?* )                 TEST_RUN="$LONG_OPTARG" ;;
           test-run* )                   die "Option '--$OPTARG' requires an argument" ;;

           dry-run* )     		 DRY_RUN=1;;
           gui* )     		 	 JMETER_GUI="";;

           env=?* )     		 ENVIRONMENT="$LONG_OPTARG" ;;
           env* )       		 die "Option '--$OPTARG' requires an argument" ;;

           region=?* )     		 SERVER_REGION="$LONG_OPTARG" ;;
           region* )       		 die "Option '--$OPTARG' requires an argument" ;;

           prefix=?* )     		 SUBSCRIPTION_PREFIX="$LONG_OPTARG" ;;
           prefix* )       		 die "Option '--$OPTARG' requires an argument" ;;

           product=?* )     		 PRODUCT="$LONG_OPTARG" ;;
           product* )       		 die "Option '--$OPTARG' requires an argument" ;;

           tag-id=?* )     		 TAG="$LONG_OPTARG" ;;
           tag-id* )       		 die "Option '--$OPTARG' requires an argument" ;;

           site-url=?* )     		 URL="$LONG_OPTARG" ;;
           site-url* )       		 die "Option '--$OPTARG' requires an argument" ;;

           stack-colour=?* )     	 COLOUR="$LONG_OPTARG" ;;
           stack-colour* )       	 die "Option '--$OPTARG' requires an argument" ;;

           stack-type=?* )     	 	 STACK_TYPE="$LONG_OPTARG" ;;
           stack-type* )       	 	 die "Option '--$OPTARG' requires an argument" ;;

           gui=?* )     	 	 JMETER_GUI="$LONG_OPTARG" ;;
           gui* )       	 	 die "Option '--$OPTARG' requires an argument" ;;

           jmeter-test-file=?* )     	 JMETER_TEST_FILE="$LONG_OPTARG" ;;
           jmeter-test-file* )       	 die "Option '--$OPTARG' requires an argument" ;;

           jmeter-threads=?* )     	 JMETER_THREADS="$LONG_OPTARG" ;;
           jmeter-threads* )       	 die "Option '--$OPTARG' requires an argument" ;;

           jmeter-users=?* )     	 JMETER_USERS="$LONG_OPTARG" ;;
           jmeter-users* )       	 die "Option '--$OPTARG' requires an argument" ;;

           jmeter-sleep=?* )     	 JMETER_SLEEP="$LONG_OPTARG" ;;
           jmeter-sleep* )       	 die "Option '--$OPTARG' requires an argument" ;;

	   perf-test)			 command="launch_test";;
           version )                     version ; exit 0;;
           help )                        usage ; exit 0;;
           * )                           die "Illegal option --$OPTARG" ; usage ; exit 1;;
         esac ;;
    \? ) exit 2 ;;
  esac
done
shift $((OPTIND-1))

case "$command" in
  none )  usage ;;
  *)      ${command};;
esac
