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
      variables+={$OPTARG}
      ;;
    t) 
      echo "Setting: $OPTARG" >&1
      template+={$OPTARG}
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

if [ -z "$page" ]; then
  usage
fi

if [ -z "$template" ]; then
  template="${template_path}/default/"
fi

if [ -f "${project_path}/${page}.html" ]; then
  echo "$page.html already exists in $project_path";
  mv "${project_path}/${page}.html" "${project_path}/${page}.html.old";
fi

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
