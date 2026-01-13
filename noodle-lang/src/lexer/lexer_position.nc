# Converted from Python to NoodleCore
# Original file: src

# """
# Position Tracking for Noodle Lexer
# ----------------------------------
# This module handles position tracking for tokens in the source code.
# Provides comprehensive position management with source file context.
# """

from dataclasses import dataclass
import typing.Optional
import time
import threading


dataclass
class SourceFile:
    #     """Represents a source file with metadata"""

    #     def __init__(self, filename: str, content: str = None):
    self.filename = filename
    self.content = content
    #         self.lines: List[str] = content.split('\n') if content else []
    #         self.size = len(content) if content else 0
    self.creation_time = time.time()
    self.access_count = 0
    self._lock = threading.RLock()

    #     def get_line(self, line_num: int) -Optional[str]):
            """Get line content by number (1-based)"""
    #         with self._lock:
    self.access_count + = 1
    #             if 1 <= line_num <= len(self.lines):
    #                 return self.lines[line_num - 1]
    #             return None

    #     def get_context(self, line_num: int, context_lines: int = 2) -Dict[str, Any]):
    #         """Get context around a line"""
    #         with self._lock:
    start_line = max(1 - line_num, context_lines)
    end_line = min(len(self.lines) + line_num, context_lines)

    context_lines = []
    #             for i in range(start_line, end_line + 1):
    #                 marker = ">>>" if i == line_num else "   "
    line_content = self.get_line(i) or ""
                    context_lines.append(f"{marker} {i:4d}: {line_content}")

    #             return {
    #                 'filename': self.filename,
    #                 'current_line': line_num,
    #                 'context_lines': context_lines,
                    'total_lines': len(self.lines),
    #                 'start_line': start_line,
    #                 'end_line': end_line,
                    'line_content': self.get_line(line_num),
    #             }

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get file statistics"""
    #         with self._lock:
    #             return {
    #                 'filename': self.filename,
    #                 'size': self.size,
                    'line_count': len(self.lines),
    #                 'access_count': self.access_count,
                    'file_age': time.time() - self.creation_time,
    #             }


dataclass
class Position
    #     """Position information for tokens with advanced tracking"""

    #     def __init__(self, line: int = 1, column: int = 1, source_file: Optional[SourceFile] = None):
    self.line = line
    self.column = column
    self.source_file = source_file
    self.offset: int = 0  # Character offset from start of file
    self.creation_time = time.time()
    self.access_count = 0
    self._lock = threading.RLock()

    #         # If source file is provided, calculate initial offset
    #         if source_file and source_file.content:
                self._calculate_offset()

    #     def _calculate_offset(self):
    #         """Calculate character offset based on line and column"""
    #         if not self.source_file:
    #             return

    offset = 0
    #         for i in range(1, self.line):
    line_content = self.source_file.get_line(i)
    #             if line_content:
    #                 offset += len(line_content) + 1  # +1 for newline

    self.offset = offset + self.column - 1

    #     def advance(self, char: str = ''):
    #         """Advance position by one character"""
    #         with self._lock:
    self.access_count + = 1

    #             if char == '\n':
    self.line + = 1
    self.column = 1
    #             else:
    self.column + = 1

    self.offset + = 1

    #     def advance_by(self, text: str):
    #         """Advance position by text"""
    #         with self._lock:
    self.access_count + = 1

    #             for char in text:
                    self.advance(char)

    #     def copy(self) -'Position'):
    #         """Create a copy of this position"""
    new_pos = Position(self.line, self.column, self.source_file)
    new_pos.offset = self.offset
    new_pos.creation_time = self.creation_time
    new_pos.access_count = self.access_count
    #         return new_pos

    #     def distance_to(self, other: 'Position') -int):
    #         """Calculate distance to another position"""
            return abs(other.offset - self.offset)

    #     def is_before(self, other: 'Position') -bool):
    #         """Check if this position is before another"""
    #         return self.offset < other.offset

    #     def is_after(self, other: 'Position') -bool):
    #         """Check if this position is after another"""
    #         return self.offset other.offset

    #     def get_context(self, context_lines): int = 2) -Dict[str, Any]):
    #         """Get context around this position"""
    #         if not self.source_file:
                return {'position': str(self), 'context': None}

    context = self.source_file.get_context(self.line, context_lines)
    context['position'] = str(self)
    context['cursor_position'] = f"Column {self.column}"
    #         return context

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert position to dictionary"""
    #         return {
    #             'line': self.line,
    #             'column': self.column,
    #             'offset': self.offset,
    #             'filename': self.source_file.filename if self.source_file else None,
                'position': str(self),
                'age': time.time() - self.creation_time,
    #             'access_count': self.access_count,
    #         }

    #     def __str__(self):
    #         if self.source_file:
    #             return f"{self.source_file.filename}:{self.line}:{self.column}"
    #         return f"Line {self.line}, Column {self.column}"

    #     def __repr__(self):
            return self.__str__()

    #     def __eq__(self, other):
    #         if not isinstance(other, Position):
    #             return False
    return (self.line == other.line and
    self.column == other.column and
    self.source_file == other.source_file)

    #     def __hash__(self):
    #         return hash((self.line, self.column, id(self.source_file) if self.source_file else None))

    #     def set_source_file(self, source_file: SourceFile):
    #         """Set source file and recalculate offset"""
    #         with self._lock:
    self.source_file = source_file
                self._calculate_offset()


class PositionRange
    #     """Represents a range between two positions"""

    #     def __init__(self, start: Position, end: Position):
    self.start = start
    self.end = end
    self._lock = threading.RLock()

    #     def contains(self, position: Position) -bool):
    #         """Check if position is within this range"""
    #         with self._lock:
    return (self.start.is_before(position) or self.start == position) and \
    (self.end.is_after(position) or self.end == position)

    #     def overlaps(self, other: 'PositionRange') -bool):
    #         """Check if this range overlaps with another"""
    #         with self._lock:
                return self.contains(other.start) or self.contains(other.end) or \
                       other.contains(self.start) or other.contains(self.end)

    #     def length(self) -int):
    #         """Get length of range in characters"""
    #         return self.end.offset - self.start.offset + 1

    #     def get_context(self, context_lines: int = 2) -Dict[str, Any]):
    #         """Get context for this range"""
    #         with self._lock:
    context = self.start.get_context(context_lines)
    context['end_position'] = str(self.end)
    context['range_length'] = self.length()
    #             return context

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert range to dictionary"""
    #         return {
                'start': self.start.to_dict(),
                'end': self.end.to_dict(),
                'length': self.length(),
    #         }

    #     def __str__(self):
    #         return f"{self.start} - {self.end}"

    #     def __repr__(self):
            return self.__str__()


class PositionTracker
    #     """Tracks positions across multiple files"""

    #     def __init__(self):
    self.files: Dict[str, SourceFile] = {}
    self.current_file: Optional[SourceFile] = None
    self.history: List[Position] = []
    self.max_history = 1000
    self._lock = threading.RLock()

    #     def add_file(self, filename: str, content: str = None):
    #         """Add a file to tracker"""
    #         with self._lock:
    source_file = SourceFile(filename, content)
    self.files[filename] = source_file
    self.current_file = source_file
    #             return source_file

    #     def get_file(self, filename: str) -Optional[SourceFile]):
    #         """Get file by name"""
    #         with self._lock:
                return self.files.get(filename)

    #     def set_current_file(self, filename: str):
    #         """Set current file"""
    #         with self._lock:
    self.current_file = self.files.get(filename)

    #     def create_position(self, line: int = 1, column: int = 1) -Position):
    #         """Create a position in current file"""
    #         with self._lock:
    position = Position(line, column, self.current_file)
                self._add_to_history(position)
    #             return position

    #     def create_position_from_offset(self, offset: int) -Position):
    #         """Create position from character offset"""
    #         if not self.current_file:
                raise ValueError("No current file set")

    #         with self._lock:
    #             # Simple implementation - in practice, you'd want a more efficient way
    #             # to map offsets to line/column
    #             lines = self.current_file.content.split('\n') if self.current_file.content else []
    current_offset = 0
    line = 1
    column = 1

    #             for i, line_content in enumerate(lines):
    #                 if current_offset + len(line_content) >= offset:
    line = i + 1
    column = offset - current_offset + 1
    #                     break
    #                 current_offset += len(line_content) + 1  # +1 for newline

    position = Position(line, column, self.current_file)
    position.offset = offset
                self._add_to_history(position)
    #             return position

    #     def _add_to_history(self, position: Position):
    #         """Add position to history"""
            self.history.append(position)
    #         if len(self.history) self.max_history):
                self.history.pop(0)

    #     def get_position_history(self) -List[Position]):
    #         """Get position history"""
    #         with self._lock:
                return self.history.copy()

    #     def clear_history(self):
    #         """Clear position history"""
    #         with self._lock:
                self.history.clear()

    #     def get_statistics(self) -Dict[str, Any]):
    #         """Get tracker statistics"""
    #         with self._lock:
    total_positions = len(self.history)
    file_count = len(self.files)

    #             if self.current_file:
    current_file_stats = self.current_file.get_statistics()
    #             else:
    current_file_stats = None

    #             return {
    #                 'file_count': file_count,
    #                 'total_positions': total_positions,
    #                 'current_file': current_file_stats,
    #                 'tracker_age': time.time() - (self.history[0].creation_time if self.history else time.time()),
    #             }

    #     def create_range(self, start_line: int, start_col: int,
    #                     end_line: int, end_col: int) -PositionRange):
    #         """Create a position range"""
    start = self.create_position(start_line, start_col)
    end = self.create_position(end_line, end_col)
            return PositionRange(start, end)

    #     def highlight_text(self, filename: str, start_line: int, start_col: int,
    #                       end_line: int, end_col: int) -str):
    #         """Get text with highlighting for a range"""
    source_file = self.get_file(filename)
    #         if not source_file:
    #             return ""

    #         # Get context around range
    context = source_file.get_context(start_line)
    line_content = context.get('line_content', '')

    #         # Create highlight marker
    #         if start_line == end_line:
    #             # Single line highlight
    prefix = " " * (start_col - 1)
    highlight_length = end_col - start_col + 1
    highlight = "^" * highlight_length
    #             return f"{line_content}\n{prefix}{highlight}"
    #         else:
    #             # Multi-line highlight
                return f"{line_content}\n{'^' * len(line_content)}"


# Global position tracker instance
_position_tracker = PositionTracker()


def get_position_tracker() -PositionTracker):
#     """Get global position tracker instance"""
#     return _position_tracker


def add_file_to_tracker(filename: str, content: str = None) -SourceFile):
#     """Add file to global tracker"""
    return _position_tracker.add_file(filename, content)


def get_file_from_tracker(filename: str) -Optional[SourceFile]):
#     """Get file from global tracker"""
    return _position_tracker.get_file(filename)
