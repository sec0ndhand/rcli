# RCLI

(Our CLI)

A tool to help create simple CLI commands for repetitive tasks.

# Table of Contents
1. [Goal](#goal)
2. [Usage](#usage)
3. [Example Usage](#example-usage)
4. [Contributing](#contributing)
5. [Requirements](#requirements)


## Goal

Create a simple CLI that is based on bash scripts.

## Usage

   1. [Installation](#installation)
   2. [Creating a New Command](#creating-a-new-command)
   3. [Structure](#structure)
   4. [Default Handling](#default-handling)
   5. [Help Text](#help-text)
   6. [Version](#version)

### Installation
To create your own cli named `mycli` run:

```bash
curl -fsSL https://raw.githubusercontent.com/sec0ndhand/rcli/main/install.sh | bash -s -- mycli
```
This will create a folder named mycli, and clone the repo into it.  It will also create a symlink in your `/usr/local/bin` so you can run `mycli` command from anywhere.  If you don't provide a name, it will default to `rcli`.


### Creating a new Command

This comes with a utility to help you create new commands.  It will create the folder structure and files for you.

```bash
cli create-command my_resource my_action
```

Will create a new resource folder in the `resources` folder named `my_resource` and a file named `my_action` where you can add your code.  It will also create a default command that will run if no action is specified.


### Structure

Each command is structured like this in the terminal

```bash
cli [RESOURCE] [ACTION] [--option1] [--option2] [...]
```

This will call the bash file held here:

`/resources/[RESOURCE]/[ACTION]`

The options set the environment variables that are used in the `ACTION` file.  So if you have an option called
`--NAME=joe_strummer` then you can use `$NAME` in your `ACTION` file and it will equal `joe_strummer`.  If nothing is
set it will be `true`.

Usage from the Terminal with or without the `=` sign:

--NAME=ian_mackaye

--NAME ian_mackaye

Are both acceptable.  And will pass the environment variable $NAME=ian_mackaye to the `ACTION` file.  So
in the `ACTION` file you can use `$NAME` and it will equal `ian_mackaye` like this:

```bash
echo $NAME
```

### Default Handling

When a user runs the command:

```bash
cli RESOURCE
```

It will automatically run the help for that resource only.  If you want to override that behavior, you can add a
`default` file to the `RESOURCE` folder, and the command in that file will be used instead.  The file would be found
here:

`/resources/[RESOURCE]/default`

This is created as part of the `create-command`` utility.

### Help Text
The help text can be specified at the top of your `ACTION` file with a comment like this:

```bash
# HELP=This command deletes the entire file system
```

This will be used when the user wants to know what your command does, and runs

```bash
cli help --all
```

### Version

The `VERSION` file at at the root of the project holds the version that is displayed when running `rcli version`.

The version should be bumped every time a change is made, or bundled with like changes while working in a branch like
`all/version-1-0-0` which would equate to version 1.0.0

### Example Usage

I used this to create a CLI for a company that I worked at had a small team that needed to document how we deployed, and
used different pieces of infrastructure.  There were a lot of commands and tools that were needed, but I wanted a
centralized place that the engineers could go to to find all the tooling that they needed to connect to servers
databases and other things.  I showed it to a friend, a great engineer and he made some changes, and then I decided to
open source it.

Here is an example of what our CLI looked like:

<!-- show the /imgs/example.gif below  -->
![example](/imgs/example.gif)

The commands above represent some common problems our engineers had to solve.

## Contributing

First fork the repository, then clone it to your local machine.

Make the changes.

Make sure the tests still pass, or add to the tests to cover your changes.

Submit a PR and HOPE that I am still maintaining this project, or I will probably give you maintainer rights 😬.

## Requirements

Right now you need to have a mac with git installed.  Most people use the xcode commandline tools, and that is the
recommended way to install git.

Windows Subsystem for Linux is not supported, but if you can get it to work, please submit a PR.


