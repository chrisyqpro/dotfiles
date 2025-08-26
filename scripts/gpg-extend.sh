#!/usr/bin/env bash
#
# extend-keys
#
# Usage:
#   ./extend-keys [expiration]
#
# The expiration period for the subkeys (e.g., "1y", "2y", or a date like "2027-12-31").
# Defaults to "1y" if not provided.
#
# This script assumes:
#  - You have a full backup of your secret key in "full-secret-backup.asc"
#  - Your primary key is identified by KEYID which is either determined from the backup or provided interactively.
#  - Your key setup includes a primary key (with certify usage only, never expiring)
#    and one or more subkeys (for signing, encryption and possibly authentication).
#  - After updating, you want to remove the full secret key from your local keyring
#    and re-import only the subkeys for daily use.
#

set -e

# --- Configuration and Defaults ---
EXPIRY=${1:-1y} # expiration period for subkeys, default is 1y
DRIVE_PATH="/Volumes/my-key"
SSH_PATH="$HOME/.ssh"

for uid in d y; do
  SEC_FILE="$DRIVE_PATH/$uid-sec.asc"
  SSB_FILE="$DRIVE_PATH/$uid-ssb.asc"
  PUB_FILE="$DRIVE_PATH/$uid-pub.asc"
  SSH_FILE="$SSH_PATH/$uid-ssh.pub"
  SEC_BACKUP="$DRIVE_PATH/$uid-sec.asc.old"
  SSB_BACKUP="$DRIVE_PATH/$uid-ssb.asc.old"
  PUB_BACKUP="$DRIVE_PATH/$uid-pub.asc.old"
  SSH_BACKUP="$SSH_PATH/$uid-ssh.pub.old"

  # --- Step 0: backup current key files
  cp "${SEC_FILE}" "${SEC_BACKUP}"
  cp "${SSB_FILE}" "${SSB_BACKUP}"
  cp "${PUB_FILE}" "${PUB_BACKUP}"
  cp "${SSH_FILE}" "${SSH_BACKUP}"

  # --- Step A: Import the Full Secret Key ---
  echo "Importing full secret key from ${SEC_FILE}..."
  gpg --import "$SEC_FILE"

  # --- Determine the Primary Key ID ---
  # FIX: detect correct sec record by using the current secret key file ($SEC_FILE)
  # Instead of extracting from a sec record (which may yield a keygrip), extract the fingerprint
  # from the first fpr record. Field 10 of an "fpr" record is the full fingerprint.
  KEYID=$(gpg --with-colons --import-options show-only --import "$SEC_FILE" 2>/dev/null \
    | awk -F: '$1=="fpr" {print $10; exit}')
  if [ -z "$KEYID" ]; then
    read -r -p "Could not auto-detect primary key ID. Please enter your primary key ID (fingerprint): " KEYID
  fi
  echo "Using primary key ID: $KEYID"

  # --- Step B: Extend the Expiration for All Subkeys ---
  echo "Updating expiration for all secret subkeys of $KEYID to $EXPIRY..."

  # Instead of extracting field 5 from "ssb" lines,
  # extract the full fingerprint for each subkey by reading the following "fpr" line.
  SUBKEYS=$(gpg --with-colons --list-secret-keys "$KEYID" \
    | awk -F: '$1=="ssb" { getline; if($1=="fpr") print $10 }')

  if [ -z "$SUBKEYS" ]; then
    echo "No secret subkeys found for key $KEYID. Exiting."
    exit 1
  fi

  for sub in $SUBKEYS; do
    echo "  Setting expiration for subkey $sub..."
    gpg --batch --yes --quick-set-expire "$KEYID" "$EXPIRY" "$sub"
  done

  # --- Step C: Export Updated Keys ---
  echo "Exporting updated keys..."

  # Export the full secret key (primary + subkeys)
  gpg --armor --export-secret-keys "$KEYID" >"$SEC_FILE"
  echo "  Full secret key backup exported to $SEC_FILE"

  # Export only the secret subkeys (without the primary secret)
  gpg --armor --export-secret-subkeys "$KEYID" >"$SSB_FILE"
  echo "  Secret subkeys backup exported to $SSB_FILE"

  # Export the public key (which now includes the updated expiration info)
  gpg --armor --export "$KEYID" >"$PUB_FILE"
  echo "  Updated public key exported to $PUB_FILE"

  # --- Step D: Regenerate the OpenSSH Public Key (if an auth subkey exists) ---
  # Look for a subkey whose usage includes 'A' (authentication).
  AUTH_SUBKEY=$(gpg --with-colons --list-secret-keys "$KEYID" | grep '^ssb' | awk -F: '$12 ~ /A/ { print $5; exit }')
  if [ -n "$AUTH_SUBKEY" ]; then
    echo "Found authentication subkey: $AUTH_SUBKEY"
    echo "Exporting corresponding OpenSSH public key to ${SSH_FILE}..."
    gpg --export-ssh-key "$AUTH_SUBKEY" >"$SSH_FILE"
  else
    echo "No authentication subkey found. Skipping OpenSSH public key export."
  fi

  # --- Step E: Remove the Full Secret Key from the Local Keyring ---
  echo "Removing full secret key (primary + subkeys) from the local keyring..."
  gpg --batch --yes --delete-secret-key "$KEYID"

  # --- Step F: Re-import Only the Secret Subkeys ---
  echo "Re-importing only the secret subkeys from ${SSB_FILE}..."
  gpg --import "$SSB_FILE"
done

# --- Step G: Final Verification ---
echo "Final secret key listing (gpg -K):"
gpg --list-secret-keys --keyid-format LONG

echo ""
echo "Final public key listing (gpg -k):"
gpg --list-keys --keyid-format LONG

echo ""
echo "Key update and backup process completed."
