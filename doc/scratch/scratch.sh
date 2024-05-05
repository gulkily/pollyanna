# Check if script is being sourced
if [ "$0" != "$BASH_SOURCE" ]; then
  echo "Script is being sourced"
else
  echo "Script is being executed"
fi




####################################################################################################
# This script is designed to be run from the root of the project directory.
# It will create an alias for the "hike" command which will change to the project directory
# and run the script from there. This is useful for running the script from anywhere on the system.
# The alias is written to the script itself, so it will be available the next time the script is run.
# It should also add this command to the .bashrc file so that it is available every time a new terminal is opened.
# Get the current directory
current_dir=$(pwd)

# Check if HOME variable is set
if [ -n "$HOME" ]; then
  # Replace home directory path with ~ if current directory is under home
  current_dir="${current_dir/#$HOME/\~}"
else
  echo "HOME variable is not defined. Please make sure it is set."
  exit 1
fi

# Remove any line which begins with "alias"
sed -i.bak '/^alias/ d' hike.sh

# Write the new alias line to the script
echo "alias hike='cd \"$current_dir\" ; bash \"\$PWD/hike.sh\"'" >> hike.sh

## Also add to the .bashrc file and .profile file if not already there
#if ! grep -q "alias hike='cd \"$current_dir\" ; bash \"\$PWD/hike.sh\"'" ~/.bashrc; then
#  echo "alias hike='cd \"$current_dir\" ; bash \"\$PWD/hike.sh\"'" >> ~/.bashrc
#fi
#if ! grep -q "alias hike='cd \"$current_dir\" ; bash \"\$PWD/hike.sh\"'" ~/.profile; then
#  echo "alias hike='cd \"$current_dir\" ; bash \"\$PWD/hike.sh\"'" >> ~/.profile
#fi

####################################################################################################



#if [ $1 = sql ]
#	then
#		#sqlite3 cache/b/index.sqlite3 "${@:2}"
#		#sqlite3 cache/b/index.sqlite3 "${*:2}"
#		exit
#fi

# sanity checks for git and cut
# check that git command exists
# check that cut command exists
# check that git rev-parse HEAD returns a string

    #Matthew 5:37
    #Let what you say be simply ‘Yes’ or ‘No’; anything more than this comes from evil.

    #echo Rejoice always
    #echo Pray without ceasing
    #echo Give thanks in all circumstances

