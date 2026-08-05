#!/bin/bash
# Reusable deploy script for Bazel-common projects publishing to Maven Central Portal or installing locally.

set -eu

readonly MODE="${1:-}"
readonly VERSION_NAME="${2:-}"
shift 2 || true
readonly EXTRA_ARGS=("$@")

if [ -z "$MODE" ] || [ -z "$VERSION_NAME" ]; then
  echo "Usage: $0 <mode> <version-name> [extra-args...]" >&2
  echo "  mode: 'install:install-file' or 'central-portal' (or 'gpg:sign-and-deploy-file')" >&2
  exit 1
fi

STAGING_DIR=""
GPG_KEY=""

# Extract GPG key if passed in extra args
for arg in "${EXTRA_ARGS[@]:+${EXTRA_ARGS[@]}}"; do
  if [[ "$arg" =~ ^-Dgpg\.keyname=(.*)$ ]]; then
    GPG_KEY="${BASH_REMATCH[1]}"
  elif [[ "$arg" =~ ^--key=(.*)$ ]]; then
    GPG_KEY="${BASH_REMATCH[1]}"
  fi
done

if [ "$MODE" = "central-portal" ] || [ "$MODE" = "gpg:sign-and-deploy-file" ]; then
  STAGING_DIR=$(mktemp -d /tmp/maven-central-staging-XXXXXX)
  trap 'publish_to_central_portal; rm -rf "$STAGING_DIR"' EXIT
fi

bazel_output_file() {
  local library=$1
  local library_output=bazel-bin/$library
  if [[ ! -e $library_output ]]; then
     library_output=bazel-genfiles/$library
  fi
  if [[ ! -e $library_output ]]; then
    echo "Could not find bazel output file for $library" >&2
    exit 1
  fi
  echo -n "$library_output"
}

deploy_library() {
  local library=$1
  local srcjar=$2
  local javadoc=$3
  local pomfile=$4

  bazelisk build --define=pom_version="$VERSION_NAME" \
    "$library" "$srcjar" "$javadoc" "$pomfile"

  local lib_path
  lib_path=$(bazel_output_file "$library")
  local src_path
  src_path=$(bazel_output_file "$srcjar")
  local doc_path
  doc_path=$(bazel_output_file "$javadoc")
  local pom_path
  pom_path=$(bazel_output_file "$pomfile")

  if [ "$MODE" = "install:install-file" ]; then
    mvn install:install-file \
      -Dfile="$lib_path" \
      -Djavadoc="$doc_path" \
      -DpomFile="$pom_path" \
      -Dsources="$src_path" \
      "${EXTRA_ARGS[@]:+${EXTRA_ARGS[@]}}"
  elif [ "$MODE" = "central-portal" ] || [ "$MODE" = "gpg:sign-and-deploy-file" ]; then
    local coords
    coords=$(python3 -c "
import xml.etree.ElementTree as ET
import sys

tree = ET.parse('$pom_path')
root = tree.getroot()
ns = {'m': 'http://maven.apache.org/POM/4.0.0'}

group_id = root.find('m:groupId', ns)
if group_id is None and root.find('m:parent', ns) is not None:
    group_id = root.find('m:parent/m:groupId', ns)
artifact_id = root.find('m:artifactId', ns)
version = root.find('m:version', ns)
if version is None and root.find('m:parent', ns) is not None:
    version = root.find('m:parent/m:version', ns)

print(f'{group_id.text}:{artifact_id.text}:{version.text}')
")
    local artifact_id
    artifact_id=$(echo "$coords" | cut -d':' -f2)
    local version
    version=$(echo "$coords" | cut -d':' -f3)

    cp "$lib_path" "$STAGING_DIR/${artifact_id}-${version}.jar"
    cp "$src_path" "$STAGING_DIR/${artifact_id}-${version}-sources.jar"
    cp "$doc_path" "$STAGING_DIR/${artifact_id}-${version}-javadoc.jar"
    cp "$pom_path" "$STAGING_DIR/${artifact_id}-${version}.pom"
  fi
}

find_sonatype_bearer_token() {
  if [ -n "${CENTRAL_PORTAL_BEARER_TOKEN:-}" ]; then
    echo "$CENTRAL_PORTAL_BEARER_TOKEN"
    return 0
  fi
  if [ -n "${SONATYPE_BEARER_TOKEN:-}" ]; then
    echo "$SONATYPE_BEARER_TOKEN"
    return 0
  fi
  if [ -n "${SONATYPE_USERNAME:-}" ] && [ -n "${SONATYPE_PASSWORD:-}" ]; then
    echo -n "${SONATYPE_USERNAME}:${SONATYPE_PASSWORD}" | base64 | tr -d '\n'
    return 0
  fi

  if [ -f "$HOME/.m2/settings.xml" ]; then
    local token
    token=$(python3 -c "
import xml.etree.ElementTree as ET
import base64, os, sys

settings_path = os.path.expanduser('~/.m2/settings.xml')
if not os.path.exists(settings_path):
    sys.exit(1)

try:
    tree = ET.parse(settings_path)
    root = tree.getroot()
    for elem in root.iter():
        if '}' in elem.tag:
            elem.tag = elem.tag.split('}', 1)[1]

    target_ids = {'central', 'sonatype-nexus-staging', 'ossrh'}
    username = None
    password = None

    for server in root.findall('.//server'):
        id_elem = server.find('id')
        if id_elem is not None and id_elem.text in target_ids:
            u_elem = server.find('username')
            p_elem = server.find('password')
            if u_elem is not None and p_elem is not None:
                username = u_elem.text
                password = p_elem.text
                if id_elem.text == 'central':
                    break

    if username and password:
        user_pass = f'{username}:{password}'
        print(base64.b64encode(user_pass.encode('utf-8')).decode('utf-8'))
        sys.exit(0)
except Exception:
    pass
sys.exit(1)
" 2>/dev/null)
    if [ -n "$token" ]; then
      echo "$token"
      return 0
    fi
  fi

  return 1
}

publish_to_central_portal() {
  if [ -z "$STAGING_DIR" ] || [ ! -d "$STAGING_DIR" ]; then
    return 0
  fi

  local file_count
  file_count=$(find "$STAGING_DIR" -type f | wc -l)
  if [ "$file_count" -eq 0 ]; then
    return 0
  fi

  if [ "${SKIP_GPG_SIGNING:-false}" = "true" ]; then
    echo "Skipping GPG signing (SKIP_GPG_SIGNING=true)..."
    for file in "$STAGING_DIR"/*; do
      if [ -f "$file" ] && [[ "$file" != *.asc ]]; then
        touch "${file}.asc"
      fi
    done
  else
    echo "Signing staged artifacts in $STAGING_DIR with GPG..."
    for file in "$STAGING_DIR"/*; do
      if [ -f "$file" ] && [[ "$file" != *.asc ]]; then
        local gpg_cmd=(gpg --batch --yes --detach-sign --armor)
        if [ -n "$GPG_KEY" ]; then
          gpg_cmd+=(-u "$GPG_KEY")
        fi
        "${gpg_cmd[@]}" "$file"
      fi
    done
  fi

  local bundle_zip
  bundle_zip=$(mktemp /tmp/central-bundle-XXXXXX.zip)
  rm -f "$bundle_zip"
  (cd "$STAGING_DIR" && zip -q -r "$bundle_zip" .)

  echo "Created Central Portal deployment bundle: $bundle_zip"

  if [ "${DRY_RUN:-false}" = "true" ]; then
    echo "[DRY RUN] Skipping upload to Central Portal. Deployment bundle contents:"
    unzip -l "$bundle_zip"
    rm -f "$bundle_zip"
    return 0
  fi

  local bearer_token
  bearer_token=$(find_sonatype_bearer_token) || {
    echo "ERROR: Could not find Sonatype Central Portal credentials in environment or ~/.m2/settings.xml" >&2
    rm -f "$bundle_zip"
    exit 1
  }

  echo "Uploading deployment bundle to Sonatype Central Publishing Portal..."
  local response
  response=$(curl --request POST \
    --show-error --fail \
    --header "Authorization: Bearer ${bearer_token}" \
    --form "bundle=@${bundle_zip}" \
    --form "publishingType=AUTOMATIC" \
    "https://central.sonatype.com/api/v1/publisher/upload")

  echo "Upload complete. Sonatype Central Portal response: $response"
  rm -f "$bundle_zip"
}
