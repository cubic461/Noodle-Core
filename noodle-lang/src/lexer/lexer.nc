# Noodle Language Lexer - Unified Implementation
# ----------------------------------------------

# Lexer voor Noodle taal met geavanceerde token processing
# Implementeert consistente syntax notatie en foutafhandeling

import re
import enum.Enum
import typing.Any
import typing.Optional
import typing.List
import typing.Dict
import typing.Callable
import logging
import time
import dataclasses

logger = logging.getLogger(__name__)

class TokenType(Enum)
    """Token types voor Noodle taal"""
    
    # Literals
    IDENTIFIER = "IDENTIFIER"
    NUMBER = "NUMBER"
    STRING = "STRING"
    BOOLEAN = "BOOLEAN"
    NULL = "NULL"
    
    # Operators
    PLUS = "PLUS"
    MINUS = "MINUS"
    MULTIPLY = "MULTIPLY"
    DIVIDE = "DIVIDE"
    MODULO = "MODULO"
    POWER = "POWER"
    
    # Comparison
    EQUAL = "EQUAL"
    NOT_EQUAL = "NOT_EQUAL"
    LESS_THAN = "LESS_THAN"
    LESS_EQUAL = "LESS_EQUAL"
    GREATER_THAN = "GREATER_THAN"
    GREATER_EQUAL = "GREATER_EQUAL"
    
    # Logical
    AND = "AND"
    OR = "OR"
    NOT = "NOT"
    
    # Assignment
    ASSIGN = "ASSIGN"
    
    # Delimiters
    COMMA = "COMMA"
    SEMICOLON = "SEMICOLON"
    COLON = "COLON"
    DOT = "DOT"
    
    # Brackets
    LEFT_PAREN = "LEFT_PAREN"
    RIGHT_PAREN = "RIGHT_PAREN"
    LEFT_BRACE = "LEFT_BRACE"
    RIGHT_BRACE = "RIGHT_BRACE"
    LEFT_BRACKET = "LEFT_BRACKET"
    RIGHT_BRACKET = "RIGHT_BRACKET"
    
    # Keywords
    IF = "IF"
    ELSE = "ELSE"
    ELIF = "ELIF"
    WHILE = "WHILE"
    FOR = "FOR"
    FUNCTION = "FUNCTION"
    RETURN = "RETURN"
    BREAK = "BREAK"
    CONTINUE = "CONTINUE"
    IMPORT = "IMPORT"
    CLASS = "CLASS"
    EXTENDS = "EXTENDS"
    
    # Special
    NEWLINE = "NEWLINE"
    INDENT = "INDENT"
    DEDENT = "DEDENT"
    EOF = "EOF"
    UNKNOWN = "UNKNOWN"

@dataclasses.dataclass
class Token
    """Token representatie voor Noodle taal"""
    
    type: TokenType
    value: str
    line: int
    column: int
    position: Optional["Position"] = None
    
    def __str__(self) -> str:
        return f"Token({self.type.value}, '{self.value}', {self.line}:{self.column})"

@dataclasses.dataclass
class Position
    """Positie informatie voor foutmeldingen"""
    
    line: int
    column: int
    filename: str = "<string>"
    
    def __str__(self) -> str:
        return f"{self.filename}:{self.line}:{self.column}"

class LexerError(Exception):
    """Lexer fout met context informatie"""
    
    def __init__(self, message: str, position: Optional[Position] = None):
        self.message = message
        self.position = position
        super().__init__(f"Lexer Error: {message}")
    
    def __str__(self) -> str:
        if self.position:
            return f"Lexer Error at {self.position}: {self.message}"
        return f"Lexer Error: {self.message}"

class Lexer
    """Unified lexer voor Noodle taal"""
    
    def __init__(self, source_code: str, filename: str = "<string>"):
        self.source_code = source_code
        self.filename = filename
        self.position = Position(line=1, column=1, filename=filename)
        self.tokens: List[Token] = []
        self.errors: List[LexerError] = []
        self.keywords = {
            "if", "else", "elif", "while", "for", "function", 
            "return", "break", "continue", "import", "class", "extends"
        }
        
        # Precompile regex patterns voor performance
        self.patterns = {
            'identifier': re.compile(r'[a-zA-Z_][a-zA-Z0-9_]*'),
            'number': re.compile(r'\d+(\.\d+)?'),
            'string': re.compile(r'"([^"\\]|\\.)*"'),
            'boolean': re.compile(r'(true|false)'),
            'operator': re.compile(r'[\+\-\*/%=!<>=]'),
            'assignment': re.compile(r'='),
            'delimiter': re.compile(r'[,\;:\.\(\)\{\}\[\]]'),
            'whitespace': re.compile(r'\s+'),
            'newline': re.compile(r'\n'),
        }
        
        self.start_time = time.time()
    
    def tokenize(self) -> List[Token]:
        """Converteer source code naar token lijst"""
        start_time = time.time()
        
        try:
            while not self._is_at_end():
                self._skip_whitespace_and_comments()
                
                if self._is_at_end():
                    break
                    
                # Check voor multi-character tokens
                char = self._current_char()
                
                # Numbers
                if char.isdigit() or (char == '.' and self._peek_next_char() and self._peek_next_char().isdigit()):
                    self._tokenize_number()
                
                # Strings
                elif char == '"':
                    self._tokenize_string()
                
                # Identifiers en keywords
                elif char.isalpha() or char == '_':
                    self._tokenize_identifier_or_keyword()
                
                # Operators
                elif char in '+-*/%=!<>=;:,.(){}[]':
                    self._tokenize_operator_or_delimiter()
                
                # Onbekend character
                else:
                    self._add_error(f"Unexpected character: '{char}'")
                    self._advance_position()
        
        except Exception as e:
            logger.error(f"Tokenization failed: {e}")
            self._add_error(f"Tokenization error: {str(e)}")
        
        # Voeg EOF token toe
        self._add_token(TokenType.EOF, "")
        
        tokenize_time = time.time() - start_time
        logger.info(f"Tokenized {len(self.tokens)} tokens in {tokenize_time:.3f}s")
        
        return self.tokens
    
    def _is_at_end(self) -> bool:
        """Check of we aan het einde van de source zijn"""
        return self.position.line > len(self.source_code.split('\n')) or \
               self.position.column > len(self.source_code.split('\n')[-1]) if self.source_code.split('\n') else 0
    
    def _current_char(self) -> str:
        """Krijg huidig character"""
        lines = self.source_code.split('\n')
        if self.position.line <= len(lines):
            line = lines[self.position.line - 1]
            if self.position.column <= len(line):
                return line[self.position.column - 1]
        return ''
    
    def _peek_next_char(self) -> str:
        """Kijk naar volgend character zonder te bewegen"""
        lines = self.source_code.split('\n')
        if self.position.line <= len(lines):
            line = lines[self.position.line - 1]
            next_col = self.position.column
            if next_col < len(line):
                return line[next_col]
        return ''
    
    def _advance_position(self, steps: int = 1):
        """Beweg positie vooruit"""
        self.position.column += steps
        
        # Handle nieuwe regels
        lines = self.source_code.split('\n')
        current_line_length = len(lines[self.position.line - 1]) if self.position.line <= len(lines) else 0
        if self.position.column > current_line_length:
            self.position.line += 1
            self.position.column = 1
    
    def _skip_whitespace_and_comments(self):
        """Sla witruimte en comments over"""
        while not self._is_at_end():
            char = self._current_char()
            
            # Witruimte
            if char.isspace():
                self._advance_position()
                continue
            
            # Single line comments
            if char == '#':
                self._advance_position()
                while not self._is_at_end() and self._current_char() != '\n':
                    self._advance_position()
                continue
            
            # Multi-line comments
            if char == '/' and self._peek_next_char() == '*':
                self._advance_position(2)  # Skip '/*'
                while not self._is_at_end():
                    if self._current_char() == '*' and self._peek_next_char() == '/':
                        self._advance_position(2)  # Skip '*/'
                        break
                    self._advance_position()
                continue
            
            break
    
    def _tokenize_number(self):
        """Tokenize getallen"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        number_str = ''
        
        while not self._is_at_end():
            char = self._current_char()
            if char.isdigit() or (char == '.' and self._peek_next_char() and self._peek_next_char().isdigit()):
                number_str += char
                self._advance_position()
            else:
                break
        
        if '.' in number_str:
            token_type = TokenType.NUMBER
        else:
            token_type = TokenType.NUMBER
        
        self._add_token(token_type, number_str, start_pos)
    
    def _tokenize_string(self):
        """Tokenize strings"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        self._advance_position()  # Skip opening quote
        
        string_value = ''
        while not self._is_at_end() and self._current_char() != '"':
            char = self._current_char()
            
            # Escape sequences
            if char == '\\':
                self._advance_position()
                if not self._is_at_end():
                    escaped_char = self._current_char()
                    string_value += '\\' + escaped_char
                    self._advance_position()
                continue
            
            string_value += char
            self._advance_position()
        
        self._add_token(TokenType.STRING, string_value, start_pos)
    
    def _tokenize_identifier_or_keyword(self):
        """Tokenize identifiers of keywords"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        identifier = ''
        
        while not self._is_at_end():
            char = self._current_char()
            if char.isalnum() or char == '_':
                identifier += char
                self._advance_position()
            else:
                break
        
        # Check of het een keyword is
        token_type = TokenType.KEYWORD if identifier in self.keywords else TokenType.IDENTIFIER
        self._add_token(token_type, identifier, start_pos)
    
    def _tokenize_operator_or_delimiter(self):
        """Tokenize operators en delimiters"""
        start_pos = Position(line=self.position.line, column=self.position.column, filename=self.filename)
        char = self._current_char()
        
        # Multi-character operators
        if char in ['=', ':', '==', '!=', '<=', '>=', '<=', '&&', '||']:
            self._advance_position(len(char))
            self._add_token(TokenType.OPERATOR, char, start_pos)
        else:
            self._advance_position()
            self._add_token(TokenType.OPERATOR, char, start_pos)
    
    def _add_token(self, token_type: TokenType, value: str, position: Optional[Position] = None):
        """Voeg token toe aan lijst"""
        token = Token(
            type=token_type,
            value=value,
            line=position.line if position else self.position.line,
            column=position.column if position else self.position.column,
            position=position or self.position
        )
        self.tokens.append(token)
    
    def _add_error(self, message: str):
        """Voeg fout toe aan lijst"""
        error = LexerError(message, self.position.copy())
        self.errors.append(error)
        logger.warning(f"Lexer error: {message} at {self.position}")
    
    def get_errors(self) -> List[LexerError]:
        """Krijg alle lexer fouten"""
        return self.errors
    
    def get_statistics(self) -> Dict[str, Any]:
        """Krijg lexer statistieken"""
        tokenize_time = time.time() - self.start_time
        
        return {
            'tokens_count': len(self.tokens),
            'errors_count': len(self.errors),
            'tokenize_time': tokenize_time,
            'tokens_per_second': len(self.tokens) / tokenize_time if tokenize_time > 0 else 0,
            'source_lines': len(self.source_code.split('\n')),
            'source_characters': len(self.source_code),
        }

# Utility functies
def tokenize(source_code: str, filename: str = "<string>") -> List[Token]:
    """
    Converteer Noodle source code naar token lijst
    
    Args:
        source_code: De te tokenizen source code
        filename: Optionele filename voor foutmeldingen
    
    Returns:
        List van tokens
    """
    lexer = Lexer(source_code, filename)
    return lexer.tokenize()

def validate_syntax(tokens: List[Token]) -> List[str]:
    """
    Valideer basale syntax van token lijst
    
    Args:
        tokens: Token lijst om te valideren
    
    Returns:
        Lijst van syntax fouten
    """
    errors = []
    
    # Simpele validatie regels
    paren_count = sum(1 for token in tokens if token.type == TokenType.LEFT_PAREN)
    paren_close_count = sum(1 for token in tokens if token.type == TokenType.RIGHT_PAREN)
    
    if paren_count != paren_close_count:
        errors.append("Mismatched parentheses")
    
    # Check voor semicolons aan einde van statements
    for i, token in enumerate(tokens):
        if token.type == TokenType.SEMICOLON:
            next_token = tokens[i + 1] if i + 1 < len(tokens) else None
            if next_token and next_token.type not in [TokenType.NEWLINE, TokenType.EOF, TokenType.RIGHT_BRACE]:
                errors.append(f"Unexpected token after semicolon at line {token.line}")
    
    return errors