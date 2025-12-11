#!/bin/bash

# Usage check
if [ -z "$1" ]; then
    echo "Usage: $0 <level-name>"
    exit 1
fi

LEVEL="$1"
PASS="guest"

# Source
sshpass -p "$PASS" scp -P 2222 \
    "${LEVEL}@pwnable.kr:/home/${LEVEL}/${LEVEL}.c" \
    "./${LEVEL}.c"

# Binary
sshpass -p "$PASS" scp -P 2222 \
    "${LEVEL}@pwnable.kr:/home/${LEVEL}/${LEVEL}" \
    "./${LEVEL}"
