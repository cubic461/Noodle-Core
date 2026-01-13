"""
Converter::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleTensor Converter - AI model conversie pipeline

Converteert AI-modellen (ONNX, PyTorch, TensorFlow) naar NoodleCore-native formaat
via NTIR (Noodle Tensor Intermediate Representation) en NBC (Noodle Binary Code).

ðŸŽ¯ Doel:
- Gebruiksvriendelijke conversie van bestaande AI-modellen
- Optimalisatie voor NoodleCore distributed matrix runtime
- Type-safety en prestatieoptimalisatie
- Interoperabiliteit met diverse AI-frameworks

ðŸ—ï¸ Architectuur:
Converter Pipeline
â”œâ”€â”€ ONNX Parser (onnx_parser.py)
â”œâ”€â”€ NTIR Generator (ntir_generator.py)
â”œâ”€â”€ Type System (tensor_types.py)
â”œâ”€â”€ Matrix Optimizer (matrix_optimizer.py)
â””â”€â”€ NBC Bridge (nbc_bridge.py)

ðŸ“ Documentatie:
- Implementatiedetails: docs/implementation.md
- API specificaties: docs/api_reference.md
- Usage examples: docs/converter_examples.md
"""


