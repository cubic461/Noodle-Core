"""
LSP Facts Gate - v2 Interface for API Break Detection

The LspFactsGate is responsible for:
- Extracting facts from LSP servers
- Detecting public API changes
- Validating no breaking changes occur
- Analyzing function/class signatures
- Checking for deprecated API usage
"""
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional, Set, Tuple
from dataclasses import dataclass
from enum import Enum


class ChangeType(Enum):
    """Types of API changes."""
    ADDITION = "addition"
    REMOVAL = "removal"
    MODIFICATION = "modification"
    SIGNATURE_CHANGE = "signature_change"
    DEPRECATION = "deprecation"
    RENAMING = "renaming"


class Severity(Enum):
    """Severity of API changes."""
    BREAKING = "breaking"
    MAJOR = "major"
    MINOR = "minor"
    PATCH = "patch"


@dataclass
class SymbolInfo:
    """Information about a symbol (function, class, etc.)."""
    name: str
    kind: str  # "function", "class", "method", "variable", etc.
    signature: Optional[str] = None
    parameters: Optional[List[str]] = None
    return_type: Optional[str] = None
    documentation: Optional[str] = None
    deprecated: bool = False
    public: bool = False
    file_path: Optional[str] = None
    line: Optional[int] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "name": self.name,
            "kind": self.kind,
            "signature": self.signature,
            "parameters": self.parameters,
            "return_type": self.return_type,
            "documentation": self.documentation,
            "deprecated": self.deprecated,
            "public": self.public,
            "file_path": self.file_path,
            "line": self.line
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "SymbolInfo":
        """Create from dictionary."""
        return cls(**data)


@dataclass
class APIChange:
    """Represents a change to the public API."""
    symbol_name: str
    change_type: ChangeType
    severity: Severity
    old_signature: Optional[str] = None
    new_signature: Optional[str] = None
    description: str = ""
    file_path: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "symbol_name": self.symbol_name,
            "change_type": self.change_type.value,
            "severity": self.severity.value,
            "old_signature": self.old_signature,
            "new_signature": self.new_signature,
            "description": self.description,
            "file_path": self.file_path
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "APIChange":
        """Create from dictionary."""
        return cls(
            symbol_name=data["symbol_name"],
            change_type=ChangeType(data["change_type"]),
            severity=Severity(data["severity"]),
            old_signature=data.get("old_signature"),
            new_signature=data.get("new_signature"),
            description=data.get("description", ""),
            file_path=data.get("file_path")
        )


@dataclass
class LSPAnalysisResult:
    """Result of LSP analysis."""
    changes: List[APIChange]
    breaking_changes: List[APIChange]
    public_symbols_added: int
    public_symbols_removed: int
    public_symbols_modified: int
    passed: bool
    errors: Optional[List[str]] = None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "changes": [change.to_dict() for change in self.changes],
            "breaking_changes": [change.to_dict() for change in self.breaking_changes],
            "public_symbols_added": self.public_symbols_added,
            "public_symbols_removed": self.public_symbols_removed,
            "public_symbols_modified": self.public_symbols_modified,
            "passed": self.passed,
            "errors": self.errors
        }


class LspFactsGate(ABC):
    """
    Abstract base class for LSP-based API validation.
    
    The LspFactsGate uses Language Server Protocol to extract
    information about code changes and validate that no breaking
    changes are introduced to public APIs.
    """
    
    @abstractmethod
    def extract_symbols(
        self,
        file_path: str,
        content: Optional[str] = None
    ) -> List[SymbolInfo]:
        """
        Extract symbols from a file using LSP.
        
        Args:
            file_path: Path to the file
            content: Optional file content
            
        Returns:
            List of symbols found in the file
        """
        pass
    
    @abstractmethod
    def compare_symbols(
        self,
        old_symbols: List[SymbolInfo],
        new_symbols: List[SymbolInfo]
    ) -> List[APIChange]:
        """
        Compare two sets of symbols and identify changes.
        
        Args:
            old_symbols: Symbols before changes
            new_symbols: Symbols after changes
            
        Returns:
            List of API changes
        """
        pass
    
    @abstractmethod
    def detect_breaking_changes(
        self,
        changes: List[APIChange]
    ) -> List[APIChange]:
        """
        Filter changes to find breaking changes.
        
        Args:
            changes: List of all changes
            
        Returns:
            List of breaking changes
        """
        pass
    
    @abstractmethod
    def validate_no_api_break(
        self,
        old_files: Dict[str, str],
        new_files: Dict[str, str],
        public_api_paths: Optional[List[str]] = None
    ) -> LSPAnalysisResult:
        """
        Validate that no breaking changes were introduced.
        
        Args:
            old_files: Map of file paths to old content
            new_files: Map of file paths to new content
            public_api_paths: Paths that define public API
            
        Returns:
            LSPAnalysisResult with validation outcome
        """
        pass


class SimpleLspFactsGate(LspFactsGate):
    """
    Simple implementation of LSP facts gate for v2.
    
    This is a basic implementation that can be extended
    with actual LSP server integration.
    """
    
    def __init__(self):
        self.symbols_extracted = 0
    
    def extract_symbols(
        self,
        file_path: str,
        content: Optional[str] = None
    ) -> List[SymbolInfo]:
        """
        Extract symbols from a file.
        
        Note: This is a simplified implementation that uses
        basic regex parsing. A production version would use
        actual LSP servers (pyls, typescript-language-server, etc.)
        """
        
        # Read content if not provided
        if content is None:
            try:
                with open(file_path, 'r') as f:
                    content = f.read()
            except Exception as e:
                return []
        
        symbols = []
        
        # Simple regex-based extraction (Python-focused)
        # In production, use actual LSP
        
        # Extract function definitions
        import re
        
        # Functions: def public_function(...)
        func_pattern = r'^def\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\((.*?)\):'
        for match in re.finditer(func_pattern, content, re.MULTILINE):
            func_name = match.group(1)
            params = match.group(2)
            
            # Check if public (not starting with _)
            is_public = not func_name.startswith('_')
            
            if is_public:
                symbols.append(SymbolInfo(
                    name=func_name,
                    kind="function",
                    signature=f"def {func_name}({params}):",
                    parameters=[p.strip() for p in params.split(',') if p.strip()],
                    public=True,
                    file_path=file_path
                ))
        
        # Classes: class PublicClass:
        class_pattern = r'^class\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*(?:\((.*?)\))?:'
        for match in re.finditer(class_pattern, content, re.MULTILINE):
            class_name = match.group(1)
            bases = match.group(2) if match.group(2) else ""
            
            is_public = not class_name.startswith('_')
            
            if is_public:
                symbols.append(SymbolInfo(
                    name=class_name,
                    kind="class",
                    signature=f"class {class_name}({bases}):",
                    public=True,
                    file_path=file_path
                ))
        
        self.symbols_extracted += len(symbols)
        return symbols
    
    def compare_symbols(
        self,
        old_symbols: List[SymbolInfo],
        new_symbols: List[SymbolInfo]
    ) -> List[APIChange]:
        """Compare two sets of symbols and identify changes."""
        
        old_map = {sym.name: sym for sym in old_symbols if sym.public}
        new_map = {sym.name: sym for sym in new_symbols if sym.public}
        
        changes = []
        
        # Check for removed symbols
        for name, old_sym in old_map.items():
            if name not in new_map:
                changes.append(APIChange(
                    symbol_name=name,
                    change_type=ChangeType.REMOVAL,
                    severity=Severity.BREAKING,
                    old_signature=old_sym.signature,
                    description=f"Public {old_sym.kind} '{name}' was removed",
                    file_path=old_sym.file_path
                ))
        
        # Check for added symbols
        for name, new_sym in new_map.items():
            if name not in old_map:
                changes.append(APIChange(
                    symbol_name=name,
                    change_type=ChangeType.ADDITION,
                    severity=Severity.MINOR,
                    new_signature=new_sym.signature,
                    description=f"Public {new_sym.kind} '{name}' was added",
                    file_path=new_sym.file_path
                ))
        
        # Check for modified symbols
        for name in old_map.keys() & new_map.keys():
            old_sym = old_map[name]
            new_sym = new_map[name]
            
            if old_sym.signature != new_sym.signature:
                changes.append(APIChange(
                    symbol_name=name,
                    change_type=ChangeType.SIGNATURE_CHANGE,
                    severity=Severity.MAJOR,
                    old_signature=old_sym.signature,
                    new_signature=new_sym.signature,
                    description=f"Public {old_sym.kind} '{name}' signature changed",
                    file_path=new_sym.file_path
                ))
        
        return changes
    
    def detect_breaking_changes(
        self,
        changes: List[APIChange]
    ) -> List[APIChange]:
        """Filter changes to find breaking changes."""
        
        breaking = []
        
        for change in changes:
            # Removals are always breaking
            if change.change_type == ChangeType.REMOVAL:
                breaking.append(change)
            
            # Signature changes can be breaking
            elif change.change_type == ChangeType.SIGNATURE_CHANGE:
                # Check if parameters changed in breaking way
                if self._is_breaking_signature_change(change):
                    change.severity = Severity.BREAKING
                    breaking.append(change)
            
            # Deprecations are major but not breaking
            elif change.change_type == ChangeType.DEPRECATION:
                change.severity = Severity.MAJOR
        
        return breaking
    
    def validate_no_api_break(
        self,
        old_files: Dict[str, str],
        new_files: Dict[str, str],
        public_api_paths: Optional[List[str]] = None
    ) -> LSPAnalysisResult:
        """Validate that no breaking changes were introduced."""
        
        try:
            # Extract symbols from old files
            old_symbols = []
            for file_path, content in old_files.items():
                old_symbols.extend(self.extract_symbols(file_path, content))
            
            # Extract symbols from new files
            new_symbols = []
            for file_path, content in new_files.items():
                new_symbols.extend(self.extract_symbols(file_path, content))
            
            # Compare symbols
            changes = self.compare_symbols(old_symbols, new_symbols)
            
            # Detect breaking changes
            breaking_changes = self.detect_breaking_changes(changes)
            
            # Count changes
            public_added = len([c for c in changes if c.change_type == ChangeType.ADDITION])
            public_removed = len([c for c in changes if c.change_type == ChangeType.REMOVAL])
            public_modified = len([c for c in changes if c.change_type == ChangeType.MODIFICATION])
            
            # Check if passed
            passed = len(breaking_changes) == 0
            
            return LSPAnalysisResult(
                changes=changes,
                breaking_changes=breaking_changes,
                public_symbols_added=public_added,
                public_symbols_removed=public_removed,
                public_symbols_modified=public_modified,
                passed=passed,
                errors=None
            )
            
        except Exception as e:
            return LSPAnalysisResult(
                changes=[],
                breaking_changes=[],
                public_symbols_added=0,
                public_symbols_removed=0,
                public_symbols_modified=0,
                passed=False,
                errors=[f"Validation error: {str(e)}"]
            )
    
    def _is_breaking_signature_change(self, change: APIChange) -> bool:
        """Check if a signature change is breaking."""
        
        # Simple heuristic: if parameters changed, it's likely breaking
        if not change.old_signature or not change.new_signature:
            return True
        
        # Extract parameters
        import re
        old_params = re.findall(r'\((.*?)\)', change.old_signature)
        new_params = re.findall(r'\((.*?)\)', change.new_signature)
        
        if old_params and new_params:
            return old_params != new_params
        
        return True


def create_lsp_facts_gate(gate_type: str = "simple") -> LspFactsGate:
    """
    Factory function to create an LSP facts gate.
    
    Args:
        gate_type: Type of gate ("simple", "lsp")
        
    Returns:
        LspFactsGate instance
    """
    if gate_type == "simple":
        return SimpleLspFactsGate()
    else:
        raise ValueError(f"Unknown gate type: {gate_type}")


# Convenience function for quick validation
def validate_no_api_break(
    old_files: Dict[str, str],
    new_files: Dict[str, str]
) -> LSPAnalysisResult:
    """
    Quick function to validate no breaking API changes.
    
    Args:
        old_files: Map of file paths to old content
        new_files: Map of file paths to new content
        
    Returns:
        LSPAnalysisResult
    """
    gate = create_lsp_facts_gate()
    return gate.validate_no_api_break(old_files, new_files)
