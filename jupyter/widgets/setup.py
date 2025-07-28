"""
Setup script for Cloud Threat Graph Lab Instruction Widget
Python package for educational guidance in Jupyter notebooks
"""

from setuptools import setup, find_packages

setup(
    name="cloud-threat-instructor",
    version="1.0.0",
    description="Interactive instruction widget for Cloud Threat Graph Lab",
    author="Cloud Security Lab",
    author_email="security@example.com",
    packages=find_packages(),
    python_requires=">=3.7",
    install_requires=[
        "ipywidgets>=7.6.0",
        "IPython>=7.0.0"
    ],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Framework :: Jupyter",
        "Intended Audience :: Education",
        "Topic :: Security",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
    ],
    keywords="jupyter cybersecurity education security-training graph-analysis",
    project_urls={
        "Documentation": "https://github.com/cloud-threat-lab/docs",
        "Source": "https://github.com/cloud-threat-lab/jupyter-overlay",
        "Tracker": "https://github.com/cloud-threat-lab/jupyter-overlay/issues",
    }
)