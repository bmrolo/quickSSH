# quickSSH
- A command line tool that does no more than it needs to
- quickSSH is CLI tool that enables faster SSH into an EC2 instance

<br>

## Installation

To install quickSSH, run the following command:

```sh
curl -s https://raw.githubusercontent.com/bmrolo/quickSSH/main/install.sh | bash
```
#### Uninstallation
To uninstall quickSSH, run `sudo rm -rf /usr/local/bin/quickssh`

<br>

## Dependencies
- [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#using-homebrew) - Used to quickly select directories - `brew install fzf`
- [jq](https://github.com/jqlang/jq) - Used to parse JSON output from awscli - `brew install jq`
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - Used to interact with AWS services. Install instructions are found in documentation 

<br>

## Usage
To use quickSSH, type:
```sh
quickssh
```
quickSSH uses user-defined directories to locate `.pem` files. Use the menu in the command line to naviagate directories, and utilize the directory of your choosing

<br>

## Configuration
To save custom directories that quickSSH can read, edit `~/.quickssh` using the following syntax:
```
alias=path
```
For example:
```
personal=/Users/myuser/personal_keys
work=~/work_keys
```
