#!/bin/bash

set -e

REPO_NAME=$1
PACKAGE_NAME=$2
MAIN_CLASS_NAME=$3

PACKAGE_DIR="src/main/java/$(echo "$PACKAGE_NAME" | tr '.' '/')"
TEST_DIR="src/test/java/$(echo "$PACKAGE_NAME" | tr '.' '/')"

echo "🔧 Initialization Started"
echo "📦 Repository Name    : $REPO_NAME"
echo "📂 Java Package Name  : $PACKAGE_NAME"
echo "🚀 Main Class Name    : ${MAIN_CLASS_NAME}Application"

# --- Step 1: Update pom.xml artifactId ---
echo "📝 Updating artifactId in pom.xml..."
sed -i "s|<artifactId>.*</artifactId>|<artifactId>$REPO_NAME</artifactId>|" pom.xml

# --- Step 2: Delete TemplateApplication files ---
echo "🧹 Removing template application files..."
find src/main/java -name '*TemplateApplication.java' -exec echo "❌ Deleting {}" \; -delete
find src/test/java -name '*TemplateApplicationTests.java' -exec echo "❌ Deleting {}" \; -delete

# --- Step 3: Create required directory structure ---
echo "📁 Creating new package directories..."
mkdir -p "$PACKAGE_DIR"
mkdir -p "$TEST_DIR"

# --- Step 4: Add .gitkeep for tracking empty dirs ---
echo "🔒 Adding .gitkeep to ensure Git tracks directories..."
touch "$PACKAGE_DIR/.gitkeep"
touch "$TEST_DIR/.gitkeep"

# --- Step 5: Generate new main class file ---
echo "🛠️  Creating main application class..."
cat <<EOF > "$PACKAGE_DIR/${MAIN_CLASS_NAME}Application.java"
package $PACKAGE_NAME;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${MAIN_CLASS_NAME}Application {
    public static void main(String[] args) {
        SpringApplication.run(${MAIN_CLASS_NAME}Application.class, args);
    }
}
EOF

# --- Step 6: Generate basic test class ---
echo "🧪 Creating test class..."
cat <<EOF > "$TEST_DIR/${MAIN_CLASS_NAME}ApplicationTests.java"
package $PACKAGE_NAME;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class ${MAIN_CLASS_NAME}ApplicationTests {

    @Test
    void contextLoads() {
    }
}
EOF

echo "✅ Initialization completed successfully!"
