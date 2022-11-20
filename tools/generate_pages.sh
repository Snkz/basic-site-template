generated_path=~/git/basic-site-template/generated
template_path=~/git/basic-site-template/template
content_path=~/git/basic-site-template/content
program_name=$0
page=`tr [A-Z] [a-z] <<< ${1}`
header=""
blurb=""
nav=""
blog=""

shift 1

while getopts "t:c:v:" opt; do
  case ${opt} in
    v) 
      echo "Setting: $OPTARG" >&1
      variables+=$OPTARG
      ;;
    t) 
      echo "Setting: $OPTARG" >&1
      template+=$OPTARG
      ;;
    c) 
      echo "Setting: $OPTARG" >&1
      content+=$OPTARG
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

usage() { echo "Usage: $program_name page [-t template/path/dir/] [-c content/path/dir/]" 1>&2; exit 1; }
template_formatting_error() { echo "Template Directory layout: $template/header.ini $template/blurb.ini $template/nav.ini $template/nav_element.ini $template/blog.ini" 1>&2; exit 1; }
content_formatting_error() { echo "Content Directory layout: $content/header.txt $content/blurb.txt $content/nav.txt [directory/blogs.txt ...]" 1>&2; exit 1; }
generate_nav_section() {
  # Break reached generate a nav section
  export nav_header="${nav_content[0]}"
  nav_element=""
  for ((i=1; i<=${#nav_content[@]}; i++))
  do
    export nav_element+="<li id=\"location\">"${nav_content[$i]}"</li>"
  done
  nav_data+=`envsubst < "$template/nav.ini"`
  nav_content=()
  should_generate_line=0
}

generate_blog_section() {
}

generate_page() {
if [ -f "${generated_path}/${page}.html" ]; then
  echo "$page.html already exists in $generated_path";
  mv "${generated_path}/${page}.html" "${generated_path}/${page}.html.old";
fi
echo "Creating $generated_path/$page.html...";
cat <<- _EOF_ > $generated_path/$page.html
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="/style.css">
    <title> ${title} </title>
  </head>
  <body>
    ${header_data}
    <div id="side">
      ${blurb_data}
      ${nav_data}
    </div>
    ${blog_data} 
  </body>
</html>
_EOF_
}

if [ -z "$page" ]; then
  usage
  exit;
fi

# Setup template path
if [ -z "$template" ]; then
  template="${template_path}/default"
  echo "template path unset using default path: $template";
else
  echo "template path set: $template";
fi

if [ ! -d "$template/" ] || [ ! -f "$template/header.ini" ] || [ ! -f "$template/blurb.ini" ] || [ ! -f "$template/nav.ini" ] || [ ! -f "$template/nav_element.ini" ] || [ ! -f "$template/blog.ini" ]; then
  template_formatting_error
  exit;
fi

# Setup content path 
if [ -z "$content" ]; then
  content="${content_path}"
  echo "content path unset using default path: $content";
else
  echo "content path set: $content";
fi

if [ ! -d "$content" ] || [ ! -f "$content/header.txt" ] || [ ! -f "$content/blurb.txt" ] || [ ! -f "$content/nav.txt" ]; then
  content_formatting_error
  exit;
fi

# Move old index page over (TODO: For all pages we generate we need to do this)
if [ -f "${generated_path}/${page}.html" ]; then
  echo "$page.html already exists in $generated_path";
  mv "${generated_path}/${page}.html" "${generated_path}/${page}.html.old";
fi


# For each directory
  # Read main header.txt (unless a sub is present in directory)
  # Set env variables (Title, Header, SubHeader)
  # envsubst the template
  # save as header var
  #
  # Read main blurb.txt (unless a sub is present in directory)
  # For each line until new line, append line to blurb_content, wrap in <p>
  # envsubst the template blurb
  # save as nav var blurb
  # 
  # Read main nav.txt (unless a sub is present in directory)
  # First line is set to nav_header
  # For each line until new line, set line to nav_contnet 
  # envsubst the template nav_element, append to nav_element until new line
  # envsubst the template nav
  # save as nav var
  #
  # Read every file other then the blurb/header/nav labeled ones
  # First line takes date variable
  # Second line takes header variable, if new line, header is skipped
  # Every other line from this point on is read until a new line is met, wrap in <p>
  # store into variable blog_text
  # envsubst the template blog
  # save as nav blog
  # 
  # Generate the page according to directory name (no more passing in "page"
  # Move if overlaps
  # move to next directory

echo "Page: [$page]"
echo "Template: [$template]"
echo "Content: [$content]"

for dir in $content/*/
do
  page=${dir%*/}
  page=${page##*/}
  echo Parsing Directory: [$dir] ...
  echo " >>> Header ..."
  #TODO: Need to test if current directory has a header override
  # Avoid pipe to preserve scope, pipes create new env
  header_content=()
  while read line
  do
    if [ ! -z "$line" ]; then
      header_content+=("$line")
    fi
  done < "$content/header.txt"

  export title="${header_content[0]}"
  export header=${header_content[1]}
  export sub_header=${header_content[2]}
  header_data=`envsubst < "$template/header.ini"`
  export header=""
  export sub_header=""

  echo " >>> Blurb..."
  blurb_data=""
  while read line
  do
    if [ ! -z "$line" ]; then
      # Run template against every line in blurb content
      export blurb_content=$line
      blurb_data+=`envsubst < "$template/blurb.ini"`"<br/>"
    fi
  done < "$content/blurb.txt"

  echo " >>> Nav..."
  nav_content=()
  nav_data=""
  should_generate_line=0
  while read line
  do
    # Consume lines until a break
    if [ ! -z "$line" ]; then
      should_generate_line=1
      nav_content+=("$line")
    else
      generate_nav_section
    fi
  done < "$content/nav.txt"


  if [ $should_generate_line -eq 1 ]; then
    generate_nav_section
  fi
  should_generate_line=0

  echo " >>> Blog..."
  blog_content=()
  blog_data=""
  should_generate_line=0

  if [ $should_generate_line -eq 1 ]; then
    generate_blog_section
  fi
  should_generate_line=0

  generate_page
done
