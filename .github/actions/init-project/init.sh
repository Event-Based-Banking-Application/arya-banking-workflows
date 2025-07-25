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

# Step 2: Dynamically detect current main and test class locations
SRC_DIR="src/main/java"
TEST_DIR="src/test/java"

MAIN_JAVA=$(find "$SRC_DIR" -name '*TemplateApplication.java' | head -n 1)
TEST_JAVA=$(find "$TEST_DIR" -name '*TemplateApplicationTests.java' | head -n 1)

if [[ ! -f "$MAIN_JAVA" ]]; then
  echo "❌ Error: Could not find a file matching *TemplateApplication.java in $SRC_DIR"
  exit 1
fi

if [[ ! -f "$TEST_JAVA" ]]; then
  echo "❌ Error: Could not find a file matching *TemplateApplicationTests.java in $TEST_DIR"
  exit 1
fi

OLD_PACKAGE_DIR=$(dirname "$MAIN_JAVA")
OLD_TEST_PACKAGE_DIR=$(dirname "$TEST_JAVA")

# Move and rename source files
echo "🚚 Refactoring Java source files..."
mkdir -p "$SRC_DIR/$PACKAGE_PATH"
mkdir -p "$TEST_DIR/$PACKAGE_PATH"

mv "$OLD_PACKAGE_DIR"/*.java "$SRC_DIR/$PACKAGE_PATH/"
mv "$OLD_TEST_PACKAGE_DIR"/*.java "$TEST_DIR/$PACKAGE_PATH/"

rm -rf "$OLD_PACKAGE_DIR"
rm -rf "$OLD_TEST_PACKAGE_DIR"

# Rename class files
mv "$SRC_DIR/$PACKAGE_PATH/"*TemplateApplication.java "$SRC_DIR/$PACKAGE_PATH/${MAIN_CLASS}.java"
mv "$TEST_DIR/$PACKAGE_PATH/"*TemplateApplicationTests.java "$TEST_DIR/$PACKAGE_PATH/${MAIN_CLASS}Tests.java"

# Update package declarations
find "$SRC_DIR/$PACKAGE_PATH" -name "*.java" -exec sed -i "s|package .*;|package ${PACKAGE_NAME};|g" {} \;
find "$TEST_DIR/$PACKAGE_PATH" -name "*.java" -exec sed -i "s|package .*;|package ${PACKAGE_NAME};|g" {} \;

# Update class names inside files
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "$SRC_DIR/$PACKAGE_PATH/${MAIN_CLASS}.java"
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "$TEST_DIR/$PACKAGE_PATH/${MAIN_CLASS}Tests.java"

echo "✅ Initialization complete for $REPO_NAME"
