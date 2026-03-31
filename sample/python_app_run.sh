#!/bin/bash
set -e

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd "$SCRIPT_DIR"

VENV_NAME="venv"
MAIN_APP_FILENAME="main.py"

APP_FOLDER_PATH=""
if [ -z "$1" ]; then
    echo "[script] Error: Target application folder path must be specified as an argument." >&2
    echo "[script] Usage: $0 <path_to_pythion_application_folder>" >&2
    exit 1
fi
APP_FOLDER_PATH="$1"
if [ ! -d "$APP_FOLDER_PATH" ]; then
    echo "[script] Error: Application folder '$APP_FOLDER_PATH' not found." >&2
    exit 1
fi

cd "$APP_FOLDER_PATH"

function cleanup {
    if command -v deactivate &> /dev/null && [[ "$(type deactivate)" =~ "function" ]]; then
        deactivate
    fi

    echo "[script] ***"
    echo "[script] *** Finished the python application ($APP_FOLDER_PATH)."
    echo "[script] ***"
    echo "[script]"
}

trap cleanup EXIT

echo "[script] ***"
echo "[script] *** Started the python application ($APP_FOLDER_PATH)."
echo "[script] ***"

echo "[script] Initializing virtual environment"
if [ -d "$VENV_NAME" ]; then
    echo "[script] Removing existing virtual environment '$VENV_NAME'..."
    rm -rf "$VENV_NAME"
fi

echo "[script] Creating new virtual environment '$VENV_NAME'..."
python3 -m venv "$VENV_NAME"

echo "[script] Activating virtual environment '$VENV_NAME'..."
source "$VENV_NAME/bin/activate"

echo "[script] Installing dependencies"
pip install -e .

echo "[script] ***"
echo "[script] *** Running the python application ($APP_FOLDER_PATH)."
echo "[script] ***"
python "$MAIN_APP_FILENAME"
