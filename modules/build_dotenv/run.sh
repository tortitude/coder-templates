TARGET_DOTENV="${TARGET_DOTENV}"
# Expand home if it's specified!
TARGET_DOTENV="$${TARGET_DOTENV/#\~/$${HOME}}"

%{if ALLOW_OVERWRITE != "true" ~}
# Exit early if the target file already exists
if [ -f "$TARGET_DOTENV" ]; then
    exit 0
fi
%{endif ~}

%{if SOURCE_DOTENV != "" ~}
# Copy from a source file (e.g. .env.example)
SOURCE_DOTENV="${SOURCE_DOTENV}"
SOURCE_DOTENV="$${SOURCE_DOTENV/#\~/$${HOME}}"
cp "$SOURCE_DOTENV" "$TARGET_DOTENV"
%{endif ~}

# Replace env vars or append them if they are not present
%{ for key, value in ENV_VARS ~}
sed -i 's|${key}=.*|${key}=${value}|' "$TARGET_DOTENV"
grep -E '^${key}=' "$TARGET_DOTENV" || printf '%s=%s\n' '${key}' '${value}' >> "$TARGET_DOTENV"
%{ endfor ~}
