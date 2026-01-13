"""
Setup script for NoodleCore Fase 1 package.
Ensures src/ is in Python path for imports.
"""

from setuptools import setup, find_packages

setup(
    name="noodle-poc-fase1",
    version="0.1.0",
    description="NoodleCore Distributed Inference - Fase 1: Observability Engine",
    author="NoodleCore Team",
    author_email="team@noodlecore.dev",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.9",
    install_requires=[
        "torch>=2.0.0",
        "transformers>=4.30.0",
        "numpy>=1.24.0",
        "pandas>=2.0.0",
        "psutil>=5.9.0",
        "matplotlib>=3.7.0",
        "seaborn>=0.12.0",
        "tqdm>=4.65.0",
        "pyyaml>=6.0"
    ],
    extras_require={
        "dev": [
            "pytest>=7.3.0",
            "pytest-cov>=4.1.0",
            "black>=23.3.0",
            "flake8>=6.0.0",
            "mypy>=1.3.0"
        ],
        "dashboard": [
            "dash>=2.10.0",
            "dash-bootstrap-components>=1.4.0",
            "plotly>=5.14.0"
        ],
        "all": [
            "pytest>=7.3.0",
            "pytest-cov>=4.1.0",
            "black>=23.3.0",
            "flake8>=6.0.0",
            "mypy>=1.3.0",
            "dash>=2.10.0",
            "dash-bootstrap-components>=1.4.0",
            "plotly>=5.14.0"
        ]
    },
)
