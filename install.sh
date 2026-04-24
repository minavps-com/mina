#!/bin/bash
#
# Copyright 2026 MinaVPS (https://minavps.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

# Default values
VERSION="0.1.0"
INSTALL_DIR="${HOME}/.local/bin"
BIN_NAME="mina"
REPO_URL="https://raw.githubusercontent.com/minavps-com/mina/main"
BIN_BASE="bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Detect OS and Architecture
detect_platform() {
    local os
    local arch
    
    # Detect OS
    case "$(uname -s)" in
        Linux*)     os="linux" ;;
        Darwin*)    os="darwin" ;;
        CYGWIN*|MINGW*|MSYS*) os="windows" ;;
        *)          os="unknown" ;;
    esac
    
    # Detect Architecture
    case "$(uname -m)" in
        x86_64|amd64)   arch="amd64" ;;
        aarch64|arm64)  arch="arm64" ;;
        *)              arch="unknown" ;;
    esac
    
    echo "${os}-${arch}"
}

# Detect the user's shell config file
detect_shell_config() {
    local platform="$1"
    local config_file=""

    # On Windows (Git Bash/MSYS2), use .bash_profile
    if [[ "$platform" == "windows"* ]]; then
        if [[ -f "${HOME}/.bash_profile" ]]; then
            config_file="${HOME}/.bash_profile"
        elif [[ -f "${HOME}/.bashrc" ]]; then
            config_file="${HOME}/.bashrc"
        else
            config_file="${HOME}/.bash_profile"
        fi
        echo "$config_file"
        return
    fi

    # Detect shell from SHELL env var
    local shell_name
    shell_name=$(basename "${SHELL:-/bin/bash}")

    case "$shell_name" in
        zsh)
            # Zsh: prefer .zshrc, then .zshenv, then .zprofile
            if [[ -f "${HOME}/.zshrc" ]]; then
                config_file="${HOME}/.zshrc"
            elif [[ -f "${HOME}/.zshenv" ]]; then
                config_file="${HOME}/.zshenv"
            elif [[ -f "${HOME}/.zprofile" ]]; then
                config_file="${HOME}/.zprofile"
            else
                config_file="${HOME}/.zshrc"
            fi
            ;;
        bash)
            # Bash: prefer .bashrc, then .bash_profile, then .profile
            if [[ "$platform" == "darwin"* ]]; then
                # On macOS, bash login shells read .bash_profile, not .bashrc
                if [[ -f "${HOME}/.bash_profile" ]]; then
                    config_file="${HOME}/.bash_profile"
                elif [[ -f "${HOME}/.bashrc" ]]; then
                    config_file="${HOME}/.bashrc"
                elif [[ -f "${HOME}/.profile" ]]; then
                    config_file="${HOME}/.profile"
                else
                    config_file="${HOME}/.bash_profile"
                fi
            else
                # On Linux, .bashrc is typically the right choice
                if [[ -f "${HOME}/.bashrc" ]]; then
                    config_file="${HOME}/.bashrc"
                elif [[ -f "${HOME}/.bash_profile" ]]; then
                    config_file="${HOME}/.bash_profile"
                elif [[ -f "${HOME}/.profile" ]]; then
                    config_file="${HOME}/.profile"
                else
                    config_file="${HOME}/.bashrc"
                fi
            fi
            ;;
        *)
            # Fallback: try common config files
            for candidate in ".profile" ".bashrc" ".bash_profile" ".zshrc"; do
                if [[ -f "${HOME}/${candidate}" ]]; then
                    config_file="${HOME}/${candidate}"
                    break
                fi
            done
            # If none exist, default to .profile
            if [[ -z "$config_file" ]]; then
                config_file="${HOME}/.profile"
            fi
            ;;
    esac

    echo "$config_file"
}

# Add install directory to PATH in shell config
add_to_path() {
    local platform="$1"
    local config_file
    config_file=$(detect_shell_config "$platform")
    local export_line="export PATH=\"${INSTALL_DIR}:\$PATH\""
    local marker="# Added by mina CLI installer"

    # Check if already in PATH
    if [[ ":$PATH:" == *":${INSTALL_DIR}:"* ]]; then
        return 0
    fi

    # Check if the line already exists in the config file
    if [[ -f "$config_file" ]] && grep -qF "$export_line" "$config_file" 2>/dev/null; then
        log_success "${INSTALL_DIR} is already configured in ${config_file}"
        return 0
    fi

    # Add to config file
    log_info "Adding ${INSTALL_DIR} to PATH in ${config_file}..."
    
    {
        echo ""
        echo "$marker"
        echo "$export_line"
    } >> "$config_file"

    log_success "Added ${INSTALL_DIR} to PATH in ${config_file}"
    log_info "Restart your terminal or run: source ${config_file}"
}

# Get latest version from GitHub API (optional)
get_latest_version() {
    # This can be enhanced to fetch latest version from GitHub releases
    # For now, we use the version passed via --version or default
    echo "$VERSION"
}

# Determine binary filename
get_binary_filename() {
    local platform="$1"
    local version="$2"
    local os="${platform%-*}"
    local arch="${platform#*-}"
    
    if [[ "$os" == "windows" ]]; then
        echo "mina-${version}-${os}-${arch}.exe"
    else
        echo "mina-${version}-${os}-${arch}"
    fi
}

# Get download URL for binary
get_download_url() {
    local filename="$1"
    local version="$2"
    echo "${REPO_URL}/${BIN_BASE}/${version}/${filename}"
}

# Download binary
download_binary() {
    local filename="$1"
    local version="$2"
    local dest="$3"
    
    local url
    url=$(get_download_url "$filename" "$version")
    
    log_info "Downloading ${filename} (version: ${version})..."
    
    # Try curl first, then wget
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$dest"
    else
        log_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    if [[ ! -f "$dest" ]]; then
        log_error "Download failed: $url"
        exit 1
    fi
    
    # Make executable (except Windows .exe)
    if [[ "$filename" != *.exe ]]; then
        chmod +x "$dest"
    fi
}

# Download and verify checksum
verify_checksum() {
    local filename="$1"
    local version="$2"
    local filepath="$3"
    
    local checksum_url
    checksum_url=$(get_download_url "${filename}.sha256" "$version")
    local checksum_file="${filepath}.sha256"
    
    log_info "Verifying checksum..."
    
    # Download checksum
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$checksum_url" -o "$checksum_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$checksum_url" -O "$checksum_file"
    else
        log_warning "Cannot download checksum (no curl/wget). Skipping verification."
        return 0
    fi
    
    if [[ ! -f "$checksum_file" ]]; then
        log_warning "Checksum file not found. Skipping verification."
        return 0
    fi
    
    # Calculate local checksum
    local expected_checksum
    expected_checksum=$(cat "$checksum_file")
    local actual_checksum
    
    if command -v shasum >/dev/null 2>&1; then
        actual_checksum=$(shasum -a 256 "$filepath" | cut -d ' ' -f1)
    elif command -v sha256sum >/dev/null 2>&1; then
        actual_checksum=$(sha256sum "$filepath" | cut -d ' ' -f1)
    else
        log_warning "No checksum tool found. Skipping verification."
        return 0
    fi
    
    if [[ "$expected_checksum" == "$actual_checksum" ]]; then
        log_success "Checksum verified"
        rm -f "$checksum_file"
    else
        log_error "Checksum verification failed!"
        log_error "Expected: $expected_checksum"
        log_error "Got:      $actual_checksum"
        rm -f "$filepath" "$checksum_file"
        exit 1
    fi
}

# Main installation
main() {
    log_info "Installing Mina CLI..."
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    
    if [[ "$platform" == "unknown-unknown" ]]; then
        log_error "Unsupported platform: $(uname -s) $(uname -m)"
        exit 1
    fi
    
    log_info "Detected platform: $platform"
    
    # Get version (could be passed as argument or detected)
    local version
    version=$(get_latest_version)
    
    log_info "Installing version: $version"
    
    # Determine binary filename
    local binary_filename
    binary_filename=$(get_binary_filename "$platform" "$version")
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Download binary
    local temp_file="${INSTALL_DIR}/${binary_filename}.tmp"
    download_binary "$binary_filename" "$version" "$temp_file"
    
    # Verify checksum
    verify_checksum "$binary_filename" "$version" "$temp_file"
    
    # Finalize installation
    local final_path="${INSTALL_DIR}/${BIN_NAME}"
    if [[ "$platform" == *"windows"* ]]; then
        final_path="${INSTALL_DIR}/${BIN_NAME}.exe"
    fi
    
    mv "$temp_file" "$final_path"
    
    log_success "Installed Mina CLI to ${final_path}"
    
    # Add to PATH in shell config
    add_to_path "$platform"
    
    # Test installation
    if [[ -x "$final_path" ]]; then
        log_info "Testing installation..."
        "$final_path" --version
        log_success "Installation complete! Run 'mina --help' to get started."
    else
        log_info "Installation complete. Run '${final_path} --help' to get started."
    fi
}

# Handle command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dir=*)
            INSTALL_DIR="${1#*=}"
            shift
            ;;
        --version=*)
            VERSION="${1#*=}"
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --dir=<directory>    Installation directory (default: ~/.local/bin)"
            echo "  --version=<version>  Specific version to install (default: 0.1.0)"
            echo "  --help               Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run main installation
main
