generated_path=~/git/basic-site-template/generated
destination_path=/var/www/tests
destination_server=dahir.ca
assets_copied=0

program_name=$0
username=${1}
shift 1
password=${1}
shift 1

while getopts "p:s:g:h:" opt; do
  case ${opt} in
    p) 
      echo "Setting: $OPTARG" >&1
      destination+=$OPTARG
      ;;
    s) 
      echo "Setting: $OPTARG" >&1
      server+=$OPTARG
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

usage() { echo "Usage: $program_name username password [-s server.com] [-p /destination/on/server] [-g generated/path/dir] [-h]" 1>&2; exit 1; }
generated_formatting_error() { echo "Destination path $generated is not a directory" 1>&2; exit 1; }

if [ -z "$username" ]; then
  usage
  exit;
fi

if [ -z "$password" ]; then
  usage
  exit;
fi

# Setup server path
if [ -z "$server" ]; then
  #server="${username}@${destination_server}"
  server="${destination_server}"
  echo "server path unset using default path: $server";
else
  #server="${username}@${server}"
  echo "server path set: $server";
fi

# Setup destination path
if [ -z "$destination" ]; then
  destination="${destination_path}/"
  echo "destination path unset using default path: $destination";
else
  echo "destination path set: $destination";
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

echo "Server: [$server]"
echo "Destination: [$destination]"
echo "Generated: [$generated]"
echo "User: [$username:$password]"

# Copy over all the generated files
for file in $generated/*
do
  page=${file%*/}
  page=${page##*/}
  if [[ $page == *".html" ]]; then
    echo "SCP [$page] to [$server:$destination] ..."
    #mv "${file}" "${destination}/${page}";
    #scp "${file}" "${username}@${server}:${destination}/${page}";
    curl --insecure --user ${username}:${password} -T ${file} sftp://"${server}/${destination}/${page}";
  fi
done

# Copy over static directories
if [ -d "js" ]; then
  scp -r "js" "${username}@${server}:${destination}/";
fi

if [ -d "game" ]; then
  scp -r "game" "${username}@${server}:${destination}/";
fi

if [ -d "font" ]; then
  scp -r "font" "${username}@${server}:${destination}/";
fi

if [ -f "style.css" ]; then
  scp "style.css" "${username}@${server}:${destination}/";
fi

exit 0
