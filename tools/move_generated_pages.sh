generated_path=~/git/basic-site-template/generated
destination_path=~/git/basic-site-template/site
program_name=$0
first_arg=`tr [A-Z] [a-z] <<< ${1}`

shift 1

while getopts "p:g:h:" opt; do
  case ${opt} in
    p) 
      echo "Setting: $OPTARG" >&1
      destination+=$OPTARG
      ;;
    g) 
      echo "Setting: $OPTARG" >&1
      generated+=$OPTARG
      ;;
    h) 
      usage
      ;;
    \?) 
      echo "Ignoring: $OPTARG" >&1
      ;;
    *) 
      echo "Star ignore: $OPTARG" >&1
      ;;
  esac
done

shift $((OPTIND - 1))

usage() { echo "Usage: $program_name [-p destination/path/dir] [-g generated/path/dir] [-h]" 1>&2; exit 1; }
destination_formatting_error() { echo "Destination path $destination is not a directory" 1>&2; exit 1; }
generated_formatting_error() { echo "Destination path $generated is not a directory" 1>&2; exit 1; }

if [ ! -z "$first_arg" ]; then
  usage
  exit;
fi

# Setup destination path
if [ -z "$destination" ]; then
  destination="${destination_path}/"
  echo "destination path unset using default path: $destination";
else
  echo "destination path set: $destination";
fi

if [ ! -d "$destination" ]; then
  destination_formatting_error
  exit;
fi

# Setup generated path
if [ -z "$generated" ]; then
  generated="${generated_path}"
  echo "generated path unset using default path: $generated";
else
  echo "generated path set: $generated";
fi

if [ ! -d "$generated" ]; then
  generated_formatting_error
  exit;
fi

echo "Destination: [$destination]"
echo "Generated: [$generated]"

for file in $generated/*
do
  page=${file%*/}
  page=${page##*/}
  if [[ $page == *".html" ]]; then
    if [ -f "${destination}/${page}" ]; then
      echo "$page already exists in $destination";
      mv "${destination}/${page}" "${destination}/${page}.old";
    fi
    echo "Moving [$page] to [$destination] ..."
    mv "${file}" "${destination}/${page}";
  fi
done

exit 0
