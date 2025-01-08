# SQLmap 

This script simplifies the process of using `SQLmap` by interactively prompting the user for input parameters, constructing the appropriate command, and executing it. It includes options for crawling, risk levels, tamper scripts, and more, making SQL injection testing more intuitive.

## Features

1. **Interactive Parameter Input**: Prompts the user for SQLmap options like target URL, HTTP method, risk level, testing level, tamper scripts, and more.
2. **Customizable Command**: Dynamically constructs the SQLmap command based on user input.
3. **Verbose and Tamper Support**: Includes options for verbose output and tamper scripts for bypassing security mechanisms.
4. **Automatic Table and Content Extraction**: Allows users to save database tables and their content for further analysis.

## Prerequisites

Ensure `SQLmap` is installed on your system. To install SQLmap, use:
```bash
sudo apt-get update
sudo apt-get install -y sqlmap
