"""
Demo::Generate Icons - generate_icons.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import os
from PIL import Image, ImageDraw, ImageFont

# Ensure the icons directory exists
icons_dir = os.path.join(os.path.dirname(__file__), 'icons')
if not os.path.exists(icons_dir):
    os.makedirs(icons_dir)

# Define the icon sizes we need
icon_sizes = [16, 32, 72, 96, 128, 144, 152, 192, 384, 512]

# Create a simple icon for each size
for size in icon_sizes:
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw a circular background
    margin = int(size * 0.1)
    draw.ellipse([margin, margin, size - margin, size - margin], fill=(25, 118, 210, 255))
    
    # Draw a simple "N" letter in the center
    try:
        # Try to use a nice font if available
        font_size = int(size * 0.5)
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Calculate text position to center it
    text = "N"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Draw the text
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    # Save the icon
    img.save(os.path.join(icons_dir, f'icon-{size}x{size}.png'))
    print(f"Created icon-{size}x{size}.png")

print("All icons generated successfully!")

