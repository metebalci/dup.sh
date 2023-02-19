
# dup.sh

**WARNING: This tool uses mv and rm commands, that may modify the file system, move and delete files. Use it with extra caution.**

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/metebalci/dup.sh/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/metebalci/dup.sh/tree/master)

dup.sh is a bash script to find and optionally move or delete duplicate files.

*Warning: dup.sh uses sha1 only, if the hashes of two files are equal, they are considered to be the same. No byte-to-byte comparison is performed.*

Its functionally is similar to [fdupes](https://github.com/adrianlopezroche/fdupes) with some differences:

- dup.sh saves the intermediate processing state. This is the main reason I created this script because when I want to run fdupes over a huge number of files spread across many folders in a network share, it takes a lot of time and if something happens (if I terminate the execution etc.), it has to restart, there is no way to save the intermediate state. Since dup.sh saves the intermediate state, it restarts the process from where it stopped and that is particularly useful while calculating the hashes, the most computationally heavy part of the process.

- dup.sh uses sha1 by default. It uses [sha1sum](https://linux.die.net/man/1/sha1sum) tool and you can easily change this to something else. I think the performance difference between md5 and sha1 is minimal in modern computers so I decided to use sha1.

- dup.sh uses the awesome [GNU Parallel](https://www.gnu.org/software/parallel/) tool to distribute the calculation of hashes to the cores.

- Because dup.sh is a shell script, it has minimal dependencies and it does not need compilation.

- dup.sh can both delete and move duplicate files. It keeps the first file in the dictionary sorted set of duplicate file paths.

- dup.sh always run in recursive mode, it always goes into subdirectories, however it does not follow symbolic links.

# Usage

Run dup.sh to see the usage. Basic commands:

- `dup.sh clean`: cleans intermediate and temporary files
- `dup.sh prepare`: prepare intermediate files, required for move and delete
- `dup.sh move`: move duplicate files (leaving only one copy) to another folder (`.dup.moved_files`) keeping their directory structure. use `testmove` to see move commands instead of executing
- `dup.sh delete`: delete duplicate files (leaving only one copy). use `testdelete` to see rm commands instead of executing.

Below is the output from a test run while running on Linux kernel repo.

![dup.sh screenshot](dupsh.png?raw=true)
