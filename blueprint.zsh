#!/bin/zsh

create_file()
{
  if [[ -e "$1" ]]; then
    echo "$1 already exists."
  else
    echo "Creating file $1..."
    touch "$1"
    echo "Done!"
  fi
}

create_directory()
{
  if [[ -d "$1" ]]; then
    echo "$1 already exists."
  else
    mkdir -p "$1"
    echo "Created Directory $1"
  fi
}

if [[ $1 == 1 ]]; then
  for name in "${@:2}"
  do
    create_file "$name"
  done

elif [[ $1 == 2 ]]; then
  if [[ -f "$2" ]]; then
    while read line
    do
      create_file "$line"
    done < "$2"
  else
    echo "File does not exist."
  fi

else
  echo "Usage:"
  echo 
  echo "$0 1 ..... enter file names manually"
  echo "$0 2 ..... give a file with names"
fi
