#!/bin/bash

# Comment out whatever you do not need

# Variables:

    # Colors
    Color_Off='\033[0m'     # Text Reset
    BYellow='\033[1;33m'    # Bold Yellow
    BGreen='\033[1;32m'     # Green
    BRed="\\033[1;31m"      # RED

### Define default settings
    sleepDuration=10
    DEFFILE="config/project-scratch-def.json"

### Get Settings from command  
while getopts d:n:f flag

do
        case "${flag}" in
                d) DURATION=${OPTARG}
                        ;;
                n) ORGNAME=${OPTARG}
                         ;;
                f) DEFFILE=${OPTARG}
                ;;
                *) echo "Invalid option: -$flag" ;;
        esac
done
####

if [ -z "$ORGNAME" ];
then
    echo -e "$BYellow Please provide a name for the Org.$Color_Off"
    read ORGNAME
fi

if [ -z "$DURATION" ];
then
    echo -e "$BYellow Please provide a duration for the scratch org (1-30)$Color_Off"
    while :; do
    read DURATION
    [[ $DURATION =~ ^[0-9]+$ ]] || { echo -e "$BRed Enter a valid number$Color_Off"; continue; }
    if ((DURATION >= 1 && DURATION <= 30)); then
        break
    else
        echo -e "$BRed Number out of range, try again$Color_Off"
    fi
    done
fi

### Execution

# Create Scratch Org

echo -e "$BYellow Creating Scratch org $Color_Off"
sf org create scratch -a $ORGNAME orgName=$ORGNAME -s -f $DEFFILE -d $DURATION
echo -e "$BGreen Creating Scratch org completed✅  $Color_Off"

# Install package dependencies
echo -e "$BYellow "install package dependency 1 $Color_Off""
sf package install --package 04t... -w 15
echo -e "$BGreen Package Installation completed✅  $Color_Off"

echo -e "$BYellow "install package dependency 2$Color_Off""
sf package install --package 04t... -w 15
echo -e "$BGreen Package Installation completed✅  $Color_Off"

# Push or deploy Metadata
# Pre Deployment
echo -e "$BYellow PRE DEPLOYMENT: Pushing Source / Deploying Metadata $Color_Off"
sf project deploy start --source-dir pre-deployment/force-app
echo -e "$BGreen PRE DEPLOYMENT: Pushing Source / Deploying Metadata completed✅  $Color_Off"

# Main Deployment
echo -e "$BYellow MAIN DEPLOYMENT: Pushing Source / Deploying Metadata $Color_Off"
sf project deploy start --source-dir force-app
echo -e "$BGreen MAIN DEPLOYMENT: Pushing Source / Deploying Metadata completed✅  $Color_Off"

# Post Deployment
echo -e "$BYellow POST DEPLOYMENT: Pushing Source / Deploying Metadata $Color_Off"
sf project deploy start --source-dir post-deployment/force-app
echo -e "$BGreen POST DEPLOYMENT: Pushing Source / Deploying Metadata completed✅  $Color_Off"



# Creating user(s)
echo -e "$BYellow Creating User $Color_Off"
sf org create user --definition-file config/project-user-def.json
echo -e "$BGreen Creating User completed✅  $Color_Off"

# Assign permissionsets
echo -e "$BYellow Assigning Permissions $Color_Off"
sf org assign permset --name DreamHouse --name CloudHouse
echo -e "$BGreen Assigning Permissions completed✅  $Color_Off"

# Load Data

# Tree Import
echo -e "$BYellow Importing Data $Color_Off"
sf data import tree --files Contact.json,Account.json
echo -e "$BGreen Data Import completed✅  $Color_Off"

# Bulk Import
echo -e "$BYellow Importing Data $Color_Off"
sf data import bulk --file accounts.csv --sobject Account
echo -e "$BGreen Data Import completed✅  $Color_Off"


### Running post deployment scripts
echo -e "$BYellow Running Post Deployment Script $Color_Off"
sf apex run --file ~/yourscript.apex 
echo -e "$BGreen Running Post Deployment Script completed✅ $Color_Off" 

#Open Org
echo "Org is set up"
sf force org open -p /lightning/page/home
