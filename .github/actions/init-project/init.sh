#!/bin/bash

set -e

FULL_REPO_NAME=$1
REPO_NAME=$(basename "$FULL_REPO_NAME")

echo "📦 Repo Name: $REPO_NAME"

# PascalCase Class Name
CLASS_BASE=$(echo "$REPO_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
MAIN_CLASS="${CLASS_BASE}Application"
TEST_CLASS="${MAIN_CLASS}Tests"

# Step 1: Detect actual files
MAIN_FILE=$(find src/main/java -type f -name '*Application.java' | head -n 1)
TEST_FILE=$(find src/test/java -type f -name '*ApplicationTests.java' | head -n 1)

if [[ -z "$MAIN_FILE" ]]; then
  echo "❌ Could not find any *Application.java"
  exit 1
fi

if [[ -z "$TEST_FILE" ]]; then
  echo "❌ Could not find any *ApplicationTests.java"
  exit 1
fi

# Extract dirs and old names
MAIN_OLD_DIR=$(dirname "$MAIN_FILE")
TEST_OLD_DIR=$(dirname "$TEST_FILE")
OLD_MAIN_CLASS=$(basename "$MAIN_FILE" .java)
OLD_TEST_CLASS=$(basename "$TEST_FILE" .java)

# Compute new package
PACKAGE_SUFFIX=$(echo "$REPO_NAME" | cut -d'-' -f3- | tr '-' '.')
PACKAGE_NAME="org.arya.banking.${PACKAGE_SUFFIX}"
PACKAGE_PATH="org/arya/banking/${PACKAGE_SUFFIX//./\/}"

echo "🔧 New package: $PACKAGE_NAME"
echo "📂 Package path: $PACKAGE_PATH"

# Step 2: Update pom.xml
sed -i "s|<artifactId>.*</artifactId>|<artifactId>${REPO_NAME}</artifactId>|" pom.xml
sed -i "s|<name>.*</name>|<name>${REPO_NAME}</name>|" pom.xml
sed -i "s|<description>.*</description>|<description>${REPO_NAME}</description>|" pom.xml

# Step 3: Move and rename
mkdir -p "src/main/java/$PACKAGE_PATH"
NEW_MAIN_FILE="src/main/java/$PACKAGE_PATH/${MAIN_CLASS}.java"
mv "$MAIN_FILE" "$NEW_MAIN_FILE"

mkdir -p "src/test/java/$PACKAGE_PATH"
NEW_TEST_FILE="src/test/java/$PACKAGE_PATH/${TEST_CLASS}.java"
mv "$TEST_FILE" "$NEW_TEST_FILE"

# Step 4: Clean old dirs
rm -rf "$MAIN_OLD_DIR"
rm -rf "$TEST_OLD_DIR"

# Step 5: Update package + class references (✅ only new files used here!)
sed -i "s|package .*;|package ${PACKAGE_NAME};|" "$NEW_MAIN_FILE"
sed -i "s|package .*;|package ${PACKAGE_NAME};|" "$NEW_TEST_FILE"

sed -i "s/$OLD_MAIN_CLASS/$MAIN_CLASS/g" "$NEW_MAIN_FILE"
sed -i "s/$OLD_MAIN_CLASS/$MAIN_CLASS/g" "$NEW_TEST_FILE"
sed -i "s/$OLD_TEST_CLASS/$TEST_CLASS/g" "$NEW_TEST_FILE"

echo "✅ Done: Main → $NEW_MAIN_FILE"
echo "✅ Done: Test → $NEW_TEST_FILE"
