"""
Cloud Threat Graph Lab - Interactive Instruction Widget Package
Educational guidance system for Jupyter notebook cybersecurity learning
"""

from .instructor import (
    InstructionWidget,
    show_instructions,
    create_custom_instructions,
    demo_instructions
)

__version__ = "1.0.0"
__author__ = "Cloud Security Lab"

__all__ = [
    "InstructionWidget",
    "show_instructions", 
    "create_custom_instructions",
    "demo_instructions"
]