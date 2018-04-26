#!/bin/bash
# This script pushes build information to verigames.github.io.

setup_git() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
}

commit_website_files() {
    ls
    git clone git://github.com/verigames/verigames.github.io.git
    cd verigames.github.io
    REPO=`git config remote.origin.url`
    SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
    setup_git
    ls > index.html
    git add index.html
    git commit -m "Travis build: $TRAVIS_BUILD_NUMBER"

    #ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
    #ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
    #ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
    #ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
    #openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../deploy_key.enc -out ../deploy_key -d
    chmod 600 ../deploy_key
    eval `ssh-agent -s`
    ssh-add ../deploy_key

    git push -u $SSH_REPO master
}

commit_website_files
