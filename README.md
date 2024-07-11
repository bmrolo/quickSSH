# quickSSH
A command line tool that does no more than it needs to.

## What is quickSSH?
A shell script that enables faster SSH into an EC2 instance

## Dependencies
- [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#using-homebrew) - Used to quickly select directories
- [jq](https://github.com/jqlang/jq) - Used to parse JSON output from awscli

## Installation

To install quickSSH, run the following command:

```sh
curl -s https://raw.githubusercontent.com/bmrolo/quickSSH/main/install.sh | bash
```
#### Uninstallation
To uninstall quickSSH, run `sudo rm -rf /usr/local/bin/quickssh`


## Usage
To use quickSSH, type:
```sh
quickssh
```
quickSSH uses the most common directories `/Downloads` and `$HOME` to locate `.pem` files. Use the menu in the command line to naviagate directories, and utilize the directory of your choosing


