#!/bin/bash

# Opera Certificate Installation
BASE_URL="https://opera-public-certificates.s3.amazonaws.com"
CERTS=("OperaSoftwareAS-PrivateCA.crt" "OperaSoftwareAS-PrivateSubCA.crt" "OperaSoftwareAS-PrivateRootX1.crt" "OperaNorwayAS-OvertureRoot.crt")
CERT_NAMES=("Opera Software AS - Private CA" "Opera Software AS - Private SubCA" "Opera Software AS - Private Root X1" "Opera Norway AS - Overture Root")

echo "Checking Opera certificates..."

# Check if all certificates are already installed (system-wide)
all_system_installed=true
for cert in "${CERTS[@]}"; do
  if [ ! -f "/etc/ca-certificates/trust-source/anchors/$cert" ]; then
    all_system_installed=false
    break
  fi
done

# Check if all certificates are already installed (browser)
all_browser_installed=true
if command -v certutil >/dev/null 2>&1 && [ -d "$HOME/.pki/nssdb" ]; then
  for cert_name in "${CERT_NAMES[@]}"; do
    if ! certutil -d sql:$HOME/.pki/nssdb -L 2>/dev/null | grep -q "$cert_name"; then
      all_browser_installed=false
      break
    fi
  done
else
  all_browser_installed=false
fi

# If all certificates are installed, abort
if [ "$all_system_installed" = true ] && [ "$all_browser_installed" = true ]; then
  echo "All Opera certificates are already installed. Skipping installation."
  exit 0
fi

echo "Installing Opera certificates..."

# Install system-wide certificates
cd /tmp
for cert in "${CERTS[@]}"; do
  if [ ! -f "/etc/ca-certificates/trust-source/anchors/$cert" ]; then
    echo "Downloading and installing $cert..."
    wget "$BASE_URL/$cert"
    sudo cp "$cert" /etc/ca-certificates/trust-source/anchors/
    rm "$cert"
  else
    echo "Certificate $cert already exists, skipping..."
  fi
done

# Update system certificate store if any new certificates were added
if ls /etc/ca-certificates/trust-source/anchors/Opera*.crt >/dev/null 2>&1; then
  sudo trust extract-compat
fi

# Check if NSS tools are available
if ! command -v certutil >/dev/null 2>&1; then
  echo "NSS tools not found. Please install the 'nss' package:"
  echo "  sudo pacman -S nss"
  echo "Then re-run the installation."
  exit 1
fi

# Create NSS database if it doesn't exist
if [ ! -d "$HOME/.pki/nssdb" ]; then
  echo "Creating NSS database..."
  mkdir -m 700 -p "$HOME/.pki"
  mkdir -m 700 -p "$HOME/.pki/nssdb"
  certutil -d "$HOME/.pki/nssdb" -N --empty-password
fi

# Install browser certificates
cd /tmp
for i in "${!CERTS[@]}"; do
  cert="${CERTS[$i]}"
  cert_name="${CERT_NAMES[$i]}"
  
  if ! certutil -d sql:$HOME/.pki/nssdb -L 2>/dev/null | grep -q "$cert_name"; then
    echo "Installing '$cert_name' to browser trust store..."
    if [ ! -f "$cert" ]; then
      wget "$BASE_URL/$cert"
    fi
    certutil -d sql:$HOME/.pki/nssdb -A -t "CT,," -n "$cert_name" -i "$cert"
    rm -f "$cert"
  else
    echo "Certificate '$cert_name' already exists in browser, skipping..."
  fi
done

echo "Opera certificate installation complete!"