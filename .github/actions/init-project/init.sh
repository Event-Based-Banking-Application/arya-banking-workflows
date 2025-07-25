#!/bin/bash

set -e

REPO_NAME="$1"           # e.g., demo-service
PACKAGE_NAME="$2"        # e.g., org.arya.banking.demo.service
CLASS_NAME="$3"          # e.g., DemoService

OLD_PACKAGE="org.arya.banking"
OLD_PACKAGE_PATH="org/arya/banking"
OLD_CLASS="AryaBankingTemplateApplication"

PACKAGE_PATH="${PACKAGE_NAME//./\/}"

echo "📦 Repo Name: $REPO_NAME"
echo "🔧 New package name: $PACKAGE_NAME"
echo "📂 Package path: $PACKAGE_PATH"
echo "🧠 Old class: $OLD_CLASS → ${CLASS_NAME}Application"

# 1. Update pom.xml
echo "📝 Updating pom.xml..."
sed -i "s|<artifactId>.*</artifactId>|<artifactId>$REPO_NAME</artifactId>|" pom.xml

# 2. Create new package directories
mkdir -p src/main/java/"$PACKAGE_PATH"
mkdir -p src/test/java/"$PACKAGE_PATH"

# 3. Move and rename classes
echo "🔀 Moving and renaming main/test classes..."
mv src/main/java/${OLD_PACKAGE_PATH}/${OLD_CLASS}.java src/main/java/${PACKAGE_PATH}/${CLASS_NAME}Application.java
mv src/test/java/${OLD_PACKAGE_PATH}/${OLD_CLASS}Tests.java src/test/java/${PACKAGE_PATH}/${CLASS_NAME}ApplicationTests.java

# 4. Update package declarations and class names
echo "📝 Updating package declarations and class names..."
sed -i "s|package ${OLD_PACKAGE};|package ${PACKAGE_NAME};|" src/main/java/${PACKAGE_PATH}/${CLASS_NAME}Application.java
sed -i "s|package ${OLD_PACKAGE};|package ${PACKAGE_NAME};|" src/test/java/${PACKAGE_PATH}/${CLASS_NAME}ApplicationTests.java

sed -i "s|${OLD_CLASS}|${CLASS_NAME}Application|g" src/main/java/${PACKAGE_PATH}/${CLASS_NAME}Application.java
sed -i "s|${OLD_CLASS}|${CLASS_NAME}Application|g" src/test/java/${PACKAGE_PATH}/${CLASS_NAME}ApplicationTests.java

# 5. Cleanup old package
echo "🧹 Cleaning up old package..."
rm -rf src/main/java/${OLD_PACKAGE_PATH}
rm -rf src/test/java/${OLD_PACKAGE_PATH}

echo "✅ Initialization complete."
