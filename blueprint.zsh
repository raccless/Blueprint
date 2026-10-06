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

if [[ $1 == 1 ]]; then
  echo "Give me some file names (+ extentions)"
  for name in "${@:2}"
  do
    create_file "$name"
  done

elif [[ $1 == 2 ]]; then
  echo "Enter the filename: "
  read filename
  if [[ -f "$filename" ]]; then
    while read line
    do
      create_file "$line"
    done < "$filename"
  else
    echo "File does not exist."
  fi

else
  echo "Usage:"
  echo 
  echo "$0 1 ..... enter file names manually"
  echo "$0 2 ..... give a file with names"
fi
