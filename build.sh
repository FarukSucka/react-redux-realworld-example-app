#!/bin/bash

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

if [[ $environment == "staging" ]]
then
    REACT_APP_API_ROOT=https://faruk-staging.faruksuljic.com npm run-script build && mv build dist/staging
fi

if [[ $environment == "production" ]]
then
    REACT_APP_API_ROOT=https://faruk-production.faruksuljic.com npm run-script build && mv build dist/production
fi