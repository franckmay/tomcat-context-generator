#!/usr/bin/env bash
set -euo pipefail

progname=$(basename "$0")

usage() {
  cat <<EOF
Usage: $progname --app APP_NAME [--input INPUT_FILE] [--output-dir OUTPUT_DIR] [--profile PROFILE]

  -a, --app         Nom de l'application (ex: monapp) – génère monapp.xml
  -i, --input       Chemin vers application.properties (défaut : ./application.properties)
  -o, --output-dir  Répertoire de sortie (défaut : répertoire courant)
  -p, --profile     Suffixe de profil (ex: prod). Défaut : prod
  -h, --help        Cette aide
EOF
  exit 1
}

# Valeurs par défaut
PROFILE="prod"
INPUT_FILE="./application.properties"
OUTPUT_DIR="."

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--app)        APP_NAME="$2"; shift 2;;
    -i|--input)      INPUT_FILE="$2"; shift 2;;
    -o|--output-dir) OUTPUT_DIR="$2"; shift 2;;
    -p|--profile)    PROFILE="$2"; shift 2;;
    -h|--help)       usage;;
    *) echo "[WARN] Option inconnue : $1"; usage;;
  esac
done

# Vérifications
if [[ -z "${APP_NAME:-}" ]]; then
  echo "[ERROR] Le paramètre --app est obligatoire." >&2
  usage
fi
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "[ERROR] Fichier source introuvable : $INPUT_FILE" >&2
  exit 2
fi

mkdir -p "$OUTPUT_DIR"

XML_FILE="$OUTPUT_DIR/${APP_NAME}.xml"
PROPS_FILE="$OUTPUT_DIR/application-${PROFILE}.properties"

echo "[INFO] Génération de $XML_FILE et $PROPS_FILE…"

# En-tête XML
echo "<Context>" > "$XML_FILE"

prop_count=0
while IFS='=' read -r raw_key raw_value; do
  [[ -z "$raw_key" || "${raw_key:0:1}" == "#" ]] && continue
  key=$(echo "$raw_key" | xargs)
  value=$(echo "${raw_value:-}" | xargs)
  esc_value=${value//&/&amp;}
  esc_value=${esc_value//</&lt;}
  esc_value=${esc_value//>/&gt;}
  esc_value=${esc_value//\"/&quot;}
  esc_value=${esc_value//\'/&apos;}
  env_name=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '.-' '_')

  printf '  <Environment name="%s" value="%s" type="java.lang.String" override="true"/>\n' \
    "$env_name" "$esc_value" >> "$XML_FILE"
  printf '%s=${%s}\n' "$key" "$env_name" >> "$PROPS_FILE"
  ((prop_count++))
done < "$INPUT_FILE"

echo "</Context>" >> "$XML_FILE"

echo "[INFO] $prop_count propriétés traitées."
echo "[OK] Fichiers générés :"
echo "     - $XML_FILE"
echo "     - $PROPS_FILE"
