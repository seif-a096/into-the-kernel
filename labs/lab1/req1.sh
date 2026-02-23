#!/bin/bash
rm -r Lab1
mkdir Lab1
cd Lab1
cp ~/Desktop/words.txt ~/Desktop/numbers.txt .
paste words.txt numbers.txt > MergedContent.txt
head -n 3 MergedContent.txt
sort MergedContent.txt > SortedMergedContent.txt

echo "The sorted file is :"
cat SortedMergedContent.txt

# considering all users including me and my group 
chmod a-r SortedMergedContent.txt

sort MergedContent.txt | uniq

cat SortedMergedContent.txt | tr "a-z" "A-Z" > CapitalSortedMergedContent.txt
echo "cannot read SortedMergedContent.txt as you don't have read permission"

chmod a+r SortedMergedContent.txt 
# 12 again
cat SortedMergedContent.txt | tr "a-z" "A-Z" > CapitalSortedMergedContent.txt

# regex
cat MergedContent.txt | grep -n ^w.*[0-9]$

tr "i" "o" < MergedContent.txt > NewMergedContent.txt
paste MergedContent.txt NewMergedContent.txt
