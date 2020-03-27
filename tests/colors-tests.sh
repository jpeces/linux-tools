#!/bin/bash

. resources/colors
declare colorArr=(
    "${Black}"
    "${Red}"
    "${Green}"
    "${Brown}"
    "${Blue}"
    "${Purple}"
    "${Cyan}"
    "${LightGray}"
    "${darkGray}"
    "${lightRed}"
    "${lightGreen}"
    "${Yellow}"
    "${lightBlue}"
    "${lightPurple}"
    "${lightCyan}"
    "${White}"
    "${colorRestore}"
)

for color in "${colorArr[@]}"; do
    printf "${color}Color test\n"
done
