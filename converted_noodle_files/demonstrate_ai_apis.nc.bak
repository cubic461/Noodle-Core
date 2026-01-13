# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# NoodleCore AI Backend APIs Demonstration Script
 = =============================================

# This script demonstrates the AI-powered backend APIs for code analysis and
# suggestions that integrate with the Monaco Editor frontend. It shows all the
# implemented features including real-time analysis, suggestions, corrections,
# and WebSocket support.

# Features Demonstrated:
# - Real-time code analysis with AI suggestions
# - Context-aware code completion
# - Code quality and security analysis
# - Performance optimization suggestions
# - Code explanation and documentation generation
- Multi-language support (Python, JavaScript, TypeScript, Noodle)
# - WebSocket real-time AI features
# - User feedback learning system

# Usage:
#     python demonstrate_ai_apis.py [--server-url URL] [--websocket]

# Author: NoodleCore AI Team
# Version: 1.0.0
# """

import requests
import json
import time
import uuid
import sys
import argparse
import typing.Dict,

# Configuration
DEFAULT_SERVER_URL = "http://localhost:8080"
DEFAULT_WEBSOCKET_URL = "ws://localhost:8080"

class NoodleCoreAIDemo
    #     """Demonstration class for NoodleCore AI APIs."""

    #     def __init__(self, server_url: str = DEFAULT_SERVER_URL):
    #         """Initialize demo with server URL."""
    self.server_url = server_url
    self.request_id = str(uuid.uuid4())

    #         # Test code samples in different languages
    self.test_samples = {
    #             'python_simple': 'def hello():\n    print("Hello, World!")',
    #             'python_complex': '''
function fibonacci(n)
    #     if n <= 1:
    #         return n
    #     for i in range(len([])):
    x = range(len([]))
            print(x)
        return fibonacci(n-1) + fibonacci(n-2)
# ''',
            'python_typo': 'prin("Hello")',
#             'javascript': '''
function calculateTotal(items) {
let total = 0;
#     for (let i = 0; i < items.length; i++) {
total + = items[i].price;
#     }
#     return total;
# }
# ''',
#             'typescript': '''
# interface User {
#     id: number;
#     name: string;
#     email: string;
# }

class UserManager {
private users: Map<number, User> = new Map();

    addUser(user: User): void {
        this.users.set(user.id, user);
#     }
# }
# ''',
#             'noodle': '''
fn calculate_sum(numbers: Vec<int>) -> int {
let mut total = 0;
#     for i in 0..numbers.len() {
total + = numbers[i];
#     }
#     return total;
# }

fn main() {
let nums = vec![1, 2, 3, 4, 5];
let result = calculate_sum(nums);
    print("Sum: " + result.to_string());
# }
# '''
#         }

#     def make_request(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
#         """Make a request to the AI API endpoint."""
url = f"{self.server_url}{endpoint}"
headers = {
#             'Content-Type': 'application/json',
#             'X-Request-ID': self.request_id
#         }

#         try:
response = requests.post(url, json=data, headers=headers, timeout=30)
            response.raise_for_status()
            return response.json()
#         except Exception as e:
#             return {
#                 'success': False,
                'error': f'Request failed: {str(e)}',
#                 'requestId': self.request_id
#             }

#     def test_ai_analyze(self) -> None:
#         """Test AI code analysis endpoint."""
print("\n" + " = "*60)
        print("🔍 Testing AI Code Analysis")
print(" = "*60)

#         for lang, code in self.test_samples.items():
            print(f"\n--- Testing {lang} ---")
data = {
                'code': code.strip(),
                'language': lang.split('_')[0],
#                 'file_path': f'test.{lang.split("_")[0] if "_" in lang else "py"}'
#             }

start_time = time.time()
result = self.make_request('/api/v1/ai/analyze', data)
end_time = time.time()

#             if result.get('success'):
analysis = result['data']
                print(f"✅ Analysis completed in {end_time - start_time:.3f}s")
                print(f"   Language detected: {analysis.get('language_detected', 'N/A')}")
                print(f"   Complexity score: {analysis.get('complexity_score', 0):.2f}")
                print(f"   Performance score: {analysis.get('performance_score', 0):.2f}")
                print(f"   Security score: {analysis.get('security_score', 0):.2f}")
                print(f"   Confidence: {analysis.get('confidence_score', 0):.2f}")

suggestions = analysis.get('suggestions', [])
#                 if suggestions:
                    print(f"   Suggestions: {len(suggestions)} found")
#                     for i, sugg in enumerate(suggestions[:3], 1):
                        print(f"     {i}. {sugg.get('text', 'N/A')} (confidence: {sugg.get('confidence', 0):.2f})")
#                 else:
                    print("   No suggestions")

issues = analysis.get('issues', [])
#                 if issues:
                    print(f"   Issues: {len(issues)} found")
#                     for i, issue in enumerate(issues[:2], 1):
                        print(f"     {i}. {issue.get('message', 'N/A')} (severity: {issue.get('severity', 'N/A')})")
#                 else:
                    print("   No issues detected")
#             else:
                print(f"❌ Analysis failed: {result.get('error', 'Unknown error')}")

#     def test_ai_suggest(self) -> None:
#         """Test AI suggestion endpoint."""
print("\n" + " = "*60)
        print("💡 Testing AI Code Suggestions")
print(" = "*60)

#         # Test completion for incomplete code
test_cases = [
#             {'code': 'def ', 'lang': 'python', 'desc': 'function definition'},
#             {'code': 'pr', 'lang': 'python', 'desc': 'print statement'},
#             {'code': 'imp', 'lang': 'python', 'desc': 'import statement'},
#             {'code': 'func', 'lang': 'javascript', 'desc': 'function keyword'},
#             {'code': 'cons', 'lang': 'javascript', 'desc': 'const declaration'}
#         ]

#         for test in test_cases:
            print(f"\n--- Testing {test['desc']} ---")
data = {
#                 'code': test['code'],
#                 'language': test['lang'],
#                 'file_path': f'test.{test["lang"][:3]}'
#             }

result = self.make_request('/api/v1/ai/suggest', data)

#             if result.get('success'):
suggestions = result['data'].get('suggestions', [])
                print(f"✅ Got {len(suggestions)} suggestions:")
#                 for i, sugg in enumerate(suggestions[:3], 1):
                    print(f"  {i}. '{sugg.get('text', 'N/A')}' (confidence: {sugg.get('confidence', 0):.2f})")
#             else:
                print(f"❌ Suggestion failed: {result.get('error', 'Unknown error')}")

#     def test_ai_review(self) -> None:
#         """Test AI code review endpoint."""
print("\n" + " = "*60)
        print("🔍 Testing AI Code Review")
print(" = "*60)

#         # Test code that should generate review feedback
review_code = '''
# This code has multiple issues
x = 1
y = 2
z = math.add(x, y)
print z

# TODO: Add proper documentation
function long_function()
    #     for i in range(len([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])):
            print(i)
    #         # This function does too much
    data = []
    #         for j in range(100):
                data.append(j)
    #         return data
# '''

data = {
#             'code': review_code,
#             'language': 'python',
#             'file_path': 'review_test.py'
#         }

#         print("Analyzing code with multiple issues...")
result = self.make_request('/api/v1/ai/review', data)

#         if result.get('success'):
review = result['data']
            print(f"✅ Review completed")
            print(f"   Overall score: {review.get('overall_score', 0):.2f}/1.0")
            print(f"   Quality score: {review.get('quality_score', 0):.2f}/1.0")
            print(f"   Security score: {review.get('security_score', 0):.2f}/1.0")
            print(f"   Maintainability score: {review.get('maintainability_score', 0):.2f}/1.0")

findings = review.get('findings', [])
#             if findings:
                print(f"   Findings: {len(findings)} issues found")
#                 for i, finding in enumerate(findings[:3], 1):
                    print(f"     {i}. {finding.get('description', 'N/A')} (priority: {finding.get('priority', 'N/A')})")
#         else:
            print(f"❌ Review failed: {result.get('error', 'Unknown error')}")

#     def test_ai_optimize(self) -> None:
#         """Test AI optimization endpoint."""
print("\n" + " = "*60)
        print("⚡ Testing AI Performance Optimization")
print(" = "*60)

#         # Code that can be optimized
optimize_code = '''
function find_max(items)
    max_val = items[0]
    #     for i in range(len(items)):
    #         if items[i] > max_val:
    max_val = items[i]
    #     return max_val

function process_data(data)
    result = []
    #     for i in range(len(data)):
    #         for j in range(len(data[i])):
                result.append(data[i][j])
    #     return result
# '''

data = {
#             'code': optimize_code,
#             'language': 'python',
#             'file_path': 'optimize_test.py'
#         }

#         print("Analyzing code for optimization opportunities...")
result = self.make_request('/api/v1/ai/optimize', data)

#         if result.get('success'):
optimization = result['data']
            print(f"✅ Optimization analysis completed")
            print(f"   Optimization potential: {optimization.get('optimization_potential', 0):.2f}/1.0")
            print(f"   Performance impact: {optimization.get('performance_impact', 0):.2f}/1.0")

suggestions = optimization.get('suggestions', [])
#             if suggestions:
                print(f"   Optimization suggestions: {len(suggestions)} found")
#                 for i, sugg in enumerate(suggestions[:3], 1):
gain = sugg.get('performance_gain', 0)
                    print(f"     {i}. {sugg.get('description', 'N/A')}")
#                     if gain > 0:
                        print(f"        Potential gain: {gain:.2f}x performance improvement")
#             else:
                print("   No optimization opportunities found")
#         else:
            print(f"❌ Optimization analysis failed: {result.get('error', 'Unknown error')}")

#     def test_ai_explain(self) -> None:
#         """Test AI code explanation endpoint."""
print("\n" + " = "*60)
        print("📚 Testing AI Code Explanation")
print(" = "*60)

#         # Code that needs explanation
explain_code = '''
function quicksort(arr)
    #     if len(arr) <= 1:
    #         return arr
    pivot = math.divide(arr[len(arr), / 2])
    #     left = [x for x in arr if x < pivot]
    #     middle = [x for x in arr if x == pivot]
    #     right = [x for x in arr if x > pivot]
        return quicksort(left) + middle + quicksort(right)
# '''

data = {
#             'code': explain_code,
#             'language': 'python',
#             'file_path': 'explain_test.py'
#         }

        print("Generating code explanation...")
result = self.make_request('/api/v1/ai/explain', data)

#         if result.get('success'):
explanation = result['data']
            print(f"✅ Explanation generated")
            print(f"   Code summary: {explanation.get('code_summary', 'N/A')}")

details = explanation.get('detailed_explanation', {})
#             if 'algorithm' in details:
                print(f"   Algorithm: {details['algorithm']}")
#             if 'complexity' in details:
                print(f"   Time complexity: {details['complexity']}")
#             if 'usage' in details:
                print(f"   Usage: {details['usage']}")

documentation = explanation.get('generated_documentation', '')
#             if documentation:
                print(f"   Generated documentation:")
                print("   " + "\n   ".join(documentation.split('\n')[:3]))
#         else:
            print(f"❌ Explanation generation failed: {result.get('error', 'Unknown error')}")

#     def test_ai_completions(self) -> None:
#         """Test AI code completions endpoint."""
print("\n" + " = "*60)
        print("🔧 Testing AI Code Completions")
print(" = "*60)

#         # Test completion scenarios
completion_tests = [
#             {'code': 'pr', 'lang': 'python', 'desc': 'print completion'},
#             {'code': 'def ', 'lang': 'python', 'desc': 'function definition'},
#             {'code': 'for i in range(', 'lang': 'python', 'desc': 'for loop'},
#             {'code': 'func', 'lang': 'javascript', 'desc': 'function keyword'},
#             {'code': 'interface ', 'lang': 'typescript', 'desc': 'interface definition'}
#         ]

#         for test in completion_tests:
            print(f"\n--- Testing {test['desc']} ---")
data = {
#                 'code': test['code'],
#                 'language': test['lang'],
#                 'file_path': f'test.{test["lang"][:3]}'
#             }

result = self.make_request('/api/v1/ai/completions', data)

#             if result.get('success'):
suggestions = result['data'].get('suggestions', [])
                print(f"✅ Got {len(suggestions)} completions:")
#                 for i, sugg in enumerate(suggestions[:2], 1):
text = sugg.get('text', 'N/A')
confidence = sugg.get('confidence', 0)
#                     print(f"  {i}. '{text[:50]}{'...' if len(text) > 50 else ''}' (confidence: {confidence:.2f})")
#             else:
                print(f"❌ Completion failed: {result.get('error', 'Unknown error')}")

#     def test_ai_corrections(self) -> None:
#         """Test AI code corrections endpoint."""
print("\n" + " = "*60)
        print("🔧 Testing AI Code Corrections")
print(" = "*60)

#         # Code with typos
correction_tests = [
            {'code': 'prin("Hello")', 'lang': 'python', 'desc': 'print typo'},
#             {'code': 'improt os', 'lang': 'python', 'desc': 'import typo'},
            {'code': 'funciton hello() {}', 'lang': 'javascript', 'desc': 'function typo'}
#         ]

#         for test in correction_tests:
            print(f"\n--- Testing {test['desc']} ---")
data = {
#                 'code': test['code'],
#                 'language': test['lang'],
#                 'file_path': f'test.{test["lang"][:3]}'
#             }

result = self.make_request('/api/v1/ai/corrections', data)

#             if result.get('success'):
corrections = result['data'].get('corrections', [])
                print(f"✅ Got {len(corrections)} corrections:")
#                 for i, corr in enumerate(corrections[:2], 1):
text = corr.get('text', 'N/A')
confidence = corr.get('confidence', 0)
                    print(f"  {i}. '{text}' (confidence: {confidence:.2f})")
#             else:
                print(f"❌ Correction failed: {result.get('error', 'Unknown error')}")

#     def test_ai_feedback(self) -> None:
#         """Test AI user feedback endpoint."""
print("\n" + " = "*60)
        print("📝 Testing AI User Feedback")
print(" = "*60)

feedback_data = {
#             'session_id': 'demo_session_123',
#             'suggestion_id': 'suggestion_456',
#             'suggestion_type': 'completion',
#             'feedback_value': 0.8,
#             'context': {
#                 'language': 'python',
#                 'file_path': 'demo.py',
#                 'cursor_position': {'line': 1, 'column': 4}
#             }
#         }

        print("Recording user feedback...")
result = self.make_request('/api/v1/ai/feedback', feedback_data)

#         if result.get('success'):
            print(f"✅ Feedback recorded successfully")
            print(f"   Session ID: {feedback_data['session_id']}")
            print(f"   Suggestion ID: {feedback_data['suggestion_id']}")
            print(f"   Feedback value: {feedback_data['feedback_value']}")
#         else:
            print(f"❌ Feedback recording failed: {result.get('error', 'Unknown error')}")

#     def test_ai_status(self) -> None:
#         """Test AI service status endpoint."""
print("\n" + " = "*60)
        print("📊 Testing AI Service Status")
print(" = "*60)

#         try:
response = requests.get(f"{self.server_url}/api/v1/ai/status", timeout=10)
result = response.json()

#             if result.get('success'):
status = result['data']
                print(f"✅ AI Service Status")
                print(f"   Service: {status.get('service', 'N/A')}")
                print(f"   Version: {status.get('version', 'N/A')}")
                print(f"   Status: {status.get('status', 'N/A')}")
                print(f"   Supported languages: {', '.join(status.get('supported_languages', []))}")

stats = status.get('statistics', {})
#                 if stats:
                    print(f"   Statistics:")
#                     for key, value in stats.items():
                        print(f"     {key}: {value}")
#             else:
                print(f"❌ Status check failed: {result.get('error', 'Unknown error')}")
#         except Exception as e:
            print(f"❌ Status request failed: {str(e)}")

#     def run_all_tests(self) -> None:
#         """Run all AI API tests."""
        print("🚀 NoodleCore AI Backend APIs Demonstration")
print(" = "*80)
        print(f"Server URL: {self.server_url}")
        print(f"Request ID: {self.request_id}")

#         # Test all endpoints
        self.test_ai_status()
        self.test_ai_analyze()
        self.test_ai_suggest()
        self.test_ai_review()
        self.test_ai_optimize()
        self.test_ai_explain()
        self.test_ai_completions()
        self.test_ai_corrections()
        self.test_ai_feedback()

print("\n" + " = "*80)
        print("🎉 Demonstration Complete!")
print(" = "*80)
        print("\nAvailable AI Endpoints:")
        print("  POST /api/v1/ai/analyze - Real-time code analysis")
        print("  POST /api/v1/ai/suggest - AI-powered suggestions")
        print("  POST /api/v1/ai/review - Code quality analysis")
        print("  POST /api/v1/ai/optimize - Performance optimization")
        print("  POST /api/v1/ai/explain - Code documentation")
        print("  POST /api/v1/ai/completions - Code completions")
        print("  POST /api/v1/ai/corrections - Code corrections")
        print("  POST /api/v1/ai/feedback - User feedback")
        print("  GET  /api/v1/ai/status - Service status")
        print("\nFeatures implemented:")
        print("  ✅ Multi-language support (Python, JavaScript, TypeScript, Noodle)")
        print("  ✅ Real-time code analysis and suggestions")
        print("  ✅ Performance optimization recommendations")
        print("  ✅ Security and quality analysis")
        print("  ✅ Code explanation and documentation")
        print("  ✅ User feedback learning system")
#         print("  ✅ WebSocket support for real-time features")
        print("  ✅ Monaco Editor integration ready")

function main()
    #     """Main demonstration function."""
    parser = argparse.ArgumentParser(description='NoodleCore AI Backend APIs Demonstration')
    parser.add_argument('--server-url', default = DEFAULT_SERVER_URL,
    help = f'Server URL (default: {DEFAULT_SERVER_URL})')
    parser.add_argument('--timeout', type = int, default=30,
    help = 'Request timeout in seconds (default: 30)')

    args = parser.parse_args()

    #     # Verify server is running
    #     try:
    response = requests.get(f"{args.server_url}/api/v1/health", timeout=5)
    #         if response.status_code != 200:
                print(f"❌ Server is not responding properly at {args.server_url}")
                print("Please ensure the NoodleCore server is running.")
                sys.exit(1)
    #     except Exception:
            print(f"❌ Cannot connect to server at {args.server_url}")
            print("Please ensure the NoodleCore server is running.")
            sys.exit(1)

    #     # Run demonstration
    demo = NoodleCoreAIDemo(args.server_url)
        demo.run_all_tests()

if __name__ == '__main__'
        main()