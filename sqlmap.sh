#!/bin/bash

# Function to explain a parameter
function explain() {
    echo -e "\033[1;34m$1\033[0m"
}

# Function to prompt the user for input with a default value
function prompt() {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}

# Ask for the target URL
explain "SQLmap Target URL"
echo "The URL to test for vulnerabilities (e.g., 'http://example.com/vulnerable.php?id=1')."
TARGET_URL=$(prompt "Enter the target URL" "")

# Ask for the crawl depth
explain "Crawl Depth"
echo "Specify how deeply SQLmap should crawl the website to discover links. A higher value means more pages will be tested but increases runtime."
CRAWL_DEPTH=$(prompt "Enter crawl depth (e.g., 1 for basic or 3 for deep)" "1")

# Ask for the request method
explain "HTTP Request Method"
echo "Specify the HTTP method to use (GET, POST, PUT, etc.). SQLmap will use this method when sending requests."
REQUEST_METHOD=$(prompt "Enter the HTTP request method" "GET")

# Ask for the risk level
explain "Risk Level"
echo "The risk level determines the aggressiveness of tests performed. 
1: Low risk (safe, minimal tests), 
2: Medium risk (moderate tests),
3: High risk (aggressive tests with potential impact)."
RISK_LEVEL=$(prompt "Enter the risk level (1, 2, or 3)" "1")

# Ask for the SQLmap level
explain "Testing Level"
echo "The testing level determines how many techniques and payloads are tested. 
1: Minimal testing, 
2: Moderate testing, 
5: Full testing with all techniques."
LEVEL=$(prompt "Enter the testing level (1-5)" "1")

# Ask if the user wants verbose output
explain "Verbose Output"
echo "Verbose mode provides detailed logs about the testing process."
VERBOSE_MODE=$(prompt "Enable verbose mode? (y/n)" "n")

# Ask if the user wants to use tamper scripts
explain "Tamper Scripts"
echo "Tamper scripts obfuscate SQL queries to bypass WAFs and IDS. For example: 'space2comment', 'between', etc."
TAMPER=$(prompt "Enter tamper script(s) to use (comma-separated, leave blank for none)" "")

# Ask for the output file
explain "Save Output"
echo "Save the results of the scan to a file in the current directory."
OUTPUT_FILE=$(prompt "Enter the output file name" "sqlmap_output.txt")

# Ask if the user wants to save tables and their contents
explain "Save Tables and Contents"
echo "SQLmap can extract and save tables and their contents into files."
SAVE_TABLES=$(prompt "Do you want to save tables and their contents? (y/n)" "n")

# Construct the SQLmap command
SQLMAP_CMD="sqlmap -u \"$TARGET_URL\" --level=$LEVEL --risk=$RISK_LEVEL --crawl=$CRAWL_DEPTH --method=$REQUEST_METHOD -o --batch --output=\"$PWD/$OUTPUT_FILE\""
[[ "$VERBOSE_MODE" == "y" ]] && SQLMAP_CMD+=" -v 3"
[[ -n "$TAMPER" ]] && SQLMAP_CMD+=" --tamper=\"$TAMPER\""

# Show the constructed command
explain "Constructed SQLmap Command"
echo "$SQLMAP_CMD"

# Ask for confirmation to run
read -p "Run this command? (y/n): " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
    eval $SQLMAP_CMD

    # If saving tables and content, proceed to extract them
    if [[ "$SAVE_TABLES" == "y" ]]; then
        echo "Extracting tables and content..."
        echo "Running SQLmap to enumerate databases..."
        DATABASES=$(sqlmap -u "$TARGET_URL" --batch --batch --dbs | grep -oP '(?<=\*\*\* ).*(?= \*\*\*)' | tail -n +2)

        for DB in $DATABASES; do
            echo "Found database: $DB"
            TABLES=$(sqlmap -u "$TARGET_URL" --batch -D "$DB" --tables | grep -oP '(?<=\*\*\* ).*(?= \*\*\*)' | tail -n +2)

            for TABLE in $TABLES; do
                echo "Extracting content from table: $TABLE in database: $DB"
                CONTENT_FILE="$PWD/${DB}_${TABLE}_content.txt"
                sqlmap -u "$TARGET_URL" --batch -D "$DB" -T "$TABLE" --dump > "$CONTENT_FILE"
                echo "Saved content of table $TABLE to $CONTENT_FILE"
            done
        done
    fi

    echo "SQLmap execution completed. Outputs saved to $PWD/$OUTPUT_FILE."
else
    echo "SQLmap command not executed. Modify the parameters and try again."
fi
