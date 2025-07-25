#!/bin/bash

set -e

FULL_REPO_NAME=$1
REPO_NAME=$(basename "$FULL_REPO_NAME")

echo "📦 Repo Name: $REPO_NAME"

# PascalCase Main Class
CLASS_BASE=$(echo "$REPO_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
MAIN_CLASS="${CLASS_BASE}Application"
TEST_CLASS="${MAIN_CLASS}Tests"

# Step 1: Find existing main and test class paths
MAIN_FILE=$(find src/main/java -type f -name '*TemplateApplication.java')
TEST_FILE=$(find src/test/java -type f -name '*TemplateApplicationTests.java')

if [[ -z "$MAIN_FILE" ]]; then
  echo "❌ Error: Could not find *TemplateApplication.java"
  exit 1
fi

if [[ -z "$TEST_FILE" ]]; then
  echo "❌ Error: Could not find *TemplateApplicationTests.java"
  exit 1
fi

# Extract package base path (e.g., org/arya/banking/template)
MAIN_OLD_DIR=$(dirname "$MAIN_FILE")
TEST_OLD_DIR=$(dirname "$TEST_FILE")

# Extract package name from path
PACKAGE_SUFFIX=$(echo "$REPO_NAME" | cut -d'-' -f3- | tr '-' '.')
PACKAGE_NAME="org.arya.banking.${PACKAGE_SUFFIX}"
PACKAGE_PATH="org/arya/banking/${PACKAGE_SUFFIX//./\/}"

echo "🔧 New package: $PACKAGE_NAME"
echo "📂 Package path: $PACKAGE_PATH"

# Update pom.xml
echo "📝 Updating pom.xml..."
sed -i "s|<artifactId>.*</artifactId>|<artifactId>${REPO_NAME}</artifactId>|" pom.xml
sed -i "s|<name>.*</name>|<name>${REPO_NAME}</name>|" pom.xml
sed -i "s|<description>.*</description>|<description>${REPO_NAME}</description>|" pom.xml

# Move and rename main files
echo "🚚 Refactoring source files..."
mkdir -p "src/main/java/$PACKAGE_PATH"
mv "$MAIN_FILE" "src/main/java/$PACKAGE_PATH/${MAIN_CLASS}.java"

mkdir -p "src/test/java/$PACKAGE_PATH"
mv "$TEST_FILE" "src/test/java/$PACKAGE_PATH/${TEST_CLASS}.java"

# Remove old empty directories
rm -rf "$MAIN_OLD_DIR"
rm -rf "$TEST_OLD_DIR"

# Update package declarations
sed -i "s|package .*;|package ${PACKAGE_NAME};|" "src/main/java/$PACKAGE_PATH/${MAIN_CLASS}.java"
sed -i "s|package .*;|package ${PACKAGE_NAME};|" "src/test/java/$PACKAGE_PATH/${TEST_CLASS}.java"

# Replace old class name inside files
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "src/main/java/$PACKAGE_PATH/${MAIN_CLASS}.java"
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "src/test/java/$PACKAGE_PATH/${TEST_CLASS}.java"

echo "✅ Initialization complete for $REPO_NAME"
