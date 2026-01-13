"""
Ide Integration::Setup - setup.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Setup configuration for Noodle IDE package.
"""

from setuptools import find_packages, setup

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="noodle_ide",
    version="0.1.0",
    author="Noodle Development Team",
    author_email="dev@noodle-lang.org",
    description="Integrated Development Environment for Noodle programming language",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/noodle-lang/noodle-ide",
    packages=find_packages(include=["noodle_ide*"]),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=[
        "pytest>=6.0",
        "asyncio",
        "tempfile",
        "pathlib",
        "unittest.mock",
    ],
    extras_require={
        "dev": [
            "pytest>=6.0",
            "pytest-asyncio",
            "black",
            "flake8",
            "mypy",
        ],
        "test": [
            "pytest>=6.0",
            "pytest-asyncio",
        ],
    },
    # entry_points={
    #     "console_scripts": [
    #         "noodle-ide=noodle_ide.cli:main",
    #     ],
    # },
)


