#!/bin/bash
# Package the odoo-dev skill

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$SKILL_DIR}"

echo "📦 Packaging odoo-dev skill..."
echo "   Source: $SKILL_DIR"
echo "   Output: $OUTPUT_DIR"
echo ""

# Validate
echo "🔍 Validating skill..."

# Check SKILL.md exists
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    echo "❌ Error: SKILL.md not found!"
    exit 1
fi

# Check frontmatter
if ! grep -q "^---" "$SKILL_DIR/SKILL.md"; then
    echo "❌ Error: SKILL.md missing YAML frontmatter!"
    exit 1
fi

if ! grep -q "^name:" "$SKILL_DIR/SKILL.md"; then
    echo "❌ Error: SKILL.md missing 'name' field!"
    exit 1
fi

if ! grep -q "^description:" "$SKILL_DIR/SKILL.md"; then
    echo "❌ Error: SKILL.md missing 'description' field!"
    exit 1
fi

echo "✅ Validation passed!"
echo ""

# Create package
echo "📦 Creating .skill package..."
cd "$SKILL_DIR"

# Create temp directory for packaging
TEMP_DIR=$(mktemp -d)
SKILL_NAME=$(grep "^name:" SKILL.md | head -1 | sed 's/name: //' | tr -d ' ')

cp -r . "$TEMP_DIR/$SKILL_NAME"
cd "$TEMP_DIR"

# Remove any .git or unnecessary files
rm -rf "$SKILL_NAME/.git" 2>/dev/null || true
rm -rf "$SKILL_NAME/package.sh" 2>/dev/null || true

# Create zip with .skill extension
zip -r "$OUTPUT_DIR/$SKILL_NAME.skill" "$SKILL_NAME" -x "*.pyc" -x "__pycache__/*" -x ".DS_Store"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Skill packaged successfully!"
echo "   Output: $OUTPUT_DIR/$SKILL_NAME.skill"
echo ""
echo "To install:"
echo "   openclaw skills install $OUTPUT_DIR/$SKILL_NAME.skill"
echo ""
