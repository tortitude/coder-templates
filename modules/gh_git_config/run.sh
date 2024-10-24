#!/usr/bin/env bash

%{ if GH_TOKEN == null ~}
GIT_USER_NAME="${GIT_USER_NAME}"
if [ -n "$GIT_USER_NAME" ]; then
    echo "Configuring git global user name with provided $GIT_USER_NAME..."
    git config --global user.name "$GIT_USER_NAME"
fi

GIT_USER_EMAIL="${GIT_USER_EMAIL}"
if [ -n "$GIT_USER_EMAIL" ]; then
    echo "Configuring git global user name with provided $GIT_USER_EMAIL..."
    git config --global user.email "$GIT_USER_EMAIL"
fi

exit 0
%{ endif ~}

DATA_FILE=$(mktemp)

if [ command -v gh ]; then
    echo "Using GitHub CLI to query user data"
    GH_TOKEN="${GH_TOKEN}" gh api /user -q '{ id: .id, login: .login }' > $DATA_FILE
else
    echo "GitHub CLI command gh not found; trying curl with jq instead"
    API_RESPONSE_FILE=$(mktemp)
    curl -o $API_RESPONSE_FILE -L \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GH_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/user
    jq '{ id: .id, login: .login }' $API_RESPONSE_FILE > $DATA_FILE
    rm $API_RESPONSE_FILE
fi

GITHUB_LOGIN=$(jq --raw-output .login $DATA_FILE)
GITHUB_UID=$(jq --raw-output .id $DATA_FILE)
rm $DATA_FILE
GITHUB_EMAIL_ALIAS="$GITHUB_UID+$GITHUB_LOGIN@users.noreply.github.com"

echo "Configuring git global user name with GitHub login $GITHUB_LOGIN..."
git config --global user.name "$GITHUB_LOGIN"
echo "Configuring git global user email with with anonymized GitHub email $GITHUB_EMAIL_ALIAS..."
git config --global user.email "$GITHUB_EMAIL_ALIAS"
