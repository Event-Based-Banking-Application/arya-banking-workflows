#!/bin/bash

set -e

FULL_REPO_NAME=$1
REPO_NAME=$(basename "$FULL_REPO_NAME")

echo "📦 Repo Name: $REPO_NAME"

# PascalCase class names
CLASS_BASE=$(echo "$REPO_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
MAIN_CLASS="${CLASS_BASE}Application"
TEST_CLASS="${MAIN_CLASS}Tests"

# Step 1: Locate the original files
MAIN_FILE=$(find src/main/java -type f -name '*TemplateApplication.java')
TEST_FILE=$(find src/test/java -type f -name '*TemplateApplicationTests.java')

if [[ -z "$MAIN_FILE" || -z "$TEST_FILE" ]]; then
  echo "❌ Template application files not found."
  exit 1
fi

OLD_CLASS_NAME=$(basename "$MAIN_FILE" .java)
OLD_TEST_CLASS_NAME=$(basename "$TEST_FILE" .java)
MAIN_OLD_DIR=$(dirname "$MAIN_FILE")
TEST_OLD_DIR=$(dirname "$TEST_FILE")

PACKAGE_SUFFIX=$(echo "$REPO_NAME" | cut -d'-' -f3- | tr '-' '.')
PACKAGE_NAME="org.arya.banking.${PACKAGE_SUFFIX}"
PACKAGE_PATH="org/arya/banking/${PACKAGE_SUFFIX//./\/}"

echo "🔧 New package name: $PACKAGE_NAME"
echo "📂 Package path: $PACKAGE_PATH"
echo "🧠 Old class: $OLD_CLASS_NAME, New class: $MAIN_CLASS"

# Update POM
echo "📝 Updating pom.xml..."
sed -i "s|<artifactId>.*</artifactId>|<artifactId>${REPO_NAME}</artifactId>|" pom.xml
sed -i "s|<name>.*</name>|<name>${REPO_NAME}</name>|" pom.xml
sed -i "s|<description>.*</description>|<description>${REPO_NAME}</description>|" pom.xml

# Create new directories
mkdir -p "src/main/java/$PACKAGE_PATH"
mkdir -p "src/test/java/$PACKAGE_PATH"

# Move files
NEW_MAIN_FILE="src/main/java/$PACKAGE_PATH/${MAIN_CLASS}.java"
NEW_TEST_FILE="src/test/java/$PACKAGE_PATH/${TEST_CLASS}.java"

echo "🔀 Moving $MAIN_FILE → $NEW_MAIN_FILE"
mv "$MAIN_FILE" "$NEW_MAIN_FILE"

echo "🔀 Moving $TEST_FILE → $NEW_TEST_FILE"
mv "$TEST_FILE" "$NEW_TEST_FILE"

# Confirm they exist
echo "🔍 Checking files after move..."
if [[ ! -f "$NEW_MAIN_FILE" ]]; then
  echo "❌ ERROR: Main file not found at $NEW_MAIN_FILE"
  ls -R src/main/java || true
  exit 2
fi

if [[ ! -f "$NEW_TEST_FILE" ]]; then
  echo "❌ ERROR: Test file not found at $NEW_TEST_FILE"
  ls -R src/test/java || true
  exit 2
fi

# Clean old dirs
echo "🧹 Cleaning up old directories..."
rm -rf "$MAIN_OLD_DIR"
rm -rf "$TEST_OLD_DIR"

# Update packages and class names
echo "📝 Updating package and class names..."
echo "📄 Main file: $NEW_MAIN_FILE"
echo "📄 Test file: $NEW_TEST_FILE"

# Package declaration
sed -i "s|package .*;|package ${PACKAGE_NAME};|" "$NEW_MAIN_FILE"
sed -i "s|package .*;|package ${PACKAGE_NAME};|" "$NEW_TEST_FILE"

# Class name replacements
sed -i "s/$OLD_CLASS_NAME/$MAIN_CLASS/g" "$NEW_MAIN_FILE"
sed -i "s/$OLD_CLASS_NAME/$MAIN_CLASS/g" "$NEW_TEST_FILE"
sed -i "s/$OLD_TEST_CLASS_NAME/$TEST_CLASS/g" "$NEW_TEST_FILE"

echo "✅ Initialization complete for $REPO_NAME"
