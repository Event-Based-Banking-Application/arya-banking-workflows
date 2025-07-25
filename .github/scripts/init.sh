#!/bin/bash

# Get repo name and convert to naming formats
REPO_NAME="${REPO_NAME:-arya-banking-user-service}"
PACKAGE_NAME=$(echo "$REPO_NAME" | sed 's/-/./g')
CLASS_BASE=$(echo "$REPO_NAME" | sed -E 's/(^|-)([a-z])/\U\2/g')
MAIN_CLASS="${CLASS_BASE}Application"

echo ">> Replacing with:"
echo "   ArtifactId: $REPO_NAME"
echo "   Package   : org.arya.banking.${PACKAGE_NAME#arya.banking.}"
echo "   Main Class: $MAIN_CLASS"

# Update pom.xml
sed -i "s/<artifactId>.*<\/artifactId>/<artifactId>${REPO_NAME}<\/artifactId>/g" pom.xml
sed -i "s/<name>.*<\/name>/<name>${REPO_NAME}<\/name>/g" pom.xml
sed -i "s/<description>.*<\/description>/<description>${CLASS_BASE}<\/description>/g" pom.xml

# Rename main class
mv src/main/java/org/arya/banking/AryaBankingTemplateApplication.java "src/main/java/org/arya/banking/${MAIN_CLASS}.java"
sed -i "s/class AryaBankingTemplateApplication/class ${MAIN_CLASS}/g" "src/main/java/org/arya/banking/${MAIN_CLASS}.java"
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "src/main/java/org/arya/banking/${MAIN_CLASS}.java"

# Rename test class
mv src/test/java/org/arya/banking/AryaBankingTemplateApplicationTests.java "src/test/java/org/arya/banking/${MAIN_CLASS}Tests.java"
sed -i "s/class AryaBankingTemplateApplicationTests/class ${MAIN_CLASS}Tests/g" "src/test/java/org/arya/banking/${MAIN_CLASS}Tests.java"
sed -i "s/AryaBankingTemplateApplication/${MAIN_CLASS}/g" "src/test/java/org/arya/banking/${MAIN_CLASS}Tests.java"

echo "✅ Initialization complete!"
