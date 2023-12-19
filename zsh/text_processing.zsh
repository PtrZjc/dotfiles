function line() {
    head -$1 | tail -1
}

function unescape() {
    pbpaste | \
    sd '\\\\\\\"' 'ALREADY_ESCAPED' | \
    sd '\\n' '' | \
    sd '\\"' '"' | \
    sd 'ALREADY_ESCAPED' '\\\"' 
}

# this function is meant to be used with stdin input 
function ucase() {
  while read -r line; do
    print -r -- ${(U)line}
  done
}

# Function used to divide stdin into multiple files. Takes 1 argument as number of files to split into.
function split() {
  # Read stdin into a variable
  input_string=$(cat)

  # Calculate the length of the string
  length=${#input_string}

  # Number of files to split into
  num_files=$1

  # Calculate the length of each segment
  segment_length=$((length / num_files))

  # Initialize variables
  start=0
  end=$segment_length

  # Loop to create files
  for (( i=1; i<=num_files; i++ )); do
    # Extract the substring
    segment=${input_string:start:end}

    # Write to a fileune1
    echo -n "$segment" > "split_$i.txt"

    # Update start and end for the next iteration
    start=$((start + segment_length))
    end=$((end + segment_length))
  done
}

alias extract-ids='pbpaste | rg id | sd ".*(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w+{12}).*" "\$1," | pbcopy && pbpaste'
alias wrap-with-uuid='pbpaste | sd ".*?(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}).*" "UUID(\"\$1\"), " | pbcopy && pbpaste'
