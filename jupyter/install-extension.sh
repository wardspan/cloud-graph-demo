#!/bin/bash

# Cloud Threat Graph Lab - Jupyter Extension Installation Script
# Installs the interactive instruction overlay system

echo "🎓 Installing Cloud Threat Graph Lab Jupyter Overlay System..."

# Install the nbextension
echo "📦 Installing nbextension..."
jupyter nbextension install ./extensions/instruction_overlay --user --overwrite

# Enable the extension
echo "✅ Enabling extension..."
jupyter nbextension enable instruction_overlay/main --user

# Install Python widget package
echo "🐍 Installing Python widget package..."
pip install -e ./widgets

# Verify installation
echo "🔍 Verifying installation..."
if jupyter nbextension list | grep -q "instruction_overlay.*enabled"; then
    echo "✅ Extension successfully installed and enabled!"
else
    echo "❌ Extension installation failed"
    exit 1
fi

echo "🎉 Installation complete!"
echo ""
echo "📚 Usage:"
echo "  - JavaScript Overlay: Click 'Learning Guide' button in notebook toolbar"
echo "  - Python Widget: Add this to notebook cells:"
echo "    from cloud_threat_instructor import show_instructions"
echo "    show_instructions('notebook-name.ipynb')"
echo ""
echo "🚀 Restart Jupyter Lab to see the changes!"