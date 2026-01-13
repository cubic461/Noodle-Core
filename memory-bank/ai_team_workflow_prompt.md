# 🤖 AI Team Workflow Prompt for Noodle Development

## 📋 Overview

This document provides a comprehensive workflow prompt for AI team members working on the Noodle programming language development. The workflow is designed to ensure consistency, quality, and knowledge sharing while preventing repeated mistakes through structured learning and validation processes.

## 🎯 Core Principles

### 1. **Context-First Development**
- Every task begins with comprehensive context gathering
- Project specifications, solution database entries, and memory bank lessons are mandatory
- No task execution without proper context enrichment

### 2. **Iterative Quality Assurance**
- Multi-stage validation process with automated and manual checks
- Continuous feedback loops and improvement cycles
- Quality gates that must be passed before progression

### 3. **Knowledge Preservation**
- Automatic capture of lessons learned and successful solutions
- Structured solution database with rating system
- Context-aware knowledge retrieval and application

### 4. **Role-Based Collaboration**
- Clear role definitions and responsibilities
- Cross-role validation and peer review
- Specialized expertise applied appropriately

---

## 🔄 Workflow Process

### Phase 1: Context Enrichment (Spec Wrapper)

#### 1.1 Mandatory Context Components
Every task input is enriched with:

```json
{
  "task": "Original task description",
  "context": {
    "specifications": {
      "requirements": [
        "List of specific requirements from project docs",
        "Language design decisions",
        "Architecture constraints"
      ],
      "constraints": [
        "Technical limitations",
        "Compatibility requirements",
        "Performance targets"
      ]
    },
    "solution_database": {
      "relevant_solutions": [
        {
          "id": "sol_001",
          "title": "Solution title",
          "rating": 5,
          "description": "Brief description",
          "problem": "Problem addressed",
          "solution": "Approach used",
          "lessons_learned": "Key insights",
          "applicability": "When to use"
        }
      ],
      "search_keywords": ["relevant", "keywords", "for", "current", "task"]
    },
    "memory_bank": {
      "lessons_learned": [
        {
          "id": "lesson_001",
          "title": "Lesson title",
          "description": "What was learned",
          "application": "How to apply",
          "prevention": "How to prevent issues",
          "context": "When relevant"
        }
      ],
      "avoid_mistakes": [
        "Common mistakes to avoid",
        "Pitfalls in similar tasks",
        "Anti-patterns to recognize"
      ]
    }
  },
  "validation_criteria": {
    "spec_compliance": "Check if output meets specifications",
    "solution_application": "Verify solution database entries are applied",
    "lessons_applied": "Ensure lessons learned are implemented",
    "quality_standards": "Check against project quality metrics"
  }
}
```

#### 1.2 Context Gathering Procedure
1. **Search Solution Database**: Query for relevant solutions using task keywords
2. **Review Memory Bank**: Extract applicable lessons and avoid mistakes
3. **Check Project Specifications**: Review language specs and architecture docs
4. **Enrich Task**: Combine all context into enhanced task specification

### Phase 2: Pre-Hook Query

#### 2.1 Knowledge Retrieval Process
Before task execution:

1. **Problem Analysis**: Break down task into sub-problems
2. **Solution Matching**: Map sub-problems to solution database entries
3. **Lesson Application**: Identify relevant lessons learned
4. **Risk Assessment**: Identify potential pitfalls and prevention measures

#### 2.2 Query Template
```python
def pre_hook_query(task_context):
    """
    Execute pre-hook query to gather relevant knowledge
    """
    knowledge_base = {
        'solutions': query_solution_database(task_context['keywords']),
        'lessons': query_memory_bank(task_context['problem_type']),
        'specifications': get_project_specifications(task_context['domain'])
    }

    return {
        'enriched_task': enrich_task_with_context(task_context, knowledge_base),
        'risks': identify_potential_risks(knowledge_base),
        'approach': recommend_approach(knowledge_base)
    }
```

### Phase 3: Task Execution

#### 3.1 Execution Guidelines
1. **Context-Aware Implementation**: Apply retrieved knowledge throughout execution
2. **Incremental Progress**: Work in small, verifiable steps
3. **Documentation**: Document decisions and reasoning
4. **Quality Checks**: Perform self-validation at each step

#### 3.2 Implementation Pattern
```python
def execute_task(enriched_task):
    """
    Execute task with full context awareness
    """
    # Step 1: Apply solution database entries
    for solution in enriched_task['context']['solution_database']['relevant_solutions']:
        apply_solution(solution)

    # Step 2: Implement lessons learned
    for lesson in enriched_task['context']['memory_bank']['lessons_learned']:
        apply_lesson(lesson)

    # Step 3: Execute main task
    result = implement_main_task(enriched_task['task'])

    # Step 4: Self-validation
    validate_against_criteria(result, enriched_task['validation_criteria'])

    return result
```

### Phase 4: Validation (Quality Gate)

#### 4.1 Multi-Level Validation
1. **Automated Validation**: Technical correctness and compliance checks
2. **Spec Compliance**: Verification against project specifications
3. **Solution Application**: Confirmation that solution database entries were applied
4. **Lesson Implementation**: Verification that lessons learned were implemented

#### 4.2 Validation Process
```python
def validate_output(output, validation_criteria):
    """
    Multi-level validation of task output
    """
    validation_results = {
        'automated_checks': perform_automated_validation(output),
        'spec_compliance': check_spec_compliance(output, validation_criteria['spec_compliance']),
        'solution_application': verify_solution_application(output, validation_criteria['solution_application']),
        'lessons_applied': verify_lessons_applied(output, validation_criteria['lessons_applied']),
        'quality_standards': check_quality_standards(output, validation_criteria['quality_standards'])
    }

    overall_result = all(validation_results.values())

    return {
        'passed': overall_result,
        'details': validation_results,
        'feedback': generate_feedback(validation_results)
    }
```

#### 4.3 Failure Handling
If validation fails:
1. **Root Cause Analysis**: Identify why validation failed
2. **Correction Plan**: Develop plan to address failures
3. **Re-execution**: Re-execute task with corrections
4. **Learning Capture**: Document the failure and solution

### Phase 5: Context Digest

#### 5.1 Information Overload Management
To prevent context overload:

1. **Relevance Filtering**: Only include most relevant information
2. **Summarization**: Create concise summaries (max 500 tokens)
3. **Prioritization**: Focus on high-impact, high-relevance items
4. **Context Awareness**: Adapt context based on task nature

#### 5.2 Digest Creation Process
```python
def create_context_digest(full_context):
    """
    Create concise context digest to prevent information overload
    """
    digest = {
        'critical_specifications': filter_by_importance(full_context['specifications'], 'critical'),
        'high_relevance_solutions': filter_by_relevance(full_context['solution_database']['solutions'], 0.8),
        'key_lessons': filter_by_applicability(full_context['memory_bank']['lessons_learned'], 0.9),
        'avoid_mistakes': get_top_mistakes_to_avoid(full_context['memory_bank']['avoid_mistakes']),
        'validation_focus': identify_critical_validation_areas(full_context)
    }

    # Ensure digest stays within token limits
    digest = ensure_token_limit(digest, max_tokens=500)

    return digest
```

---

## 🛠️ Implementation Details

### Solution Database Integration

#### Query Strategy
```python
def query_solution_database(keywords, task_type=None, max_results=5):
    """
    Query solution database with intelligent matching
    """
    # Extract keywords from task
    task_keywords = extract_keywords(keywords)

    # Query database
    results = []
    for entry in solution_database.entries:
        relevance_score = calculate_relevance(task_keywords, entry.keywords)
        if relevance_score > 0.6:  # Minimum relevance threshold
            results.append({
                'entry': entry,
                'relevance': relevance_score,
                'applicability': assess_applicability(entry, task_type)
            })

    # Sort by relevance and return top results
    return sorted(results, key=lambda x: x['relevance'], reverse=True)[:max_results]
```

### Memory Bank Integration

#### Lesson Application
```python
def apply_lessons_learned(lessons, task_context):
    """
    Apply relevant lessons learned to current task
    """
    applied_lessons = []

    for lesson in lessons:
        if is_lesson_applicable(lesson, task_context):
            try:
                # Apply lesson prevention measures
                prevention_measures = lesson.get('prevention', [])
                for measure in prevention_measures:
                    apply_prevention_measure(measure, task_context)

                applied_lessons.append({
                    'lesson_id': lesson.id,
                    'title': lesson.title,
                    'applied': True,
                    'measures_applied': prevention_measures
                })
            except Exception as e:
                log_lesson_application_failure(lesson, e)

    return applied_lessons
```

### Role Assignment Integration

#### Role-Based Context Enhancement
```python
def enhance_context_for_role(context, role):
    """
    Enhance context based on assigned role
    """
    role_specific_context = {
        'Project Architect': {
            'focus_areas': ['architecture', 'design_patterns', 'scalability'],
            'validation_priorities': ['spec_compliance', 'design_consistency']
        },
        'Code Implementation Specialist': {
            'focus_areas': ['code_quality', 'performance', 'testing'],
            'validation_priorities': ['code_standards', 'test_coverage']
        },
        'Quality Assurance Specialist': {
            'focus_areas': ['testing', 'validation', 'error_handling'],
            'validation_priorities': ['comprehensive_testing', 'edge_cases']
        }
    }

    if role in role_specific_context:
        context['role_focus'] = role_specific_context[role]['focus_areas']
        context['validation_priorities'] = role_specific_context[role]['validation_priorities']

    return context
```

---

## 📊 Quality Metrics

### Success Metrics
1. **Context Application Rate**: >90% of relevant solutions and lessons applied
2. **Validation Pass Rate**: >95% of tasks pass validation on first attempt
3. **Knowledge Reuse Rate**: >80% of tasks use existing solutions
4. **Error Reduction**: >70% reduction in repeated errors

### Quality Gates
1. **Spec Compliance**: Output must meet all specifications
2. **Solution Application**: Relevant solutions must be applied
3. **Lesson Implementation**: Key lessons must be implemented
4. **Quality Standards**: Output must meet project quality standards

---

## 🔄 Continuous Improvement

### Learning Loop
1. **Task Completion**: Document what worked well
2. **Validation Results**: Record validation outcomes
3. **Solution Rating**: Update solution database ratings
4. **Lesson Capture**: Add new lessons learned

### System Enhancement
1. **Context Optimization**: Improve context relevance over time
2. **Validation Enhancement**: Strengthen validation criteria
3. **Knowledge Base Growth**: Expand solution database and memory bank
4. **Workflow Adaptation**: Evolve workflow based on experience

---

## 🚀 Implementation Plan

### Phase 1: Foundation Setup
1. **Context System Implementation**: Build context gathering and enrichment system
2. **Solution Database Integration**: Connect workflow to existing solution database
3. **Memory Bank Integration**: Connect workflow to existing memory bank
4. **Validation Framework**: Implement multi-level validation system

### Phase 2: Workflow Integration
1. **Role Integration**: Connect with existing role assignment system
2. **Tool Integration**: Integrate with existing development tools
3. **Documentation Update**: Update project documentation with new workflow
4. **Team Training**: Train team on new workflow processes

### Phase 3: Optimization and Scaling
1. **Performance Optimization**: Optimize context processing and validation
2. **Scalability Testing**: Test with large numbers of concurrent tasks
3. **Feedback Integration**: Collect and incorporate team feedback
4. **Continuous Improvement**: Establish ongoing improvement processes

---

## 📝 Example Usage

### Task: "Build the parser for expressions"

#### Context Enrichment
```json
{
  "task": "Build the parser for expressions",
  "context": {
    "specifications": {
      "requirements": [
        "Whitespace is not significant",
        "Support operator associativity and precedence"
      ],
      "constraints": [
        "Keep grammar modular",
        "Compatible with existing parser infrastructure"
      ]
    },
    "solution_database": {
      "relevant_solutions": [
        {
          "id": "sol_parser_expr",
          "title": "Expression Parser Implementation",
          "rating": 5,
          "description": "Modular expression parser with operator precedence",
          "problem": "Complex expression parsing with operator precedence",
          "solution": "Recursive descent parser with precedence climbing",
          "lessons_learned": "Modular design helps with maintenance",
          "applicability": "Expression parsing tasks"
        }
      ]
    },
    "memory_bank": {
      "lessons_learned": [
        {
          "id": "lesson_parser_001",
          "title": "Parser Error Handling",
          "description": "Proper error handling in parsers",
          "application": "Add comprehensive error messages",
          "prevention": "Don't skip error handling for edge cases"
        }
      ]
    }
  }
}
```

#### Execution Flow
1. **Context Gathering**: Query solution database and memory bank
2. **Pre-Hook Analysis**: Identify relevant solutions and lessons
3. **Implementation**: Build parser applying learned solutions
4. **Validation**: Check against specifications and quality standards
5. **Learning Capture**: Document successful approach

---

## 🎯 Success Criteria

The workflow is successful when:
1. **Context Application**: >90% of relevant solutions and lessons are applied
2. **Validation Success**: >95% of tasks pass validation on first attempt
3. **Knowledge Growth**: Solution database and memory bank expand with each iteration
4. **Quality Improvement**: Measurable improvement in code quality and consistency
5. **Team Adoption**: Team consistently uses the workflow processes

This comprehensive workflow ensures that AI team members work with the right context, apply existing knowledge, maintain high quality standards, and continuously learn from their work.
