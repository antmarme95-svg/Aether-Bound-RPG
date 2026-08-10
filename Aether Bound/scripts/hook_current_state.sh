#!/usr/bin/env bash
# Hook de PostToolUse (Edit|Write). Si el archivo tocado es Current-State.md,
# corre check_vault.py y devuelve el semáforo de arranque + si el archivo
# quedó sobre su techo blando como contexto adicional del mismo turno — así
# la compresión deja de ser una revisión reactiva al cierre de sesión.
#
# Usa Python para el JSON (no jq: no está instalado en este Git Bash).
# Se asume cwd = raíz del repo (así corre siempre en esta sesión).
export PYTHONIOENCODING=utf-8
file="$(python -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
f = (d.get("tool_input") or {}).get("file_path") or (d.get("tool_response") or {}).get("filePath") or ""
print(f)
')"

case "$file" in
  *Current-State.md)
    out="$(python "Aether Bound/scripts/check_vault.py" 2>&1 | grep -E "ARRANQUE|Current-State\.md" || true)"
    if [ -n "$out" ]; then
      python -c '
import json, sys
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": sys.stdin.read()}}))
' <<< "$out"
    fi
    ;;
esac
exit 0
