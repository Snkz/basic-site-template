project_path=~/git/basic-site-template/generated
template_path=~/git/basic-site-template/template
program_name=$0
page=`tr [A-Z] [a-z] <<< ${1}`
header=""
blurb=""
nav=""
blog=""

shift 1

while getopts "t:v:" opt; do
  case ${opt} in
    v) 
      echo "Setting: $OPTARG" >&1
      variables+=$OPTARG
      ;;
    t) 
      echo "Setting: $OPTARG" >&1
      template+=$OPTARG
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

usage() { echo "Usage: $program_name page [-t template/path/dir/] [-v variables]" 1>&2; exit 1; }
template_formatting_error() { echo "Template Directory layout: $template/header.ini $template/blurb.ini $template/nav.ini $template/blog.ini" 1>&2; exit 1; }

if [ -z "$page" ]; then
  usage
  exit;
fi

if [ -z "$template" ]; then
  template="${template_path}/default/"
  echo "template path unset using default path: $template";
else
  echo "template path set: $template";
fi

if [ ! -d "$template" ] ||[ ! -f "$template/header.ini" ] || [ ! -f "$template/blurb.ini" ] || [ ! -f "$template/nav.ini" ] || [ ! -f "$template/blog.ini" ]; then
  template_formatting_error
  exit;
fi

if [ -f "${project_path}/${page}.html" ]; then
  echo "$page.html already exists in $project_path";
  mv "${project_path}/${page}.html" "${project_path}/${page}.html.old";
fi


export sub_header="BIG WORDS"
echo "Parsing Header ..."
envsubst < "$template/header.ini" | while read line
do
  echo $line
done
echo "... done"

echo "Parsing Blurb ..."
envsubst < "$template/blurb.ini" | while read line
do
  echo "$line"
done
echo "... done"

echo "Parsing Nav ..."
envsubst < "$template/nav.ini" | while read line
do
  echo "$line"
done
echo "... done"

echo "Parsing Blog ..."
envsubst < "$template/blog.ini" | while read line
do
  echo "$line"
done
echo "... done"


echo "Page: [$page]"
echo "Template: [$template]"
echo "Variables [$variables]"

echo "Creating $project_path/$page.html...";

cat <<- _EOF_ > $project_path/$page.html
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="style.css">
    <title> ${page} </title>
  </head>
  <body>
    ${header}
    <div id="side">
      ${blurb} -- list
      ${nav} -- list
    </div> <!-- side -->
    ${blog} -- list
  </body>
</html>
_EOF_
