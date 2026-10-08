#!/bin/zsh

create_file()
{
  local file="$1"

  # checks if file already exists 
  if [[ -e "$file" ]]; then
    echo "$file already exists."
  
  else
    echo "Creating file $file..."

    
    # ${file:h} is the folder part of the path (core/game.py -> core, main.py -> .)
    # mkdir -p creates that folder first, so the order of the lines doesn't matter anymore
    if mkdir -p "${file:h}" && touch "$file"; then
      echo "Done!"
    else
      echo "Failed to create $file"
    fi

  fi
}


create_directory()
{
  local directory="$1"

  # checks if directory already exists
  if [[ -d "$directory" ]]; then
    echo "$directory already exists."

  else
    mkdir -p "$directory"
    echo "Created Directory $directory"

  fi
}


remove_file()
{
  local file="$1"

  if [[ -f "$file" ]]; then
    echo "Removing file $file..."
    rm "$file"
    echo "Done!"
  
  else
    echo "Failed to remove $file."
 
  fi
}


remove_directory()
{
  local directory="$1"

  if [[ -d "$directory" ]]; then
    echo "Removing directory $directory..."
    rm -rf "$directory"
    echo "Done!"

  else
    echo "Failed to remove $directory."

  fi
}


scan_directory()
{
  local directory="$1"
  local output_file="$2"
  local item

  # * = anything, D = also match hidden files like .gitignore,
  # N = if nothing matches (empty folder) give back nothing instead of an error
  for item in "$directory"/*(DN)
  do
    
    # skip the outputfile itself.
    if [[ "$item" == "./$output_file" ]]; then
      continue
    fi

    # ${item:t} is the last part of the path (./core/game.py -> game.py)
    # skip folders that would only add noise
    if [[ "${item:t}" == ".git" || "${item:t}" == ".venv" || "${item:t}" == "__pycache__" ]]; then
      continue
    fi

    # ${item#./} cuts the "./" off the front, so we get core/game.py
    if [[ -f "$item" ]]; then
      echo "f ${item#./}" >> "$output_file"

    elif [[ -d "$item" ]]; then
      echo "d ${item#./}" >> "$output_file"
      scan_directory "$item" "$output_file"
    fi

  done
}


# action is either "create" or "remove", so one function can do both
process_line()
{
    local action="$1"
    local line="$2"
 
    # f or d is the first character, the path is everything after "f " or "d "
    # (this way paths with spaces work too)
    local kind="${line[1]}"
    local target="${line[3,-1]}"
 
    # guard clause to check if line is empty or not
    if [[ -z "$line" ]]; then
        echo "Empty Line..."
        return
    fi
 
    # a correct line looks like "f something" or "d something"
    # the second character has to be a space and the path can't be empty
    if [[ "${line[2]}" != " " || -z "$target" ]]; then
        echo "Wrong input on line: $line"
        return
    fi
 
    if [[ "$kind" == "f" && "$action" == "create" ]]; then
        create_file "$target"
    elif [[ "$kind" == "d" && "$action" == "create" ]]; then
        create_directory "$target"
    elif [[ "$kind" == "f" && "$action" == "remove" ]]; then
        remove_file "$target"
    elif [[ "$kind" == "d" && "$action" == "remove" ]]; then
        remove_directory "$target"
    else
        echo "Wrong input on line: $line"
    fi
}

if [[ $1 == "line" ]]; then
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

elif [[ $1 == "file" ]]; then

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

elif [[ "$1" == "remove" ]]; then

  if [[ -z "$2" ]]; then
    echo "Usage: $0 remove [file.txt]"
    exit 1
  fi

  if [[ -f "$2" ]]; then
    lines=()

    while read line
    do
      if [[ -n "$line" ]]; then
        # this stores every blueprint line
        lines+=("$line")
      fi
    done < "$2"

    echo "Removing blueprint:"

    index=${#lines[@]}

    # removes the blueprint line in reverse order
    while [[ $index -gt 0 ]]
    do
      processing_and_removing "${lines[$index]}"
      ((index--))
    done

  else
    echo "File $2 does not exist"
  fi


elif [[ "$1" == "scan" ]]; then
  output_file="$2/structure.txt"

  : > "$output_file"
  scan_directory "$2" "$output_file"
  echo "Structure written to $output_file"

else
  echo "Usage:"
  echo 
  echo "$0 line ..... enter file names manually"
  echo "$0 file ..... give a file with names"
  echo "$0 remove ... remove a blueprint structure"
  echo "$0 scan ..... scan an existing structure"

fi
