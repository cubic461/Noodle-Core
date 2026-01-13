#!/usr/bin/env python3
"""
Output Processor Module
=======================

This module provides execution result processing and formatting capabilities,
including output parsing, error formatting, and result aggregation.

Author: NoodleCore Development Team
Version: 1.0.0
"""

import re
import json
import time
import uuid
import logging
from typing import Dict, List, Optional, Any, Tuple, Union
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
import html

# Configure logging
logger = logging.getLogger(__name__)


@dataclass
class OutputChunk:
    """Individual output chunk from execution."""
    chunk_id: str
    script_id: str
    stream_type: str  # "stdout", "stderr", "info", "error"
    content: str
    timestamp: datetime
    line_number: Optional[int] = None
    metadata: Dict[str, Any] = None
    
    def __post_init__(self):
        if not self.chunk_id:
            self.chunk_id = str(uuid.uuid4())
        if isinstance(self.timestamp, str):
            self.timestamp = datetime.fromisoformat(self.timestamp.replace('Z', '+00:00'))
        if self.metadata is None:
            self.metadata = {}


@dataclass
class ExecutionOutput:
    """Complete execution output with processed results."""
    script_id: str
    execution_id: str
    start_time: datetime
    end_time: Optional[datetime] = None
    exit_code: Optional[int] = None
    output_chunks: List[OutputChunk] = None
    summary: Dict[str, Any] = None
    formatted_output: Dict[str, Any] = None
    performance_metrics: Dict[str, Any] = None
    error_analysis: Dict[str, Any] = None
    
    def __post_init__(self):
        if isinstance(self.start_time, str):
            self.start_time = datetime.fromisoformat(self.start_time.replace('Z', '+00:00'))
        if isinstance(self.end_time, str) and self.end_time:
            self.end_time = datetime.fromisoformat(self.end_time.replace('Z', '+00:00'))
        if self.output_chunks is None:
            self.output_chunks = []
        if self.summary is None:
            self.summary = {}
        if self.formatted_output is None:
            self.formatted_output = {}
        if self.performance_metrics is None:
            self.performance_metrics = {}
        if self.error_analysis is None:
            self.error_analysis = {}


@dataclass
class ProcessedResult:
    """Final processed execution result."""
    script_id: str
    success: bool
    execution_time: float
    stdout_text: str
    stderr_text: str
    output_lines: List[str]
    error_lines: List[str]
    warnings: List[str]
    info_messages: List[str]
    structured_output: Dict[str, Any] = None
    metrics: Dict[str, Any] = None
    recommendations: List[str] = None
    
    def __post_init__(self):
        if self.structured_output is None:
            self.structured_output = {}
        if self.metrics is None:
            self.metrics = {}
        if self.recommendations is None:
            self.recommendations = []


class OutputParser:
    """Parser for different output formats."""
    
    def __init__(self):
        self.parsers = {
            "json": self._parse_json_output,
            "yaml": self._parse_yaml_output,
            "csv": self._parse_csv_output,
            "xml": self._parse_xml_output,
            "python": self._parse_python_output,
            "table": self._parse_table_output,
            "log": self._parse_log_output
        }
    
    def parse_output(self, content: str, format_hint: str = None) -> Dict[str, Any]:
        """Parse output content based on format."""
        
        if not content.strip():
            return {"type": "empty", "content": ""}
        
        # Try to detect format if not provided
        if format_hint is None:
            format_hint = self._detect_format(content)
        
        parser = self.parsers.get(format_hint, self._parse_generic_output)
        return parser(content)
    
    def _detect_format(self, content: str) -> str:
        """Detect output format from content."""
        
        content = content.strip()
        
        # JSON detection
        if content.startswith('{') and content.endswith('}'):
            try:
                json.loads(content)
                return "json"
            except:
                pass
        
        # YAML detection (simple)
        if content.startswith('---') or ': ' in content:
            return "yaml"
        
        # CSV detection
        if ',' in content and '\n' in content:
            lines = content.split('\n')
            if lines and all(',' in line for line in lines[:3]):
                return "csv"
        
        # XML detection
        if content.startswith('<') and content.endswith('>'):
            return "xml"
        
        # Python output detection
        if any(keyword in content for keyword in ['print(', 'def ', 'import ', 'class ']):
            return "python"
        
        # Table detection
        if '\t' in content or ('|' in content and '---' in content):
            return "table"
        
        # Log format detection
        if re.search(r'\d{4}-\d{2}-\d{2}', content) or 'INFO:' in content:
            return "log"
        
        return "generic"
    
    def _parse_json_output(self, content: str) -> Dict[str, Any]:
        """Parse JSON formatted output."""
        
        try:
            data = json.loads(content)
            return {
                "type": "json",
                "data": data,
                "formatted": json.dumps(data, indent=2),
                "summary": self._generate_json_summary(data)
            }
        except json.JSONDecodeError as e:
            return {
                "type": "json",
                "error": str(e),
                "content": content
            }
    
    def _parse_yaml_output(self, content: str) -> Dict[str, Any]:
        """Parse YAML formatted output (simplified)."""
        
        # Simple YAML parsing - in real implementation, use PyYAML
        lines = content.split('\n')
        parsed_data = {}
        
        for line in lines:
            line = line.strip()
            if ':' in line and not line.startswith('#'):
                key, value = line.split(':', 1)
                parsed_data[key.strip()] = value.strip()
        
        return {
            "type": "yaml",
            "data": parsed_data,
            "formatted": content,
            "summary": {"key_count": len(parsed_data)}
        }
    
    def _parse_csv_output(self, content: str) -> Dict[str, Any]:
        """Parse CSV formatted output."""
        
        lines = [line.strip() for line in content.split('\n') if line.strip()]
        if not lines:
            return {"type": "csv", "data": [], "summary": {"rows": 0}}
        
        # Simple CSV parsing
        rows = []
        headers = []
        
        for i, line in enumerate(lines):
            values = [v.strip() for v in line.split(',')]
            
            if i == 0:
                headers = values
            else:
                row = dict(zip(headers, values))
                rows.append(row)
        
        return {
            "type": "csv",
            "headers": headers,
            "data": rows,
            "summary": {
                "rows": len(rows),
                "columns": len(headers)
            }
        }
    
    def _parse_xml_output(self, content: str) -> Dict[str, Any]:
        """Parse XML formatted output (simplified)."""
        
        # Simple XML parsing - in real implementation, use xml.etree.ElementTree
        import xml.etree.ElementTree as ET
        
        try:
            root = ET.fromstring(content)
            return {
                "type": "xml",
                "tag": root.tag,
                "attributes": root.attrib,
                "text": root.text,
                "summary": {"tag": root.tag, "has_attributes": bool(root.attrib)}
            }
        except ET.ParseError as e:
            return {
                "type": "xml",
                "error": str(e),
                "content": content
            }
    
    def _parse_python_output(self, content: str) -> Dict[str, Any]:
        """Parse Python code/output."""
        
        lines = content.split('\n')
        parsed_lines = []
        
        for i, line in enumerate(lines, 1):
            line_info = {
                "line_number": i,
                "content": line,
                "type": self._classify_python_line(line)
            }
            parsed_lines.append(line_info)
        
        return {
            "type": "python",
            "lines": parsed_lines,
            "summary": {
                "total_lines": len(lines),
                "non_empty_lines": len([l for l in lines if l.strip()])
            }
        }
    
    def _parse_table_output(self, content: str) -> Dict[str, Any]:
        """Parse table formatted output."""
        
        lines = content.split('\n')
        
        # Detect delimiter
        delimiter = '|' if '|' in content else '\t' if '\t' in content else ' '
        
        # Parse table
        table_data = []
        headers = []
        
        for i, line in enumerate(lines):
            if not line.strip():
                continue
            
            cells = [cell.strip() for cell in line.split(delimiter)]
            
            if i == 0:
                headers = cells
            else:
                row = dict(zip(headers, cells))
                table_data.append(row)
        
        return {
            "type": "table",
            "headers": headers,
            "data": table_data,
            "delimiter": delimiter,
            "summary": {
                "rows": len(table_data),
                "columns": len(headers)
            }
        }
    
    def _parse_log_output(self, content: str) -> Dict[str, Any]:
        """Parse log formatted output."""
        
        lines = content.split('\n')
        log_entries = []
        
        for line in lines:
            if not line.strip():
                continue
            
            # Simple log parsing
            log_info = {
                "timestamp": None,
                "level": "INFO",
                "message": line,
                "components": []
            }
            
            # Extract timestamp
            timestamp_match = re.search(r'\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}', line)
            if timestamp_match:
                log_info["timestamp"] = timestamp_match.group()
            
            # Extract log level
            level_match = re.search(r'(DEBUG|INFO|WARNING|ERROR|CRITICAL)', line)
            if level_match:
                log_info["level"] = level_match.group()
            
            log_entries.append(log_info)
        
        return {
            "type": "log",
            "entries": log_entries,
            "summary": {
                "total_entries": len(log_entries),
                "levels": list(set(entry["level"] for entry in log_entries))
            }
        }
    
    def _parse_generic_output(self, content: str) -> Dict[str, Any]:
        """Parse generic text output."""
        
        lines = content.split('\n')
        return {
            "type": "generic",
            "content": content,
            "summary": {
                "total_lines": len(lines),
                "non_empty_lines": len([l for l in lines if l.strip()]),
                "character_count": len(content)
            }
        }
    
    def _classify_python_line(self, line: str) -> str:
        """Classify Python line type."""
        
        line = line.strip()
        
        if not line or line.startswith('#'):
            return "comment"
        elif line.startswith('def '):
            return "function"
        elif line.startswith('class '):
            return "class"
        elif line.startswith('import ') or line.startswith('from '):
            return "import"
        elif line.startswith('if '):
            return "conditional"
        elif line.startswith('for ') or line.startswith('while '):
            return "loop"
        elif line.startswith('try:'):
            return "exception"
        else:
            return "statement"
    
    def _generate_json_summary(self, data: Any) -> Dict[str, Any]:
        """Generate summary for JSON data."""
        
        if isinstance(data, dict):
            return {
                "type": "object",
                "keys": list(data.keys()),
                "key_count": len(data),
                "nested_levels": self._calculate_nesting_level(data)
            }
        elif isinstance(data, list):
            return {
                "type": "array",
                "length": len(data),
                "element_types": list(set(type(item).__name__ for item in data))
            }
        else:
            return {
                "type": type(data).__name__,
                "value": str(data)
            }
    
    def _calculate_nesting_level(self, data: Any, level: int = 0) -> int:
        """Calculate maximum nesting level in data structure."""
        
        if isinstance(data, dict):
            if not data:
                return level
            return max(self._calculate_nesting_level(value, level + 1) for value in data.values())
        elif isinstance(data, list):
            if not data:
                return level
            return max(self._calculate_nesting_level(item, level + 1) for item in data)
        else:
            return level


class OutputFormatter:
    """Formatter for different output presentation formats."""
    
    def __init__(self):
        self.formatters = {
            "html": self._format_html,
            "markdown": self._format_markdown,
            "json": self._format_json,
            "text": self._format_text,
            "table": self._format_table
        }
    
    def format_output(self, output: ExecutionOutput, format_type: str = "text") -> str:
        """Format output in specified format."""
        
        formatter = self.formatters.get(format_type, self._format_text)
        return formatter(output)
    
    def _format_html(self, output: ExecutionOutput) -> str:
        """Format output as HTML."""
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Execution Output - {output.script_id}</title>
    <style>
        body {{ font-family: monospace; margin: 20px; }}
        .stdout {{ color: black; background: #f9f9f9; padding: 10px; }}
        .stderr {{ color: red; background: #ffe6e6; padding: 10px; }}
        .info {{ color: blue; background: #e6f3ff; padding: 10px; }}
        .metrics {{ border: 1px solid #ccc; padding: 10px; margin: 10px 0; }}
        .timestamp {{ color: #666; font-size: 0.9em; }}
    </style>
</head>
<body>
    <h1>Execution Output</h1>
    <div class="metrics">
        <h2>Execution Summary</h2>
        <p><strong>Script ID:</strong> {output.script_id}</p>
        <p><strong>Execution Time:</strong> {output.end_time - output.start_time if output.end_time else 'N/A'}</p>
        <p><strong>Exit Code:</strong> {output.exit_code}</p>
    </div>
"""
        
        # Add output chunks
        for chunk in output.output_chunks:
            css_class = chunk.stream_type
            escaped_content = html.escape(chunk.content)
            timestamp = chunk.timestamp.strftime("%H:%M:%S.%f")[:-3]
            
            html_content += f"""
    <div class="{css_class}">
        <div class="timestamp">[{timestamp}] {chunk.stream_type.upper()}</div>
        <pre>{escaped_content}</pre>
    </div>
"""
        
        html_content += """
</body>
</html>"""
        
        return html_content
    
    def _format_markdown(self, output: ExecutionOutput) -> str:
        """Format output as Markdown."""
        
        md_content = f"""# Execution Output

**Script ID:** `{output.script_id}`  
**Start Time:** {output.start_time}  
**End Time:** {output.end_time or 'N/A'}  
**Exit Code:** {output.exit_code}  

## Summary

"""
        
        if output.summary:
            for key, value in output.summary.items():
                md_content += f"- **{key}:** {value}\n"
        
        md_content += "\n## Output\n\n"
        
        # Group output by type
        chunks_by_type = {}
        for chunk in output.output_chunks:
            if chunk.stream_type not in chunks_by_type:
                chunks_by_type[chunk.stream_type] = []
            chunks_by_type[chunk.stream_type].append(chunk)
        
        for stream_type, chunks in chunks_by_type.items():
            md_content += f"### {stream_type.upper()}\n\n"
            for chunk in chunks:
                md_content += f"```\n{chunk.content}\n```\n\n"
        
        return md_content
    
    def _format_json(self, output: ExecutionOutput) -> str:
        """Format output as JSON."""
        
        # Convert to serializable format
        output_dict = asdict(output)
        return json.dumps(output_dict, indent=2, default=str)
    
    def _format_text(self, output: ExecutionOutput) -> str:
        """Format output as plain text."""
        
        text_content = f"=== Execution Output ===\n"
        text_content += f"Script ID: {output.script_id}\n"
        text_content += f"Start Time: {output.start_time}\n"
        text_content += f"End Time: {output.end_time or 'N/A'}\n"
        text_content += f"Exit Code: {output.exit_code}\n\n"
        
        # Group output by type
        chunks_by_type = {}
        for chunk in output.output_chunks:
            if chunk.stream_type not in chunks_by_type:
                chunks_by_type[chunk.stream_type] = []
            chunks_by_type[chunk.stream_type].append(chunk)
        
        for stream_type, chunks in chunks_by_type.items():
            text_content += f"=== {stream_type.upper()} ===\n"
            for chunk in chunks:
                text_content += f"[{chunk.timestamp.strftime('%H:%M:%S.%f')[:-3]}] {chunk.content}\n"
            text_content += "\n"
        
        return text_content
    
    def _format_table(self, output: ExecutionOutput) -> str:
        """Format output as table."""
        
        # Simple table formatting for metrics
        table_content = "=== Execution Summary ===\n"
        table_content += f"{'Field':<20} {'Value':<30}\n"
        table_content += f"{'-'*50}\n"
        table_content += f"{'Script ID':<20} {output.script_id:<30}\n"
        table_content += f"{'Start Time':<20} {str(output.start_time):<30}\n"
        table_content += f"{'End Time':<20} {str(output.end_time) if output.end_time else 'N/A':<30}\n"
        table_content += f"{'Exit Code':<20} {output.exit_code:<30}\n"
        
        if output.performance_metrics:
            table_content += f"\n{'Performance Metrics':<20} {'Value':<30}\n"
            table_content += f"{'-'*50}\n"
            for key, value in output.performance_metrics.items():
                table_content += f"{key:<20} {str(value):<30}\n"
        
        return table_content


class OutputProcessor:
    """Main output processor for execution results."""
    
    def __init__(self):
        self.parser = OutputParser()
        self.formatter = OutputFormatter()
        self.processors = {}
    
    def process_execution_output(self, raw_output: Dict[str, Any]) -> ProcessedResult:
        """Process raw execution output into structured result."""
        
        logger.info(f"Processing execution output for script {raw_output.get('script_id')}")
        
        try:
            # Extract basic information
            script_id = raw_output.get("script_id", "")
            execution_time = raw_output.get("execution_time", 0.0)
            exit_code = raw_output.get("exit_code")
            stdout = raw_output.get("stdout", "")
            stderr = raw_output.get("stderr", "")
            
            # Parse outputs
            stdout_lines = [line for line in stdout.split('\n') if line.strip()]
            stderr_lines = [line for line in stderr.split('\n') if line.strip()]
            
            # Parse structured output
            structured_output = {}
            if stdout:
                structured_output["stdout_parsed"] = self.parser.parse_output(stdout)
            if stderr:
                structured_output["stderr_parsed"] = self.parser.parse_output(stderr)
            
            # Generate warnings and info messages
            warnings = self._generate_warnings(raw_output)
            info_messages = self._generate_info_messages(raw_output)
            
            # Calculate metrics
            metrics = self._calculate_metrics(raw_output)
            
            # Generate recommendations
            recommendations = self._generate_recommendations(raw_output, warnings)
            
            result = ProcessedResult(
                script_id=script_id,
                success=exit_code == 0,
                execution_time=execution_time,
                stdout_text=stdout,
                stderr_text=stderr,
                output_lines=stdout_lines,
                error_lines=stderr_lines,
                warnings=warnings,
                info_messages=info_messages,
                structured_output=structured_output,
                metrics=metrics,
                recommendations=recommendations
            )
            
            logger.info(f"Processing completed for script {script_id}")
            return result
            
        except Exception as e:
            logger.error(f"Output processing failed: {e}")
            return ProcessedResult(
                script_id=raw_output.get("script_id", ""),
                success=False,
                execution_time=0.0,
                stdout_text="",
                stderr_text=str(e),
                output_lines=[],
                error_lines=[str(e)],
                warnings=["Output processing failed"],
                info_messages=[],
                recommendations=["Check execution logs for details"]
            )
    
    def create_execution_output(self, script_id: str, execution_data: Dict[str, Any]) -> ExecutionOutput:
        """Create ExecutionOutput from execution data."""
        
        # Create output chunks
        output_chunks = []
        
        # Add stdout chunks
        stdout = execution_data.get("stdout", "")
        if stdout:
            lines = stdout.split('\n')
            for i, line in enumerate(lines, 1):
                if line.strip():
                    chunk = OutputChunk(
                        script_id=script_id,
                        stream_type="stdout",
                        content=line,
                        timestamp=datetime.utcnow(),
                        line_number=i
                    )
                    output_chunks.append(chunk)
        
        # Add stderr chunks
        stderr = execution_data.get("stderr", "")
        if stderr:
            lines = stderr.split('\n')
            for i, line in enumerate(lines, 1):
                if line.strip():
                    chunk = OutputChunk(
                        script_id=script_id,
                        stream_type="stderr",
                        content=line,
                        timestamp=datetime.utcnow(),
                        line_number=i
                    )
                    output_chunks.append(chunk)
        
        # Create execution output
        execution_output = ExecutionOutput(
            script_id=script_id,
            execution_id=str(uuid.uuid4()),
            start_time=datetime.utcnow(),
            end_time=datetime.utcnow(),
            exit_code=execution_data.get("exit_code"),
            output_chunks=output_chunks,
            summary=self._generate_execution_summary(execution_data)
        )
        
        return execution_output
    
    def format_execution_output(self, output: ExecutionOutput, format_type: str = "text") -> str:
        """Format execution output in specified format."""
        
        return self.formatter.format_output(output, format_type)
    
    def _generate_warnings(self, execution_data: Dict[str, Any]) -> List[str]:
        """Generate warnings based on execution data."""
        
        warnings = []
        
        execution_time = execution_data.get("execution_time", 0)
        if execution_time > 30:
            warnings.append(f"Long execution time: {execution_time:.2f}s")
        
        stderr = execution_data.get("stderr", "")
        if stderr:
            warnings.append("Errors detected in stderr")
        
        exit_code = execution_data.get("exit_code")
        if exit_code and exit_code != 0:
            warnings.append(f"Non-zero exit code: {exit_code}")
        
        return warnings
    
    def _generate_info_messages(self, execution_data: Dict[str, Any]) -> List[str]:
        """Generate informational messages."""
        
        messages = []
        
        execution_time = execution_data.get("execution_time", 0)
        messages.append(f"Execution completed in {execution_time:.2f}s")
        
        stdout = execution_data.get("stdout", "")
        if stdout:
            lines = len([line for line in stdout.split('\n') if line.strip()])
            messages.append(f"Generated {lines} output lines")
        
        return messages
    
    def _calculate_metrics(self, execution_data: Dict[str, Any]) -> Dict[str, Any]:
        """Calculate execution metrics."""
        
        metrics = {
            "execution_time": execution_data.get("execution_time", 0),
            "exit_code": execution_data.get("exit_code", -1),
            "stdout_size": len(execution_data.get("stdout", "")),
            "stderr_size": len(execution_data.get("stderr", "")),
            "output_lines": len([line for line in execution_data.get("stdout", "").split('\n') if line.strip()]),
            "error_lines": len([line for line in execution_data.get("stderr", "").split('\n') if line.strip()])
        }
        
        return metrics
    
    def _generate_recommendations(self, execution_data: Dict[str, Any], warnings: List[str]) -> List[str]:
        """Generate improvement recommendations."""
        
        recommendations = []
        
        for warning in warnings:
            if "Long execution time" in warning:
                recommendations.append("Consider optimizing the code for better performance")
            elif "Errors detected" in warning:
                recommendations.append("Review and fix any errors in the code")
            elif "Non-zero exit code" in warning:
                recommendations.append("Check the exit code and handle errors appropriately")
        
        if not recommendations:
            recommendations.append("Code executed successfully with no issues")
        
        return recommendations
    
    def _generate_execution_summary(self, execution_data: Dict[str, Any]) -> Dict[str, Any]:
        """Generate execution summary."""
        
        return {
            "execution_successful": execution_data.get("exit_code", -1) == 0,
            "total_execution_time": execution_data.get("execution_time", 0),
            "output_size": len(execution_data.get("stdout", "")),
            "error_size": len(execution_data.get("stderr", "")),
            "has_warnings": bool(execution_data.get("stderr")),
            "performance_rating": self._calculate_performance_rating(execution_data)
        }
    
    def _calculate_performance_rating(self, execution_data: Dict[str, Any]) -> str:
        """Calculate performance rating."""
        
        execution_time = execution_data.get("execution_time", 0)
        
        if execution_time < 1:
            return "excellent"
        elif execution_time < 5:
            return "good"
        elif execution_time < 15:
            return "fair"
        else:
            return "poor"
    
    def get_processing_statistics(self) -> Dict[str, Any]:
        """Get output processing statistics."""
        
        return {
            "supported_formats": list(self.parser.parsers.keys()),
            "output_formatters": list(self.formatter.formatters.keys()),
            "processing_capabilities": [
                "JSON parsing", "CSV parsing", "XML parsing", 
                "Log analysis", "Table formatting", "HTML output"
            ]
        }


# Factory function
def create_output_processor() -> OutputProcessor:
    """Create a new OutputProcessor instance."""
    return OutputProcessor()


# Global instance
_output_processor = None

def get_output_processor() -> OutputProcessor:
    """Get the global output processor instance."""
    global _output_processor
    if _output_processor is None:
        _output_processor = create_output_processor()
    return _output_processor