#!/bin/bash

make build 

compare_output() {
    # The program to compile 
    input_file="$1" 
    echo "$input_file"
    ./zig-out/bin/cli "$input_file" $3 $5
    # The expected output 
    expected_content="$2"
    function_output=$(cat runtime.txt)
    
    # Compare runtime output 
    if [ "$function_output" = "$expected_content" ]; then
        echo "Runtime output matches the content of the file."
    else
        echo "Runtime output does not match the content of the file."
        echo "Expected $expected_content"
        echo "Found $function_output"
        exit 1
    fi
    # Check the deployment code also
    if [ -n "$3" ]; then
    # The expected output 
        expected_content="$4"
        function_output=$(cat deploy.txt)
        if [ "$function_output" = "$expected_content" ]; then
            echo "Deploy output matches the content of the file."
        else
            echo "Deploy output does not match the content of the file."
            echo "Expected $expected_content"
            echo "Found $function_output"
            exit 1
        fi
    fi
}

# Expected output tests
compare_output "./programs/your_first_program.golf" "5f"
compare_output "./programs/your_second_program.golf" "5f3560e01c63deadbeef146004580157005b5f"
compare_output "./programs/your_third_program.golf" "6007565b5f50565b586007016003565b"
compare_output "./programs/your_forth_program.golf" "6008565b60ff50565b586007016003565b"
compare_output "./programs/abi_decoer_program.golf" "6038565b5f516020511415600f57005b5f51600101805f526020028060405101358160605101355f5f5f5f84865af1586007016003565b565b5f600152600480350160405260243560040160605260405135602052586007016003565b" "deploy" "6060566038565b5f516020511415600f57005b5f51600101805f526020028060405101358160605101355f5f5f5f84865af1586007016003565b565b5f600152600480350160405260243560040160605260405135602052586007016003565b5b605d6003600039605d6000f3"
compare_output "./programs/constructor_program.golf" "5f54" "deploy" "6005565f545b6002600360003960183560005560026000f3" "1"
compare_output "./programs/if_conditions.golf" "5f3560e01c63deadbeef14601f5801575f3560e01c63deadc0de146008580157602b5f55005b602a5f0055005b60015f5500"

echo "Good compiler :)"
