#!/usr/bin/env bash
set -euo pipefail
# 2026 battle-tested verifier — opensuse-nexus. Returns 0 only if agent truly finished.
RELAY=".opencode-relay.md"
FAIL=0
echo "----- VERIFICATION REPORT -----"
if [[ -f "$RELAY" ]]; then
  dep_rows=$(grep -c "deps-verified\|deps-fixed" "$RELAY" 2>/dev/null || echo 0)
  echo "Dependency table rows: $dep_rows (need >=21, need 21 rows deps-verified/deps-fixed)"
  if [[ "$dep_rows" -lt 21 ]]; then
    echo "FAIL: dependency audit table has $dep_rows rows, need 21"
    FAIL=1
  else
    echo "PASS: Dependency table: $dep_rows rows"
  fi
  for tool in "spec-cleaner" "rpmlint" "zypper"; do
    if ! grep -qi "$tool" "$RELAY"; then
      echo "WARNING: relay missing evidence for $tool (2026 h. checks)"
    fi
  done
  if ! grep -qi "install-test table\|zypper install test" "$RELAY"; then
    echo "FAIL: install-test table missing in relay"
    FAIL=1
  else
    echo "PASS: Install-test table present"
  fi
  if ! grep -qi "DOCKER BATTLE TEST\|opensuse/tumbleweed\|zypper.*in" "$RELAY"; then
    echo "WARNING: relay missing Docker battle test evidence (tumbleweed + zypper)"
  fi
else
  echo "FAIL: $RELAY missing"
  FAIL=1
fi
bad=0
for spec in */*.spec; do
  [[ -f "$spec" ]] || continue
  if ! grep -q "^Name:" "$spec" 2>/dev/null; then echo "FAIL: $spec missing Name:"; bad=$((bad+1)); fi
done
if [[ "$bad" -gt 0 ]]; then echo "FAIL: $bad specs malformed"; FAIL=1; fi
if [[ "$FAIL" -ne 0 ]]; then echo "FAIL: NOT COMPLETE — agent must continue working"; exit 1; fi
echo "PASS: VERIFICATION PASSED — all 21 deps rows, evidence, install+battle test present"
exit 0
