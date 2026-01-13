"""
Noodle::Create Thumbnail Fixed - create_thumbnail_fixed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Thumbnail Creator - Working version
"""

import os


def create_thumbnail(filename="demo_thumbnail.png"):
    """Create YouTube thumbnail with basic fonts"""
    
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("PIL (Pillow) not found. Please install: pip install Pillow")
        return False
    
    try:
        # Create canvas (1280x720 pixels)
        width, height = 1280, 720
        img = Image.new('RGB', (width, height), color='#1e1e1e')
        draw = ImageDraw.Draw(img)
        
        # Brand colors
        primary_color = '#4CAF50'  # Green
        accent_color = '#2196F3'   # Blue
        
        # Background gradient
        for y in range(height):
            ratio = y / height
            r = int(30 + ratio * 42)
            g = int(30 + ratio * 42)
            b = int(30 + ratio * 42)
            draw.line([(0, y), (width, y)], fill=(r, g, b))
        
        # Accent circle
        circle_size = 400
        for i in range(circle_size, 0, -10):
            alpha = int(120 * (i / circle_size))
            ellipse_box = [width - i - 100, -i//2, width + i//2 - 100, i + 100]
            draw.ellipse(ellipse_box, fill=(67, 160, 71, alpha))
        
        # Title text with font fallback
        try:
            title_font = ImageFont.truetype("arialbd.ttf", 70)
        except:
            try:
                title_font = ImageFont.truetype("arial.ttf", 70)
            except:
                title_font = ImageFont.load_default()
        
        # Main title
        title = "FASTEST LSP SERVER"
        bbox = draw.textbbox((0, 0), title, font=title_font)
        title_w = bbox[2] - bbox[0]
        title_h = bbox[3] - bbox[1]
        
        # Title with glow
        for offset in range(8, 0, -2):
            draw.text(((width - title_w) // 2 - offset, height // 3 - offset),
                     title, fill=(67, 160, 71, 30), font=title_font)
        
        draw.text(((width - title_w) // 2, height // 3),
                 title, fill='white', font=title_font)
        
        # Subtitle
        subtitle = "10x Faster Than Python LSP"
        try:
            subtitle_font = ImageFont.truetype("arial.ttf", 32)
        except:
            subtitle_font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
        subtitle_w = bbox[2] - bbox[0]
        subtitle_h = bbox[3] - bbox[1]
        
        # Background for subtitle
        subtitle_bg = Image.new('RGBA', (subtitle_w + 40, subtitle_h + 20), (33, 150, 243, 180))
        img.paste(subtitle_bg, ((width - subtitle_w - 40) // 2, height // 3 + title_h + 30), subtitle_bg)
        
        draw.text(((width - subtitle_w) // 2, height // 3 + title_h + 40),
                 subtitle, fill='white', font=subtitle_font)
        
        # Feature badges
        features = [
            ("AI-Powered", (67, 160, 71)),
            ("Real-Time", (33, 150, 243)),
            ("Lightning Fast", (255, 152, 0)),
            ("Smart Completion", (156, 39, 176))
        ]
        
        y_pos = height // 2 + 30
        x_spacing = 230
        
        for i, (feature, color) in enumerate(features):
            x_pos = 100 + (i * x_spacing)
            
            badge_w, badge_h = 200, 50
            badge = Image.new('RGBA', (badge_w, badge_h), color)
            badge_draw = ImageDraw.Draw(badge)
            
            try:
                badge_font = ImageFont.truetype("arial.ttf", 18)
            except:
                badge_font = ImageFont.load_default()
            
            bbox = badge_draw.textbbox((0, 0), feature, font=badge_font)
            text_w = bbox[2] - bbox[0]
            text_h = bbox[3] - bbox[1]
            
            badge_draw.text(((badge_w - text_w) // 2, (badge_h - text_h) // 2),
                          feature, fill='white', font=badge_font)
            
            img.paste(badge, (x_pos, y_pos), badge)
        
        # Save thumbnail
        full_path = os.path.join(os.getcwd(), filename)
        img.save(full_path, "PNG", dpi=(300, 300))
        
        print(f"Thumbnail created: {filename}")
        print(f"Saved to: {full_path}")
        
        return full_path
        
    except Exception as e:
        print(f"Error creating thumbnail: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("Creating thumbnail...")
    result = create_thumbnail("noodlecore_thumbnail.png")
    if result:
        print("Success!")
    else:
        print("Failed!")


