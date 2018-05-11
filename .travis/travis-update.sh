#!/bin/bash
# This script pushes build information to verigames.github.io.

setup_git() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
}

# For number of files with compilation errors
update_data_file_errors() {
    cd ..
    NUM_FILES=$(cut -d ":" -f 1 < pipejam.log | sort | uniq | wc -l | tr -d '[:space:]')
    DATE=$(git show -s --format=%ci)
    cd verigames.github.io
    echo "$DATE=$NUM_FILES" >> data.txt
}

# For FlowJam cohesion graph
update_cohesion_graph() {
    cd ..
    python3 .travis/relations.py
    mv fj_relations_data.txt verigames.github.io/
    cd verigames.github.io
}

# For amount of files modified
update_data_modified() {
    FILTER="haxe/FlowJam"

    cd ..
    NUM_MODIFIED=$(git whatchanged --format=oneline | grep "^:" | grep $FILTER | cut -d " " -f 5 | cut -f 2 | sort | uniq | wc -l)
    NUM_TOTAL=$(find "$PWD" | grep $FILTER | wc -l)
    PERCENT=$(echo "scale=5; $NUM_MODIFIED/$NUM_TOTAL" | bc)
    DATE=$(git show -s --format=%ci)
    cd verigames.github.io
    echo "$DATE=$PERCENT" >> data.txt
}

commit_website_files() {
    git clone https://github.com/verigames/verigames.github.io.git
    cd verigames.github.io
    REPO=`git config remote.origin.url`
    SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
    setup_git
    
    update_data_file_errors
    git add data.txt
    
    update_cohesion_graph
    git add fj_relations_data.txt

    git commit -m "Travis build: $TRAVIS_BUILD_NUMBER"
    chmod 600 ../.travis/deploy_key
    eval `ssh-agent -s`
    ssh-add ../.travis/deploy_key

    git push -u $SSH_REPO master
}

commit_website_files
