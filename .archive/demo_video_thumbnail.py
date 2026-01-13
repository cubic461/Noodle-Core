"""
Noodle::Demo Video Thumbnail - demo_video_thumbnail.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Demo Video Thumbnail Creation Script
Creates a professional YouTube thumbnail for the NoodleCore LSP Server demo video
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import requests
import textwrap


def create_thumbnail():
    """Create professional YouTube thumbnail"""
    
    # Create blank canvas (YouTube thumbnail size: 1280x720)
    width, height = 1280, 720
    thumbnail = Image.new('RGB', (width, height), color='#1e1e1e')
    draw = ImageDraw.Draw(thumbnail)
    
    # Define colors
    primary_color = '#4CAF50'  # NoodleCore green
    accent_color = '#2196F3'   # Blue accent
    text_color = '#FFFFFF'
    bg_gradient = ['#1e1e1e', '#2a2a2a']
    
    # Create gradient background
    for i in range(height):
        ratio = i / height
        r = int((1 - ratio) * int(bg_gradient[0][1:3], 16) + ratio * int(bg_gradient[1][1:3], 16))
        g = int((1 - ratio) * int(bg_gradient[0][3:5], 16) + ratio * int(bg_gradient[1][3:5], 16))
        b = int((1 - ratio) * int(bg_gradient[0][5:7], 16) + ratio * int(bg_gradient[1][5:7], 16))
        draw.line([(0, i), (width, i)], fill=(r, g, b))
    
    # Add geometric elements
    # Circle accent in top right
    accent_circle = Image.new('RGBA', (400, 400), (0, 0, 0, 0))
    circle_draw = ImageDraw.Draw(accent_circle)
    circle_draw.ellipse([0, 0, 400, 400], fill=(67, 160, 71, 80))  # Semi-transparent green
    
    accent_circle = accent_circle.filter(ImageFilter.GaussianBlur(20))
    thumbnail.paste(accent_circle, (width - 300, -100), accent_circle)
    
    # Logo placeholder (using text for now)
    logo_font = ImageFont.truetype("arial.ttf", 60)
    logo_text = "NoodleCore LSP"
    bbox = draw.textbbox((0, 0), logo_text, font=logo_font)
    logo_width = bbox[2] - bbox[0]
    logo_height = bbox[3] - bbox[1]
    
    draw.text(((width - logo_width) // 2, 50), logo_text, fill=primary_color, font=logo_font)
    
    # Main headline
    headline = "FASTEST LSP SERVER"
    headline_font = ImageFont.truetype("arialbd.ttf", 72)
    bbox = draw.textbbox((0, 0), headline, font=headline_font)
    headline_width = bbox[2] - bbox[0]
    headline_height = bbox[3] - bbox[1]
    
    # Position at 1/3 of screen
    draw.text(((width - headline_width) // 2, height // 3), headline, fill=text_color, font=headline_font)
    
    # Subtitle with key benefit
    subtitle = "âš¡ 10x Faster Than Python LSP"
    subtitle_font = ImageFont.truetype("arial.ttf", 36)
    bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = bbox[2] - bbox[0]
    subtitle_height = bbox[3] - bbox[1]
    
    draw.text(((width - subtitle_width) // 2, height // 3 + headline_height + 20), 
              subtitle, fill=accent_color, font=subtitle_font)
    
    # Feature badges
    features = [
        ("AI Integration", primary_color),
        ("Real-Time", accent_color),
        ("âš¡ Fast", "#FFC107"),
        ("Smart", "#E91E63")
    ]
    
    badge_start_y = height // 2 + 60
    badge_spacing = 250
    
    for i, (feature, color) in enumerate(features):
        x_pos = 150 + (i * badge_spacing)
        if x_pos + 200 > width:
            x_pos = (width - 200) // 2
        
        # Badge background
        badge_width, badge_height = 180, 60
        badge = Image.new('RGBA', (badge_width, badge_height), color)
        badge_draw = ImageDraw.Draw(badge)
        
        feature_font = ImageFont.truetype("arial.ttf", 20)
        bbox = badge_draw.textbbox((0, 0), feature, font=feature_font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        badge_draw.text(((badge_width - text_width) // 2, (badge_height - text_height) // 2), 
                        feature, fill='white', font=feature_font)
        
        thumbnail.paste(badge, (x_pos, badge_start_y), badge)
    
    # Call-to-action at bottom
    cta_font = ImageFont.truetype("arialbd.ttf", 28)
    cta_text = "Try It Now â†’ github.com/noodlecore/lsp-server"
    bbox = draw.textbbox((0, 0), cta_text, font=cta_font)
    cta_width = bbox[2] - bbox[0]
    
    draw.text(((width - cta_width) // 2, height - 80), cta_text, fill=text_color, font=cta_font)
    
    # Add decorative code braces in corners
    code_font = ImageFont.truetype("consola.ttf", 24)
    draw.text((30, 30), "() => {", fill=(255, 255, 255, 128), font=code_font)
    draw.text((width - 100, height - 60), "}", fill=(255, 255, 255, 128), font=code_font)
    
    return thumbnail


def create_alternative_thumbnail():
    """Create alternative thumbnail design"""
    
    width, height = 1280, 720
    thumbnail = Image.new('RGB', (width, height), color='#121212')
    draw = ImageDraw.Draw(thumbnail)
    
    # Main background with subtle pattern
    for i in range(0, width, 40):
        draw.rectangle([i, 0, i + 20, height], fill='#1a1a1a')
    
    # Center circle burst
    center = (width // 2, height // 2)
    for radius in range(300, 0, -20):
        circle = Image.new('RGBA', (radius * 2, radius * 2), (0, 0, 0, 0))
        circle_draw = ImageDraw.Draw(circle)
        gradient = int(255 * (1 - radius / 300))
        circle_draw.ellipse([0, 0, radius * 2, radius * 2], 
                           fill=(67, 160, 71, gradient // 2))
        thumbnail.paste(circle, (center[0] - radius, center[1] - radius), circle)
    
    # Radial lines
    for angle in range(0, 360, 15):
        import math
        x = center[0] + 250 * math.cos(math.radians(angle))
        y = center[1] + 250 * math.sin(math.radians(angle))
        draw.line([center, (x, y)], fill=(67, 160, 71, 100), width=3)
    
    # Main title
    title = "âš¡ NoodleCore LSP"
    title_font = ImageFont.truetype("arialbd.ttf", 64)
    bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = bbox[2] - bbox[0]
    
    draw.text(((width - title_width) // 2, 100), title, fill='white', font=title_font)
    
    # Speed descriptor
    speed_font = ImageFont.truetype("arial.ttf", 36)
    speed_text = "10x Faster Language Server"
    bbox = draw.textbbox((0, 0), speed_text, font=speed_font)
    speed_width = bbox[2] - bbox[0]
    
    draw.text(((width - speed_width) // 2, 180), speed_text, fill='#4CAF50', font=speed_font)
    
    # Features in center
    features = [
        "Auto-completion",
        "Go-to-definition", 
        "Real-time diagnostics",
        "AI-powered suggestions",
        "Pattern matching"
    ]
    
    features_font = ImageFont.truetype("arial.ttf", 24)
    features_y = 300
    
    for feature in features:
        bbox = draw.textbbox((0, 0), feature, font=features_font)
        feature_width = bbox[2] - bbox[0]
        draw.text(((width - feature_width) // 2, features_y), 
                  "âœ“ " + feature, fill='white', font=features_font)
        features_y += 50
    
    # URL at bottom
    url_font = ImageFont.truetype("arial.ttf", 20)
    url_text = "github.com/noodlecore/lsp-server"
    bbox = draw.textbbox((0, 0), url_text, font=url_font)
    url_width = bbox[2] - bbox[0]
    
    draw.text(((width - url_width) // 2, height - 60), url_text, fill='#BBB', font=url_font)
    
    return thumbnail


def add_thumbnail_elements(base_thumbnail, elements):
    """Add specific elements to thumbnail"""
    
    width, height = base_thumbnail.size
    draw = ImageDraw.Draw(base_thumbnail)
    
    if 'arrow' in elements:
        # Add directional arrow
        arrow_points = [
            (width - 150, height // 2),
            (width - 100, height // 2 - 25),
            (width - 100, height // 2 - 10),
            (width - 50, height // 2 - 10),
            (width - 50, height // 2 + 10),
            (width - 100, height // 2 + 10),
            (width - 100, height // 2 + 25),
        ]
        draw.polygon(arrow_points, fill='#4CAF50')
    
    if 'glow' in elements:
        # Add glow effect around title
        glow_layer = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow_layer)
        
        title_font = ImageFont.truetype("arialbd.ttf", 64)
        title = "NoodleCore LSP"
        bbox = draw.textbbox((0, 0), title, font=title_font)
        title_width = bbox[2] - bbox[0]
        title_x = (width - title_width) // 2
        title_y = 100
        
        for offset in range(15, 0, -1):
            glow_draw.text((title_x - offset, title_y - offset), title, 
                          fill=(67, 160, 71, 10), font=title_font)
            glow_draw.text((title_x + offset, title_y + offset), title, 
                          fill=(67, 160, 71, 10), font=title_font)
        
        base_thumbnail = Image.alpha_composite(base_thumbnail.convert('RGBA'), glow_layer)
    
    return base_thumbnail


# Usage instructions
if __name__ == "__main__":
    print("Creating thumbnails for NoodleCore LSP Server demo video...")
    
    try:
        # Create main thumbnail
        thumbnail1 = create_thumbnail()
        thumbnail1.save("demo_thumbnail_v1.png", "PNG", dpi=(300, 300))
        print("âœ“ Created demo_thumbnail_v1.png")
        
        # Create alternative thumbnail
        thumbnail2 = create_alternative_thumbnail()
        thumbnail2.save("demo_thumbnail_v2.png", "PNG", dpi=(300, 300))
        print("âœ“ Created demo_thumbnail_v2.png")
        
        print("\nThumbnail Specifications:")
        print("- Size: 1280x720 pixels (YouTube recommended)")
        print("- Format: PNG with 300 DPI")
        print("- Colors: NoodleCore brand colors (green/blue)")
        print("- Features: Professional design with clear call-to-action")
        print("\nUse thumbnail_v2.png for a more modern, tech-focused look")
        print("Use thumbnail_v1.png for a cleaner, more traditional approach")
        
    except Exception as e:
        print(f"Error creating thumbnails: {e}")
        print("Note: This script requires PIL (Pillow) library")
        print("Install with: pip install Pillow")


