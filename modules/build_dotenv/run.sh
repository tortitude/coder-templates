#!/usr/bin/env bash

%{ for waiter in WAIT_FOR ~}
WAIT_PATH="${waiter.path}"
WAIT_PATH="$${WAIT_PATH/#\~/$${HOME}}"
WAIT_INTERVAL="${waiter.interval}"
WAIT_STARTED_AT=$(date '+%s')

echo "Waiting for $WAIT_PATH to exist..."
while [ ! -e "$WAIT_PATH" ]; do
%{ if coalesce(waiter.timeout, 0) > 0 ~}
    WAIT_TIMEOUT="${waiter.timeout}"
    WAIT_INTERVAL="${max(coalesce(try(parseint(waiter.interval), 1), 1), 1)}"
    WAIT_ELAPSED=$(($(date '+%s') - $WAIT_STARTED_AT))
    if [ $WAIT_ELAPSED -gt $WAIT_TIMEOUT ]; then
        echo "FAIL: Path $WAIT_PATH not found after $WAIT_TIMEOUT seconds" > /dev/stderr
        exit 1
    fi
%{ endif ~}
    sleep $WAIT_INTERVAL
done

%{ endfor ~}

TARGET_DOTENV="${TARGET_DOTENV}"
TARGET_DOTENV="$${TARGET_DOTENV/#\~/$${HOME}}"

%{ if ALLOW_OVERWRITE != "true" ~}
# Exit early if the target file already exists
if [ -f "$TARGET_DOTENV" ]; then
    exit 0
fi
%{ endif ~}

%{ if SOURCE_DOTENV != "" ~}
# Copy from a source file (e.g. .env.example)
SOURCE_DOTENV="${SOURCE_DOTENV}"
SOURCE_DOTENV="$${SOURCE_DOTENV/#\~/$${HOME}}"
echo "Copying $SOURCE_DOTENV to $TARGET_DOTENV..."
cp "$SOURCE_DOTENV" "$TARGET_DOTENV"
%{ endif ~}

# Replace env vars or append them if they are not present
echo "Building dotenv file $TARGET_DOTENV..."
%{ for key, value in ENV_VARS ~}
sed -i 's|${key}=.*|${key}=${value}|' "$TARGET_DOTENV"
grep -E '^${key}=' "$TARGET_DOTENV" > /dev/null || printf '%s=%s\n' '${key}' '${value}' >> "$TARGET_DOTENV"
%{ endfor ~}

echo "Built dotenv file $TARGET_DOTENV"
