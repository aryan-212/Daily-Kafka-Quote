#!/bin/bash

# Download the file and check if successful
if ! curl -o Kafka.txt 'https://drive.usercontent.google.com/download?id=1NG-d085E20ql-2mUTaWY7ndQMjFb9KTk&export=download&authuser=0'; then
    echo "Failed to download Kafka.txt"
    exit 1
fi

# Check if file exists and is readable
if [ ! -r "Kafka.txt" ]; then
    echo "Cannot read Kafka.txt"
    exit 1
fi

# Get current shell
shell=$(basename "$SHELL")

# Determine rc file and command format based on shell
case $shell in
    bash|zsh)
        rc_file="$HOME/.${shell}rc"
        read -r -d '' command << 'EOL'
daily_quote() {
    grep "^$(date '+%1d %B')" "$HOME/Kafka.txt" | shuf -n 1 | awk '{printf "\033[1;31m%s %s\033[0m\n%s\n", $1, $2, substr($0,index($0,$3))}'
}
daily_quote
EOL
        ;;
    fish)
        rc_file="$HOME/.config/fish/config.fish"
        read -r -d '' command << 'EOL'
function daily_quote
    grep "^"(date "+%1d %B") "$HOME/Kafka.txt" | shuf -n 1 | awk '{printf "\033[1;31m%s %s\033[0m\n%s\n", $1, $2, substr($0,index($0,$3))}'
end
daily_quote
EOL
        ;;
    *)
        echo "Unsupported shell: $shell"
        exit 1
        ;;
esac

# Check if rc file exists and is writable
if [ ! -w "$rc_file" ]; then
    echo "Cannot write to $rc_file"
    exit 1
fi

# Add command to rc file if it doesn't exist
if ! grep -q "daily_quote" "$rc_file"; then
    echo "$command" >> "$rc_file"
    echo "Command added to $rc_file"
else
    echo "Command already exists in $rc_file"
fi

# Execute the command immediately to show a quote
grep "^$(date "+%d %B")" Kafka.txt | shuf -n 1 | awk '{printf "\033[1;31m%s %s\033[0m\n%s\n", $1, $2, substr($0,index($0,$3))}'
