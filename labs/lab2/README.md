# Assignment: `sub_tool` - The C Subtitle Editor

Your task is to develop a command-line utility in **pure C** to manage subtitle files. This assignment focuses on low-level file handling, manual string manipulation, and CLI argument parsing.

---

## Constraints & Requirements
* **Language:** Pure C only.
* **Prohibited:** Do not use C++ libraries (`<iostream>`, `std::string`, etc.) or any non-standard third-party libraries.
* **Allowed Libraries:** `<stdio.h>`, `<stdlib.h>`, `<string.h>`.
* **Memory Management:** Ensure all opened files are closed properly and any dynamically allocated memory is freed.

---

## 1. Functional Requirements

The program must support the following flags and operations. The first argument after the executable must always be the input file path.

### View Operations
| Flag | Description |
| :--- | :--- |
| `-v` | **View All:** Prints the entire content of the input file to `stdout`. |
| `-v -n <line>` | **View Specific:** Prints only the specified line number to `stdout`. |
| `-f <n>` | **First Lines:** Reads and prints the first `n` lines of the file. |
| `-l <n>` | **Last Lines:** Reads and prints the last `n` lines of the file. |

### Edit Operations
For all edit operations, if `-s <output_file>` is specified, the result is saved to that file and the input file remains unchanged. If `-s` is **not** specified, the changes must be applied to the input file.

| Flag | Description |
| :--- | :--- |
| `-e <"text"> -n <line>` | **Edit Line:** Replaces the content of the specified line number with the new text. |
| `-i <"text">` | **Insert:** Appends the provided string as a new line at the very end of the file. |

---

## 2. Error Handling (Required)
Your program must handle the following cases by printing the specific error message to `stderr` and exiting with a non-zero status code:

1.  **File does not exist:** If the input file provided in the command line cannot be opened.
    * *Message:* `Error: File does not exist.`
2.  **Line out of bounds:** If a user requests a specific line number (via `-n`) that is less than 1 or greater than the total lines in the file.
    * *Message:* `Error: Line out of bounds.`
3.  **File limit exceeded:** If the user requests `-f` or `-l` with a number `n` that is larger than the total number of lines available in the file.
    * *Message:* `Error: File limit exceeded.`

---

## 3. Example Usage

```bash
# 1. Display the whole file
./sub_tool movie.srt -v

# 2. Display the 5th line only
./sub_tool movie.srt -v -n 5

# 3. Display the first 10 lines
./sub_tool movie.srt -f 10

# 4. Replace line 3 and save to a new file 'updated.srt'
./sub_tool movie.srt -e "Hello World" -n 3 -s updated.srt

# 5. Append a line to the end of the original file
./sub_tool movie.srt -i "End of Scene"
```

## 4. Submission Files
You must include the following files in your repository:

1. **sub_tool.h**: Your main header file.
2. **sub_tool.c**: Your main source file implementing the header functions.
3. **main.c**: Your main entry-point source file (must contain the main function).

4. **Makefile**: A file to compile your code into an executable named sub_tool.

## 5. Grading Criteria
1. **Correctness**: Code must produce the exact output requested.

2. **Compilation**: Code must compile with gcc -Wall -Werror without any warnings or errors.

3. **Robustness**: Proper error messages must be printed to stderr for invalid inputs.

4. **Cleanup**: No file pointer leaks (every fopen must have a corresponding fclose).
