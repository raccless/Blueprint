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


processing_and_splitting()
{
  line="$1"
  parts=(${=line})
    if [[ -z "$line" ]]; then
      echo "Empty line... do nothing"
    elif [[ "$parts[1]" == "f" ]]; then
        create_file "$parts[2]"

    elif [[ "$parts[1]" == "d" ]]; then
        create_directory "$parts[2]"

    else
        echo "Wrong input"
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
      processing_and_splitting "$line"
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
