# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Voorbeeld van hoe Monozukuri Quality Layers te gebruiken
# """

import asyncio
import logging
import typing.Dict,

import .quality_layers.(
#     MonozukuriQualityLayers,
#     QualityMode,
#     QualityIssueType,
#     QualityIssue,
#     QualityReport
# )

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


function example_basic_usage()
    #     """Basis gebruik van quality layers"""
    logger.info(" = == Basic Quality Layers Usage Example ===")

    #     # Maak quality layers instance
    quality_layers = MonozukuriQualityLayers()

    #     # Test code met verschillende kwaliteitsissues
    test_code = """
import os

function process_data(data)
    result = []
    #     for item in data:
    #         # Unsafe operation
    eval_result = eval(str(item))
            result.append(eval_result)

    #     # Complex nested logic
    #     if len(result) > 0:
    #         if result[0] > 0:
    #             if result[0] < 100:
    #                 return result
    #             else:
    #                 return []
    #         else:
    #             return None
    #     else:
    #         return result

# Performance bottleneck
function process_large_dataset(data)
    result = []
    #     for i in range(50000):
            result.append(i * 2)
    #     return result
# """

#     # Analyseer code in verschillende modi
modes = [QualityMode.PEDANTIC, QualityMode.BEST_PRACTICES, QualityMode.CRAFT]

#     for mode in modes:
        logger.info(f"\n--- Analyzing in {mode.value} mode ---")

#         # Analyseer code
report = quality_layers.analyze_code(test_code, mode, {"file": "test.py"})

#         # Toon resultaten
        logger.info(f"Quality Score: {report.score:.2f}")
        logger.info(f"Number of Issues: {len(report.issues)}")

#         # Toon issues
#         for issue in report.issues:
            logger.info(f"  - {issue.issue_type.value}: {issue.message} (Severity: {issue.severity})")
#             if issue.suggestion:
                logger.info(f"    Suggestion: {issue.suggestion}")

#     # Suggesteer beste modus
suggested_mode = quality_layers.suggest_mode(test_code)
    logger.info(f"\nSuggested mode: {suggested_mode.value}")


function example_code_fixing()
    #     """Voorbeeld van code fixen"""
    logger.info("\n = == Code Fixing Example ===")

    quality_layers = MonozukuriQualityLayers()

    #     # Code met veiligheidsissues
    unsafe_code = """
function calculate(expression)
    #     # Unsafe eval usage
    result = eval(expression)
    #     return result

function execute_command(command)
    #     # Dangerous OS command execution
        os.system(command)
    #     return "Command executed"
# """

    logger.info("Original code:")
    logger.info(unsafe_code)

#     # Analyseer in pedantic mode
report = quality_layers.analyze_code(unsafe_code, QualityMode.PEDANTIC, {"file":unsafe.py"})
    logger.info(f"\nFound {len(report.issues)} issues in pedantic mode")

#     # Fix de code
fixed_code = quality_layers.fix_code(unsafe_code, QualityMode.PEDANTIC, report.issues)

    logger.info("\nFixed code:")
    logger.info(fixed_code)

#     # Analyseer gefixte code
fixed_report = quality_layers.analyze_code(fixed_code, QualityMode.PEDANTIC, {"file": "unsafe_fixed.py"})
    logger.info(f"\nQuality score after fix: {fixed_report.score:.2f}")


function example_batch_analysis()
    #     """Voorbeeld van batch analyse"""
    logger.info("\n = == Batch Analysis Example ===")

    quality_layers = MonozukuriQualityLayers()

    #     # Meerdere code bestanden
    code_files = [
            ("file1.py", """
function process_data(data)
    result = []
    #     for item in data:
            result.append(item * 2)
    #     return result
# """),
        ("file2.py", """
import os

function execute_command(cmd)
        return os.system(cmd)
# """),
        ("file3.py", """
function complex_function(a, b, c, d, e)
    #     if a > 0:
    #         if b > 0:
    #             if c > 0:
    #                 if d > 0:
    #                     if e > 0:
    #                         return True
    #                     else:
    #                         return False
    #                 else:
    #                     return None
    #             else:
    #                 return None
    #         else:
    #             return None
    #     else:
    #         return False
# """)
#     ]

#     # Voer batch analyse uit
reports = quality_layers.batch_analyze(code_files, QualityMode.BEST_PRACTICES)

    logger.info(f"Analyzed {len(reports)} files")

#     # Toel resultaten per bestand
#     for i, (filename, report) in enumerate(zip([f[0] for f in code_files], reports)):
        logger.info(f"\nFile {i+1}: {filename}")
        logger.info(f"  Quality Score: {report.score:.2f}")
        logger.info(f"  Issues: {len(report.issues)}")

#         # Toel top issues
#         for issue in report.issues[:3]:  # Toon eerste 3 issues
            logger.info(f"    - {issue.issue_type.value}: {issue.message}")

#     # Genereer samenvattingsrapport
summary = quality_layers.generate_summary_report(reports)
    logger.info(f"\nSummary Report:")
    logger.info(f"  Total Files: {summary['total_reports']}")
    logger.info(f"  Total Issues: {summary['total_issues']}")
    logger.info(f"  Average Score: {summary['average_score']:.2f}")

#     # Toel issue distributie
    logger.info(f"  Issue Distribution:")
#     for issue_type, stats in summary['issue_types'].items():
        logger.info(f"    {issue_type}: {stats['count']} issues")


function example_custom_rules()
    #     """Voorbeeld van custom rules toevoegen"""
    logger.info("\n = == Custom Rules Example ===")

    quality_layers = MonozukuriQualityLayers()

    #     # Maak een custom rule
    #     from .quality_layers import QualityRule

    #     class CustomNamingRule(QualityRule):
    #         """Custom rule voor function naming"""

    #         def __init__(self):
                super().__init__(
    #                 "CUSTOM_NAMING_001",
    #                 "Function names must follow snake_case convention",
    #                 "medium"
    #             )

    #         def check(self, code: str, context: Dict[str, Any]) -> List[QualityIssue]:
    #             """Check function naming"""
    issues = []

    #             try:
    #                 import ast
    tree = ast.parse(code)

    #                 for node in ast.walk(tree):
    #                     if isinstance(node, ast.FunctionDef):
    #                         # Check if function name follows snake_case
    #                         if not node.name.islower() or '_' not in node.name:
                                issues.append(QualityIssue(
    issue_type = QualityIssueType.MAINTAINABILITY,
    severity = "medium",
    message = f"Function name '{node.name}' doesn't follow snake_case convention",
    location = {
                                        'file': context.get('file', 'unknown'),
    #                                     'line': node.lineno,
    #                                     'column': node.col_offset
    #                                 },
    suggestion = "Rename function to follow snake_case convention (e.g., 'my_function')",
    rule_id = self.rule_id,
    confidence = 0.9
    #                             ))
    #             except SyntaxError as e:
                    issues.append(QualityIssue(
    issue_type = QualityIssueType.SAFETY,
    severity = "critical",
    message = f"Syntax error: {e.msg}",
    location = {
                            'file': context.get('file', 'unknown'),
    #                         'line': e.lineno,
    #                         'column': e.offset
    #                     },
    rule_id = self.rule_id,
    confidence = 1.0
    #                 ))

    #             return issues

    #         def fix(self, code: str, issues: List[QualityIssue]) -> str:
    #             """Fix function naming"""
    #             # Implementeer specifieke fixes
    #             return code

    #     # Voeg custom rule toe
        quality_layers.add_custom_rule(QualityMode.BEST_PRACTICES, CustomNamingRule())

    #     # Test code met naming issues
    test_code = """
function BadFunctionName()
    #     return "hello"

function AnotherBadName()
    #     return "world"
# """

#     # Analyseer met custom rule
report = quality_layers.analyze_code(test_code, QualityMode.BEST_PRACTICES, {"file": "test.py"})

    logger.info(f"Found {len(report.issues)} issues including custom rules")
#     for issue in report.issues:
        logger.info(f"  - {issue.message}")


function example_mode_transitions()
    #     """Voorbeeld van mode transities"""
    logger.info("\n = == Mode Transitions Example ===")

    quality_layers = MonozukuriQualityLayers()

    #     # Test code
    test_code = """
function process_data(data)
    result = []
    #     for item in data:
            result.append(item)
    #     return result
# """

#     # Test verschillende modi
current_mode = QualityMode.PEDANTIC
    logger.info(f"Starting in {current_mode.value} mode")

#     # Voer enkele transities uit
transitions = [
#         (QualityMode.BEST_PRACTICES, "Check for best practices"),
#         (QualityMode.CRAFT, "Check for performance optimizations"),
        (QualityMode.PEDANTIC, "Return to strict mode")
#     ]

#     for target_mode, description in transitions:
#         if quality_layers.validate_mode_transition(current_mode, target_mode):
            logger.info(f"Transitioning to {target_mode.value}: {description}")

#             # Analyseer in nieuwe modus
report = quality_layers.analyze_code(test_code, target_mode, {"file": "test.py"})
            logger.info(f"  Quality score: {report.score:.2f}")

current_mode = target_mode
#         else:
            logger.info(f"Cannot transition from {current_mode.value} to {target_mode.value}")


function example_performance_monitoring()
    #     """Voorbeeld van performance monitoring"""
    logger.info("\n = == Performance Monitoring Example ===")

    quality_layers = MonozukuriQualityLayers()

    #     # Analyseer verschillende code snippets
    code_snippets = [
            ("efficient", """
function process_efficiently(data)
    #     return [x * 2 for x in data]
# """),
        ("inefficient", """
function process_inefficiently(data)
    result = []
    #     for x in data:
            result.append(x * 2)
    #     return result
# """),
        ("very_inefficient", """
function process_very_inefficiently(data)
    result = []
    #     for i in range(len(data)):
            result.append(data[i] * 2)
    #     return result
# """)
#     ]

#     # Analyseer alle snippets
results = []
#     for name, code in code_snippets:
report = quality_layers.analyze_code(code, QualityMode.CRAFT, {"file": f"{name}.py"})
        results.append((name, report))

        logger.info(f"\n{name.capitalize()} code:")
        logger.info(f"  Quality Score: {report.score:.2f}")
        logger.info(f"  Issues: {len(report.issues)}")

#         # Toel performance issues
#         performance_issues = [i for i in report.issues if i.issue_type == QualityIssueType.PERFORMANCE]
#         if performance_issues:
            logger.info("  Performance Issues:")
#             for issue in performance_issues:
                logger.info(f"    - {issue.message}")

#     # Toel metrics
metrics = quality_layers.get_metrics()
    logger.info(f"\nOverall Metrics:")
    logger.info(f"  Total Checks: {metrics['total_checks']}")
    logger.info(f"  Total Issues: {metrics['total_issues']}")
    logger.info(f"  Average Score: {metrics['average_score']:.2f}")


# async def main():
#     """Hoofd functie om alle voorbeelden uit te voeren"""
    logger.info("Starting Monozukuri Quality Layers Examples")

#     try:
#         # Voer alle voorbeelden uit
        example_basic_usage()
        example_code_fixing()
        example_batch_analysis()
        example_custom_rules()
        example_mode_transitions()
        example_performance_monitoring()

#     except Exception as e:
        logger.error(f"Error running examples: {e}")
#         raise

    logger.info("All examples completed successfully")


if __name__ == "__main__"
        asyncio.run(main())