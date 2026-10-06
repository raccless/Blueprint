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

  # guard clause to check if line is empty or not
  if [[ -z "$line" ]]; then
    echo "Empty Line..."
    return # maybe remove later if it randomly terminates
  fi
 
  # if the line is not empty then we can part the command, its more efficient
  parts=(${=line})

  # if the first part of the command is either f (file) or d (directory) and the last part isnt empty we continue
  if [[ "$parts[1]" == "f" && -n "$parts[2]" ]]; then
      create_file "$parts[2]"

  elif [[ "$parts[1]" == "d" && -n "$parts[2]" ]]; then
      create_directory "$parts[2]"

  else
      echo "Wrong input on line: $line"
  
  fi
}


if [[ $1 == 1 ]]; then
  for argument in "${@:2}"
  do
    echo "$argument"
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
