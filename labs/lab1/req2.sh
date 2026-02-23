#!/bin/bash
#2.a
#helpers
function toDecimal {
    printf "%d\n" "$1"
}

function toHex {
    printf "%X\n" "$1"
}

#convert func
function convert {
    local data;

    if [[ "$1" == 1 ]]; then
        data="0x$2"
        toDecimal "$data" 
    elif [[ "$1" == 2 ]]; then
        toHex "$2"
    elif [[ -z "$2" ]];   then
        data="0x$1" 
        toDecimal "$data"
    else 
        echo "============invalid data...============="
        echo "Usage:"
        echo "  convert <number>      - hex to decimal"
        echo "  convert 1 <number>    - hex to decimal"
        echo "  convert 2 <number>    - decimal to hex"
        echo "========================================"
     fi
}

#2.b
function checkParen {
    local str="$1"
    local count=0
    
    for ((i=0; i<${#str}; i++)); do
        char="${str:$i:1}"
        
        if [[ "$char" == "(" ]]; then
            ((count++))
        elif [[ "$char" == ")" ]]; then
            ((count--))
            
            if (( count < 0 )); then
                echo 0
                return 0
            fi
        fi
    done
    
    if (( count == 0 )); then
        echo 1
        return 1
    else
        echo 0
        return 0
    fi
}