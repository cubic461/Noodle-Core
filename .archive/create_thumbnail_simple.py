"""
Noodle::Create Thumbnail Simple - create_thumbnail_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Thumbnail Creator for NoodleCore LSP Demo Video
Creates professional YouTube thumbnail with basic fonts
"""

import os
import sys


def create_simple_thumbnail(filename="demo_thumbnail.png"):
    """Create thumbnail using basic system fonts"""
    
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("âŒ PIL (Pillow) not found. Please install: pip install Pillow")
        return False
    
    try:
        # Create canvas (YouTube thumbnail: 1280x720)
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
        
        # Title text
        try:
            # Try to use Arial Bold
            title_font = ImageFont.truetype("arialbd.ttf", 70)
        except:
            try:
                # Fallback to regular Arial
                title_font = ImageFont.truetype("arial.ttf", 70)
            except:
                # Final fallback to default
                title_font = ImageFont.load_default()
                title_font.size = (15, 15)  # Small default size
        
        # Main title
        title = "FASTEST LSP SERVER"
        bbox = draw.textbbox((0, 0), title, font=title_font)
        title_w = bbox[2] - bbox[0]
        title_h = bbox[3] - bbox[1]
        
        # Glow effect for title
        for offset in range(8, 0, -2):
            draw.text(((width - title_w) // 2 - offset, height // 3 - offset),
                     title, fill=(67, 160, 71, 30), font=title_font)
        
        # Main title
        draw.text(((width - title_w) // 2, height // 3),
                 title, fill='white', font=title_font)
        
        # Subtitle
        subtitle = "10x Faster Than Python LSP"
        if hasattr(ImageFont, 'truetype'):
            subtitle_font = ImageFont.truetype("arial.ttf", 32)
        else:
            subtitle_font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
        subtitle_w = bbox[2] - bbox[0]
        
        # Background for subtitle
        subtitle_bg = Image.new('RGBA', (subtitle_w + 40, bbox[3] - bbox[1] + 20), (33, 150, 243, 180))
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
            
            if hasattr(ImageFont, 'truetype'):
                badge_font = ImageFont.truetype("arial.ttf", 18)
            else:
                badge_font = ImageFont.load_default()
            
            bbox = badge_draw.textbbox((0, 0), feature, font=badge_font)
            text_w = bbox[2] - bbox[0]
            text_h = bbox[3] - bbox[1]
            
            badge_draw.text(((badge_w - text_w) // 2, (badge_h - text_h) // 2),
                          feature, fill='white', font=badge_font)
            
            img.paste(badge, (x_pos, y_pos), badge)
        
        # Call-to-action
        cta_text = "Try It Now â†’ github.com/noodlecore/lsp-server"
        if hasattr(ImageFont, 'truetype'):
            cta_font = ImageFont.truetype("arial.ttf", 24)
        else:
            cta_font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), cta_text, font=cta_font)
        cta_w = bbox[2] - bbox[0]
        
        # Background for CTA
        cta_bg = Image.new('RGBA', (cta_w + 60, bbox[3] - bbox[1] + 30), (46, 46, 46, 200))
        img.paste(cta_bg, ((width - cta_w - 60) // 2, height - 100), cta_bg)
        
        draw.text(((width - cta_w) // 2, height - 90),
                 cta_text, fill='#4CAF50', font=cta_font)
        
        # Corner accents
        corner_code = "() => { NoodleCore LSP }"
        if hasattr(ImageFont, 'truetype'):
            code_font = ImageFont.truetype("consola.ttf", 16)
        else:
            code_font = ImageFont.load_default()
        
        draw.text((20, 20), "() => {", fill=(255, 255, 255, 100), font=code_font)
        draw.text((width - 150, height - 60), "NoodleCore LSP", fill=(255, 255, 255, 100), font=code_font)
        
        # Save thumbnail
        full_path = os.path.join(os.getcwd(), filename)
        img.save(full_path, "PNG", dpi=(300, 300))
        
        print(f"âœ… Thumbnail created: {filename}")
        print(f"ðŸ“ Saved to: {full_path}")
        print(f"ðŸ“ Size: 1280x720 pixels @ 300 DPI")
        
        return full_path
        
    except Exception as e:
        print(f"âŒ Error creating thumbnail: {e}")
        import traceback
        traceback.print_exc()
        return False


def create_alternative_thumbnail(filename="demo_thumbnail_alt.png"):
    """Create alternative thumbnail design"""
    
    try:
        from PIL import Image, ImageDraw, ImageFont, ImageFilter
    except ImportError:
        print("âŒ PIL (Pillow) not found. Please install: pip install Pillow")
        return False
    
    try:
        width, height = 1280, 720
        img = Image.new('RGB', (width, height), color='#121212')
        draw = ImageDraw.Draw(img)
        
        # Modern background pattern
        for x in range(0, width, 60):
            draw.rectangle([x, 0, x + 30, height], fill='#1a1a1a')
        
        # Center burst effect
        center_x, center_y = width // 2, height // 2
        for radius in range(400, 0, -30):
            intensity = int(180 * (1 - radius / 400))
            
            burst_layer = Image.new('RGBA', (width, height), (0, 0, 0, 0))
            burst_draw = ImageDraw.Draw(burst_layer)
            
            for angle in range(0, 360, 10):
                import math
                x1 = center_x + (radius - 30) * math.cos(math.radians(angle))
                y1 = center_y + (radius - 30) * math.sin(math.radians(angle))
                x2 = center_x + radius * math.cos(math.radians(angle))
                y2 = center_y + radius * math.sin(math.radians(angle))
                burst_draw.line([(x1, y1), (x2, y2)], 
                               fill=(67, 160, 71, intensity), width=3)
            
            img = Image.alpha_composite(img.convert('RGBA'), burst_layer).convert('RGB')
        
        # Title with glow
        title = "âš¡ NoodleCore LSP"
        if hasattr(ImageFont, 'truetype'):
            title_font = ImageFont.truetype("arialbd.ttf", 64)
        else:
            title_font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), title, font=title_font)
        title_w = bbox[2] - bbox[0]
        title_x = (width - title_w) // 2
        title_y = 120
        
        # Glow effect
        glow_layer = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow_layer)
        
        for offset in range(12, 0, -2):
            glow_draw.text((title_x - offset, title_y - offset), title,
                          fill=(255, 152, 0, 40), font=title_font)
        
        img = Image.alpha_composite(img.convert('RGBA'), glow_layer).convert('RGB')
        
        # Main title
        draw.text((title_x, title_y), title, fill='#4CAF50', font=title_font)
        
        # Speed indicator
        speed_text = "10x FASTER AUTO-COMPLETION"
        if hasattr(ImageFont, 'truetype'):
            speed_font = ImageFont.truetype("arialbd.ttf", 36)
        else:
            speed_font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), speed_text, font=speed_font)
        speed_w = bbox[2] - bbox[0]
        
        draw.text(((width - speed_w) // 2, title_y + 80), speed_text, fill='#FF9800', font=speed_font)
        
        # Features in circle pattern
        features = ["Complete", "Navigate", "Refactor", "Optimize", "Debug"]
        feature_angles = [0, 72, 144, 216, 288]  # 5 points on circle
        
        for i, (feature, angle) in enumerate(zip(features, feature_angles)):
            import math
            feature_radius = 150
            
            x = center_x + int(feature_radius * math.cos(math.radians(angle - 90)))
            y = center_y + int(feature_radius * math.sin(math.radians(angle - 90)))
            
            if hasattr(ImageFont, 'truetype'):
                feature_font = ImageFont.truetype("arial.ttf", 20)
            else:
                feature_font = ImageFont.load_default()
            
            bbox = draw.textbbox((0, 0), feature, font=feature_font)
            feature_w = bbox[2] - bbox[0]
            
            # Feature bubble
            bubble = Image.new('RGBA', (feature_w + 40, bbox[3] - bbox[1] + 20), (33, 150, 243, 180))
            bubble_draw = ImageDraw.Draw(bubble)
            bubble_draw.text((20, 10), feature, fill='white', font=feature_font)
            
            img.paste(bubble, (x - feature_w//2 - 20, y - 15), bubble)
        
        # URL
        url_text = "github.com/noodlecore/lsp-server"
        if hasattr(ImageFont, 'truetype'):
            url_font = ImageFont.truetype("arial.ttf", 22)
        else:
            url_font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), url_text, font=url_font)
        url_w = bbox[2] - bbox[0]
        
        draw.text(((width - url_w) // 2, height - 60), url_text, fill='#888', font=url_font)
        
        # Save thumbnail
        full_path = os.path.join(os.getcwd(), filename)
        img.save(full_path, "PNG", dpi=(300, 300))
        
        print(f"âœ… Alternative thumbnail created: {filename}")
        print(f"ðŸ“ Saved to: {full_path}")
        print(f"ðŸ“ Size: 1280x720 pixels @ 300 DPI")
        
        return full_path
        
    except Exception as e:
        print(f"âŒ Error creating alternative thumbnail: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("ðŸŽ¬ Creating NoodleCore LSP Server Demo Video Thumbnails")
    print("=" * 60)
    
    # Create main thumbnail
    print("\n1ï¸âƒ£ Creating main thumbnail...")
    main_thumbnail = create_simple_thumbnail("demo_thumbnail_v1.png")
    
    print("\n2ï¸âƒ£ Creating alternative thumbnail...")
    alt_thumbnail = create_alternative_thumbnail("demo_thumbnail_v2.png")
    
    print("\n" + "=" * 60)
    print("âœ¨ Thumbnail Creation Complete!")
    
    if main_thumbnail and alt_thumbnail:
        print("\nðŸ“‹ Created Files:")
        print(f"  ðŸ“¸ {main_thumbnail}")
        print(f"  ðŸ“¸ {alt_thumbnail}")
        
        print("\nðŸ’¡ Usage Recommendations:")
        print("  â€¢ Use v1 for professional, clean look")
        print("  â€¢ Use v2 for modern, tech-focused look")
        print("  â€¢ Both are optimized for YouTube thumbnails")
        print("  â€¢ Both include AI integration messaging")
        
        print("\nðŸŽ¯ Next Steps:")
        print("  1. Review the thumbnails")
        print("  2. Choose your preferred design")
        print("  3. Use for video upload")
        print("  4. Test on different devices")
    else:
        print("\nâš ï¸  There were issues creating the thumbnails.")
        print("   Please check the error messages above.")


