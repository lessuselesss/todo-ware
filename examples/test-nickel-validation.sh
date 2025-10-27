#!/usr/bin/env bash
# Test Nickel Runtime Validation
#
# This script demonstrates how Nickel contracts validate scope structure at runtime

set -euo pipefail

echo "🧪 Testing Nickel Runtime Validation"
echo "===================================="
echo ""

# Test 1: Valid scope
echo "Test 1: Valid Scope Structure"
echo "------------------------------"
cat > /tmp/valid-scope-test.ncl <<'EOF'
let contract = import ".contracts/schema/scope-directory-runtime.ncl" in
let state = {
  path = "src/auth",
  has_source_files = true,
  has_claude_md = true,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = true,
    context = true,
  },
  optional_files = {
    contracts_dir = true,
  },
} in
contract.validate_and_format state
EOF

echo "Validation result:"
nickel eval /tmp/valid-scope-test.ncl
echo ""
echo ""

# Test 2: Invalid scope (missing context.md)
echo "Test 2: Invalid Scope (Missing context.md)"
echo "-------------------------------------------"
cat > /tmp/invalid-scope-test.ncl <<'EOF'
let contract = import ".contracts/schema/scope-directory-runtime.ncl" in
let state = {
  path = "src/api",
  has_source_files = true,
  has_claude_md = true,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = true,
    context = false,  # Missing!
  },
} in
contract.validate_and_format state
EOF

echo "Validation result:"
nickel eval /tmp/invalid-scope-test.ncl || true
echo ""
echo ""

# Test 3: Invalid scope (missing CLAUDE.md and .kiro-scope/)
echo "Test 3: Invalid Scope (Missing CLAUDE.md and .kiro-scope/)"
echo "----------------------------------------------------------"
cat > /tmp/broken-scope-test.ncl <<'EOF'
let contract = import ".contracts/schema/scope-directory-runtime.ncl" in
let state = {
  path = "src/database",
  has_source_files = true,
  has_claude_md = false,
  has_kiro_scope_dir = false,
  required_files = {
    scoped_tasks = false,
    assertions = false,
    context = false,
  },
} in
contract.validate_and_format state
EOF

echo "Validation result:"
nickel eval /tmp/broken-scope-test.ncl || true
echo ""
echo ""

# Test 4: Quick validation test
echo "Test 4: Quick Validation (is_valid_scope)"
echo "-------------------------------------------"
cat > /tmp/quick-valid-test.ncl <<'EOF'
let contract = import ".contracts/schema/scope-directory-runtime.ncl" in
let state = {
  path = "src/test",
  has_claude_md = true,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = true,
    context = true,
  },
} in
contract.is_valid_scope state
EOF

echo "Is valid scope? (should be true):"
nickel eval /tmp/quick-valid-test.ncl
echo ""

cat > /tmp/quick-invalid-test.ncl <<'EOF'
let contract = import ".contracts/schema/scope-directory-runtime.ncl" in
let state = {
  path = "src/test",
  has_claude_md = false,
  has_kiro_scope_dir = true,
  required_files = {
    scoped_tasks = true,
    assertions = true,
    context = false,
  },
} in
contract.is_valid_scope state
EOF

echo "Is valid scope? (should be false):"
nickel eval /tmp/quick-invalid-test.ncl
echo ""
echo ""

echo "✅ All tests complete!"
echo ""
echo "To enable Nickel validation in hooks:"
echo "  cp hooks/hooks-nickel.json hooks/hooks.json"
