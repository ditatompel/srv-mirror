#!/usr/bin/env bash
# $HOME/.local/src/dt/srv-mirror/utils.sh

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}"

print_prog_desc()
{
   echo "Simple script to auto commit server configration to GitHub"
   echo
}

print_help()
{
   echo "Syntax: ${0} [-m 'your commit message'|-s|-p|-h]"
   echo "options:"
   echo "-s                     Only [s]ync changes without commit."
   echo "-p                     Merge [p]ull request to main branch."
   echo "-m 'Commit message'    Add your custom commit [m]essage."
   echo "-h                     [P]rint this Help."
   echo
}

COMMIT_MESSAGE="chore(bot): Sync update $(date +'%Y-%m-%d %H:%M:%S')"

mkdir -p "${SCRIPT_DIR}/versions"

sync() {
  # Crontab
  mkdir -p "${SCRIPT_DIR}/cron"
  crontab -l > "${SCRIPT_DIR}/cron/mirror"

  # Scripts
  mkdir -p "${SCRIPT_DIR}/opt/mirror/.local/scripts"
  rsync -avh \
    /opt/mirror/.local/scripts/ \
    "${SCRIPT_DIR}/opt/mirror/.local/scripts" --delete-after
}

# `:` means "takes an argument", not "mandatory argument".
# That is, an option character not followed by `:` means a
# flag-style option (no argument), whereas an option
# character followed by `:` means an option with an argument.
# https://stackoverflow.com/questions/18414054/reading-optarg-for-optional-flags
while getopts ":hspm:" option; do
  case $option in
    h) # display Help
      print_prog_desc
      print_help
      exit;;
    s) # sync
      sync
      exit;;
    p) # pull request
      git pull origin main
      git checkout main
      git merge automation
      git push -u origin main
      git checkout automation
      exit;;
    m) # custom commit message
      COMMIT_MESSAGE="$OPTARG"
      ;;
    \?) # Invalid option
      echo "Invalid option!"
      print_help
      exit;;
  esac
done

sync

cd "${SCRIPT_DIR}"

git checkout automation
git add .
git commit -m "${COMMIT_MESSAGE}" -m "Co-authored-by: Christian Ditaputratama <ditatompel@gmail.com>"
git push -u origin automation # you need to change this if using automation branch

# vim: set ts=2 sw=2 et:
