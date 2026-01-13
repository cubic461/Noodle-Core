# Converted from Python to NoodleCore
# Original file: src

# """
# NoodleCore CLI Setup

# This script sets up the NoodleCore CLI package.
# """

import os
import pathlib.Path
import setuptools.setup

# Read the README file
this_directory = Path(__file__).parent
# long_description = (this_directory / "README.md").read_text(encoding='utf-8') if (this_directory / "README.md").exists() else ""

# Read requirements
requirements = []
if (this_directory / "requirements.txt").exists()
    #     with open(this_directory / "requirements.txt", 'r', encoding='utf-8') as f:
    #         requirements = [line.strip() for line in f if line.strip() and not line.startswith('#')]

# Version
version = "1.0.0"

setup(
name = "noodlecore-cli",
version = version,
author = "NoodleCore Team",
author_email = "team@noodlecore.com",
#     description="NoodleCore CLI for AI-powered code generation and validation",
long_description = long_description,
long_description_content_type = "text/markdown",
url = "https://github.com/noodlecore/noodlecore-cli",
project_urls = {
#         "Bug Tracker": "https://github.com/noodlecore/noodlecore-cli/issues",
#         "Documentation": "https://noodlecore-cli.readthedocs.io/",
#         "Source Code": "https://github.com/noodlecore/noodlecore-cli",
#     },
package_dir = {"": "src"},
packages = find_packages(where="src"),
classifiers = [
#         "Development Status :: 4 - Beta",
#         "Intended Audience :: Developers",
#         "License :: OSI Approved :: MIT License",
#         "Operating System :: OS Independent",
#         "Programming Language :: Python :: 3",
#         "Programming Language :: Python :: 3.9",
#         "Programming Language :: Python :: 3.10",
#         "Programming Language :: Python :: 3.11",
#         "Programming Language :: Python :: 3.12",
#         "Topic :: Software Development :: Code Generators",
#         "Topic :: Software Development :: Libraries :: Python Modules",
#         "Topic :: Text Processing :: Markup",
#         "Topic :: Utilities",
#     ],
python_requires = ">=3.9",
install_requires = requirements,
extras_require = {
#         "dev": [
"pytest= 7.0.0",
"pytest-mock> = 3.6.0",
"pytest-asyncio> = 0.18.0",
"pytest-cov> = 3.0.0",
"black> = 22.0.0",
"flake8> = 4.0.0",
"mypy> = 0.950",
#         ],
#         "docs"): [
"sphinx= 4.0.0",
"sphinx-rtd-theme> = 1.0.0",
#         ],
#     },
entry_points = {
#         "console_scripts"): [
"noodle = noodlecore.cli.main:main",
#         ],
#     },
include_package_data = True,
package_data = {
#         "noodlecore": [
#             "cli/templates/*.nc",
#             "cli/config/*.json",
#             "cli/ide/*.json",
#         ],
#     },
keywords = [
#         "noodlecore",
#         "cli",
#         "ai",
#         "code generation",
#         "validation",
#         "sandbox",
#         "ide",
#         "lsp",
#     ],
zip_safe = False,
# )
