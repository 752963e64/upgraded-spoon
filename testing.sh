#!/usr/bin/env sh

[ -f "$1" ] && [ -d "$2" ] || {
    echo "usage: $0 <redbean fullpath> <fullpath to directory>"
    echo "like so: $0 ~/bin/redbean ~/git/upgraded-spoon/shm_sqlite"
    echo "you need an empty redbean, you can remove asset with \"zip -d\"..."
    exit 0
}

cd "$2"
$1 -D .
