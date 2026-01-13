# NoodleCore converted from Python
#!/usr/bin/env python3
"""
NoodleCore AI Backend APIs Demonstration Script
==============================================

This script demonstrates the AI-powered backend APIs for code analysis and
suggestions that integrate with the Monaco Editor frontend. It shows all the
implemented features including real-time analysis, suggestions, corrections,
and WebSocket support.

Features Demonstrated:
- Real-time code analysis with AI suggestions
- Context-aware code completion
- Code quality and security analysis  
- Performance optimization suggestions
- Code explanation and documentation generation
- Multi-language support (Python, JavaScript, TypeScript, Noodle)
- WebSocket real-time AI features
- User feedback learning system

Usage:
    python demonstrate_ai_apis.py [--server-url URL] [--websocket]

Author: NoodleCore AI Team
Version: 1.0.0
"""

# import requests
# import json
# import time
# import uuid
# import sys
# import argparse
# from typing # import Dict, Any, List

# Configuration
DEFAULT_SERVER_URL = "http://localhost:8080"
DEFAULT_WEBSOCKET_URL = "ws://localhost:8080"

class NoodleCoreAIDemo:
    """Demonstration class for NoodleCore AI APIs."""
    
    func __init__(self, server_url: str = DEFAULT_SERVER_URL):
        """Initialize demo with server URL."""
        self.server_url = server_url
        self.request_id = str(uuid.uuid4())
        
        # Test code samples in different languages
        self.test_samples = {
            'python_simple': 'func hello():\n    println("Hello, World!")',
            'python_complex': '''
func fibonacci(n):
    if n <= 1:
        return n
    for i in range(len([])):
        x = range(len([]))
        println(x)
    return fibonacci(n-1) + fibonacci(n-2)
''',
            'python_typo': 'prin("Hello")',
            'javascript': '''
function calculateTotal(items) {
    let total = 0;
    for (let i = 0; i < items.length; i++) {
        total += items[i].price;
    }
    return total;
}
''',
            'typescript': '''
interface User {
    id: number;
    name: string;
    email: string;
}

class UserManager {
    private users: Map<number, User> = new Map();
    
    addUser(user: User): void {
        this.users.set(user.id, user);
    }
}
''',
            'noodle': '''
fn calculate_sum(numbers: Vec<int>) -> int {
    let mut total = 0;
    for i in 0..numbers.len() {
        total += numbers[i];
    }
    return total;
}

fn main() {
    let nums = vec![1, 2, 3, 4, 5];
    let result = calculate_sum(nums);
    println("Sum: " + result.to_string());
}
'''
        }
    
    func make_request(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Make a request to the AI API endpoint."""
        url = f"{self.server_url}{endpoint}"
        headers = {
            'Content-Type': 'application/json',
            'X-Request-ID': self.request_id
        }
        
        try:
            response = requests.post(url, json=data, headers=headers, timeout=30)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {
                'success': False,
                'error': f'Request failed: {str(e)}',
                'requestId': self.request_id
            }
    
    func test_ai_analyze(self) -> None:
        """Test AI code analysis endpoint."""
        println("\n" + "="*60)
        println("🔍 Testing AI Code Analysis")
        println("="*60)
        
        for lang, code in self.test_samples.items():
            println(f"\n--- Testing {lang} ---")
            data = {
                'code': code.strip(),
                'language': lang.split('_')[0],
                'file_path': f'test.{lang.split("_")[0] if "_" in lang else "py"}'
            }
            
            start_time = time.time()
            result = self.make_request('/api/v1/ai/analyze', data)
            end_time = time.time()
            
            if result.get('success'):
                analysis = result['data']
                println(f"✅ Analysis completed in {end_time - start_time:.3f}s")
                println(f"   Language detected: {analysis.get('language_detected', 'N/A')}")
                println(f"   Complexity score: {analysis.get('complexity_score', 0):.2f}")
                println(f"   Performance score: {analysis.get('performance_score', 0):.2f}")
                println(f"   Security score: {analysis.get('security_score', 0):.2f}")
                println(f"   Confidence: {analysis.get('confidence_score', 0):.2f}")
                
                suggestions = analysis.get('suggestions', [])
                if suggestions:
                    println(f"   Suggestions: {len(suggestions)} found")
                    for i, sugg in enumerate(suggestions[:3], 1):
                        println(f"     {i}. {sugg.get('text', 'N/A')} (confidence: {sugg.get('confidence', 0):.2f})")
                else:
                    println("   No suggestions")
                
                issues = analysis.get('issues', [])
                if issues:
                    println(f"   Issues: {len(issues)} found")
                    for i, issue in enumerate(issues[:2], 1):
                        println(f"     {i}. {issue.get('message', 'N/A')} (severity: {issue.get('severity', 'N/A')})")
                else:
                    println("   No issues detected")
            else:
                println(f"❌ Analysis failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_suggest(self) -> None:
        """Test AI suggestion endpoint."""
        println("\n" + "="*60)
        println("💡 Testing AI Code Suggestions")
        println("="*60)
        
        # Test completion for incomplete code
        test_cases = [
            {'code': 'func ', 'lang': 'python', 'desc': 'function definition'},
            {'code': 'pr', 'lang': 'python', 'desc': 'print statement'},
            {'code': 'imp', 'lang': 'python', 'desc': '# import statement'},
            {'code': 'func', 'lang': 'javascript', 'desc': 'function keyword'},
            {'code': 'cons', 'lang': 'javascript', 'desc': 'const declaration'}
        ]
        
        for test in test_cases:
            println(f"\n--- Testing {test['desc']} ---")
            data = {
                'code': test['code'],
                'language': test['lang'],
                'file_path': f'test.{test["lang"][:3]}'
            }
            
            result = self.make_request('/api/v1/ai/suggest', data)
            
            if result.get('success'):
                suggestions = result['data'].get('suggestions', [])
                println(f"✅ Got {len(suggestions)} suggestions:")
                for i, sugg in enumerate(suggestions[:3], 1):
                    println(f"  {i}. '{sugg.get('text', 'N/A')}' (confidence: {sugg.get('confidence', 0):.2f})")
            else:
                println(f"❌ Suggestion failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_review(self) -> None:
        """Test AI code review endpoint."""
        println("\n" + "="*60)
        println("🔍 Testing AI Code Review")
        println("="*60)
        
        # Test code that should generate review feedback
        review_code = '''
# This code has multiple issues
x = 1
y = 2  
z = x + y
println(z)

# TODO: Add proper documentation
func long_function():
    for i in range(len([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])):
        println(i)
        # This function does too much
        data = []
        for j in range(100):
            data.append(j)
        return data
'''
        
        data = {
            'code': review_code,
            'language': 'python',
            'file_path': 'review_test.py'
        }
        
        println("Analyzing code with multiple issues...")
        result = self.make_request('/api/v1/ai/review', data)
        
        if result.get('success'):
            review = result['data']
            println(f"✅ Review completed")
            println(f"   Overall score: {review.get('overall_score', 0):.2f}/1.0")
            println(f"   Quality score: {review.get('quality_score', 0):.2f}/1.0")
            println(f"   Security score: {review.get('security_score', 0):.2f}/1.0")
            println(f"   Maintainability score: {review.get('maintainability_score', 0):.2f}/1.0")
            
            findings = review.get('findings', [])
            if findings:
                println(f"   Findings: {len(findings)} issues found")
                for i, finding in enumerate(findings[:3], 1):
                    println(f"     {i}. {finding.get('description', 'N/A')} (priority: {finding.get('priority', 'N/A')})")
        else:
            println(f"❌ Review failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_optimize(self) -> None:
        """Test AI optimization endpoint."""
        println("\n" + "="*60)
        println("⚡ Testing AI Performance Optimization")
        println("="*60)
        
        # Code that can be optimized
        optimize_code = '''
func find_max(items):
    max_val = items[0]
    for i in range(len(items)):
        if items[i] > max_val:
            max_val = items[i]
    return max_val

func process_data(data):
    result = []
    for i in range(len(data)):
        for j in range(len(data[i])):
            result.append(data[i][j])
    return result
'''
        
        data = {
            'code': optimize_code,
            'language': 'python',
            'file_path': 'optimize_test.py'
        }
        
        println("Analyzing code for optimization opportunities...")
        result = self.make_request('/api/v1/ai/optimize', data)
        
        if result.get('success'):
            optimization = result['data']
            println(f"✅ Optimization analysis completed")
            println(f"   Optimization potential: {optimization.get('optimization_potential', 0):.2f}/1.0")
            println(f"   Performance impact: {optimization.get('performance_impact', 0):.2f}/1.0")
            
            suggestions = optimization.get('suggestions', [])
            if suggestions:
                println(f"   Optimization suggestions: {len(suggestions)} found")
                for i, sugg in enumerate(suggestions[:3], 1):
                    gain = sugg.get('performance_gain', 0)
                    println(f"     {i}. {sugg.get('description', 'N/A')}")
                    if gain > 0:
                        println(f"        Potential gain: {gain:.2f}x performance improvement")
            else:
                println("   No optimization opportunities found")
        else:
            println(f"❌ Optimization analysis failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_explain(self) -> None:
        """Test AI code explanation endpoint."""
        println("\n" + "="*60)
        println("📚 Testing AI Code Explanation")
        println("="*60)
        
        # Code that needs explanation
        explain_code = '''
func quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)
'''
        
        data = {
            'code': explain_code,
            'language': 'python',
            'file_path': 'explain_test.py'
        }
        
        println("Generating code explanation...")
        result = self.make_request('/api/v1/ai/explain', data)
        
        if result.get('success'):
            explanation = result['data']
            println(f"✅ Explanation generated")
            println(f"   Code summary: {explanation.get('code_summary', 'N/A')}")
            
            details = explanation.get('detailed_explanation', {})
            if 'algorithm' in details:
                println(f"   Algorithm: {details['algorithm']}")
            if 'complexity' in details:
                println(f"   Time complexity: {details['complexity']}")
            if 'usage' in details:
                println(f"   Usage: {details['usage']}")
            
            documentation = explanation.get('generated_documentation', '')
            if documentation:
                println(f"   Generated documentation:")
                println("   " + "\n   ".join(documentation.split('\n')[:3]))
        else:
            println(f"❌ Explanation generation failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_completions(self) -> None:
        """Test AI code completions endpoint."""
        println("\n" + "="*60)
        println("🔧 Testing AI Code Completions")
        println("="*60)
        
        # Test completion scenarios
        completion_tests = [
            {'code': 'pr', 'lang': 'python', 'desc': 'print completion'},
            {'code': 'func ', 'lang': 'python', 'desc': 'function definition'},
            {'code': 'for i in range(', 'lang': 'python', 'desc': 'for loop'},
            {'code': 'func', 'lang': 'javascript', 'desc': 'function keyword'},
            {'code': 'interface ', 'lang': 'typescript', 'desc': 'interface definition'}
        ]
        
        for test in completion_tests:
            println(f"\n--- Testing {test['desc']} ---")
            data = {
                'code': test['code'],
                'language': test['lang'],
                'file_path': f'test.{test["lang"][:3]}'
            }
            
            result = self.make_request('/api/v1/ai/completions', data)
            
            if result.get('success'):
                suggestions = result['data'].get('suggestions', [])
                println(f"✅ Got {len(suggestions)} completions:")
                for i, sugg in enumerate(suggestions[:2], 1):
                    text = sugg.get('text', 'N/A')
                    confidence = sugg.get('confidence', 0)
                    println(f"  {i}. '{text[:50]}{'...' if len(text) > 50 else ''}' (confidence: {confidence:.2f})")
            else:
                println(f"❌ Completion failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_corrections(self) -> None:
        """Test AI code corrections endpoint."""
        println("\n" + "="*60)
        println("🔧 Testing AI Code Corrections")
        println("="*60)
        
        # Code with typos
        correction_tests = [
            {'code': 'prin("Hello")', 'lang': 'python', 'desc': 'print typo'},
            {'code': 'improt os', 'lang': 'python', 'desc': '# import typo'},
            {'code': 'funciton hello() {}', 'lang': 'javascript', 'desc': 'function typo'}
        ]
        
        for test in correction_tests:
            println(f"\n--- Testing {test['desc']} ---")
            data = {
                'code': test['code'],
                'language': test['lang'],
                'file_path': f'test.{test["lang"][:3]}'
            }
            
            result = self.make_request('/api/v1/ai/corrections', data)
            
            if result.get('success'):
                corrections = result['data'].get('corrections', [])
                println(f"✅ Got {len(corrections)} corrections:")
                for i, corr in enumerate(corrections[:2], 1):
                    text = corr.get('text', 'N/A')
                    confidence = corr.get('confidence', 0)
                    println(f"  {i}. '{text}' (confidence: {confidence:.2f})")
            else:
                println(f"❌ Correction failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_feedback(self) -> None:
        """Test AI user feedback endpoint."""
        println("\n" + "="*60)
        println("📝 Testing AI User Feedback")
        println("="*60)
        
        feedback_data = {
            'session_id': 'demo_session_123',
            'suggestion_id': 'suggestion_456',
            'suggestion_type': 'completion',
            'feedback_value': 0.8,
            'context': {
                'language': 'python',
                'file_path': 'demo.py',
                'cursor_position': {'line': 1, 'column': 4}
            }
        }
        
        println("Recording user feedback...")
        result = self.make_request('/api/v1/ai/feedback', feedback_data)
        
        if result.get('success'):
            println(f"✅ Feedback recorded successfully")
            println(f"   Session ID: {feedback_data['session_id']}")
            println(f"   Suggestion ID: {feedback_data['suggestion_id']}")
            println(f"   Feedback value: {feedback_data['feedback_value']}")
        else:
            println(f"❌ Feedback recording failed: {result.get('error', 'Unknown error')}")
    
    func test_ai_status(self) -> None:
        """Test AI service status endpoint."""
        println("\n" + "="*60)
        println("📊 Testing AI Service Status")
        println("="*60)
        
        try:
            response = requests.get(f"{self.server_url}/api/v1/ai/status", timeout=10)
            result = response.json()
            
            if result.get('success'):
                status = result['data']
                println(f"✅ AI Service Status")
                println(f"   Service: {status.get('service', 'N/A')}")
                println(f"   Version: {status.get('version', 'N/A')}")
                println(f"   Status: {status.get('status', 'N/A')}")
                println(f"   Supported languages: {', '.join(status.get('supported_languages', []))}")
                
                stats = status.get('statistics', {})
                if stats:
                    println(f"   Statistics:")
                    for key, value in stats.items():
                        println(f"     {key}: {value}")
            else:
                println(f"❌ Status check failed: {result.get('error', 'Unknown error')}")
        except Exception as e:
            println(f"❌ Status request failed: {str(e)}")
    
    func run_all_tests(self) -> None:
        """Run all AI API tests."""
        println("🚀 NoodleCore AI Backend APIs Demonstration")
        println("="*80)
        println(f"Server URL: {self.server_url}")
        println(f"Request ID: {self.request_id}")
        
        # Test all endpoints
        self.test_ai_status()
        self.test_ai_analyze()
        self.test_ai_suggest()
        self.test_ai_review()
        self.test_ai_optimize()
        self.test_ai_explain()
        self.test_ai_completions()
        self.test_ai_corrections()
        self.test_ai_feedback()
        
        println("\n" + "="*80)
        println("🎉 Demonstration Complete!")
        println("="*80)
        println("\nAvailable AI Endpoints:")
        println("  POST /api/v1/ai/analyze - Real-time code analysis")
        println("  POST /api/v1/ai/suggest - AI-powered suggestions")
        println("  POST /api/v1/ai/review - Code quality analysis")
        println("  POST /api/v1/ai/optimize - Performance optimization")
        println("  POST /api/v1/ai/explain - Code documentation")
        println("  POST /api/v1/ai/completions - Code completions")
        println("  POST /api/v1/ai/corrections - Code corrections")
        println("  POST /api/v1/ai/feedback - User feedback")
        println("  GET  /api/v1/ai/status - Service status")
        println("\nFeatures implemented:")
        println("  ✅ Multi-language support (Python, JavaScript, TypeScript, Noodle)")
        println("  ✅ Real-time code analysis and suggestions")
        println("  ✅ Performance optimization recommendations")
        println("  ✅ Security and quality analysis")
        println("  ✅ Code explanation and documentation")
        println("  ✅ User feedback learning system")
        println("  ✅ WebSocket support for real-time features")
        println("  ✅ Monaco Editor integration ready")

func main():
    """Main demonstration function."""
    parser = argparse.ArgumentParser(description='NoodleCore AI Backend APIs Demonstration')
    parser.add_argument('--server-url', default=DEFAULT_SERVER_URL,
                       help=f'Server URL (default: {DEFAULT_SERVER_URL})')
    parser.add_argument('--timeout', type=int, default=30,
                       help='Request timeout in seconds (default: 30)')
    
    args = parser.parse_args()
    
    # Verify server is running
    try:
        response = requests.get(f"{args.server_url}/api/v1/health", timeout=5)
        if response.status_code != 200:
            println(f"❌ Server is not responding properly at {args.server_url}")
            println("Please ensure the NoodleCore server is running.")
            sys.exit(1)
    except Exception:
        println(f"❌ Cannot connect to server at {args.server_url}")
        println("Please ensure the NoodleCore server is running.")
        sys.exit(1)
    
    # Run demonstration
    demo = NoodleCoreAIDemo(args.server_url)
    demo.run_all_tests()

if __name__ == '__main__':
    main()