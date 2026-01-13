"""
Noodle Core::Comprehensive Unicode Fix - comprehensive_unicode_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import re

def fix_unicode_characters(file_path):
    """Fix all Unicode characters in the file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace all Unicode escape sequences with regular characters
    # This handles common emoji and special characters
    replacements = {
        '\\U0001f50d': '[SEARCH]',
        '\\U0001f4be': '[SAVE]',
        '\\U0001f4ca': '[CHART]',
        '\\U0001f3e5': '[BUILDING]',
        '\\U0001f3c6': '[TROPHY]',
        '\\U0001f916': '[ROBOT]',
        '\\U0001f4dd': '[MEMO]',
        '\\u2705': '[OK]',
        '\\u274c': '[X]',
        '\\u2728': '[SPARKLE]',
        '\\ud83d\ude80': '[ROCKET]',
        '\\ud83d\udcdd': '[CLIPBOARD]',
        '\\ud83d\udcca': '[BAR_CHART]',
        '\\ud83c\udfc6': '[TROPHY]',
        '\\ud83e\udd16': '[ROBOT_FACE]',
        '\\ud83d\udcbb': '[LAPTOP]',
        '\\ud83d\udd27': '[WRENCH]',
        '\\ud83d\udca1': '[BULB]',
        '\\ud83d\udee0': '[BUILDING_CONSTRUCTION]',
        '\\ud83d\udcc8': '[CHART_UP]',
        '\\ud83d\udcc9': '[CHART_DOWN]',
        '\\u26a0': '[WARNING]',
        '\\u26a1': '[LIGHTNING]',
        '\\u2139': '[INFO]',
        '\\u2713': '[CHECK]',
        '\\u2717': '[CROSS]',
        '\\u2192': '[ARROW]',
        '\\u2191': '[UP]',
        '\\u2193': '[DOWN]',
        '\\u2b05': '[LEFT]',
        '\\u27a1': '[RIGHT]',
        '\\u21a9': '[RETURN]',
        '\\u21aa': '[FORWARD]',
        '\\u24d8': '[CIRCLE_I]',
        '\\ud83c\udfaf': '[TARGET]',
        '\\ud83d\udcd6': '[BOOK]',
        '\\ud83d\udcda': '[BOOKS]',
        '\\ud83d\udcd8': '[NOTEBOOK]',
        '\\ud83d\udcd7': '[LEDGER]',
        '\\ud83d\udcd9': '[ROLL_PAPER]',
        '\\ud83d\udcd4': '[PAGE_WITH_CURL]',
        '\\ud83d\udcd5': '[PAGE_FACING_UP]',
        '\\ud83d\udcd3': '[CARD_INDEX]',
        '\\ud83d\udccb': '[CLIPBOARD_LIST]',
        '\\ud83d\udcc5': '[CALENDAR]',
        '\\ud83d\udcc6': '[TEAR_OFF_CALENDAR]',
        '\\ud83d\udcc7': '[SPIRAL_NOTEPAD]',
        '\\ud83d\udcc4': '[CARD_FILE_BOX]',
        '\\ud83d\udcc3': '[FILE_CABINET]',
        '\\ud83d\udcc2': '[CARD_INDEX_DIVIDERS]',
        '\\ud83d\udcc1': '[FILE_FOLDER]',
        '\\ud83d\udcc0': '[OPEN_FILE_FOLDER]',
        '\\ud83d\uddc2': '[CARD_INDEX_BOXES]',
        '\\ud83d\uddc3': '[BALLOT_BOX_WITH_BALLOT]',
        '\\ud83d\uddc4': '[POLL_BOX]',
        '\\ud83d\udd16': '[LINK]',
        '\\ud83d\udd17': '[CHAIN]',
        '\\ud83d\udd12': '[LOCK]',
        '\\ud83d\udd13': '[UNLOCK]',
        '\\ud83d\udd11': '[KEY]',
        '\\ud83d\udd10': '[LOCK_WITH_INK_PEN]',
        '\\ud83d\udd0d': '[LEFT_POINTING_MAGNIFYING_GLASS]',
        '\\ud83d\udd0e': '[RIGHT_POINTING_MAGNIFYING_GLASS]',
        '\\ud83d\udd0f': '[LEFT_POINTING_MAGNIFYING_GLASS]',
        '\\ud83d\udd0c': '[BATTERY]',
        '\\ud83d\udd0b': '[ELECTRIC_PLUG]',
        '\\ud83d\udd0a': '[SPEAKER]',
        '\\ud83d\udd09': '[LOUDSPEAKER]',
        '\\ud83d\udd08': '[MEGAPHONE]',
        '\\ud83d\udd07': '[OUTBOX_TRAY]',
        '\\ud83d\udd06': '[INBOX_TRAY]',
        '\\ud83d\udd05': '[PACKAGE]',
        '\\ud83d\udd04': '[E_MAIL]',
        '\\ud83d\udd03': '[INCOMING_ENVELOPE]',
        '\\ud83d\udd02': '[ENVELOPE_WITH_ARROW]',
        '\\ud83d\udd01': '[ENVELOPE_WITH_DOWNWARDS_ARROW_ABOVE]',
        '\\ud83d\udd00': '[INBOX_TRAY]',
        '\\ud83d\udcf1': '[MOBILE_PHONE]',
        '\\ud83d\udcf2': '[MOBILE_PHONE_WITH_ARROW]',
        '\\ud83d\udcf3': '[VIBRATION_MODE]',
        '\\ud83d\udcf4': '[MOBILE_PHONE_OFF]',
        '\\ud83d\udcf5': '[ANTENNA_WITH_BARS]',
        '\\ud83d\udcf6': '[SATELLITE_ANTENNA]',
        '\\ud83d\udcf7': '[CAMERA]',
        '\\ud83d\udcf8': '[CAMERA_WITH_FLASH]',
        '\\ud83d\udcf9': '[VIDEO_CAMERA]',
        '\\ud83d\udcfa': '[TELEVISION]',
        '\\ud83d\udcfb': '[VIDEOCASSETTE]',
        '\\ud83d\udcfc': '[PRINTER]',
        '\\ud83d\udcfd': '[COMPUTER_DISK]',
        '\\ud83d\udcfe': '[FLOPPY_DISK]',
        '\\ud83d\udcff': '[OPTICAL_DISC]',
        '\\ud83d\udce0': '[PUBLIC_ADDRESS_LOUDSPEAKER]',
        '\\ud83d\udce1': '[CHEERING_MEGAPHONE]',
        '\\ud83d\udce2': '[BELL]',
        '\\ud83d\udce3': '[BELL_WITH_SLASH]',
        '\\ud83d\udce4': '[INFORMATION_SOURCE]',
        '\\ud83d\udce5': '[LEFT_RIGHT_ARROW]',
        '\\ud83d\udce6': '[UP_DOWN_ARROW]',
        '\\ud83d\udce7': '[UPWARDS_BLACK_ARROW]',
        '\\ud83d\udce8': '[DOWNWARDS_BLACK_ARROW]',
        '\\ud83d\udce9': '[UPPER_RIGHT_ARROW]',
        '\\ud83d\udcea': '[LOWER_RIGHT_ARROW]',
        '\\ud83d\udceb': '[LOWER_LEFT_ARROW]',
        '\\ud83d\udcec': '[UPPER_LEFT_ARROW]',
        '\\ud83d\udced': '[LEFTWARDS_ARROW_WITH_HOOK]',
        '\\ud83d\udcee': '[RIGHTWARDS_ARROW_WITH_HOOK]',
        '\\ud83d\udcef': '[WATCH]',
        '\\ud83d\udcf0': '[HOURGLASS]',
        '\\ud83d\udce1': '[ALARM_CLOCK]',
        '\\ud83d\udce2': '[STOPWATCH]',
        '\\ud83d\udce3': '[TIMER_CLOCK]',
        '\\ud83d\udce4': '[MANTELPIECE_CLOCK]',
        '\\ud83d\udce5': '[TWELVE_O_CLOCK]',
        '\\ud83d\udce6': '[TWELVE_THIRTY]',
        '\\ud83d\udce7': '[ONE_O_CLOCK]',
        '\\ud83d\udce8': '[ONE_THIRTY]',
        '\\ud83d\udce9': '[TWO_O_CLOCK]',
        '\\ud83d\udcea': '[TWO_THIRTY]',
        '\\ud83d\udceb': '[THREE_O_CLOCK]',
        '\\ud83d\udcec': '[THREE_THIRTY]',
        '\\ud83d\udced': '[FOUR_O_CLOCK]',
        '\\ud83d\udcee': '[FOUR_THIRTY]',
        '\\ud83d\udcef': '[FIVE_O_CLOCK]',
        '\\ud83d\udcf0': '[FIVE_THIRTY]',
        '\\ud83d\udcf1': '[SIX_O_CLOCK]',
        '\\ud83d\udcf2': '[SIX_THIRTY]',
        '\\ud83d\udcf3': '[SEVEN_O_CLOCK]',
        '\\ud83d\udcf4': '[SEVEN_THIRTY]',
        '\\ud83d\udcf5': '[EIGHT_O_CLOCK]',
        '\\ud83d\udcf6': '[EIGHT_THIRTY]',
        '\\ud83d\udcf7': '[NINE_O_CLOCK]',
        '\\ud83d\udcf8': '[NINE_THIRTY]',
        '\\ud83d\udcf9': '[TEN_O_CLOCK]',
        '\\ud83d\udcfa': '[TEN_THIRTY]',
        '\\ud83d\udcfb': '[ELEVEN_O_CLOCK]',
        '\\ud83d\udcfc': '[ELEVEN_THIRTY]',
    }
    
    # Apply all replacements
    for unicode_char, replacement in replacements.items():
        content = content.replace(unicode_char, replacement)
    
    # Also handle any remaining Unicode characters using regex
    # This will replace any \UXXXXXXXX or \uXXXX patterns with [UNICODE]
    content = re.sub(r'\\U[0-9a-fA-F]{8}', '[UNICODE]', content)
    content = re.sub(r'\\u[0-9a-fA-F]{4}', '[UNICODE]', content)
    
    # Also replace any direct Unicode characters (not escape sequences)
    # This is a more aggressive approach to remove all non-ASCII characters
    content = re.sub(r'[^\x00-\x7F]+', '[UNICODE]', content)
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed all Unicode characters in {file_path}")

if __name__ == "__main__":
    fix_unicode_characters("noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py")

