# 🐧 Linux & Bash Scripting — Complete Guide

> A comprehensive reference covering Linux commands, how the terminal works under the hood, regular expressions, and bash scripting. Everything from the basics to the science behind how it all works.

---

## 📚 Table of Contents

1. [How the Terminal Works](#1-how-the-terminal-works)
2. [The Shell — What It Is and Why It Exists](#2-the-shell--what-it-is-and-why-it-exists)
3. [Bash — A Specific Shell](#3-bash--a-specific-shell)
4. [How Commands Are Executed](#4-how-commands-are-executed)
5. [The /bin Directories](#5-the-bin-directories)
6. [Environment Variables and PATH](#6-environment-variables-and-path)
7. [stdin, stdout, stderr](#7-stdin-stdout-stderr)
8. [Essential Linux Commands](#8-essential-linux-commands)
9. [File Permissions and chmod](#9-file-permissions-and-chmod)
10. [Redirection and Pipes](#10-redirection-and-pipes)
11. [Text Processing Commands](#11-text-processing-commands)
12. [Regular Expressions](#12-regular-expressions)
13. [How the Regex State Machine Works](#13-how-the-regex-state-machine-works)
14. [Bash Scripting](#14-bash-scripting)
15. [Bash Variables and Parameter Expansion](#15-bash-variables-and-parameter-expansion)
16. [Arithmetic Expansion](#16-arithmetic-expansion)
17. [String Manipulation](#17-string-manipulation)
18. [Arrays](#18-arrays)
19. [Control Flow](#19-control-flow)
20. [Loops](#20-loops)
21. [Functions](#21-functions)
22. [Common Syntax Errors and Pitfalls](#22-common-syntax-errors-and-pitfalls)
23. [The Three Types of Conditionals](#23-the-three-types-of-conditionals)
24. [Loop Types Deep Dive](#24-loop-types-deep-dive)
25. [Command Substitution vs Function Calls](#25-command-substitution-vs-function-calls)
26. [Number System Conversions](#26-number-system-conversions)
27. [Special Operators Reference](#27-special-operators-reference)
28. [Source vs Execute](#28-source-vs-execute)

---

## 1. How the Terminal Works

When you type a command in the terminal, a program called the **shell** is always running and listening. When you press Enter, it goes through these steps:

```
You type a command
        ↓
Shell reads and tokenizes it (splits into pieces)
        ↓
Shell interprets special characters (|, >, $, *)
        ↓
Shell finds the program in the bin directories
        ↓
Shell forks (creates a copy of itself)
        ↓
The copy replaces itself with the target program (exec)
        ↓
Original shell waits for it to finish
        ↓
Output is returned to the screen
```

### Compiled vs Interpreted

| Type            | How it runs                                                           | Example                          |
| --------------- | --------------------------------------------------------------------- | -------------------------------- |
| **Compiled**    | Translated into machine code before running, CPU runs binary directly | `grep`, `ls`, `cat` (C programs) |
| **Interpreted** | Read and executed line by line at runtime by an interpreter           | Bash scripts `.sh`               |

> **Key insight:** Commands like `grep`, `ls`, `cat` are **pre-compiled C programs** stored on your disk. What you type in the terminal are just **arguments** passed to those programs — they are data, not code that needs compiling.

### How a C Program Receives Your Input

Every compiled C program has a `main` function that receives what you type:

```c
int main(int argc, char *argv[], char *envp[])
```

- **`argc`** — number of arguments
- **`argv`** — array of what you typed
- **`envp`** — array of environment variables

So when you type `grep -i "John" myfile.txt`:

```c
argv[0] = "grep"         // program name
argv[1] = "-i"           // first argument
argv[2] = "John"         // second argument
argv[3] = "myfile.txt"   // third argument
```

### Fork and Exec

Every command you run in bash is a **separate process** created through two system calls:

- **`fork()`** — creates an exact copy of the current bash process in memory
- **`exec()`** — the copy replaces itself with the target program

```
bash process
      ↓
   fork()
      ↓
bash process  +  copy of bash
                      ↓
                   exec()
                      ↓
              grep process runs
                      ↓
              finishes, bash resumes
```

---

## 2. The Shell — What It Is and Why It Exists

The **shell** is any program that sits between you and the operating system kernel. It is called a shell because it wraps around the OS like a shell, letting you communicate with the kernel without talking to it directly.

```
You → Shell → Kernel → Hardware
```

The **kernel** is the actual core of the OS that controls hardware, memory, and processes. You cannot talk to it directly. The shell is the layer that translates your human-readable commands into kernel operations through **system calls**.

### Types of Shells

| Shell        | Full Name                  | Notes                           |
| ------------ | -------------------------- | ------------------------------- |
| `sh`         | Bourne Shell               | The original, very basic        |
| `bash`       | Bourne Again Shell         | Most common in Linux            |
| `zsh`        | Z Shell                    | Default on macOS, more features |
| `fish`       | Friendly Interactive Shell | Beginner friendly               |
| `ksh`        | Korn Shell                 | Enterprise use                  |
| `CMD`        | Command Prompt             | Windows shell                   |
| `PowerShell` | PowerShell                 | Advanced Windows shell          |

> **Analogy:** Shell is the general concept (like SQL), bash is a specific flavor of it (like MySQL). CMD and PowerShell are to Windows what bash and zsh are to Linux.

> **Important Note:** Bash is just ONE type of shell program. The generic term is "shell" - bash is a specific implementation, like how "car" is generic and "Toyota" is specific.

---

## 3. Bash — A Specific Shell

**Bash** stands for **Bourne Again Shell** — a joke name because it replaced the original **Bourne Shell** written by Stephen Bourne. So bash is literally the "born again" shell.

Bash itself is a **compiled C program** stored at `/bin/bash`. When you run a bash script, bash reads your script file line by line and for each line it:

1. Reads the line as text
2. Parses it to understand the structure
3. Finds the appropriate compiled binary
4. Executes it via fork and exec
5. Moves to the next line

```bash
#!/bin/bash
echo "Hello"      # bash finds /bin/echo, runs it
ls -l             # bash finds /usr/bin/ls, runs it
grep "x" file     # bash finds /usr/bin/grep, runs it
```

### The Shebang `#!/bin/bash`

The first line of every bash script is the **shebang** (also called **hashbang**).

```bash
#!/bin/bash
```

- **`#`** is called **hash** (or sharp in music)
- **`!`** is called **bang** (old typographer slang)
- Together: **sha**rp + **bang** = **shebang**

**What it does:** When the OS sees `#!` at the very first line, it reads the path after it and uses that program to interpret the file.

```
You run: ./myscript.sh
        ↓
OS reads first line: #!/bin/bash
        ↓
OS loads /bin/bash and passes the script to it
        ↓
bash ignores first line (# makes it a comment)
        ↓
bash starts interpreting from line 2
```

The shebang is not bash-specific. Any interpreter can be used:

```bash
#!/bin/bash          # run with bash
#!/usr/bin/python3   # run with python
#!/usr/bin/node      # run with nodejs
```

---

## 4. How Commands Are Executed

### What You Type Is Just Data

The compiled programs (`grep`, `ls`, etc.) are built once and sit on your disk. What you type in the terminal is just **data** being passed into those programs — arguments, strings, filenames. Data does not need to be compiled.

```
compiled grep = "I know how to search ANY text for ANY pattern"
                (compiled once, sits on disk)

"John" myfile.txt = the specific pattern and file right now
                    (just data, no compilation needed)
```

> **Analogy:** A meat grinder is the compiled program, built once. Whatever meat you put in is the data. The grinder doesn't need to be rebuilt for different types of meat.

### Interpreted Scripts vs Compiled Programs

|                    | Compiled (e.g. grep)    | Interpreted (e.g. bash script) |
| ------------------ | ----------------------- | ------------------------------ |
| Speed              | Fast, CPU runs directly | Slower, interpreter overhead   |
| Needs interpreter? | No                      | Yes                            |
| After change       | Must recompile          | Run immediately                |
| Stored as          | Binary machine code     | Plain text                     |

> **Analogy:** Compiled is like translating an entire book into English first, then reading it. Interpreted is like having a translator sit next to you, reading one sentence at a time.

---

## 5. The /bin Directories

**`bin`** stands for **binaries** — pre-compiled C programs that the CPU can directly execute.

| Directory        | Contents                                                    |
| ---------------- | ----------------------------------------------------------- |
| `/bin`           | Essential system binaries (`ls`, `cat`, `grep`, `cp`, `rm`) |
| `/usr/bin`       | Regular user program binaries                               |
| `/usr/local/bin` | Manually installed binaries                                 |
| `/sbin`          | System administration binaries (root only)                  |

You can find where any command lives:

```bash
which grep
# /usr/bin/grep

which ls
# /usr/bin/ls
```

---

## 6. Environment Variables and PATH

### What an Environment Variable Is

When any process starts, the OS gives it a block of memory called the **environment** — a list of key=value pairs:

```
HOME=/home/seif096
USER=seif096
PATH=/usr/bin:/bin
```

In C, these are accessible as the third argument to `main`:

```c
int main(int argc, char *argv[], char *envp[])
// envp[] contains all environment variables
```

### Variable Scope

| Type                          | Visible to                            |
| ----------------------------- | ------------------------------------- |
| `NAME="x"`                    | Current bash process only             |
| `export NAME="x"`             | Current process + all child processes |
| Defined in `~/.bashrc`        | All terminals for your user           |
| Defined in `/etc/environment` | Every process on the system           |

> Variables flow **downward** from parent to child only. If a child changes a variable, the parent never sees it — each process has its own copy.

### The PATH Variable

`$PATH` is bash's **dictionary** of where to look for commands:

```bash
echo $PATH
# /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

When you type `grep`, bash searches each directory in PATH in order until it finds the binary:

```
type "grep"
        ↓
search /usr/local/bin  → not found
        ↓
search /usr/bin        → found! /usr/bin/grep
        ↓
run it
```

You can add your own programs to this dictionary:

```bash
PATH=$PATH:/home/seif096/myprograms
```

### System Configuration Files

| File               | When it runs              |
| ------------------ | ------------------------- |
| `/etc/environment` | Every user, system-wide   |
| `/etc/profile`     | Every user at login       |
| `~/.bashrc`        | Your user, every terminal |
| `~/.bash_profile`  | Your user, at login       |

---

## 7. stdin, stdout, stderr

Every process in Linux gets three standard channels automatically:

| Channel  | Name            | Meaning                            |
| -------- | --------------- | ---------------------------------- |
| `stdin`  | Standard Input  | Data flowing **into** the program  |
| `stdout` | Standard Output | Data coming **out** of the program |
| `stderr` | Standard Error  | Error messages coming out          |

The pipe `|` connects **stdout** of one program to **stdin** of the next:

```
cat myfile.txt     |      grep "John"
       ↓                       ↑
    stdout      connects     stdin
```

---

## 8. Essential Linux Commands

### `pwd` — Print Working Directory

```bash
pwd
# /home/seif096/documents
```

Displays the full path of the directory you are currently in. Think of it as asking your GPS **"where am I right now?"**

---

### `ls` — List Directory Contents

`ls` stands for **list**.

```bash
ls                    # list files in current directory
ls /home              # list files in specific path
ls -l                 # long format (detailed view)
ls -a                 # show hidden files (starting with .)
ls -la                # combine options
```

#### Understanding `ls -l` Output

```
-rwxr-xr-x  2  john  staff  4096  Jan 10 12:00  myfile.txt
```

| Part           | Meaning                 |
| -------------- | ----------------------- |
| `-rwxr-xr-x`   | File type + permissions |
| `2`            | Number of hard links    |
| `john`         | Owner (user)            |
| `staff`        | Group                   |
| `4096`         | File size in bytes      |
| `Jan 10 12:00` | Last modified date/time |
| `myfile.txt`   | File name               |

#### File Type (First Character)

| Character | Meaning       |
| --------- | ------------- |
| `-`       | Regular file  |
| `d`       | Directory     |
| `l`       | Symbolic link |

#### Real Example

```
-rw-rw-r-- 1 seif096 seif096 0 Feb 13 18:28 test.txt
```

- `-` — regular file
- `rw-` — owner can read and write
- `rw-` — group can read and write
- `r--` — others can only read
- `1` — one hard link
- `seif096` / `seif096` — owner and group both are seif096 (Linux creates a group with same name as user automatically)
- `0` — file is empty (0 bytes)
- `Feb 13 18:28` — last modified today

---

### `cat` — Concatenate

`cat` stands for **concatenate**. Original purpose was joining files, but most commonly used to display file contents.

```bash
cat file.txt                        # display file contents
cat file1.txt file2.txt             # display both files
cat file1.txt file2.txt > combined  # join and save
cat -n myfile.txt                   # display with line numbers
```

**Important Note:** `cat` merges files **vertically** (stacks them one after another), while `paste` merges **horizontally** (side-by-side columns).

---

### `cp` — Copy

```bash
cp source.txt destination/           # copy file to directory
cp file1.txt file2.txt destination/  # copy multiple files
cp -r source_dir/ dest_dir/          # copy directory recursively
cp -p file.txt destination/          # preserve attributes (permissions, timestamps)
cp -v file.txt destination/          # verbose (show what's being copied)
```

**CRITICAL PATH RULE:** When you're already inside a directory, use relative paths:

```bash
cd ~/Desktop/
cp words.txt numbers.txt Lab1/   # ✅ CORRECT - relative path

# NOT this:
cp ~/Desktop/words.txt ~/Lab1/   # ❌ WRONG - unnecessary full path
```

> **Why?** You're already in `~/Desktop/`, so `words.txt` is in the current directory. Using full paths when you're already there is redundant and error-prone.

**Important:** `cp` creates **duplicates** - both the original and the copy exist independently on disk, each taking up space.

---

### `mv` — Move

```bash
mv oldname.txt newname.txt     # rename file
mv file.txt /destination/      # move to different location
mv file.txt /dest/newname.txt  # move and rename
```

> **Key Difference from `cp`:** `mv` does NOT create a duplicate. The original file is removed from the source location. Only one copy exists on disk.

---

### `rm` — Remove

```bash
rm file.txt          # delete a file
rm -r myfolder/      # delete directory and everything inside
```

**`-r` means recursive** — goes through all contents inside a directory, and all contents inside those, all the way down:

```
myfolder/
├── file1.txt         ← deleted
├── file2.txt         ← deleted
└── subfolder/
    ├── file3.txt     ← deleted
    └── deeper/
        └── file4.txt ← deleted
```

> **Think of it like a tree:** recursive means "go deep into every level and repeat the same action."

---

## 9. File Permissions and chmod

### Permission Groups

Every file has permissions for three groups:

| Group      | Symbol in chmod | Who                                  |
| ---------- | --------------- | ------------------------------------ |
| Owner/User | `u`             | The person who owns the file         |
| Group      | `g`             | Users in the file's associated group |
| Others     | `o`             | Everyone else on the system          |
| All        | `a`             | All three at once                    |

### Permission Types

| Permission | Symbol | Value | Meaning for file | Meaning for directory      |
| ---------- | ------ | ----- | ---------------- | -------------------------- |
| Read       | `r`    | 4     | View contents    | List contents              |
| Write      | `w`    | 2     | Modify file      | Create/delete files inside |
| Execute    | `x`    | 1     | Run as program   | Enter with `cd`            |
| None       | `-`    | 0     | No permission    | No permission              |

### What Is a Group?

A group is a **collection of users**. For example, all developers in a company might be in a group called `developers`. This makes it easy to give all of them the same permissions without setting permissions individually.

> Linux asks three questions: _Are you the owner? Are you in the group? Or are you everyone else?_ Each gets their own permissions.

### `chmod` — Change Mode

**Symbolic method:**

```bash
chmod u+x myfile.txt      # add execute for owner
chmod g-w myfile.txt      # remove write from group
chmod o+r myfile.txt      # add read for others
chmod a+x myfile.txt      # add execute for everyone
chmod ugo+x myfile.txt    # same as a+x
chmod a-r myfile.txt      # remove read from everyone
chmod a+r myfile.txt      # restore read for everyone
```

Operators:

- `+` add permission
- `-` remove permission
- `=` set exact permission

**Numeric method:**

Add up the values for each group:

```
r = 4
w = 2
x = 1
- = 0
```

| Permission | Calculation | Value |
| ---------- | ----------- | ----- |
| `rwx`      | 4+2+1       | 7     |
| `rw-`      | 4+2+0       | 6     |
| `r-x`      | 4+0+1       | 5     |
| `r--`      | 4+0+0       | 4     |

```bash
chmod 764 myfile.txt
# owner: rwx (7)
# group: rw- (6)
# others: r-- (4)
```

The file `-rw-rw-r--` has numeric value **664**.

### Difference Between `o` and `a`

| Symbol | Affects                          |
| ------ | -------------------------------- |
| `o`    | Others **only** (third group)    |
| `a`    | All three: user + group + others |

```bash
chmod o+w myfile.txt    # only others get write
chmod a+w myfile.txt    # everyone gets write
```

### Common Permission Error Pattern

**Problem:** You remove read permission with `chmod a-r`, then try to read the file:

```bash
chmod a-r SortedMergedContent.txt
cat SortedMergedContent.txt
# Permission denied ❌
```

**Why it fails:** Without read permission, even YOU (the owner) cannot read the file.

**Solution:** Restore read permission:

```bash
chmod a+r SortedMergedContent.txt  # restore read for all
# OR
chmod u+r SortedMergedContent.txt  # restore read for owner only
```

> **Important:** Permission restrictions apply to EVERYONE, including the file owner (unless you're root).

---

### Hard Links vs Symbolic Links vs Copy

#### Symbolic Link

A **shortcut** that points to another file's location. If the original is deleted, the link breaks.

```bash
ln -s /original/file shortcut
```

#### Hard Link

Two different names pointing to the **exact same data** on disk. If one name is deleted, the data still exists under the other name.

```bash
ln /original/file hardlink
```

#### Copy

The binary data is **fully duplicated** on disk. Two completely independent files.

```bash
cp file1.txt file2.txt
```

|                                 | Copy   | Hard Link | Symbolic Link       |
| ------------------------------- | ------ | --------- | ------------------- |
| Data duplicated?                | Yes    | No        | No (just a pointer) |
| Disk space                      | Double | Same      | Tiny (just a path)  |
| Edit one, affects other?        | No     | Yes       | Yes                 |
| Delete original, affects other? | No     | No        | Yes (breaks)        |

> **Analogy:** Symbolic link = sticky note saying "document is in warehouse shelf 3". Hard link = same document with two different names on the cover. Copy = completely new document with the same content.

---

## 10. Redirection and Pipes

### `>` — Redirect Output to File

Sends command output to a file instead of the screen. **Overwrites** existing content.

```bash
cat file.txt > newfile.txt      # save output to file
echo "hello" > greeting.txt     # write text to file
```

### `>>` — Append to File

Sends output to a file **without overwriting** — adds to the end.

```bash
echo "line 1" > file.txt
echo "line 2" >> file.txt       # adds to end, doesn't overwrite
```

> **Analogy:** `>` erases the paper and writes new content. `>>` writes at the bottom without erasing.

### `<` — Input Redirection

Feeds a file's contents as input to a command:

```bash
tr "a-z" "A-Z" < input.txt > output.txt
# Read from input.txt, convert to uppercase, write to output.txt
```

> **Note:** This is more efficient than `cat input.txt | tr "a-z" "A-Z"` because it avoids creating an unnecessary `cat` process.

### `2>` — Redirect Error Messages

```bash
command 2>/dev/null    # suppress error messages
command 2>errors.log   # save errors to file
```

### `|` — Pipe

Takes the **stdout** of one command and sends it as **stdin** to the next command.

```bash
cat myfile.txt | grep "John"
```

You can chain multiple pipes like an **assembly line**:

```bash
cat myfile.txt | grep "John" | cut -d, -f2 | sort
```

Each command passes its output to the next one.

> **Analogy:** Like water pipes in a house — output flows from one pipe into the next.

**`>` vs `|`:**

| Operator | Sends output to | Example                    |
| -------- | --------------- | -------------------------- |
| `>`      | A file          | `echo "hi" > file.txt`     |
| `\|`     | Another command | `cat file.txt \| grep "x"` |

---

## 11. Text Processing Commands

### `grep` — Global Regular Expression Print

Searches for a pattern and prints matching lines.

```bash
grep "John" myfile.txt              # basic search
grep -i "john" myfile.txt           # case insensitive
grep -n "John" myfile.txt           # show line numbers
grep -v "John" myfile.txt           # invert (show non-matching lines)
grep -c "John" myfile.txt           # count matching lines
grep -E "John|Sarah" myfile.txt     # extended regex (OR)
```

#### When to Use Quotes

| Case               | Example                  | Quotes needed? |
| ------------------ | ------------------------ | -------------- |
| Single word        | `grep John file`         | Optional       |
| With spaces        | `grep "John Smith" file` | Required       |
| Special characters | `grep "hello$" file`     | Required       |

Single quotes `''` treat everything literally. Double quotes `""` allow variable/special character interpretation.

---

### `cut` — Extract Columns

Extracts specific columns from each line of a file.

```bash
# file contains: John,25,Cairo
cut -d, -f1 data.txt    # extract column 1: John
cut -d, -f2 data.txt    # extract column 2: 25
cut -d, -f3 data.txt    # extract column 3: Cairo
```

- **`-d`** — delimiter (what separates columns)
- **`-f`** — field number (which column to extract)

> Note: Unlike `Ctrl+X`, the Linux `cut` command does **not** delete from the original file. It only reads and extracts. The original stays untouched.

---

### `paste` — Join Files Side by Side

Joins files **horizontally** (column by column), while `cat` joins vertically.

```bash
paste file1.txt file2.txt           # join side by side (tab separated)
paste -d, file1.txt file2.txt       # use comma as delimiter
```

**Comparison:**

| `cat file1 file2` | `paste file1 file2` |
| ----------------- | ------------------- |
| John              | John 25             |
| Sarah             | Sarah 30            |
| Mike              | Mike 28             |
| 25                |                     |
| 30                |                     |
| 28                |                     |

> **Origin of the name:** From the physical act of cutting and pasting paper — placing two columns next to each other like gluing newspaper columns side by side.

---

### `tr` — Translate Characters

Replaces or deletes specific **characters** one by one. Works at the character level, not word level.

```bash
echo "hello world" | tr 'a-z' 'A-Z'    # lowercase to uppercase: HELLO WORLD
echo "hello world" | tr ' ' '_'         # replace spaces: hello_world
echo "hello world" | tr -d 'l'          # delete all l's: heo word
```

`tr` always reads from input so use with pipe `|` or `<`:

```bash
tr 'a-z' 'A-Z' < myfile.txt
```

**Common Pattern - Useless Use of `cat`:**

```bash
# Less efficient (creates unnecessary process):
cat SortedMergedContent.txt | tr "a-z" "A-Z" > output.txt

# More efficient (direct input redirection):
tr "a-z" "A-Z" < SortedMergedContent.txt > output.txt
```

> **Think of `tr` like find-and-replace in Word, but for individual characters.**

---

### `head` and `tail`

```bash
head -n 3 file.txt    # first 3 lines
tail -n 3 file.txt    # last 3 lines
```

---

### `sort` and `uniq`

```bash
sort file.txt                # sort lines alphabetically
sort file.txt > sorted.txt   # save sorted output

uniq file.txt                # remove adjacent duplicate lines
sort file.txt | uniq         # sort first, then remove duplicates
```

> **Important:** `uniq` only removes **adjacent** duplicates. Always `sort` first to group duplicates together.

---

## 12. Regular Expressions

Regular expressions (regex) are **patterns** used to match text. Each piece of a regex is like a **slot** that gets filled with one character at a time.

> **Connection to JavaScript:** All these regex concepts work identically in JavaScript. The `/pattern/g` syntax in JS is the same idea — `g` means global (search entire string), just like `grep` searches the entire file.

### Special Characters

| Symbol    | Name                 | Meaning                  | Example       | Matches                  |
| --------- | -------------------- | ------------------------ | ------------- | ------------------------ |
| `^`       | Caret                | Start of line            | `^John`       | Lines starting with John |
| `$`       | Dollar               | End of line              | `John$`       | Lines ending with John   |
| `.`       | Period               | Any single character     | `J.hn`        | John, Jahn, Jxhn         |
| `*`       | Asterisk             | Zero or more of previous | `Jo*hn`       | Jhn, John, Joohn         |
| `[ ]`     | Brackets             | Any one character in set | `[aeiou]`     | Any vowel                |
| `[^ ]`    | Negated brackets     | Any character NOT in set | `[^aeiou]`    | Any non-vowel            |
| `-`       | Hyphen (in brackets) | Range of characters      | `[a-z]`       | Any lowercase letter     |
| `\|`      | Pipe (with -E)       | OR                       | `John\|Sarah` | John or Sarah            |
| `\{x\}`   | Braces               | Exactly x repetitions    | `Jo\{3\}hn`   | Jooohn only              |
| `\{x,y\}` | Braces range         | Between x and y times    | `Jo\{2,4\}hn` | Joohn, Jooohn, Joooohn   |
| `\{x,\}`  | Braces min           | At least x times         | `Jo\{2,\}hn`  | Joohn, Jooohn, ...       |

### Character Ranges in Brackets

```bash
[a-z]       # any lowercase letter
[A-Z]       # any uppercase letter
[0-9]       # any digit
[a-zA-Z]    # any letter
[\s]        # whitespace
[^\s]       # any non-whitespace character
```

### Examples

```bash
grep "^John" file       # lines starting with John
grep "John$" file       # lines ending with John
grep "[Jj]ohn" file     # John or john
grep "J.hn" file        # J + any char + hn
grep "Jo*hn" file       # J + zero or more o's + hn
grep -E "John|Sarah"    # John OR Sarah
grep "^T[^\s]*s" file   # starts with T, no spaces, contains s
grep -n "^w.*[0-9]$" MergedContent.txt  # starts with w, ends with digit (with line numbers)
```

### The `\` Escape Character

The backslash `\` tells the program to treat the next character **literally** rather than as something special:

```bash
\{    # literal { instead of starting a repetition group
\.    # literal . instead of "any character"
\*    # literal * instead of "zero or more"
```

### Extended Regex with `-E`

Basic `grep` has limited regex support. Use `-E` or `egrep` for full regex including `|`:

```bash
grep -E "John|Sarah" file
egrep "John|Sarah" file      # same thing
```

---

## 13. How the Regex State Machine Works

When `grep` receives your pattern, it passes it to a **regex engine** that builds a **state machine** — a flowchart of decisions.

### What Is a State Machine?

A state machine is a series of checkpoints. The engine reads your text **one character at a time** and moves through the checkpoints:

```
Pattern: ^T[^\s]*s

State 0 → State 1 → State 2 → State 3 → MATCH
  ^T       [^\s]     [^\s]*      s
```

### Walking Through an Example

Pattern: `^T[^\s]*s` against the word `Trains`:

```
T - r - a - i - n - s

State 0: start of line, is it T?     yes → move to State 1 ✓
State 1: is r a non-whitespace?      yes → move to State 2 ✓
State 2: is a a non-whitespace?      yes → stay in State 2 ✓  (loop)
State 2: is i a non-whitespace?      yes → stay in State 2 ✓  (loop)
State 2: is n a non-whitespace?      yes → stay in State 2 ✓  (loop)
State 3: is s the letter s?          yes → MATCH! ✓
```

The `*` creates a **loop arrow** — the state machine keeps looping on the same state as long as the condition is met.

### Visualizing the State Machine

```
         ^T          [^\s]        [^\s]*          s
[START] ──→ [SAW T] ──→ [NON-SPACE] ──→ [LOOP] ──→ [MATCH]
                                            ↑________|
                                         (keeps looping on
                                          non-whitespace)
```

### Bracket Expressions Are Single Slots

`[^\s]` is not multiple characters — it is a **description of what one character is allowed to be**. Think of it like a form with blank fields:

```
[ T ] [ _ ] [ _ ] [ _ ] [ s ]
```

Where each `[ _ ]` is filled by one character matching the bracket rule.

---

## 14. Bash Scripting

### Creating and Running a Script

```bash
#!/bin/bash
echo "Hello World"
```

```bash
chmod +x myscript.sh    # give execute permission
./myscript.sh           # run it
```

### Script Arguments

```bash
#!/bin/bash
echo "first argument: $1"
echo "second argument: $2"
echo "all arguments: $@"
echo "number of arguments: $#"
```

```bash
./myscript.sh hello world
# first argument: hello
# second argument: world
# all arguments: hello world
# number of arguments: 2
```

---

## 15. Bash Variables and Parameter Expansion

### Basic Variables

```bash
NAME="seif096"
AGE=20

echo $NAME          # seif096
echo $AGE           # 20
```

Rules:

- **No spaces around `=`** (this is CRITICAL)
- Access with `$`
- No type declaration — everything is a string by default

**Common Error:**

```bash
NAME = "seif096"    # ❌ WRONG - bash thinks NAME is a command
NAME="seif096"      # ✅ CORRECT
```

### User Input

```bash
echo "What is your name?"
read NAME
echo "Hello $NAME"
```

### The Three `$` Syntaxes

| Syntax    | Name                 | Does                           |
| --------- | -------------------- | ------------------------------ |
| `$NAME`   | Variable expansion   | Gets value of variable         |
| `${NAME}` | Parameter expansion  | Gets value + extra operations  |
| `$()`     | Command substitution | Runs command, returns output   |
| `$(())`   | Arithmetic expansion | Evaluates math, returns result |

> All `$` syntaxes share the same core idea: **"evaluate what is inside me and replace me with the result"** before the outer command runs.

### Why Use `${}` Instead of `$`

Removes ambiguity when attaching text to a variable:

```bash
NAME="seif096"
echo $NAME_file       # bash reads NAME_file as one variable → empty!
echo ${NAME}_file     # bash clearly reads NAME + "_file" → seif096_file
```

### Extra Powers of `${}`

```bash
${#NAME}              # length of string
${NAME:0:3}           # substring extraction
${NAME:-"default"}    # use default value if variable is empty
${NAME/seif/user}     # replace "seif" with "user"
${NAME%.txt}          # remove .txt from end
${NAME#*/}            # remove everything up to first /
```

### Command Substitution `$()`

Runs the command inside and replaces itself with the output:

```bash
FILES=$(ls)
DATE=$(date)
echo "Today is $DATE"

# nesting is possible
echo $(echo $(ls))
```

Backticks `` ` ` `` do the same thing but are older and cannot be nested:

```bash
FILES=`ls`    # old way
FILES=$(ls)   # new way (preferred)
```

---

## 16. Arithmetic Expansion

Bash treats everything as strings by default. You need special syntax to do math.

### The Four Ways

```bash
y=1

# Way 1: let
let y=$y+1
echo $y     # 2

# Way 2: double parentheses (recommended)
y=$((y+1))
echo $y     # 2

# Way 3: expr with backticks (old way, spaces required)
y=`expr $y + 1`
echo $y     # 2

# Way 4: without arithmetic → treats as string!
y=$y+1
echo $y     # 1+1  (wrong! this is a string)
```

### Operators Inside `$(( ))`

```bash
echo $((10 + 5))    # 15  addition
echo $((10 - 5))    # 5   subtraction
echo $((10 * 5))    # 50  multiplication
echo $((10 / 5))    # 2   division
echo $((10 % 3))    # 1   remainder (modulo)
echo $((2 ** 3))    # 8   power (2³)
```

> Inside `$(( ))` you do not need `$` before variable names.

**Common Arithmetic Mistakes:**

```bash
# WRONG - using = instead of == for comparison
if (( x = 5 )); then    # ❌ This assigns 5 to x, doesn't compare
    echo "x is 5"
fi

# CORRECT - use == for comparison
if (( x == 5 )); then   # ✅ This compares
    echo "x is 5"
fi
```

---

## 17. String Manipulation

Strings are indexed starting at **0**. Negative indexes count from the end.

```
a  b  c  A  B  C  1  2  3  A  B   C   a   b   c
0  1  2  3  4  5  6  7  8  9  10  11  12  13  14
                                   -4  -3  -2  -1
```

### String Length

```bash
stringZ=abcABC123ABCabc

echo ${#stringZ}            # 15  (using parameter expansion)
echo `expr length $stringZ` # 15  (using expr, old way)
```

### Substring Extraction `${string:position:length}`

```bash
echo ${stringZ:0}       # abcABC123ABCabc  (from 0 to end)
echo ${stringZ:1}       # bcABC123ABCabc   (from 1 to end)
echo ${stringZ:7:3}     # 23A              (3 chars starting at position 7)
echo ${stringZ: -4}     # Cabc             (last 4 characters)
echo ${stringZ: -4:1}   # C                (1 char starting 4 from end)
```

> The space before `-4` is required — otherwise bash confuses it with different syntax.

### Quick Reference

| Syntax            | Meaning                             |
| ----------------- | ----------------------------------- |
| `${#string}`      | Length of string                    |
| `${string:0}`     | Everything from position 0          |
| `${string:7:3}`   | 3 characters starting at position 7 |
| `${string: -4}`   | Last 4 characters                   |
| `${string: -4:1}` | 1 character starting 4 from end     |

### Character-by-Character Processing

**Important Note:** Bash strings are **immutable** - you cannot change a character directly. You must rebuild the string.

```bash
str="hello"
new=""

for ((i=0; i<${#str}; i++)); do
    char="${str:$i:1}"
    # Process char
    new+="$char"  # Build new string
done
```

**This does NOT work:**

```bash
str="hello"
str[0]="H"    # ❌ WRONG - Bash strings are not arrays
```

---

## 18. Arrays

### Defining and Accessing

```bash
farm_hosts=(web03 web04 web05 web06 web07)

echo ${farm_hosts[0]}     # web03  (first element)
echo ${farm_hosts[2]}     # web05  (third element)
echo ${farm_hosts[*]}     # all elements
echo ${farm_hosts[@]}     # all elements (same as *)
echo ${#farm_hosts[@]}    # number of elements
```

> **Why `${}`?** Without curly braces, `$farm_hosts[*]` is read as `$farm_hosts` + `[*]` literally → `web03[*]`. Curly braces tell bash to treat `farm_hosts[*]` as one expression.

### Looping Over an Array

```bash
farm_hosts=(web03 web04 web05 web06 web07)

for i in ${farm_hosts[*]}
do
    echo "item: $i"
done
# item: web03
# item: web04
# item: web05
# item: web06
# item: web07
```

---

## 19. Control Flow

### If / Else

```bash
if [ $T1 = $T2 ]
then
    echo "equal"
else
    echo "not equal"
fi
```

> `fi` is **if spelled backwards** — bash closes blocks by reversing the opening word (`if`/`fi`, `case`/`esac`, `do`/`done`).

### Comparison Operators

**Numbers:**

| Operator | Meaning               |
| -------- | --------------------- |
| `-eq`    | equal                 |
| `-ne`    | not equal             |
| `-gt`    | greater than          |
| `-lt`    | less than             |
| `-ge`    | greater than or equal |
| `-le`    | less than or equal    |

**Strings:**

| Operator | Meaning   |
| -------- | --------- |
| `=`      | equal     |
| `!=`     | not equal |

**Files:**

| Operator | Meaning             |
| -------- | ------------------- |
| `-f`     | file exists         |
| `-d`     | directory exists    |
| `-r`     | file is readable    |
| `-w`     | file is writable    |
| `-x`     | file is executable  |
| `-z`     | string is empty     |
| `-n`     | string is not empty |

### Example with File Check

```bash
#!/bin/bash
echo "Enter a filename:"
read FILENAME

if [ -f $FILENAME ]
then
    echo "File exists, contents:"
    cat $FILENAME
else
    echo "File does not exist"
fi
```

### Exit Codes

Every command returns an exit code:

- `0` = success
- anything else = failure

```bash
grep "John" myfile.txt
echo $?    # 0 if found, 1 if not found

if grep "John" myfile.txt
then
    echo "Found John"
else
    echo "John not found"
fi
```

### `elif` - Else If

```bash
if [[ "$1" == 1 ]]; then
    echo "Option 1"
elif [[ "$1" == 2 ]]; then
    echo "Option 2"
elif [[ "$1" == 3 ]]; then
    echo "Option 3"
else
    echo "Unknown option"
fi
```

**Important:** Only ONE `fi` at the end closes the entire `if/elif/else` block.

---

## 20. Loops

### For Loop

```bash
# iterate over a list
for i in 1 2 3 4 5
do
    echo $i
done

# iterate over a range
for i in {1..5}
do
    echo $i
done

# iterate with step {start..end..step}
for i in {1..5..2}
do
    echo $i     # 1 3 5
done

# iterate over command output
for i in $(ls)
do
    echo "item: $i"
done
```

### For Loop with seq

`seq` generates a number sequence: `seq start step end`

```bash
# seq 1 1 9 → generates 1 2 3 4 5 6 7 8 9
for i in `seq 1 1 9`
do
    echo $i
done

# count down
for i in `seq 10 -1 1`
do
    echo $i
done
```

### For Loop with Break

```bash
len=10
limit=5

for i in `seq 1 1 $((len-1))`
do
    if [ $i -gt $limit ]
    then
        break       # stop the loop immediately
    fi
    echo $i
done
# prints 1 2 3 4 5 then stops
```

### While Loop

Runs **as long as** condition is true.

```bash
COUNTER=0
while [ $COUNTER -lt 10 ]
do
    echo "The counter is $COUNTER"
    let COUNTER+=1
done
```

### Until Loop

Runs **as long as** condition is false — stops when it becomes true. Opposite of while.

```bash
COUNTER=20
until [ $COUNTER -lt 10 ]
do
    echo "COUNTER $COUNTER"
    let COUNTER-=1
done
# counts down from 20, stops when below 10
```

### Loop Comparison

| Loop    | Runs when                  | Use when                                     |
| ------- | -------------------------- | -------------------------------------------- |
| `for`   | Iterating over a known set | You know how many times upfront              |
| `while` | Condition is true          | You don't know how many iterations           |
| `until` | Condition is false         | You want to run until something becomes true |

---

## 21. Functions

### Defining a Function

Two equivalent syntaxes:

```bash
# way 1
function myfunction {
    echo "hello"
}

# way 2
myfunction() {
    echo "hello"
}
```

**❌ WRONG - Don't mix both:**

```bash
function myfunction() {    # ❌ Don't use both 'function' and ()
    echo "test"
}
```

**Important Syntax Rules:**

1. **Space before `{` is REQUIRED:**

```bash
function myFunc{      # ❌ WRONG - missing space
    echo "test"
}

function myFunc {     # ✅ CORRECT
    echo "test"
}
```

2. **Empty functions need a placeholder:**

```bash
function myFunc {}    # ❌ WRONG - empty body

function myFunc {     # ✅ CORRECT - use : as placeholder
    :
}
```

### Calling a Function

```bash
myfunction          # no parentheses when calling (unlike most languages)
myfunction arg1 arg2
```

### Function Arguments

```bash
function greet {
    echo "Hello $1"
    echo "Second arg: $2"
    echo "All args: $@"
    echo "Number of args: $#"
}

greet "seif096" "world"
```

### Return Values

**Using echo + command substitution (to return a value):**

```bash
function add {
    echo $(($1 + $2))
}

result=$(add 3 5)
echo $result    # 8
```

**Using return (exit codes only, 0-255):**

```bash
function check {
    if [ $1 -gt 10 ]
    then
        return 0    # success / true
    else
        return 1    # failure / false
    fi
}

check 15
echo $?    # 0
```

> `return` in bash only returns an **exit code** (0-255), not a value. For actual values, use `echo` and capture with `$()`.

**CRITICAL:** `echo` must come BEFORE `return`. Code after `return` never executes:

```bash
function test {
    return 1
    echo "This never prints"    # ❌ Never reached
}

function test {
    echo "This prints"          # ✅ Executes
    return 1
}
```

### Variable Scope

```bash
# global by default
function myfunction {
    NAME="seif096"    # accessible everywhere
}

# use local to restrict scope
function myfunction {
    local NAME="seif096"    # only inside this function
}

# Multiple local variables
function myfunction {
    local x y z           # ✅ Space-separated
    # NOT: local x,y,z    # ❌ Wrong
}
```

### Full Example — Increment Function

```bash
#!/bin/bash

function increment {
    counter=0
    inc=1

    # if an argument was passed, use it as the increment
    if [ "$#" -ne 0 ]; then
        inc=$1
    fi

    # loop 10 times (counting down with seq)
    for i in `seq 10 -1 1`; do
        echo "The counter is $counter"
        let counter=counter+$inc
    done
}

# call with no argument → increments by 1
increment

# call with argument 5 → increments by 5
increment 5
```

Output with `increment 5`:

```
The counter is 0
The counter is 5
The counter is 10
The counter is 15
The counter is 20
The counter is 25
The counter is 30
The counter is 35
The counter is 40
The counter is 45
```

> The counter **accumulates** — it keeps adding `inc` to itself. It prints **before** adding each time, which is why it starts at 0.

### Function Reference

| Feature          | Syntax                               |
| ---------------- | ------------------------------------ |
| Define           | `function name { }` or `name() { }`  |
| Call             | `name` or `name arg1 arg2`           |
| First argument   | `$1`                                 |
| All arguments    | `$@`                                 |
| Argument count   | `$#`                                 |
| Return exit code | `return 0` or `return 1`             |
| Return value     | `echo value` then capture with `$()` |
| Local variable   | `local NAME="value"`                 |

---

## 22. Common Syntax Errors and Pitfalls

### Critical Spacing Rules

**1. No spaces around `=` in variable assignment:**

```bash
NAME = "value"    # ❌ WRONG - bash thinks NAME is a command
NAME="value"      # ✅ CORRECT
```

**2. Spaces REQUIRED around `[` and `]`:**

```bash
if[ "$x" = "y" ]; then       # ❌ WRONG - no space after if
if ["$x" = "y" ]; then       # ❌ WRONG - no space after [
if [ "$x"="y" ]; then        # ❌ WRONG - no spaces around =
if [ "$x" = "y" ]; then      # ✅ CORRECT
```

**3. Space REQUIRED before `{` in functions:**

```bash
function test{               # ❌ WRONG
    echo "hi"
}

function test {              # ✅ CORRECT
    echo "hi"
}
```

**4. Spaces in `[[` and `]]`:**

```bash
if[[ "$x" == "y" ]]; then    # ❌ WRONG - no space after if
if [["$x" == "y"]]; then     # ❌ WRONG - no space after [[
if [[ "$x"=="y" ]]; then     # ❌ WRONG - no spaces around ==
if [[ "$x" == "y" ]]; then   # ✅ CORRECT
```

### Quoting Variables

**Always quote variables in `[ ]` tests:**

```bash
if [ $NAME = "test" ]; then      # ❌ Dangerous - breaks if NAME is empty
if [ "$NAME" = "test" ]; then    # ✅ CORRECT - safe
```

**In `[[` quoting is optional but recommended:**

```bash
if [[ $NAME == "test" ]]; then   # ✅ Works but not best practice
if [[ "$NAME" == "test" ]]; then # ✅ Better - always quote
```

### Using `$` with Variables

**Inside arithmetic `$(( ))`, `$` is optional:**

```bash
x=5
echo $((x + 1))      # ✅ Works
echo $(($x + 1))     # ✅ Also works
```

**Everywhere else, `$` is required:**

```bash
echo x               # ❌ Prints literal "x"
echo $x              # ✅ Prints value of x
```

### Function Definition Mistakes

```bash
# ❌ WRONG - can't use both 'function' and ()
function test() {
    echo "hi"
}

# ✅ CORRECT - choose one
function test {
    echo "hi"
}

# ✅ ALSO CORRECT
test() {
    echo "hi"
}

# ❌ WRONG - empty function needs placeholder
function test {
}

# ✅ CORRECT - use : as no-op
function test {
    :
}
```

### Arithmetic Comparison Mistakes

**Using `=` instead of `==` in arithmetic:**

```bash
if (( x = 5 )); then         # ❌ WRONG - assigns 5, doesn't compare
    echo "x is 5"
fi

if (( x == 5 )); then        # ✅ CORRECT - compares
    echo "x is 5"
fi
```

**Using `%` for modulo in `[ ]`:**

```bash
if [ ${#str} % 2 = 0 ]; then     # ❌ WRONG - [ ] treats this as string
    echo "even"
fi

if (( ${#str} % 2 == 0 )); then  # ✅ CORRECT - use (( )) for math
    echo "even"
fi
```

### Missing Semicolons

**In one-line if statements:**

```bash
if [ "$x" = "y" ] then echo "yes"; fi     # ❌ WRONG - missing ; before then
if [ "$x" = "y" ]; then echo "yes"; fi    # ✅ CORRECT
```

**In one-line for loops:**

```bash
for i in {1..5} do echo $i; done          # ❌ WRONG - missing ; before do
for i in {1..5}; do echo $i; done         # ✅ CORRECT
```

### File Extension in `${var%pattern}`

**Understanding substring removal:**

```bash
file="document.txt"
echo ${file%.txt}        # document (removes .txt from end)
echo ${file%.doc}        # document.txt (no match, nothing removed)
```

**Using it with variables:**

```bash
half=$((${#parens} / 2))        # ✅ CORRECT
lParen="${parens:0:half}"       # ✅ CORRECT - quote for safety
rParen="${parens:half}"         # ✅ CORRECT
```

---

## 23. The Three Types of Conditionals

### Complete Comparison Chart

| Feature               | `[ ]`                  | `[[ ]]`             | `(( ))`               |
| --------------------- | ---------------------- | ------------------- | --------------------- |
| **Type**              | Test command (POSIX)   | Bash keyword        | Arithmetic evaluation |
| **String comparison** | `=` only               | `==` or `=`         | ❌ Not for strings    |
| **Number comparison** | `-eq`, `-lt`, `-gt`... | `-eq`, `-lt`, `-gt` | `==`, `<`, `>`        |
| **Math operators**    | ❌ No                  | ❌ No               | ✅ Yes (`+`, `*`...)  |
| **Pattern matching**  | ❌ No                  | ✅ Yes (`*`, `?`)   | ❌ No                 |
| **Variable quoting**  | ✅ Required            | Optional (safer)    | Not needed            |
| **Word splitting**    | ✅ Yes (dangerous)     | ❌ No (safe)        | N/A                   |
| **AND / OR**          | `-a` / `-o`            | `&&` / `\|\|`       | `&&` / `\|\|`         |
| **Regex matching**    | ❌ No                  | ✅ Yes (`=~`)       | ❌ No                 |
| **Portable**          | ✅ POSIX (all shells)  | ❌ Bash only        | ❌ Bash only          |
| **When to use**       | Scripts for any shell  | Modern bash scripts | Math comparisons      |

### `[ ]` — Test Command (Old Style)

```bash
# String comparison - use = not ==
if [ "$a" = "$b" ]; then
    echo "equal"
fi

# Numeric comparison - use -eq, -ne, -lt, -gt, -le, -ge
if [ "$num" -eq 5 ]; then
    echo "equals 5"
fi

# File tests
if [ -f "file.txt" ]; then
    echo "file exists"
fi

# String tests
if [ -z "$str" ]; then      # true if string is empty
    echo "empty"
fi

if [ -n "$str" ]; then      # true if string is not empty
    echo "not empty"
fi
```

**CRITICAL RULES for `[ ]`:**

1. **Must have spaces** after `[` and before `]`
2. **Must quote variables** or it breaks with empty strings
3. Use `=` for strings (NOT `==`)
4. Use `-eq`, `-ne`, `-lt`, `-gt` for numbers (NOT `==`, `<`, `>`)

### `[[ ]]` — Advanced Test (Modern, Recommended)

```bash
# String comparison - can use == or =
if [[ "$a" == "$b" ]]; then
    echo "equal"
fi

# Pattern matching
if [[ "$filename" == *.txt ]]; then
    echo "text file"
fi

# Regex matching
if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$ ]]; then
    echo "valid email"
fi

# Logical operators
if [[ "$x" == "yes" && "$y" == "no" ]]; then
    echo "both conditions true"
fi

# Multiple conditions
if [[ "$1" == 1 ]] || [[ "$1" == 2 ]]; then
    echo "1 or 2"
fi
```

**BENEFITS of `[[ ]]`:**

1. Safer - no word splitting
2. Pattern matching works (`*`, `?`)
3. Can use `==` for strings (more intuitive)
4. Better `&&` and `||` support
5. Quoting is optional (but still recommended)

### `(( ))` — Arithmetic Evaluation (Math Only)

```bash
# Direct math comparison - use C-style operators
if (( x == 5 )); then
    echo "x equals 5"
fi

# No $ needed for variables inside
if (( length % 2 == 0 )); then
    echo "even length"
fi

# Complex expressions
if (( (x + y) * 2 > 100 )); then
    echo "result > 100"
fi

# All C operators work
if (( x >= 10 && x <= 20 )); then
    echo "x is between 10 and 20"
fi
```

**OPERATORS in `(( ))`:**

```bash
==    equal
!=    not equal
<     less than
>     greater than
<=    less than or equal
>=    greater than or equal
+     addition
-     subtraction
*     multiplication
/     division
%     modulo
**    exponentiation
&&    logical AND
||    logical OR
```

### When to Use Which

| Situation                       | Use              |
| ------------------------------- | ---------------- |
| Math comparison                 | `(( ))`          |
| String comparison               | `[[ ]]`          |
| Pattern matching                | `[[ ]]`          |
| File existence                  | `[[ ]]` or `[ ]` |
| POSIX portable script           | `[ ]`            |
| Modern bash-only script         | `[[ ]]`          |
| Arithmetic with operators `%+-` | `(( ))`          |

### Common Mistakes

```bash
# ❌ WRONG - math in [ ]
if [ ${#str} % 2 = 0 ]; then         # Treats as string!
    echo "even"
fi

# ✅ CORRECT - use (( )) for math
if (( ${#str} % 2 == 0 )); then
    echo "even"
fi

# ❌ WRONG - assignment instead of comparison in (( ))
if (( x = 5 )); then                 # Assigns 5, doesn't compare!
    echo "x is 5"
fi

# ✅ CORRECT - use ==
if (( x == 5 )); then
    echo "x is 5"
fi

# ❌ WRONG - using == with [ ]
if [ "$x" == "5" ]; then             # Works in bash but not POSIX
    echo "x is 5"
fi

# ✅ CORRECT - use = with [ ]
if [ "$x" = "5" ]; then
    echo "x is 5"
fi
```

---

## 24. Loop Types Deep Dive

### The Three For Loop Styles

#### Style 1: List Iteration (Word-Based)

```bash
# Iterate over words
for item in apple banana cherry; do
    echo "$item"
done

# Iterate over files
for file in *.txt; do
    echo "Found: $file"
done

# Iterate over command output
for user in $(cat /etc/passwd | cut -d: -f1); do
    echo "User: $user"
done
```

**COMMON MISTAKE:**

```bash
for i in flip; do        # ❌ Iterates over word "flip" (1 time)
    echo "$i"
done

# This is NOT looping over characters!
# It literally loops over the word "flip" once
```

#### Style 2: C-Style Arithmetic Loop

**This is the CORRECT way to loop over string characters:**

```bash
str="hello"

# Loop with counter
for ((i=0; i<${#str}; i++)); do
    char="${str:$i:1}"
    echo "$char"
done

# Reverse loop
for ((i=${#str}-1; i>=0; i--)); do
    char="${str:$i:1}"
    echo "$char"
done
```

**Syntax breakdown:**

```bash
for (( initialization; condition; increment )); do
    commands
done
```

**Examples:**

```bash
# Count 0 to 9
for ((i=0; i<10; i++)); do
    echo $i
done

# Count by 2s
for ((i=0; i<=10; i+=2)); do
    echo $i  # 0 2 4 6 8 10
done

# Multiple variables
for ((i=0, j=10; i<10; i++, j--)); do
    echo "i=$i j=$j"
done
```

#### Style 3: Range Expansion

```bash
# Number range
for i in {1..5}; do
    echo $i
done

# With step
for i in {0..10..2}; do
    echo $i  # 0 2 4 6 8 10
done

# Reverse
for i in {10..1}; do
    echo $i
done

# Letters
for letter in {a..z}; do
    echo $letter
done
```

**Important:** Range expansion `{1..5}` happens BEFORE variable substitution:

```bash
n=5
for i in {1..$n}; do    # ❌ WRONG - doesn't expand $n
    echo $i
done

# Use C-style instead:
for ((i=1; i<=n; i++)); do    # ✅ CORRECT
    echo $i
done
```

### Loop Comparison Table

| Loop Type     | When to Use                         | Example                 |
| ------------- | ----------------------------------- | ----------------------- |
| `for in list` | Iterating over words, files, array  | `for word in $words`    |
| `for ((;;))`  | Counter-based, character iteration  | `for ((i=0; i<n; i++))` |
| `for in {}`   | Fixed numeric/letter ranges         | `for i in {1..10}`      |
| `while`       | Condition-based, unknown iterations | `while [ $x -lt 10 ]`   |
| `until`       | Run until condition becomes true    | `until [ $x -ge 10 ]`   |

---

## 25. Command Substitution vs Function Calls

### Understanding `$()`

`$()` is **command substitution** - it runs a command and captures its output:

```bash
current_dir=$(pwd)
file_count=$(ls | wc -l)
today=$(date +%Y-%m-%d)

echo "Today is $today"
```

### When to Use `$()`

**✅ USE `$()` when you need to CAPTURE output:**

```bash
# Capture and store
result=$(command)

# Use output in another command
echo "Result: $(command)"

# Use in conditional
if [[ $(whoami) == "root" ]]; then
    echo "Running as root"
fi
```

**❌ DON'T USE `$()` when you just want to RUN something:**

```bash
# WRONG - captures output but does nothing with it
$(echo "Hello")

# CORRECT - just displays it
echo "Hello"
```

### With Functions

**CRITICAL CONCEPT:** Functions in bash are called **like commands**, NOT with `$()`:

```bash
function greet {
    echo "Hello $1"
}

# ❌ WRONG - unnecessary $()
if [[ condition ]]; then
    $(greet "World")    # Output captured and discarded!
fi

# ✅ CORRECT - just call it
if [[ condition ]]; then
    greet "World"       # Output displays directly
fi

# ✅ CORRECT - capture if you need the value
message=$(greet "World")
echo "Message: $message"
```

### Why the Confusion?

**In many languages:**

```javascript
// JavaScript
result = myFunction(); // Need () to call

// Python
result = my_function(); // Need () to call
```

**In Bash:**

```bash
# Bash - NO PARENTHESES for function calls
result=$(myfunction)      # Call with $() only if capturing output
myfunction                # Call directly to run and display
myfunction arg1 arg2      # Call with arguments
```

### Practical Examples

```bash
function toDecimal {
    printf "%d\n" "$1"
}

# WRONG ways to call:
if [[ "$1" == 1 ]]; then
    $(toDecimal "$2")     # ❌ Captures output, discards it
fi

# CORRECT ways to call:
if [[ "$1" == 1 ]]; then
    toDecimal "$2"        # ✅ Runs and displays output
fi

# OR capture if needed:
result=$(toDecimal "$2")  # ✅ Captures for later use
echo "Result: $result"
```

### Quick Decision Tree

```
Do I need the command's output as a value?
    ├─ YES → Use $()
    │         result=$(command)
    │
    └─ NO → Just run it
              command
              function_name
```

---

## 26. Number System Conversions

### Understanding Number Bases

```bash
# Decimal (base 10): 0-9
26

# Hexadecimal (base 16): 0-9, A-F
1A    # = 1×16 + 10 = 26 in decimal

# Binary (base 2): 0-1
11010 # = 16 + 8 + 2 = 26 in decimal

# Octal (base 8): 0-7
32    # = 3×8 + 2 = 26 in decimal
```

### Hex → Decimal Conversions

```bash
# Method 1: Using arithmetic expansion with 0x prefix
echo $((0x1A))              # 26
echo $((0xFF))              # 255

# Method 2: Using base#number syntax
echo $((16#1A))             # 26
echo $((16#FF))             # 255

# Method 3: Using printf
printf "%d\n" 0x1A          # 26
printf "%d\n" 0xFF          # 255
```

**IMPORTANT:** `0x` tells bash "this is hexadecimal":

```bash
echo $((0x1A))    # ✅ Correctly interprets as hex
echo $((1A))      # ❌ Error - not valid without 0x
```

### Decimal → Hex Conversions

```bash
# Method 1: Using printf (most common)
printf "%X\n" 26            # 1A (uppercase)
printf "%x\n" 26            # 1a (lowercase)
printf "0x%X\n" 26          # 0x1A (with prefix)

# Method 2: Using bc
echo "obase=16; 26" | bc    # 1A
```

**Key Point:** `$(( ))` can INPUT any base but ALWAYS OUTPUTS decimal:

```bash
echo $((0x1A))    # Input: hex, Output: 26 (decimal)
echo $((16#FF))   # Input: hex, Output: 255 (decimal)
echo $((26))      # Input: decimal, Output: 26 (decimal)
```

**To output hex, you MUST use `printf`:**

```bash
printf "%X\n" 26  # Decimal → Hex: 1A
```

### Other Base Conversions

```bash
# Binary → Decimal
echo $((2#1010))            # 10
echo $((0b1010))            # 10 (bash 4.3+)

# Octal → Decimal
echo $((8#77))              # 63
echo $((077))               # 63 (leading 0 means octal)

# Decimal → Binary
echo "obase=2; 26" | bc     # 11010

# Decimal → Octal
printf "%o\n" 26            # 32
echo "obase=8; 26" | bc     # 32
```

### Practical Conversion Functions

```bash
#!/bin/bash

function toDecimal {
    # Accepts hex with or without 0x prefix
    local input="$1"

    # Add 0x if not present
    if [[ ! "$input" =~ ^0x ]]; then
        input="0x$input"
    fi

    printf "%d\n" "$input"
}

function toHex {
    printf "%X\n" "$1"
}

# Usage
toDecimal "1A"      # 26
toDecimal "0x1A"    # 26
toHex 26            # 1A
```

### Common Mistakes

```bash
# ❌ WRONG - trying to convert decimal to hex with $(())
echo $((26))        # Still outputs 26, not 1A

# ✅ CORRECT - use printf
printf "%X\n" 26    # 1A

# ❌ WRONG - missing 0x prefix
echo $((1A))        # Error: invalid number

# ✅ CORRECT - use 0x
echo $((0x1A))      # 26
```

---

## 27. Special Operators Reference

### The `%` Operator

**Usage 1: Modulo (Remainder) - In Arithmetic**

```bash
echo $((10 % 3))    # 1 (remainder of 10 ÷ 3)
echo $((17 % 5))    # 2 (remainder of 17 ÷ 5)

# Check if even
if (( num % 2 == 0 )); then
    echo "even"
fi
```

**Usage 2: Pattern Removal from End - In Parameter Expansion**

```bash
file="document.txt"
echo ${file%.txt}        # document (removes .txt)

path="/home/user/file.txt"
echo ${path%/*}          # /home/user (removes /file.txt)

# % removes shortest match from end
file="hello.world.txt"
echo ${file%.*}          # hello.world (removes .txt)

# %% removes longest match from end
echo ${file%%.*}         # hello (removes .world.txt)
```

### The `#` Operator

**Pattern Removal from Start - In Parameter Expansion**

```bash
path="/home/user/file.txt"
echo ${path#*/}          # home/user/file.txt (removes /)

# # removes shortest match from start
echo ${path#/*/}         # user/file.txt (removes /home/)

# ## removes longest match from start
echo ${path##*/}         # file.txt (removes /home/user/)
```

### The `*` Operator

**Usage 1: Glob Pattern (Wildcard)**

```bash
ls *.txt                 # all .txt files
rm file*                 # all files starting with "file"
```

**Usage 2: Multiplication - In Arithmetic**

```bash
echo $((5 * 3))          # 15
```

**Usage 3: All Array Elements**

```bash
array=(a b c)
echo ${array[*]}         # a b c
```

### The `?` Operator

**Single Character Wildcard**

```bash
ls file?.txt             # file1.txt, fileA.txt, etc.
ls ???.txt               # abc.txt, xyz.txt, etc.
```

### The `@` Operator

**All Array Elements (Preserving Word Boundaries)**

```bash
array=(a b c)
echo ${array[@]}         # a b c

# Difference from * when quoted:
for item in "${array[*]}"; do
    echo "$item"         # Prints once: "a b c"
done

for item in "${array[@]}"; do
    echo "$item"         # Prints 3 times: a, b, c
done
```

### Comparison Table

| Operator | In Arithmetic | In Parameter Expansion | As Glob     |
| -------- | ------------- | ---------------------- | ----------- |
| `%`      | Modulo        | Remove from end        | -           |
| `#`      | -             | Remove from start      | Comment     |
| `*`      | Multiply      | All array elements     | Wildcard    |
| `?`      | -             | -                      | Single char |
| `@`      | -             | All array elements     | -           |

---

## 28. Source vs Execute

### Two Ways to Run a Script

#### Method 1: Execute (Create New Process)

```bash
chmod +x script.sh
./script.sh
```

**What happens:**

1. New bash process is created (fork)
2. Script runs in the new process
3. Variables and functions exist only in that process
4. Process ends, everything disappears
5. Your original shell is unchanged

```
Your Shell (PID 1000)
    │
    └─> Fork: New Shell (PID 1001)
            │
            └─> Runs script
            └─> Sets variables
            └─> Defines functions
            └─> Process ends
    │
    └─> Back to your shell
        Variables/functions gone ❌
```

#### Method 2: Source (Current Process)

```bash
source script.sh
# OR
. script.sh
```

**What happens:**

1. NO new process created
2. Script commands run in YOUR current shell
3. Variables persist after script ends
4. Functions persist after script ends

```
Your Shell (PID 1000)
    │
    └─> Reads script line by line
    └─> Executes each line in current shell
    └─> Variables remain ✅
    └─> Functions remain ✅
```

### Key Differences

| Aspect                | Execute `./script.sh` | Source `source script.sh` |
| --------------------- | --------------------- | ------------------------- |
| **New process**       | ✅ Yes                | ❌ No                     |
| **Needs `chmod +x`**  | ✅ Yes                | ❌ No                     |
| **Variables persist** | ❌ No                 | ✅ Yes                    |
| **Functions persist** | ❌ No                 | ✅ Yes                    |
| **Changes PATH**      | Only in subprocess    | In current shell          |
| **Use case**          | Run programs          | Load config/functions     |

### When to Use Each

**Use Execute (`./script`) when:**

- Running standalone programs
- You don't need variables/functions afterwards
- Script should run in isolation
- Script modifies files (doesn't matter which process)

**Use Source (`source script`) when:**

- Loading configuration (`.bashrc`, `.bash_profile`)
- Defining functions you want to use
- Setting environment variables for current session
- Activating virtual environments (`source venv/bin/activate`)
- Loading utility functions into current shell

### Practical Examples

**Example 1: Configuration File**

```bash
# config.sh
export DATABASE_URL="postgres://localhost/mydb"
export API_KEY="secret123"

alias ll='ls -la'

greet() {
    echo "Hello from config!"
}
```

```bash
# Execute - variables disappear
./config.sh
echo $DATABASE_URL    # Empty! ❌

# Source - variables persist
source config.sh
echo $DATABASE_URL    # postgres://localhost/mydb ✅
greet                 # Hello from config! ✅
ll                    # Works! ✅
```

**Example 2: Function Library**

```bash
# utils.sh
function toUpper {
    echo "$1" | tr 'a-z' 'A-Z'
}

function toLower {
    echo "$1" | tr 'A-Z' 'a-z'
}
```

```bash
# Execute - functions not available
./utils.sh
toUpper "hello"       # Command not found ❌

# Source - functions available
source utils.sh
toUpper "hello"       # HELLO ✅
toLower "WORLD"       # world ✅
```

**Example 3: Python Virtual Environment**

```bash
# This is why you SOURCE, not execute:
source venv/bin/activate    # ✅ Modifies current shell's PATH

# If you executed instead:
./venv/bin/activate         # ❌ PATH modified in subprocess, not your shell
```

### Common Misconceptions

**❌ WRONG:** "Source is like import in Python"

**✅ CORRECT:** Source is like copy-pasting the file's contents into your current terminal and running them line by line.

**❌ WRONG:** "Execute needs `chmod +x`, source doesn't need it"

**✅ CORRECT:** Execute needs execute permission AND read permission. Source only needs read permission.

### The `.` Shorthand

```bash
# These are identical:
source script.sh
. script.sh

# The dot (.) is the POSIX-standard command
# 'source' is a bash-specific alias for '.'
```

### Checking What Sourced Your Current Shell

```bash
# See what's loaded in current session
echo $PATH                  # Environment variables
declare -F                  # All functions
alias                       # All aliases
```

---

## 🔤 Naming History

| Name    | Stands For                      | Story                                                        |
| ------- | ------------------------------- | ------------------------------------------------------------ |
| `grep`  | Global Regular Expression Print | From the old `ed` editor command `g/re/p`                    |
| `cat`   | Concatenate                     | Original purpose was joining files                           |
| `chmod` | Change Mode                     | Changes file permission mode                                 |
| `pwd`   | Print Working Directory         | Prints current location                                      |
| `sudo`  | Super User Do                   | Run commands as root                                         |
| `bin`   | Binaries                        | Pre-compiled executable programs                             |
| `#!`    | Shebang / Hashbang              | Hash + Bang = Shebang (also old slang for "the whole thing") |
| `tr`    | Translate                       | Translates characters                                        |
| `cp`    | Copy                            | Copies files                                                 |
| `mv`    | Move                            | Moves/renames files                                          |
| `rm`    | Remove                          | Removes files                                                |
| `ls`    | List                            | Lists directory contents                                     |

---

## 🎯 Quick Reference Card

```bash
# VARIABLES
NAME="value"              # Define (no spaces around =)
echo $NAME                # Access
echo ${NAME}              # Parameter expansion
result=$(command)         # Command substitution
result=$((5 + 3))         # Arithmetic expansion

# CONDITIONALS
[ "$x" = "y" ]            # Old test (POSIX)
[[ "$x" == "y" ]]         # Modern test (bash)
(( x == 5 ))              # Arithmetic test

# LOOPS
for i in {1..5}           # Range
for ((i=0; i<n; i++))     # C-style
for item in $list         # List iteration
while [ condition ]       # While loop
until [ condition ]       # Until loop

# FUNCTIONS
function name { }         # Define (space before {)
name arg1 arg2            # Call (no parentheses)
echo "result"             # Return value (capture with $())
return 0                  # Return exit code
local var="value"         # Local variable

# STRINGS
${#str}                   # Length
${str:pos:len}            # Substring
${str^^}                  # Uppercase
${str,,}                  # Lowercase
${str/old/new}            # Replace

# MATH
$((x + y))                # Addition
$((x % 2))                # Modulo
(( x == 5 ))              # Comparison

# FILES
cp src dst                # Copy
mv src dst                # Move
rm file                   # Remove
cat file                  # Display
chmod +x file             # Make executable

# REDIRECTION
cmd > file                # Overwrite
cmd >> file               # Append
cmd < file                # Input from file
cmd1 | cmd2               # Pipe

# PERMISSIONS
chmod u+x file            # Add execute for user
chmod a-r file            # Remove read for all
chmod 755 file            # rwxr-xr-x

# CONVERSIONS
echo $((0x1A))            # Hex to decimal
printf "%X" 26            # Decimal to hex

# SOURCE vs EXECUTE
./script.sh               # Execute (new process)
source script.sh          # Source (current process)
. script.sh               # Same as source
```

---

---

## 29. Introduction to C Language

> Notes from Lab 2 — covering IO, data types, compilation, pointers, memory allocation, Makefiles, GDB debugging, and file handling in C.

---

### IO — printf and scanf

**printf format specifiers:**

| Specifier | Prints          |
| --------- | --------------- |
| `%d`      | decimal integer |
| `%c`      | character       |
| `%f`      | float/double    |
| `%s`      | string          |
| `%p`      | pointer address |

**Display width vs precision — common mistake:**

```c
printf("%6s", str);    // minimum WIDTH of 6 — pads with spaces if shorter, does NOT truncate
printf("%.6s", str);   // maximum PRECISION of 6 — truncates if longer
printf("%10.6s", str); // 10 wide, max 6 chars printed
```

> **Key distinction:** `%6s` controls minimum space used. `%.6s` controls maximum characters printed. If you want to print only 6 characters use `%.6s` not `%6s`.

**scanf — reading input:**

```c
scanf("%d", &x);       // & required for non-array types
scanf("%s", str);      // no & needed — arrays are already pointers
```

> **Common mistake:** forgetting `&` with scanf on non-array types will crash the program. `scanf` needs the address to know where in memory to store the value.

> **Another mistake:** putting messages inside scanf format string — scanf ignores text, only reads format specifiers. Always use printf for messages, scanf only for reading.

```c
// WRONG
scanf("enter a number: %d", &x);   // message is ignored, confusing

// CORRECT
printf("enter a number: ");
scanf("%d", &x);
```

**Escape sequences:**

| Sequence | Meaning                                       |
| -------- | --------------------------------------------- |
| `\n`     | newline — moves to next line                  |
| `\r`     | carriage return — moves to start of SAME line |
| `\t`     | horizontal tab                                |
| `\\`     | backslash                                     |
| `\"`     | double quote                                  |

> **`\r` note:** Moves cursor back to beginning of current line without going down. Rarely used alone. Windows uses `\r\n` to end lines while Linux uses just `\n` — this can cause bugs when sharing files between systems.

---

### Data Types

| Type     | Size    | Range                |
| -------- | ------- | -------------------- |
| `char`   | 1 byte  | -128 to 127 (signed) |
| `int`    | 4 bytes | ~±2 billion          |
| `float`  | 4 bytes | 7 digits precision   |
| `double` | 8 bytes | 15 digits precision  |

**bool in C:**

C has no built-in bool. Uses integers instead:

- `0` = false
- any non-zero = true

```c
// old C (C89) — no bool, use int
int isTrue = 1;
int isFalse = 0;

// modern C (C99+) — include header
#include <stdbool.h>
bool isTrue = true;
bool isFalse = false;
```

> **Comparison with C++:** C++ has `bool` built in without any header. C needs `<stdbool.h>`. Under the hood both are still just integers.

---

### Compilation & Execution

```bash
gcc hello.c -o hello      # compile → named executable
gcc hello.c               # compile → default name a.out
./hello                   # run executable
gcc hello.c -o hello && ./hello   # compile and run in one line
```

**Important flags:**

| Flag      | Meaning                                  |
| --------- | ---------------------------------------- |
| `-o name` | name the output file (output)            |
| `-c`      | compile to object file only, do not link |
| `-Wall`   | show all warnings                        |
| `-g`      | include debug info for gdb               |

> **`-o` is like Save As** — without it everything saves as `a.out` and overwrites each other. Always use `-o` to keep files organized.

> **`void main()` vs `int main()`:** The lab slides use `void main()` but this is non-standard. Modern C (C99+) requires `int main()` and `return 0`. gcc follows the standard so `void main()` may cause errors or warnings. Always use `int main()`.

---

### Package Management — apt

**apt** stands for **Advanced Package Tool** — it is the package manager for Ubuntu/Debian Linux. Think of it as the app store for the terminal.

```bash
sudo apt update                    # refresh list of available packages (always run first)
sudo apt install build-essential   # installs gcc, g++, make
sudo apt-get install manpages-dev  # installs man pages for C functions
sudo apt -y install gdb            # installs debugger (-y = yes to all prompts)
gcc --version                      # verify installation
```

> **`apt` vs `apt-get`:** `apt-get` is the older version. They do the same thing. `apt` is preferred now.

> **`sudo` is needed** because installing software affects the whole system, not just your user account — requires admin permissions.

**How apt works with repositories:**

```
Repository (online warehouse of packages)
      ↓
apt update  (refresh what's available)
      ↓
apt install (download and install)
      ↓
Your PC
```

Repository addresses are stored in `/etc/apt/sources.list`. Adding a new repo:

```bash
sudo add-apt-repository ppa:something
```

**What build-essential installs:**

- `gcc` — C compiler
- `g++` — C++ compiler
- `make` — build automation tool

**What manpages-dev gives you:**

```bash
man printf    # full documentation for printf
man scanf     # full documentation for scanf
```

---

### Makefiles

A Makefile automates the compilation process. Instead of typing gcc commands every time, you just type `make`.

**Build process:**

```
Source files (.c) → Compiler (-c flag) → Object files (.o) → Linker → Executable
```

**Basic Makefile format:**

```makefile
target: dependencies
[TAB] command
```

> **Critical:** Indentation MUST be a TAB not spaces — make will throw an error with spaces.

**Simple example:**

```makefile
all:
    gcc main.c -o program
```

**With dependencies (only recompiles changed files):**

```makefile
all: hello

hello: main.o factorial.o hello.o
    gcc main.o factorial.o hello.o -o hello

main.o: main.c
    gcc -c main.c

factorial.o: factorial.c
    gcc -c factorial.c

clean:
    rm -f *.o hello
```

**With variables:**

```makefile
CC=gcc
CFLAGS=-c -Wall
SOURCES=main.c hello.c factorial.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=hello

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
    $(CC) $(OBJECTS) -o $@

.c.o:
    $(CC) $(CFLAGS) $< -o $@

clean:
    rm -f $(OBJECTS) $(EXECUTABLE)
```

**Key Makefile concepts:**

| Concept            | Example            | Meaning                                 |
| ------------------ | ------------------ | --------------------------------------- |
| Variable           | `CC=gcc`           | reusable value                          |
| Use variable       | `$(CC)`            | dereference variable                    |
| Auto variable `$@` | target name        | e.g. `main.o`                           |
| Auto variable `$<` | first dependency   | e.g. `main.c`                           |
| Substitution       | `$(SOURCES:.c=.o)` | replace `.c` with `.o` in all filenames |
| Pattern rule       | `.c.o:`            | how to convert any `.c` to `.o`         |

**`$(SOURCES:.c=.o)` explained:**

```
SOURCES = main.c    hello.c    factorial.c
                ↓          ↓            ↓
OBJECTS = main.o    hello.o    factorial.o
```

Acts like find-and-replace for file extensions. Add a new `.c` file to SOURCES and OBJECTS updates automatically.

**`$<` and `$@` in pattern rule:**

```makefile
.c.o:
    $(CC) $(CFLAGS) $< -o $@
# expands to:
# gcc -c -Wall main.c -o main.o
#              ↑           ↑
#              $<          $@
#         (dependency)  (target)
```

**`.c.o:` is a special suffix rule** — not a regular target. Make recognizes two extensions as a conversion rule meaning "for ANY .c file that needs to become a .o file, use this rule." Modern equivalent:

```makefile
%.o: %.c         # newer syntax, same meaning
    $(CC) $(CFLAGS) $< -o $@
```

**Dependencies are files OR other targets:**

```
make sees a dependency → is it a file that exists?
    YES → use it
    NO  → look for a target rule to create it
```

**make flags:**

| Command                    | Meaning                                       |
| -------------------------- | --------------------------------------------- |
| `make`                     | looks for file named `Makefile` automatically |
| `make -f MyMakefile`       | use specific file (`-f` = file)               |
| `make clean`               | run the clean target                          |
| `make -f Makefile-2 clean` | run clean in specific makefile                |

**Execution order make follows:**

```
1. look at target
2. check dependencies exist
3. if dependency missing → find rule to create it
4. if .c newer than .o → recompile
5. link everything together
```

**clean target:**

```makefile
clean:
    rm -f *.o hello     # ✅ correct — only removes .o files
    rm -rf *o hello     # ⚠️ dangerous — removes ANYTHING ending in letter o
```

> **Wildcard warning:** `*o` means anything ending with the letter `o` (matches `hello`, `video` etc). `*.o` means anything ending with `.o` specifically. Always use `*.o` not `*o`.

> **On Linux vs Windows:** The output of linking is just `hello` with no extension. On Windows it would be `hello.exe`. The `-o` flag names the output file.

---

### Pointers

```c
int x = 420;
int *pointer = &x;   // pointer holds the ADDRESS of x
```

**Memory layout:**

```
x
420
pointer = 0x31
0x31  0x32  0x33  0x34
```

**argv is an array of pointers:**

```c
char* argv[]
// [] → array of
// *  → pointers to
// char → characters (strings)

argv[0] → points to → "hello\0"
argv[1] → points to → "5\0"
argv[2] → points to → "10\0"
```

> **argv contains pointers, not the data itself.** This is why arguments are always strings — argv stores pointers to character arrays, so even the number 5 is stored as the string "5".

**Casting argv — common mistake:**

```c
(int)argv[3]      // casts memory ADDRESS → garbage large number
(int)*argv[3]     // gets first char's ASCII value → '5' becomes 53, not 5
atoi(argv[3])     // correctly parses string "5" → 5  ✅
```

> **Why printf("%s", argv[3]) works but cast doesn't:** `%s` tells printf to follow the pointer and read characters. A cast just reinterprets the raw pointer address as an integer — no string parsing involved.

---

### Memory Allocation

**Three types:**

| Type   | Size known?             | Lifetime                  | Example                  |
| ------ | ----------------------- | ------------------------- | ------------------------ |
| Stack  | yes (compile time)      | during function call only | local variables          |
| Static | yes (compile time)      | entire program            | global, static variables |
| Heap   | no (decided at runtime) | you control it            | `malloc()`               |

**Stack — LIFO (Last In First Out):**

```
main() called       → added to stack
funcA() called      → added on top
funcB() called      → added on top
funcB() ends        → removed
funcA() ends        → removed
main() ends         → removed
```

> **Stack overflow** happens when too many function calls fill the stack — usually from infinite recursion.

**Static keyword:**

```c
void counter(){
    static int count = 0;  // keeps its value between calls
    int x = 0;             // resets every call (stack)
    count++;
    x++;
    printf("count=%d x=%d", count, x);
}
counter();  // count=1 x=1
counter();  // count=2 x=1
counter();  // count=3 x=1
```

**Dynamic allocation functions (all in `<stdlib.h>`):**

```c
void *malloc(size_t bytes);          // allocate memory
void *calloc(size_t n, size_t size); // allocate + initialize to zero
void *realloc(void *ptr, size_t new_size); // resize existing allocation
void free(void *p);                  // release memory
size_t sizeof(type);                 // get byte size of a type
```

**malloc example:**

```c
int *ids = malloc(sizeof(int) * 40);  // space for 40 ints
ids[0] = 5;
free(ids);   // always free!
```

**realloc — resize existing memory:**

```c
// safe pattern — always use a temp pointer
int *temp = realloc(ids, sizeof(int) * 10);
if(temp == NULL){
    free(ids);   // original still safe
} else {
    ids = temp;  // success
}
```

> **realloc behavior:** If enough space exists next to current allocation it extends in place. Otherwise it allocates a new block, copies old data, frees old block — all automatically. Always assign to a temp pointer first in case it fails.

> **Memory leak:** Forgetting `free()` means memory stays occupied even after the program doesn't need it — can slow down or crash the program over time.

**`static` on a function — file scope:**

```c
static char** read_file_lines(...)
```

Means the function is only visible inside the same `.c` file. Used to:

- hide internal helper functions (private vs public API)
- prevent naming conflicts between files
- signal intent — "this is internal plumbing"

> **C vs C++ static:** In C, `static` on a function only means file scope restriction. In C++, `static` on a class member means it belongs to the class not an instance. C++ inherited the C meaning and added its own on top.

---

### String Handling — string.h

```c
#include <string.h>
```

| Function                  | Purpose                                 | Safe version               |
| ------------------------- | --------------------------------------- | -------------------------- |
| `strlen(str)`             | string length (not counting `\0`)       | —                          |
| `strcpy(dest, src)`       | copy string                             | `strncpy(dest, src, size)` |
| `strcat(dest, src)`       | concatenate strings                     | `strncat(dest, src, size)` |
| `strcmp(a, b)`            | compare strings (0=equal)               | `strncmp(a, b, n)`         |
| `strchr(str, ch)`         | find character, returns pointer or NULL | —                          |
| `strstr(str, sub)`        | find substring, returns pointer or NULL | —                          |
| `strdup(str)`             | duplicate string on heap (must free!)   | —                          |
| `memset(ptr, val, size)`  | fill memory with value                  | —                          |
| `memcpy(dest, src, size)` | copy memory block                       | —                          |

> **Always prefer `n` versions:** `strcpy` → `strncpy`, `strcat` → `strncat`. The `n` versions respect buffer size limits and prevent overflow.

**atoi — ASCII to Integer (`<stdlib.h>`):**

```c
atoi("42")      // → 42
atoi("-5")      // → -5
atoi("3.14")    // → 3 (stops at decimal point)
atoi("abc")     // → 0 (can't convert)
atoi("42abc")   // → 42 (stops at first non-numeric)
```

> **Problem with atoi:** Returns 0 for both `"0"` (valid) and `"abc"` (error) — can't tell them apart. Use `strtol` for safer conversion.

**snprintf — safe string formatting:**

```c
char buffer[50];
snprintf(buffer, sizeof(buffer), "Name: %s Age: %d", name, age);
```

> **Never use `sprintf`** — it doesn't check buffer size and causes overflow. Always use `snprintf` which stops at the size limit.

---

### File Handling — stdio.h

**Opening files:**

```c
FILE* file = fopen(filename, mode);
```

| Mode   | File exists    | File missing | Notes        |
| ------ | -------------- | ------------ | ------------ |
| `"r"`  | opens ✅       | NULL ❌      | read only    |
| `"w"`  | overwrites ⚠️  | creates ✅   | write        |
| `"a"`  | adds to end ✅ | creates ✅   | append       |
| `"r+"` | opens ✅       | NULL ❌      | read + write |

> **`"w"` deletes existing content** — if the file exists all its content is wiped. Use `"a"` if you want to keep existing content.

**fgets — reading line by line:**

```c
char line[256];
while(fgets(line, sizeof(line), file)){
    printf("%s", line);
}
```

**How fgets works:**

- reads one line at a time
- stops at `\n`, end of file, or buffer size limit — whichever comes first
- includes the `\n` in the result
- returns NULL at EOF
- each call automatically advances to next line (file pointer moves forward)

**fgets stops at whichever comes first:**

```
\n  (end of line)    → stops, includes \n in buffer
256 (buffer full)    → stops WITHOUT \n — line was too long!
EOF                  → returns NULL
```

**If line is longer than buffer:**

```
first fgets  → reads 255 chars (reserves 1 for \0)
second fgets → reads remaining chars
```

To detect truncation:

```c
if(line[strlen(line)-1] != '\n'){
    // line was longer than buffer!
}
```

> **Use 1024 for safety** — SRT subtitle files usually have short lines but 1024 is a common standard buffer size.

**How fgets remembers position — the FILE pointer:**

The `FILE` struct internally stores a **position indicator** — a byte number saying "I am currently at byte X in the file."

```c
fopen()          // position = 0 (start)
fgets() call 1   // reads bytes 0-5 → position = 6
fgets() call 2   // reads bytes 6-11 → position = 12
fgets() call 3   // reads bytes 12-15 → position = 16 (EOF)
```

**Useful position functions:**

```c
rewind(file);              // reset position to byte 0
ftell(file);               // get current position number
fseek(file, 0, SEEK_SET);  // jump to start (same as rewind)
fseek(file, 0, SEEK_END);  // jump to end
```

**fprintf — writing to files or streams:**

```c
printf("Hello\n");                 // → stdout
fprintf(stdout, "Hello\n");        // → stdout (same)
fprintf(stderr, "Error!\n");       // → stderr
fprintf(file, "Hello\n");          // → file
```

> **`printf` is just `fprintf(stdout, ...)`** — the `f` in fprintf stands for file, as it was originally designed to print to any file/stream.

**Always use stderr for error messages:**

```c
fprintf(stderr, "Error: File does not exist.\n");  // ✅
printf("Error: File does not exist.\n");            // ❌ goes to stdout
```

This way error messages still appear in terminal even when stdout is redirected to a file.

**The f-function family:**

| Function   | `f` stands for | Purpose                                       |
| ---------- | -------------- | --------------------------------------------- |
| `printf`   | —              | print to stdout                               |
| `fprintf`  | file           | print to any stream/file                      |
| `scanf`    | —              | read from stdin                               |
| `fscanf`   | file           | read from any stream/file                     |
| `sprintf`  | string         | print to string buffer (dangerous!)           |
| `snprintf` | string+n       | print to string buffer with size limit (safe) |
| `sscanf`   | string         | read from string buffer                       |

**Common file handling pattern:**

```c
// read from one file, write to another
FILE* input  = fopen(input_filename,  "r");
FILE* output = fopen(output_filename, "w");

if(input == NULL){
    fprintf(stderr, "Error: Input file does not exist.\n");
    return 1;
}
if(output == NULL){
    fprintf(stderr, "Error: Could not create output file.\n");
    fclose(input);   // close input before returning!
    return 1;
}

char line[256];
while(fgets(line, sizeof(line), input)){
    fprintf(output, "%s", line);
}

fclose(input);
fclose(output);
```

> **Always close files before returning** — even in error paths. Not closing causes resource leaks.

---

### GDB Debugging

```bash
gcc -g -o myprogram myprogram.c   # compile with debug info (-g flag required)
gdb ./myprogram                    # start debugger
```

**Most used GDB commands:**

| Command         | Short         | Purpose                            |
| --------------- | ------------- | ---------------------------------- |
| `run`           | `r`           | start program                      |
| `run arg1 arg2` | `r arg1 arg2` | start with arguments               |
| `break 10`      | `b 10`        | breakpoint at line 10              |
| `break main`    | `b main`      | breakpoint at function             |
| `info break`    |               | show all breakpoints               |
| `delete 1`      |               | remove breakpoint 1                |
| `delete`        |               | remove all breakpoints             |
| `next`          | `n`           | next line (skip into functions)    |
| `step`          | `s`           | next line (enter functions)        |
| `finish`        |               | run until current function returns |
| `continue`      | `c`           | continue to next breakpoint        |
| `print x`       | `p x`         | print variable value               |
| `set var x = 5` |               | assign value to variable           |
| `watch x`       |               | stop when x changes                |
| `info watch`    |               | show watched variables             |
| `backtrace`     | `where`       | show call stack                    |
| `frame`         |               | show current function and line     |
| `list`          | `l`           | display source code                |
| `list main`     | `l main`      | show code for specific function    |
| `quit`          | `q`           | exit gdb                           |

> **`next` vs `step`:** `next` skips over function calls, `step` goes inside them.

---

### Common Mistakes in C

```c
// 1. semicolon after function body
int foo(){ }; // ❌ unnecessary (structs need it, functions don't)
int foo(){ }  // ✅

// 2. forgetting & in scanf
scanf("%d", x);   // ❌ crashes
scanf("%d", &x);  // ✅

// 3. message inside scanf
scanf("enter: %d", &x);  // ❌ message ignored, confusing
printf("enter: ");
scanf("%d", &x);          // ✅

// 4. wrong width specifier
printf("%6s", str);   // ❌ if you want truncation
printf("%.6s", str);  // ✅ truncates to 6 chars

// 5. casting argv instead of parsing
(int)argv[1]      // ❌ casts memory address → garbage
atoi(argv[1])     // ✅ parses string to integer

// 6. forgetting rewind after counting lines
while(fgets(...))count++;   // file pointer now at EOF
// must call rewind(file) before reading again!

// 7. not closing file before early return
if(n > count){
    return 1;           // ❌ file never closed!
    fclose(file);
    return 1;           // ✅ close before return
}

// 8. sprintf instead of snprintf
sprintf(buf, "%s", str);              // ❌ dangerous, buffer overflow
snprintf(buf, sizeof(buf), "%s", str); // ✅ safe

// 9. using *o instead of *.o in makefile clean
rm -rf *o hello    // ❌ deletes anything ending in letter o
rm -f *.o hello    // ✅ only deletes .o files

// 10. forgetting free
int* p = malloc(sizeof(int) * 40);
// ... use p ...
// forgot free(p) → memory leak ❌
free(p);  // ✅ always free

// 11. using realloc directly on original pointer
ids = realloc(ids, new_size);   // ❌ if fails, ids becomes NULL, original lost
int* temp = realloc(ids, new_size);  // ✅ safe pattern
if(temp) ids = temp;
```

---

### C vs C++ Quick Comparison

| Feature              | C                         | C++                                  |
| -------------------- | ------------------------- | ------------------------------------ |
| `bool` type          | needs `<stdbool.h>`       | built in                             |
| `malloc` return      | auto converts `void*`     | must cast `(int*)malloc(...)`        |
| `static` on function | file scope only           | file scope OR class member           |
| Standard library     | `<stdio.h>`, `<stdlib.h>` | also `<iostream>`, `std::string` etc |
| Compile with         | `gcc`                     | `g++`                                |
| String type          | `char*` arrays manually   | `std::string`                        |

> **C++ is a superset of C** — all C code is valid C++, but C++ adds classes, templates, STL, and more. Use `g++` to compile C++ source code.

---

### Naming Reference — C Functions

| Name       | Stands For                     |
| ---------- | ------------------------------ |
| `argc`     | Argument Count                 |
| `argv`     | Argument Values (Vector)       |
| `printf`   | Print Formatted                |
| `scanf`    | Scan Formatted                 |
| `fprintf`  | File Print Formatted           |
| `fgets`    | File Get String                |
| `fopen`    | File Open                      |
| `fclose`   | File Close                     |
| `malloc`   | Memory Allocate                |
| `realloc`  | Re-Allocate                    |
| `calloc`   | Clear Allocate (zeroed)        |
| `atoi`     | ASCII To Integer               |
| `snprintf` | String N Print Formatted       |
| `strlen`   | String Length                  |
| `strcpy`   | String Copy                    |
| `strcmp`   | String Compare                 |
| `strcat`   | String Concatenate             |
| `strchr`   | String Character (find)        |
| `strstr`   | String String (find substring) |
| `strdup`   | String Duplicate               |
| `memset`   | Memory Set                     |
| `memcpy`   | Memory Copy                    |
| `rewind`   | Rewind (back to start)         |
| `ftell`    | File Tell (current position)   |
| `fseek`    | File Seek (jump to position)   |
| `apt`      | Advanced Package Tool          |
| `gcc`      | GNU C Compiler                 |
| `gdb`      | GNU Debugger                   |

**END OF GUIDE** 🎓

This comprehensive guide covers everything from the foundational concepts of how Linux works to advanced bash scripting techniques, common pitfalls, and best practices. Keep it as a reference for your computer engineering journey!
