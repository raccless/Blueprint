#!/bin/zsh

create_file()
{
  # checks if file already exists 
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
  # checks if directory already exists
  if [[ -d "$1" ]]; then
    echo "$1 already exists."

  else
    mkdir -p "$1"
    echo "Created Directory $1"
  
  fi
}

scan_directory()
{
  directory="$1"

  for item in "$directory"/*
  do
    if [[ -f "$item" ]]; then
      echo "f $item"
    elif [[ -d "$item" ]]; then
      echo "d $item"
    fi
  done

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
  mode=""

  # checks for correct usage of blueprint 1 command
  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 1 f <files...> d <directories...>"
    exit
  fi
  
  for argument in "${@:2}"
  do

    if [[ "$argument" == "f" ]]; then
      mode="file"
      echo "Mode changed to File..."

    elif [[ "$argument" == "d" ]]; then
      mode="directory"
      echo "Mode changed to Directory..."

    else
      echo "Argument: $argument"
      echo "Mode: $mode"
  
      if [[ "$mode" == "file" ]]; then
        create_file "$argument"

      elif [[ "$mode" == "directory" ]]; then
        create_directory "$argument"

      else
        echo "No Type (directory or file) selected, choose via d or f"
      fi

    fi  
  done

elif [[ $1 == 2 ]]; then

  # checks if anything is given to command blueprint 2
  if [[ -z "$2" ]]; then
    echo "Usage: $0 2 [file.txt]"
    exit 1
  fi

  # checks if the file exists or is empty
  if [[ -f "$2" ]]; then
  
    while read line
    do
      processing_and_splitting "$line"
    done < "$2"

  else
    echo "File $2 does not exist."
  fi

elif [[ "$1" == "scan" ]]; then
  scan_directory "$2"

else
  echo "Usage:"
  echo 
  echo "$0 1 ..... enter file names manually"
  echo "$0 2 ..... give a file with names"
fi
