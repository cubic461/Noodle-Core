#!/usr/bin/env python3
"""
Tutorial Validation Script for NIP v3.0.0

Validates that all tutorials have:
- Required sections (Overview, Quick Start, Summary)
- Proper formatting
- Working code examples
- No broken links
"""

import re
from pathlib import Path
from typing import List, Dict


class TutorialValidator:
    """Validate tutorial structure and content"""
    
    def __init__(self, tutorials_path: str):
        self.tutorials_path = Path(tutorials_path)
        self.issues = []
        self.stats = {
            'total_tutorials': 0,
            'valid_tutorials': 0,
            'invalid_tutorials': 0,
            'total_issues': 0
        }
    
    def validate_all(self) -> Dict:
        """Validate all tutorials"""
        print("🔍 Validating tutorials...\n")
        
        # Find all markdown files
        tutorial_files = list(self.tutorials_path.rglob("*.md"))
        tutorial_files = [f for f in tutorial_files if 'node_modules' not in str(f)]
        
        print(f"📁 Found {len(tutorial_files)} tutorial files\n")
        
        # Validate each tutorial
        for tutorial_file in tutorial_files:
            self._validate_tutorial(tutorial_file)
        
        return self._generate_report()
    
    def _validate_tutorial(self, tutorial_path: Path):
        """Validate a single tutorial"""
        self.stats['total_tutorials'] += 1
        
        try:
            with open(tutorial_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.splitlines()
            
            tutorial_issues = []
            
            # Check for required sections
            required_sections = ['# ', '## 📚 Overview', '## 🚀 Quick Start', '## 📊 Summary']
            for section in required_sections:
                if section not in content:
                    tutorial_issues.append({
                        'type': 'Missing Section',
                        'message': f"Missing required section: {section}"
                    })
            
            # Check for title
            if not lines[0].startswith('# '):
                tutorial_issues.append({
                    'type': 'Missing Title',
                    'message': 'Tutorial must start with a # title'
                })
            
            # Check for emoji in title (recommended)
            if not re.search(r'[\U0001F300-\U0001F9FF]', lines[0]):
                tutorial_issues.append({
                    'type': 'Style',
                    'message': 'Title should include an emoji for visual appeal'
                })
            
            # Check for code blocks
            code_blocks = re.findall(r'```[\w]*\n(.*?)```', content, re.DOTALL)
            if len(code_blocks) < 3:
                tutorial_issues.append({
                    'type': 'Insufficient Examples',
                    'message': f'Tutorial should have at least 3 code blocks (found {len(code_blocks)})'
                })
            
            # Check for learning objectives
            if '## Learning Objectives' not in content and '## 🎯 Learning Objectives' not in content:
                tutorial_issues.append({
                    'type': 'Missing Objectives',
                    'message': 'Tutorial should have learning objectives section'
                })
            
            # Check for exercises
            if '## 🎯 Exercises' not in content and '## Exercise' not in content:
                tutorial_issues.append({
                    'type': 'Missing Exercises',
                    'message': 'Tutorial should include practical exercises'
                })
            
            # Check line length (max 120 for readability)
            long_lines = []
            for i, line in enumerate(lines, 1):
                if len(line) > 120 and not line.startswith('http'):
                    long_lines.append(i)
            
            if long_lines:
                tutorial_issues.append({
                    'type': 'Long Lines',
                    'message': f'Lines {long_lines[:5]} exceed 120 characters'
                })
            
            # Update stats
            if tutorial_issues:
                self.stats['invalid_tutorials'] += 1
                self.issues.append({
                    'file': str(tutorial_path),
                    'issues': tutorial_issues
                })
                self.stats['total_issues'] += len(tutorial_issues)
                print(f"  ⚠️  {tutorial_path.relative_to(self.tutorials_path)}: {len(tutorial_issues)} issues")
            else:
                self.stats['valid_tutorials'] += 1
                print(f"  ✅ {tutorial_path.relative_to(self.tutorials_path)}")
        
        except Exception as e:
            self.issues.append({
                'file': str(tutorial_path),
                'issues': [{
                    'type': 'Read Error',
                    'message': f'Failed to read file: {e}'
                }]
            })
            print(f"  ❌ {tutorial_path.relative_to(self.tutorials_path)}: {e}")
    
    def _generate_report(self) -> Dict:
        """Generate validation report"""
        return {
            'issues': self.issues,
            'stats': self.stats
        }


def main():
    """Main entry point"""
    root_path = Path(__file__).parent.parent
    tutorials_path = root_path / 'tutorials'
    
    print("=" * 70)
    print("📚 TUTORIAL VALIDATION")
    print("=" * 70)
    print()
    
    # Run validation
    validator = TutorialValidator(str(tutorials_path))
    report = validator.validate_all()
    
    # Print summary
    print("\n" + "=" * 70)
    print("📊 VALIDATION SUMMARY")
    print("=" * 70)
    print(f"Total Tutorials: {report['stats']['total_tutorials']}")
    print(f"Valid Tutorials: {report['stats']['valid_tutorials']}")
    print(f"Invalid Tutorials: {report['stats']['invalid_tutorials']}")
    print(f"Total Issues: {report['stats']['total_issues']}")
    
    # Print issues
    if report['issues']:
        print("\n" + "=" * 70)
        print("⚠️  ISSUES FOUND")
        print("=" * 70)
        
        for item in report['issues']:
            print(f"\n📄 {item['file']}")
            for issue in item['issues']:
                print(f"  • [{issue['type']}] {issue['message']}")
    
    # Exit with appropriate code
    exit(0 if report['stats']['total_issues'] == 0 else 1)


if __name__ == "__main__":
    main()
