
# dup.sh

**WARNING: This tool uses mv and rm commands, that may modify the file system, move and delete files. Use it with extra caution.**

[![Test Status](https://travis-ci.com/metebalci/dup.sh.svg?branch=master)](https://travis-ci.com/metebalci/dup.sh)

dup.sh is a bash script to find and optionally move or delete duplicate files.

Its functionally is similar to [fdupes](https://github.com/adrianlopezroche/fdupes) with some differences:

- dup.sh saves the intermediate processing state. This is the main reason I created this script because when I want to run fdupes over a huge number of files spread across many folders in a network share, it takes a lot of time and if something happens (if I terminate the execution etc.), it has to restart, there is no way to save the intermediate state. Since dup.sh saves the intermediate state, it restarts the process from where it stopped and that is particularly useful while calculating the hashes, the most computationally heavy part of the process.

- dup.sh uses sha1 by default. It uses [shasum](https://linux.die.net/man/1/shasum) tool and you can easily change this to something else. I think the performance difference between md5 and sha1 is minimal in modern computers so I decided to use sha1.

- dup.sh uses the awesome [GNU Parallel](https://www.gnu.org/software/parallel/) tool to distribute the calculation of hashes to the cores.

- Because dup.sh is a shell script, it has minimal dependencies and it does not need compilation.

- dup.sh can both delete and move duplicate files.

- dup.sh always run in recursive mode, it always goes into subdirectories, however it does not follow symbolic links.

# Compatibility

I am using the script in macOS. Since it is a shell script, it should run on Linux and probably in Windows Subsystem for Linux, maybe with a slight modification.

# Usage

Run dup.sh to see the usage. Basic commands:

- dups.sh clean: cleans intermediate and temporary files
- dups.sh prepare: prepare intermediate files, required for move and delete
- dups.sh move: move duplicate files (leaving only one copy) to another folder keeping their directory structure, use testmove to see move commands instead of executing
- dups.sh delete: delete duplicate files (leaving only one copy), use testdelete to see rm commands instead of executing

Below is the output from a test run while running on Linux kernel repo.

![dup.sh screenshot](dupsh.png?raw=true)

# Performance

I cloned [Linux kernel repo at Github](https://github.com/github/linux). Then I run `fdupes -mr .` and `dup.sh prepare` on a Mac Mini 2018 with Intel i7 six-core CPU. gtime is GNU time.

fdupes:

```
$ gtime fdupes -mr .
412 duplicate files (in 240 sets), occupying 1.7 megabytes

0:11.68 real
1.66 user
9.94 sys
0 amem
11868 mmem
```

dup.sh:

```
$ gtime dup.sh prepare
finding duplicate_files
creating file_list
.number of files: 62893
calculating file_hashes
.calculating hashes of all files
100% 62893:0=0s ./virt/lib/irqbypass.c                                                         
finding duplicate_hashes
8:55.90 real
1381.11 user
906.31 sys
0 amem
50908 mmem
```

As you see in this example dup.sh is very slow. So the point of using it should not be performance but other factors as summarized in the description.

# License

Copyright (C) 2020 Mete Balci

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
