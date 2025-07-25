#!/bin/bash

set -e

FULL_REPO_NAME=$1
REPO_NAME=$(basename "$FULL_REPO_NAME")

echo "📦 Repo Name: $REPO_NAME"

# PascalCase Main Class
CLASS_BASE=$(echo "$REPO_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
MAIN_CLASS="${CLASS_BASE}Application"
PACKAGE_SUFFIX=$(echo "$REPO_NAME" | cut -d'-' -f3- | tr '-' '.')

PACKAGE_NAME="org.arya.banking.${PACKAGE_SUFFIX}"
PACKAGE_PATH="org/arya/banking/${PACKAGE_SUFFIX//./\/}"

echo "🔧 New package: $PACKAGE_NAME"
echo "📂 Package path: $PACKAGE_PATH"

# Step 1: Update pom.xml
echo "📝 Updating pom.xml..."
sed -i "s|<artifactId>.*</artifactId>|<artifactId>${REPO_NAME}</artifactId>|" pom.xml
sed -i "s|<name>.*</name>|<name>${REPO_NAME}</name>|" pom.xml
sed -i "s|<description>.*</description>|<description>${REPO_NAME}</description>|" pom.xml

# Step 2: Rename Java main class and package
echo "🚚 Refactoring Java source files..."

SRC_DIR="src/main/java"
TEST_DIR="src/test/java"

OLD_PACKAGE_PATH=$(find "$SRC_DIR" -type f -name "*TemplateApplication.java" | head -n 1 | sed -E "s|/$MAIN_CLASS\.java||;s|/[^/]+$||")

OLD_PACKAGE_DIR=$(dirname "$(find "$SRC_DIR" -name '*TemplateApplication.java')")
OLD_TEST_PACKAGE_DIR=$(dirname "$(find "$TEST_DIR" -name '*TemplateApplicationTests.java')")

# Move main source files
mkdir -p "$SRC_DIR/$PACKAGE_PATH"
find "$OLD_PACKAGE_DIR" -name "*.java" -exec mv {} "$SRC_DIR/$PACKAGE_PATH" \;

# Move test files
mkdir -p "$TEST_DIR/$PACKAGE_PATH"
find "$OLD_TEST_PACKAGE_DIR" -name "*.java" -exec mv {} "$TEST_DIR/$PACKAGE_PATH" \;

# Cleanup old dirs
rm -rf "$OLD_PACKAGE_DIR"
rm -rf "$OLD_TEST_PACKAGE_DIR"

# Rename main class
mv "$SRC_DIR/$PACKAGE_PATH/"*TemplateApplication.java "$SRC_DIR/$PACKAGE_PATH/${MAIN_CLASS}.java"
mv "$TEST_DIR/$PACKAGE_PATH/"*TemplateApplicationTests.java "$TEST_DIR/$PACKAGE_PATH/${MAIN_CLASS}Tests.java"

# Update package declarations
find "$SRC_DIR/$PACKAGE_PATH" -name "*.java" -exec sed -i "s|package .*;|package ${PACKAGE_NAME};|g" {} \;
find "$TEST_DIR/$PACKAGE_PATH" -name "*.java" -exec sed -i "s|package .*;|package ${PACKAGE_NAME};|g" {} \;

# Update class names inside files
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "$SRC_DIR/$PACKAGE_PATH/${MAIN_CLASS}.java"
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "$TEST_DIR/$PACKAGE_PATH/${MAIN_CLASS}Tests.java"

echo "✅ Initialization complete for $REPO_NAME"
