#!/bin/bash

make build 

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
compare_output "./programs/your_forth_program.golf" "6008565b60ff50565b586007016003565b"
compare_output "./programs/abi_decoer_program.golf" "603c565b5f516020511415600f57005b5f51600101805f52602002806040510135816060510135600060006000600086865af1586007016003565b565b5f600152600480350160405260243560040160605260405135602052586007016003565b"

echo "Good compiler :)"
# 5b601b565f516020511015600f57005b5f5f5f5860070160565b565b5f5f525f3580356020526020355860070160565b
# 5b601a565f516020511015600f57005b5f5f5f586007016056565b5f5f525f358035602052602035586007016056
