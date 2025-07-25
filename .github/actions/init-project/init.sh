#!/bin/bash

set -e

REPO_NAME=$(basename `git rev-parse --show-toplevel`)
PACKAGE_NAME="org.arya.banking.$REPO_NAME"
PACKAGE_PATH=$(echo $PACKAGE_NAME | tr '.' '/')
OLD_PACKAGE_BASE="org.arya.banking"
OLD_PACKAGE_PATH=$(echo $OLD_PACKAGE_BASE | tr '.' '/')

echo "📦 Repo Name: $REPO_NAME"
echo "🔧 New package name: $PACKAGE_NAME"
echo "📂 Package path: $PACKAGE_PATH"

# Find the main class file (only one with @SpringBootApplication)
MAIN_FILE_PATH=$(grep -rl '@SpringBootApplication' src/main/java)
TEST_FILE_PATH=$(find src/test/java -name "*TemplateApplicationTests.java")

# Extract old class name
OLD_CLASS=$(basename "$MAIN_FILE_PATH" .java)
NEW_CLASS="$(tr '[:lower:]' '[:upper:]' <<< ${REPO_NAME:0:1})${REPO_NAME:1}Application"

# Determine test class names
OLD_TEST_CLASS=$(basename "$TEST_FILE_PATH" .java)
NEW_TEST_CLASS="${NEW_CLASS}Tests"

echo "🧠 Old class: $OLD_CLASS, New class: $NEW_CLASS"
echo "📝 Updating pom.xml..."
sed -i "s|<artifactId>.*</artifactId>|<artifactId>$REPO_NAME</artifactId>|g" pom.xml
sed -i "s|<name>.*</name>|<name>$REPO_NAME</name>|g" pom.xml

# Move and rename main class
NEW_MAIN_FILE="src/main/java/$PACKAGE_PATH/$NEW_CLASS.java"
mkdir -p "$(dirname "$NEW_MAIN_FILE")"
mv "$MAIN_FILE_PATH" "$NEW_MAIN_FILE"

# Move and rename test class
NEW_TEST_FILE="src/test/java/$PACKAGE_PATH/$NEW_TEST_CLASS.java"
mkdir -p "$(dirname "$NEW_TEST_FILE")"
mv "$TEST_FILE_PATH" "$NEW_TEST_FILE"

# Old directory paths (for cleanup)
MAIN_OLD_DIR=$(dirname "$MAIN_FILE_PATH" | sed "s|$OLD_PACKAGE_PATH.*||")$OLD_PACKAGE_PATH
TEST_OLD_DIR=$(dirname "$TEST_FILE_PATH" | sed "s|$OLD_PACKAGE_PATH.*||")$OLD_PACKAGE_PATH

echo "🔍 Checking files after move..."
ls -l "$NEW_MAIN_FILE" "$NEW_TEST_FILE"

echo "🧹 Cleaning up old directories..."
# Prevent deleting folders that now contain the new files
if [[ "$MAIN_OLD_DIR" != "$(dirname "$NEW_MAIN_FILE")" && "$MAIN_OLD_DIR" != "$(dirname "$(dirname "$NEW_MAIN_FILE")")" ]]; then
  rm -rf "$MAIN_OLD_DIR"
else
  echo "⚠️ Skipping deletion of $MAIN_OLD_DIR to avoid removing new file"
fi

if [[ "$TEST_OLD_DIR" != "$(dirname "$NEW_TEST_FILE")" && "$TEST_OLD_DIR" != "$(dirname "$(dirname "$NEW_TEST_FILE")")" ]]; then
  rm -rf "$TEST_OLD_DIR"
else
  echo "⚠️ Skipping deletion of $TEST_OLD_DIR to avoid removing new test file"
fi

echo "📂 Final file structure before sed:"
find src -type f

echo "📝 Updating package and class names..."
# Replace package and class names in moved files
sed -i "s|package $OLD_PACKAGE_BASE.*|package $PACKAGE_NAME;|g" "$NEW_MAIN_FILE"
sed -i "s|package $OLD_PACKAGE_BASE.*|package $PACKAGE_NAME;|g" "$NEW_TEST_FILE"
sed -i "s|$OLD_CLASS|$NEW_CLASS|g" "$NEW_MAIN_FILE"
sed -i "s|$OLD_CLASS|$NEW_CLASS|g" "$NEW_TEST_FILE"

echo "✅ Init complete!"
