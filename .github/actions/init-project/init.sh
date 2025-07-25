#!/bin/bash
set -e

echo "🔰 Starting repo initialization script..."

repo_name="$1"
package_name="$2"
main_class_name="$3"

echo "📦 Repo Name: $repo_name"
echo "🔧 New package name: $package_name"
package_path=$(echo "$package_name" | tr '.' '/')
echo "📂 Package path: $package_path"

old_class="AryaBankingTemplateApplication"
new_class="${main_class_name}Application"
main_file="src/main/java/$package_path/$new_class.java"
test_file="src/test/java/$package_path/${new_class}Tests.java"

# Update pom.xml artifactId
echo "📝 Updating pom.xml..."
sed -i "s/<artifactId>.*</<artifactId>${repo_name}</" pom.xml || true

# Move files
src_main_class=$(find src/main/java -name "${old_class}.java")
src_test_class=$(find src/test/java -name "${old_class}Tests.java")

echo "🔍 Checking file to move:"
echo "Main: $src_main_class"
echo "Test: $src_test_class"

mkdir -p "src/main/java/$package_path"
mkdir -p "src/test/java/$package_path"

if [[ -f "$src_main_class" ]]; then
  mv "$src_main_class" "$main_file"
  echo "✅ Moved main class to $main_file"
else
  echo "⚠️ Main class not found"
fi

if [[ -f "$src_test_class" ]]; then
  mv "$src_test_class" "$test_file"
  echo "✅ Moved test class to $test_file"
else
  echo "⚠️ Test class not found"
fi

echo "🧹 Cleaning up old dirs..."
find src/main/java -type d -empty -delete
find src/test/java -type d -empty -delete

echo "📄 Verifying final structure:"
ls -R src/main/java || true
ls -R src/test/java || true

# Update package and class names
echo "📝 Updating package/class in files..."

if [[ -f "$main_file" ]]; then
  sed -i "s/package .*/package $package_name;/" "$main_file"
  sed -i "s/class $old_class/class $new_class/" "$main_file"
else
  echo "❌ Skipping main file update - not found: $main_file"
fi

if [[ -f "$test_file" ]]; then
  sed -i "s/package .*/package $package_name;/" "$test_file"
  sed -i "s/class ${old_class}Tests/class ${new_class}Tests/" "$test_file"
else
  echo "❌ Skipping test file update - not found: $test_file"
fi

echo "🧪 Git status after all changes:"
git status

echo "📄 Git diff preview:"
git diff

# Force file change to ensure commit happens
echo "Template initialized on $(date)" > .template-init.log

# Stage, commit, and push
echo "💾 Committing changes..."
git add .
git commit -m "chore: apply template initialization" || echo "⚠️ Nothing to commit."
git push origin HEAD

echo "✅ Initialization script completed!"
