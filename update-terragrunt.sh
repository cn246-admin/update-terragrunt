#!/bin/sh

# Description: Download, verify and install terragrunt binary on Linux and Mac
# Author: Chuck Nemeth
# https://terragrunt.gruntwork.io

# Colored output
code_grn () { tput setaf 2; printf '%s\n' "${1}"; tput sgr0; }
code_red () { tput setaf 1; printf '%s\n' "${1}"; tput sgr0; }
code_yel () { tput setaf 3; printf '%s\n' "${1}"; tput sgr0; }

# Define function to delete temporary install files
clean_up () {
  printf '%s\n' "[INFO] Cleaning up install files"
  cd && rm -rf "${tmp_dir}"
}

# Variables
bin_dir="$HOME/.local/bin"
sum_file="SHA256SUMS"

tg_version="$(curl -Ls https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | \
              awk -F': ' '/tag_name/ { gsub(/\"|\,/,"",$2); print $2 }')"

tg_url="https://github.com/gruntwork-io/terragrunt/releases/download/${tg_version}/"

if command -v terragrunt >/dev/null; then
  tg_installed_version="$(terragrunt --version)"
  tg_installed_version="${tg_installed_version##*\ }"
else
  tg_installed_version="Not Installed"
fi

# OS check
archi=$(uname -sm)
case "$archi" in
  Darwin\ arm64)
    tg_binary="terragrunt_darwin_arm64"
    ;;
  Darwin\ x86_64)
    tg_binary="terragrunt_darwin_amd64"
    ;;
  Linux\ armv* | Linux\ aarch64*)
    tg_binary="terragrunt_linux_arm64"
    ;;
  Linux\ x86_64)
    tg_binary="terragrunt_linux_amd64"
    ;;
  *)
    code_red "[ERROR] OS not supported!"
    exit 1
    ;;
esac

# PATH Check
case :$PATH: in
  *:"${bin_dir}":*) ;;  # do nothing
  *)
    code_red "[ERROR] ${bin_dir} was not found in \$PATH!"
    code_red "Add ${bin_dir} to PATH or select another directory to install to"
    exit 1
    ;;
esac

# Version Check
if [ "${tg_version}" = "${tg_installed_version}" ]; then
  printf '%s\n' "Installed Verision: ${tg_installed_version}"
  printf '%s\n' "Latest Version: ${tg_version}"
  code_yel "[INFO] Already using latest version. Exiting."
  exit
else
  printf '%s\n' "Installed Verision: ${tg_installed_version}"
  printf '%s\n' "Latest Version: ${tg_version}"
  tmp_dir="$(mktemp -d /tmp/tg.XXXXXXXX)"
  cd "${tmp_dir}" || exit
fi

# Run clean_up function on exit
trap clean_up EXIT

# Download
printf '%s\n' "[INFO] Downloading the terragrunt binary and verification files"
curl -sL -o "${tmp_dir}/${tg_binary}" "${tg_url}/${tg_binary}"
curl -sL -o "${tmp_dir}/${sum_file}" "${tg_url}/${sum_file}"

# Verify
printf '%s\n' "[INFO] Verifying ${tg_binary}"
if ! shasum -qc --ignore-missing "${sum_file}"; then
  code_red "[ERROR] Problem with checksum!"
  exit 1
fi

# Create directory
if [ ! -d "${bin_dir}" ]; then
  printf '%s\n' "[INFO] Creating ${bin_dir}"
  install -m 0700 -d "${bin_dir}"
fi

# Install terragrunt binary
if [ -f "${tmp_dir}/${tg_binary}" ]; then
  printf '%s\n' "[INFO] Installing ${tg_binary} to ${bin_dir}"
  mv "${tmp_dir}/${tg_binary}" "${bin_dir}/terragrunt"
  chmod 0700 "${bin_dir}/terragrunt"
fi

# Version Check
code_grn "[SUCCESS] Done!"
code_grn "Installed Version: $(terragrunt --version)"

# vim: ft=sh ts=2 sts=2 sw=2 sr et
