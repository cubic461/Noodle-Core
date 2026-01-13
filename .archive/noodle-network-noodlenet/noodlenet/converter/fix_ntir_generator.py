"""
Converter::Fix Ntir Generator - fix_ntir_generator.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix script voor NTIR generator om STRING type te ondersteunen
"""

import sys
import os

# Voeg de converter module toe aan de Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from tensor_types import NoodleTensorType

# Print beschikbare types
print("Beschikbare NoodleTensorType waarden:")
for dtype in NoodleTensorType:
    print(f"  {dtype.name}: {dtype.value}")

# Controleer of STRING bestaat
if hasattr(NoodleTensorType, 'STRING'):
    print("\nSTRING type gevonden!")
else:
    print("\nSTRING type niet gevonden, beschikbare types:")
    print([dtype.name for dtype in NoodleTensorType])

# Maak een mapping voor ONNX naar Noodle types
dtype_mapping = {
    1: NoodleTensorType.FLOAT32,
    2: NoodleTensorType.FLOAT16,  # Eigenlijk BFLOAT16 maar die bestaat niet
    3: NoodleTensorType.INT32,
    6: NoodleTensorType.INT64,
    7: NoodleTensorType.STRING,
    9: NoodleTensorType.BOOL,
}

print("\nONNX naar Noodle tensor type mapping:")
for onnx_type, noodle_type in dtype_mapping.items():
    print(f"  {onnx_type} -> {noodle_type.name}")


