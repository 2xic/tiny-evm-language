#!/bin/bash

# Define your function
compare_output() {
    input_file="$1" # The script to run 
    echo "$input_file"
    ./zig-out/bin/cli "$input_file"
    expected_content="$2" # The expected output 
    function_output=$(cat output.txt)
    # Compare output 
    if [ "$function_output" = "$expected_content" ]; then
        echo "Function output matches the content of the file."
    else
        echo "Function output does not match the content of the file."
        echo "Expected $expected_content"
        echo "Found $function_output"
        exit 1
    fi
}

# First test 
compare_output "./programs/your_first_program.golf" "5f"
compare_output "./programs/your_second_program.golf" "5f3560e01c63deadbeef14600f57005b5f"
compare_output "./programs/your_third_program.golf" "6007565b5f50565b586007016003565b"

echo "Good compiler :)"
