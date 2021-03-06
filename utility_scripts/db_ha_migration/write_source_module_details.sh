#!/usr/bin/env bash

## Get the DB details from the statefile and write as text file for import and
## deletion.

# get the db type from the file name eg mis, misboe, misdsd
dbtype="$( pwd | awk -F/ '{print $NF}' | awk -F_ '{print $2}')"
# get the last part of the filename
db="$(pwd | awk -F/ '{print $NF}' | awk -F_ '{print $NF}')"

databases="${dbtype}_db_2 ${dbtype}_db_3"


scratch_path="/home/scratch/${TG_ENVIRONMENT_NAME}_SOURCE/${dbtype}"



if [[ ! -d "${scratch_path}" ]];
then
  echo "Create dir ${scratch_path}"
  mkdir -p "${scratch_path}"
fi

echo
echo "Environment name is :: ${TG_ENVIRONMENT_NAME}"
echo "We need to get the details for the two HA DBs"
echo "dbtype: ${dbtype}"
echo "databases: ${databases}"


for database in ${databases};
do
  echo "This database :: ${database}"

  file_prefix="${scratch_path}/${TG_ENVIRONMENT_NAME}_${database}"
  module_list="${file_prefix}_module_list.txt"
  module_ids="${file_prefix}_module_ids.txt"
  lockfile="${file_prefix}_lockfile.txt"

  if [ -f "${lockfile}" ]; then
      echo "Exiting to avoid overwriting data"
      exit 0
  fi

  echo "Get list of modules and write to file\n"
  terragrunt state list | grep "${database}" >> "${module_list}"
  echo "Get list of modules and write to file\n"
  cat "${module_list}"

  for module in $(cat ${module_list})
  do
    if [[ ${module} == *"aws_volume_attachment"* ]] || [[ ${module} == *"template_file"* ]]; then
      echo "We don't want this ${module}"
    else
      echo "${module}:"$(terragrunt state show "${module}" | grep "^id" | cut -d'=' -f2 | xargs) >> "${module_ids}"
    fi
  done

  cat "${module_ids}"

  echo "Create a lock file for ${database} to stop it running again"
  echo "${TG_ENVIRONMENT_NAME}_${database}" >> "${lockfile}"
  date >> "${lockfile}"
done
