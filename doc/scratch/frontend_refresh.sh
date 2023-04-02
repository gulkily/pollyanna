#!/bin/sh

# runs pages.pl --queue after doing a sanity check on first line

#todo more sanity checks, e.g. does ./pages.pl exist, etc.

PERLPATH=`which perl`
echo $PERLPATH

HASHBANG="#!$PERLPATH -T"
echo $HASHBANG

FILEHEAD=`head -n 1 pages.pl`
echo $FILEHEAD

if [ "$HASHBANG" = "$FILEHEAD" ]; then
    echo "Hashbang test passed!"
else
    echo "Hashbang needs prepending!"
    echo "$HASHBANG" | cat - pages.pl > /tmp/tmpoutasdfadsfad && mv /tmp/tmpoutasdfadsfad pages.pl
    #todo add os type and version
fi

./pages.pl --queue
