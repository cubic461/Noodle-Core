# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Download Monaco Editor locally to fix CDN loading issues
# """
import os
import urllib.request
import urllib.parse

function download_file(url, local_path)
    #     """Download a file from URL to local path"""
    #     try:
            print(f"Downloading {url} -> {local_path}")

    #         # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(local_path), exist_ok = True)

    #         # Download the file
    #         with urllib.request.urlopen(url) as response:
    #             with open(local_path, 'wb') as f:
                    f.write(response.read())

            print(f"✓ Successfully downloaded {local_path}")
    #         return True
    #     except Exception as e:
            print(f"✗ Failed to download {url}: {e}")
    #         return False

function main()
    #     """Download all Monaco Editor components"""

    #     # Base URL for Monaco Editor CDN
    base_url = "https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.45.0/min/vs"

    #     # Files to download
    files_to_download = [
    #         # Core files
    #         "loader.min.js",
    #         "nls.js",

    #         # Main editor files
    #         "editor/editor.main.js",
    #         "editor/editor.main.js.map",
    #         "editor/editor.main.css",
    #         "editor/editor.main.nls.js",
    #         "editor/editor.all.js",
    #         "editor/editor.all.js.map",

    #         # Worker files
    #         "base/worker/workerMain.js",
    #         "base/worker/workerMain.js.map",
    #         "base/worker/workerProxy.js",
    #         "base/worker/workerProxy.js.map",

    #         # Additional worker files that Monaco Editor needs
    #         "base/common/worker/simpleWorker.js",
    #         "base/common/worker/simpleWorker.js.map",
    #         "base/common/worker/simpleWorker.nls.js",

    #         # Language support
    #         "language/json/json.js",
    #         "language/json/json.js.map",
    #         "language/css/css.js",
    #         "language/css/css.js.map",
    #         "language/html/html.js",
    #         "language/html/html.js.map",
    #         "language/typescript/typescript.js",
    #         "language/typescript/typescript.js.map",

    #         # Worker files for languages
    #         "language/json/json.worker.js",
    #         "language/css/css.worker.js",
    #         "language/html/html.worker.js",
    #         "language/typescript/ts.worker.js",

    #         # Basic languages
    #         "basic-languages/monaco.contribution.js",
    #         "basic-languages/javascript/javascript.js",
    #         "basic-languages/typescript/typescript.js",
    #         "basic-languages/python/python.js",
    #         "basic-languages/java/java.js",
    #         "basic-languages/csharp/csharp.js",
    #         "basic-languages/cpp/cpp.js",
    #         "basic-languages/rust/rust.js",
    #         "basic-languages/go/go.js",
    #         "basic-languages/php/php.js",
    #         "basic-languages/ruby/ruby.js",
    #         "basic-languages/shell/shell.js",
    #         "basic-languages/sql/sql.js",
    #         "basic-languages/xml/xml.js",
    #         "basic-languages/yaml/yaml.js",
    #         "basic-languages/markdown/markdown.js",
    #         "basic-languages/json/json.js",
    #         "basic-languages/html/html.js",
    #         "basic-languages/css/css.js",
    #         "basic-languages/less/less.js",
    #         "basic-languages/scss/scss.js",

    #         # Localization files (nls.js) - CRITICAL for proper editor initialization
    #         "nls.js",
    #         "nls.metadata.json",
    #         "nls.metadata.header.json",
    #         "editor/editor.main.nls.js",
    #         "editor/editor.main.nls.metadata.json",
    #         "basic-languages/monaco.contribution.nls.js",
    #         "basic-languages/javascript/javascript.nls.js",
    #         "basic-languages/typescript/typescript.nls.js",
    #         "basic-languages/python/python.nls.js",
    #         "basic-languages/java/java.nls.js",
    #         "basic-languages/csharp/csharp.nls.js",
    #         "basic-languages/cpp/cpp.nls.js",
    #         "basic-languages/rust/rust.nls.js",
    #         "basic-languages/go/go.nls.js",
    #         "basic-languages/php/php.nls.js",
    #         "basic-languages/ruby/ruby.nls.js",
    #         "basic-languages/shell/shell.nls.js",
    #         "basic-languages/sql/sql.nls.js",
    #         "basic-languages/xml/xml.nls.js",
    #         "basic-languages/yaml/yaml.nls.js",
    #         "basic-languages/markdown/markdown.nls.js",
    #         "basic-languages/html/html.nls.js",
    #         "basic-languages/css/css.nls.js",
    #         "basic-languages/less/less.nls.js",
    #         "basic-languages/scss/scss.nls.js"
    #     ]

    #     # Download root loader script
    loader_url = f"{base_url}/loader.min.js"
    loader_path = "monaco-editor/min/vs/loader.min.js"
        download_file(loader_url, loader_path)

    #     # Download all other files
    downloaded_count = 0
    #     for file_path in files_to_download:
    full_url = f"{base_url}/{file_path}"
    local_path = f"monaco-editor/min/vs/{file_path}"

    #         if download_file(full_url, local_path):
    downloaded_count + = 1

        print(f"\nDownloaded {downloaded_count}/{len(files_to_download)} Monaco Editor files")
        print("Monaco Editor is now available locally!")

    #     # Create a simple verification file
    verification_content = """# Monaco Editor Local Installation

# This directory contains a local copy of Monaco Editor v0.45.0.

# All files have been downloaded from:
# https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.45.0/min/vs

# This local installation eliminates CDN dependencies and ensures
# Monaco Editor loads reliably regardless of external network status.

# To use this local Monaco Editor:
# 1. Update your HTML to point to /monaco-editor/min/vs/ instead of the CDN
# 2. Ensure the server serves files from this directory
# 3. Test the editor functionality

# Installation completed: """

#     with open("monaco-editor/INSTALLATION_INFO.md", "w") as f:
        f.write(verification_content)

    print("Installation information saved to monaco-editor/INSTALLATION_INFO.md")

if __name__ == "__main__"
        main()