#!/bin/bash

set -e

FULL_REPO_NAME=$1
REPO_NAME=$(basename "$FULL_REPO_NAME")

echo "📦 Repo Name: $REPO_NAME"

# PascalCase Class Name from repo
CLASS_BASE=$(echo "$REPO_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
MAIN_CLASS="${CLASS_BASE}Application"
TEST_CLASS="${MAIN_CLASS}Tests"

# Find existing files
MAIN_FILE=$(find src/main/java -type f -name '*Application.java' | head -n 1)
TEST_FILE=$(find src/test/java -type f -name '*ApplicationTests.java' | head -n 1)

if [[ -z "$MAIN_FILE" ]]; then
  echo "❌ Could not find main class"
  exit 1
fi

if [[ -z "$TEST_FILE" ]]; then
  echo "❌ Could not find test class"
  exit 1
fi

OLD_MAIN_CLASS=$(basename "$MAIN_FILE" .java)
OLD_TEST_CLASS=$(basename "$TEST_FILE" .java)

# Directory detection
MAIN_OLD_DIR=$(dirname "$MAIN_FILE")
TEST_OLD_DIR=$(dirname "$TEST_FILE")

# Convert repo name to package
PACKAGE_SUFFIX=$(echo "$REPO_NAME" | cut -d'-' -f3- | tr '-' '.')
PACKAGE_NAME="org.arya.banking.${PACKAGE_SUFFIX}"
PACKAGE_PATH="org/arya/banking/${PACKAGE_SUFFIX//./\/}"

echo "🔧 New package name: $PACKAGE_NAME"
echo "📂 Package path: $PACKAGE_PATH"

# Update pom.xml
echo "📝 Updating pom.xml..."
sed -i "s|<artifactId>.*</artifactId>|<artifactId>${REPO_NAME}</artifactId>|" pom.xml
sed -i "s|<name>.*</name>|<name>${REPO_NAME}</name>|" pom.xml
sed -i "s|<description>.*</description>|<description>${REPO_NAME}</description>|" pom.xml

# Move and rename files to new package
NEW_MAIN_DIR="src/main/java/${PACKAGE_PATH}"
NEW_TEST_DIR="src/test/java/${PACKAGE_PATH}"

mkdir -p "$NEW_MAIN_DIR"
mkdir -p "$NEW_TEST_DIR"

NEW_MAIN_FILE="${NEW_MAIN_DIR}/${MAIN_CLASS}.java"
NEW_TEST_FILE="${NEW_TEST_DIR}/${TEST_CLASS}.java"

mv "$MAIN_FILE" "$NEW_MAIN_FILE"
mv "$TEST_FILE" "$NEW_TEST_FILE"

# Cleanup old dirs
rm -rf "$MAIN_OLD_DIR"
rm -rf "$TEST_OLD_DIR"

# Update package declarations and class names
echo "📝 Updating package and class names..."

sed -i "s|^package .*;|package ${PACKAGE_NAME};|" "$NEW_MAIN_FILE"
sed -i "s|^package .*;|package ${PACKAGE_NAME};|" "$NEW_TEST_FILE"

sed -i "s/${OLD_MAIN_CLASS}/${MAIN_CLASS}/g" "$NEW_MAIN_FILE"
sed -i "s/${OLD_MAIN_CLASS}/${MAIN_CLASS}/g" "$NEW_TEST_FILE"
sed -i "s/${OLD_TEST_CLASS}/${TEST_CLASS}/g" "$NEW_TEST_FILE"

echo "✅ Project initialized successfully for $REPO_NAME"
