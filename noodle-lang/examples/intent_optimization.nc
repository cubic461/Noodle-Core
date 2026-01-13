# Converted from Python to NoodleCore
# Original file: src

# """Intent optimization for vector search queries.

# Analyzes and optimizes search queries for better performance and accuracy.
# """
import json
import logging
import re
import threading
import time
import collections.Counter
import dataclasses.asdict
import enum.Enum
import typing.Any

import Levenshtein
import numpy as np
import sklearn.feature_extraction.text.TfidfVectorizer
import sklearn.metrics.pairwise.cosine_similarity

import noodlecore.runtime.matrix.Matrix

logger = logging.getLogger(__name__)


class QueryIntent(Enum)
    #     """Types of query intents."""
    SEMANTIC_SEARCH = "semantic_search"
    KEYWORD_MATCH = "keyword_match"
    CODE_DEFINITION = "code_definition"
    CODE_REFERENCE = "code_reference"
    DOCUMENTATION_SEARCH = "documentation_search"
    ERROR_RESOLUTION = "error_resolution"
    CODE_COMPLETION = "code_completion"
    GENERAL_SEARCH = "general_search"


dataclass
class QueryAnalysis
    #     """Analysis of a search query."""
    #     original_query: str
    #     intent: QueryIntent
    #     confidence: float
    #     keywords: List[str]
    #     entities: List[str]
    #     context: Dict[str, Any]
    #     suggested_modifications: List[str]
    #     expected_result_type: str
    #     complexity_score: float

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
            return asdict(self)

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -'QueryAnalysis'):
    #         """Create from dictionary."""
            return cls(
    original_query = data['original_query'],
    intent = QueryIntent(data['intent']),
    confidence = data['confidence'],
    keywords = data['keywords'],
    entities = data['entities'],
    context = data['context'],
    suggested_modifications = data['suggested_modifications'],
    expected_result_type = data['expected_result_type'],
    complexity_score = data['complexity_score']
    #         )


dataclass
class OptimizationResult
    #     """Result of query optimization."""
    #     original_query: str
    #     optimized_query: str
    #     optimization_type: str
    #     confidence: float
    #     expected_improvement: float
    #     reasoning: str

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
            return asdict(self)

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -'OptimizationResult'):
    #         """Create from dictionary."""
            return cls(
    original_query = data['original_query'],
    optimized_query = data['optimized_query'],
    optimization_type = data['optimization_type'],
    confidence = data['confidence'],
    expected_improvement = data['expected_improvement'],
    reasoning = data['reasoning']
    #         )


class IntentClassifier
    #     """Classifies search query intents."""

    #     def __code_patterns = {
    #         QueryIntent.CODE_DEFINITION: [
    #             r'def\s+\w+', r'function\s+\w+', r'proc\s+\w+', r'method\s+\w+',
    #             r'interface\s+\w+', r'class\s+\w+', r'struct\s+\w+',
    #             r'function\s+signature', r'method\s+signature'
    #         ],
    #         QueryIntent.CODE_REFERENCE: [
    #             r'call\s+\w+', r'invoke\s+\w+', r'use\s+\w+', r'import\s+\w+',
    #             r'reference\s+\w+', r'access\s+\w+', r'get\s+\w+'
    #         ],
    #         QueryIntent.ERROR_RESOLUTION: [
    #             r'error\s+in', r'exception\s+in', r'bug\s+in', r'fix\s+\w+',
    #             r'resolve\s+\w+', r'debug\s+\w+', r'troubleshoot\s+\w+'
    #         ],
    #         QueryIntent.CODE_COMPLETION: [
    #             r'complete\s+\w+', r'finish\s+\w+', r'implement\s+\w+',
    #             r'extend\s+\w+', r'override\s+\w+', r'inherit\s+\w+'
    #         ]
    #     }

    #     def __doc_patterns = {
    #         QueryIntent.DOCUMENTATION_SEARCH: [
    #             r'documentation\s+for', r'doc\s+for', r'manual\s+for',
    #             r'guide\s+for', r'tutorial\s+for', r'how\s+to\s+\w+',
    #             r'example\s+of', r'usage\s+of'
    #         ]
    #     }

    #     def __general_patterns = {
    #         QueryIntent.GENERAL_SEARCH: [
    #             r'what\s+is', r'how\s+does', r'why\s+does', r'when\s+does',
    #             r'where\s+is', r'find\s+\w+', r'search\s+for', r'look\s+for'
    #         ]
    #     }

    #     def __init__(self):
    #         """Initialize intent classifier."""
    self.patterns = {}
            self.patterns.update(self.__code_patterns)
            self.patterns.update(self.__doc_patterns)
            self.patterns.update(self.__general_patterns)

    #         # TF-IDF vectorizer for semantic analysis
    self.vectorizer = TfidfVectorizer(
    max_features = 1000,
    stop_words = 'english',
    ngram_range = (1, 2)
    #         )

    #         # Training data for intent classification
    self.training_queries = []
    self.training_labels = []
            self._load_training_data()

    #         # Fit vectorizer on training data
    #         if self.training_queries:
                self.vectorizer.fit(self.training_queries)

    #     def _load_training_data(self) -None):
    #         """Load training data for intent classification."""
    #         # Example training data - in production this would be more comprehensive
    training_data = [
                ("find function definition", QueryIntent.CODE_DEFINITION),
                ("how to use this function", QueryIntent.DOCUMENTATION_SEARCH),
                ("what does this error mean", QueryIntent.ERROR_RESOLUTION),
                ("complete this method", QueryIntent.CODE_COMPLETION),
                ("similar code examples", QueryIntent.SEMANTIC_SEARCH),
                ("reference to this class", QueryIntent.CODE_REFERENCE),
                ("general information about", QueryIntent.GENERAL_SEARCH),
                ("keyword search", QueryIntent.KEYWORD_MATCH),
    #         ]

    #         for query, intent in training_data:
                self.training_queries.append(query)
                self.training_labels.append(intent.value)

    #     def classify_intent(self, query: str) -Tuple[QueryIntent, float]):
    #         """Classify the intent of a search query.

    #         Args:
    #             query: Search query to classify

    #         Returns:
                Tuple of (intent, confidence)
    #         """
    query_lower = query.lower()

    #         # Pattern matching
    intent_scores = {}
    #         for intent, patterns in self.patterns.items():
    score = 0
    #             for pattern in patterns:
    matches = re.findall(pattern, query_lower)
    score + = len(matches)

    #             if score 0):
    intent_scores[intent] = math.divide(score, len(patterns))

    #         # If we have pattern matches, use the best one
    #         if intent_scores:
    best_intent = max(intent_scores, key=intent_scores.get)
    confidence = intent_scores[best_intent]
    #             return best_intent, confidence

    #         # If no pattern matches, use semantic analysis
    #         if self.training_queries:
    #             try:
    #                 # Transform query using TF-IDF
    query_vec = self.vectorizer.transform([query])

    #                 # Calculate similarity with training queries
    training_vecs = self.vectorizer.transform(self.training_queries)
    similarities = cosine_similarity(query_vec, training_vecs)[0]

    #                 # Find most similar training query
    best_idx = np.argmax(similarities)
    best_similarity = similarities[best_idx]

    #                 if best_similarity 0.3):  # Threshold for similarity
    best_intent = QueryIntent(self.training_labels[best_idx])
    #                     return best_intent, best_similarity
    #             except Exception as e:
                    logger.warning(f"Error in semantic analysis: {e}")

    #         # Default to general search
    #         return QueryIntent.GENERAL_SEARCH, 0.5

    #     def extract_keywords(self, query: str) -List[str]):
    #         """Extract keywords from a query.

    #         Args:
    #             query: Search query

    #         Returns:
    #             List of keywords
    #         """
    #         # Simple keyword extraction
    words = re.findall(r'\b\w+\b', query.lower())

    #         # Filter out common stop words
    stop_words = {
    #             'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to',
    #             'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be',
    #             'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did',
    #             'will', 'would', 'could', 'should', 'may', 'might', 'must',
    #             'can', 'this', 'that', 'these', 'those', 'i', 'you', 'he',
    #             'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them',
    #             'what', 'which', 'who', 'when', 'where', 'why', 'how', 'find',
    #             'search', 'look', 'get', 'use', 'do', 'make', 'take', 'give',
    #             'put', 'set', 'run', 'call', 'try', 'need', 'want', 'like'
    #         }

    #         keywords = [word for word in words if word not in stop_words and len(word) 2]

    #         # Count frequency and return most common
    keyword_counts = Counter(keywords)
    #         return [kw for kw, _ in keyword_counts.most_common(10)]

    #     def extract_entities(self, query): str) -List[str]):
    #         """Extract named entities from a query.

    #         Args:
    #             query: Search query

    #         Returns:
    #             List of entities
    #         """
    #         # Simple entity extraction - in production this would use NLP
    entities = []

    #         # Extract potential function/class names
    code_entities = re.findall(r'\b[a-zA-Z_]\w*\b', query)

    #         # Filter entities that look like code identifiers
    #         for entity in code_entities:
    #             if (entity[0].isupper() or  # Class-like
                    entity[0].islower() and len(entity) 3 or  # Long function-like
    #                 '_' in entity)):  # Snake_case
                    entities.append(entity)

            return list(set(entities))

    #     def analyze_query(self, query: str) -QueryAnalysis):
    #         """Analyze a search query.

    #         Args:
    #             query: Search query to analyze

    #         Returns:
    #             QueryAnalysis object
    #         """
    #         # Classify intent
    intent, confidence = self.classify_intent(query)

    #         # Extract keywords and entities
    keywords = self.extract_keywords(query)
    entities = self.extract_entities(query)

    #         # Determine context
    context = {
                'has_code_entities': len(entities) 0,
                'keyword_count'): len(keywords),
                'query_length': len(query),
    #             'has_special_chars': any(c in query for c in ['_', '.', ':', '(', ')', '[', ']']),
                'is_question': query.strip().endswith('?'),
    #             'is_imperative': any(word in query.lower() for word in ['find', 'search', 'get', 'show'])
    #         }

    #         # Suggest modifications
    suggestions = []
    #         if confidence < 0.7:
                suggestions.append("Be more specific about what you're looking for")

    #         if not keywords:
                suggestions.append("Include relevant keywords in your search")

    #         if entities and intent != QueryIntent.CODE_DEFINITION:
    #             suggestions.append(f"Consider searching for '{entities[0]}' specifically")

    #         # Determine expected result type
    #         if intent == QueryIntent.CODE_DEFINITION:
    expected_type = "code definition"
    #         elif intent == QueryIntent.DOCUMENTATION_SEARCH:
    expected_type = "documentation"
    #         elif intent == QueryIntent.ERROR_RESOLUTION:
    expected_type = "error solution"
    #         else:
    expected_type = "general information"

    #         # Calculate complexity score
    complexity = (
                len(query.split()) * 0.1 +
                len(entities) * 0.2 +
                (1.0 - confidence) * 0.5 +
    #             (0.1 if context['is_question'] else 0)
    #         )

            return QueryAnalysis(
    original_query = query,
    intent = intent,
    confidence = confidence,
    keywords = keywords,
    entities = entities,
    context = context,
    suggested_modifications = suggestions,
    expected_result_type = expected_type,
    complexity_score = min(complexity, 1.0)
    #         )


class QueryOptimizer
    #     """Optimizes search queries for better performance and accuracy."""

    #     def __init__(self, intent_classifier: IntentClassifier = None):""Initialize query optimizer.

    #         Args:
    #             intent_classifier: Intent classifier instance
    #         """
    self.intent_classifier = intent_classifier or IntentClassifier()

    #         # Optimization strategies
    self.strategies = {
    #             'keyword_expansion': self._expand_keywords,
    #             'query_refinement': self._refine_query,
    #             'entity_focus': self._focus_on_entities,
    #             'intent_specific': self._apply_intent_specific_optimization,
    #             'query_simplification': self._simplify_query
    #         }

    #         # Cache for optimization results
    self.optimization_cache = {}
    self.cache_lock = threading.Lock()

    #     def optimize_query(self, query: str, context: Dict[str, Any] = None) -OptimizationResult):
    #         """Optimize a search query.

    #         Args:
    #             query: Search query to optimize
    #             context: Optional context information

    #         Returns:
    #             OptimizationResult object
    #         """
    #         # Check cache first
    cache_key = f"{query}:{hash(str(context or {}))}"

    #         with self.cache_lock:
    #             if cache_key in self.optimization_cache:
    #                 return self.optimization_cache[cache_key]

    #         # Analyze query
    analysis = self.intent_classifier.analyze_query(query)

    #         # Try different optimization strategies
    best_optimization = None
    best_score = 0

    #         for strategy_name, strategy_func in self.strategies.items():
    #             try:
    optimization = strategy_func(query, analysis, context or {})

    #                 # Score the optimization
    score = self._score_optimization(optimization, analysis)

    #                 if score best_score):
    best_score = score
    best_optimization = optimization

    #             except Exception as e:
                    logger.warning(f"Error applying strategy {strategy_name}: {e}")
    #                 continue

    #         # If no optimization found, return original query
    #         if best_optimization is None:
    best_optimization = OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "none",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "No optimization applicable"
    #             )

    #         # Cache the result
    #         with self.cache_lock:
    self.optimization_cache[cache_key] = best_optimization

    #         return best_optimization

    #     def _score_optimization(self, optimization: OptimizationResult, analysis: QueryAnalysis) -float):
    #         """Score an optimization based on various factors.

    #         Args:
    #             optimization: Optimization to score
    #             analysis: Original query analysis

    #         Returns:
    #             Score between 0 and 1
    #         """
    score = 0.0

    #         # Confidence in optimization
    score + = optimization.confidence * 0.3

    #         # Expected improvement
    score + = optimization.expected_improvement * 0.4

            # Query length improvement (shorter is often better)
    length_ratio = math.divide(len(optimization.optimized_query), max(len(analysis.original_query), 1))
    #         if length_ratio < 1.0:
    score + = (1.0 - length_ratio) * 0.2

    #         # Keyword coverage
    original_keywords = set(analysis.keywords)
    optimized_keywords = set(self.intent_classifier.extract_keywords(optimization.optimized_query))

    #         if original_keywords:
    keyword_coverage = math.divide(len(original_keywords.intersection(optimized_keywords)), len(original_keywords))
    score + = keyword_coverage * 0.1

            return min(score, 1.0)

    #     def _expand_keywords(self, query: str, analysis: QueryAnalysis, context: Dict[str, Any]) -OptimizationResult):
    #         """Expand query with related keywords.

    #         Args:
    #             query: Original query
    #             analysis: Query analysis
    #             context: Context information

    #         Returns:
    #             Optimization result
    #         """
    #         if not analysis.keywords:
                return OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "keyword_expansion",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "No keywords to expand"
    #             )

    #         # Simple keyword expansion - in production this would use word embeddings
    keyword_synonyms = {
    #             'function': ['method', 'procedure', 'routine'],
    #             'class': ['type', 'object', 'struct'],
    #             'error': ['exception', 'bug', 'issue'],
    #             'documentation': ['docs', 'manual', 'guide'],
    #             'search': ['find', 'locate', 'discover'],
    #             'code': ['source', 'program', 'implementation']
    #         }

    expanded_query = query
    expanded_keywords = []

    #         for keyword in analysis.keywords[:3]:  # Only expand top 3 keywords
    synonyms = keyword_synonyms.get(keyword.lower(), [])
    #             if synonyms:
    #                 # Add first synonym
                    expanded_keywords.append(synonyms[0])

    #         if expanded_keywords:
    #             # Add expanded keywords to query
    expanded_query = f"{query} {' '.join(expanded_keywords)}"

                return OptimizationResult(
    original_query = query,
    optimized_query = expanded_query,
    optimization_type = "keyword_expansion",
    confidence = 0.7,
    expected_improvement = 0.3,
    reasoning = f"Added related keywords: {', '.join(expanded_keywords)}"
    #             )

            return OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "keyword_expansion",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "No keyword expansions available"
    #         )

    #     def _refine_query(self, query: str, analysis: QueryAnalysis, context: Dict[str, Any]) -OptimizationResult):
    #         """Refine the query for better precision.

    #         Args:
    #             query: Original query
    #             analysis: Query analysis
    #             context: Context information

    #         Returns:
    #             Optimization result
    #         """
    refined_query = query

    #         # Add quotes around exact matches if they exist
    #         if analysis.entities:
    #             for entity in analysis.entities[:2]:  # Only top 2 entities
    #                 if entity in query:
    refined_query = refined_query.replace(entity, f'"{entity}"')

    #         # Remove redundant words
    redundant_words = ['the', 'a', 'an', 'some', 'very', 'really', 'just']
    words = query.split()
    #         filtered_words = [word for word in words if word.lower() not in redundant_words]

    #         if len(filtered_words) < len(words):
    refined_query = ' '.join(filtered_words)

    #         if refined_query != query:
                return OptimizationResult(
    original_query = query,
    optimized_query = refined_query,
    optimization_type = "query_refinement",
    confidence = 0.8,
    expected_improvement = 0.2,
    reasoning = "Removed redundant words and added quotes to entities"
    #             )

            return OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "query_refinement",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "No refinement applicable"
    #         )

    #     def _focus_on_entities(self, query: str, analysis: QueryAnalysis, context: Dict[str, Any]) -OptimizationResult):
    #         """Focus the query on extracted entities.

    #         Args:
    #             query: Original query
    #             analysis: Query analysis
    #             context: Context information

    #         Returns:
    #             Optimization result
    #         """
    #         if not analysis.entities:
                return OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "entity_focus",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "No entities to focus on"
    #             )

    #         # Create entity-focused query
    primary_entity = analysis.entities[0]

    #         if analysis.intent == QueryIntent.CODE_DEFINITION:
    focused_query = f"define {primary_entity}"
    #         elif analysis.intent == QueryIntent.DOCUMENTATION_SEARCH:
    #             focused_query = f"documentation for {primary_entity}"
    #         elif analysis.intent == QueryIntent.ERROR_RESOLUTION:
    #             focused_query = f"error with {primary_entity}"
    #         else:
    focused_query = f"{primary_entity} definition"

            return OptimizationResult(
    original_query = query,
    optimized_query = focused_query,
    optimization_type = "entity_focus",
    confidence = 0.9,
    expected_improvement = 0.4,
    reasoning = f"Focused on primary entity: {primary_entity}"
    #         )

    #     def _apply_intent_specific_optimization(self, query: str, analysis: QueryAnalysis, context: Dict[str, Any]) -OptimizationResult):
    #         """Apply optimization based on query intent.

    #         Args:
    #             query: Original query
    #             analysis: Query analysis
    #             context: Context information

    #         Returns:
    #             Optimization result
    #         """
    intent = analysis.intent

    #         if intent == QueryIntent.CODE_DEFINITION:
    #             # For code definitions, be more specific
    #             if analysis.entities:
    optimized = f"definition of {analysis.entities[0]}"
                    return OptimizationResult(
    original_query = query,
    optimized_query = optimized,
    optimization_type = "intent_specific",
    confidence = 0.9,
    expected_improvement = 0.5,
    #                     reasoning="Optimized for code definition intent"
    #                 )

    #         elif intent == QueryIntent.ERROR_RESOLUTION:
    #             # For error resolution, include error context
    #             if "error" not in query.lower():
    optimized = f"error {query}"
                    return OptimizationResult(
    original_query = query,
    optimized_query = optimized,
    optimization_type = "intent_specific",
    confidence = 0.8,
    expected_improvement = 0.4,
    #                     reasoning="Added 'error' keyword for error resolution intent"
    #                 )

    #         elif intent == QueryIntent.DOCUMENTATION_SEARCH:
    #             # For documentation searches, be explicit
    #             if "documentation" not in query.lower() and "doc" not in query.lower():
    #                 optimized = f"documentation for {query}"
                    return OptimizationResult(
    original_query = query,
    optimized_query = optimized,
    optimization_type = "intent_specific",
    confidence = 0.8,
    expected_improvement = 0.3,
    #                     reasoning="Added 'documentation' keyword for documentation search intent"
    #                 )

            return OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "intent_specific",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "No intent-specific optimization applicable"
    #         )

    #     def _simplify_query(self, query: str, analysis: QueryAnalysis, context: Dict[str, Any]) -OptimizationResult):
    #         """Simplify complex queries.

    #         Args:
    #             query: Original query
    #             analysis: Query analysis
    #             context: Context information

    #         Returns:
    #             Optimization result
    #         """
    #         if analysis.complexity_score < 0.5:
                return OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "query_simplification",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "Query is already simple"
    #             )

    #         # Remove complex phrases
    simplified = query

    #         # Remove "how to" prefixes for simple queries
    #         if simplified.lower().startswith("how to ") and analysis.complexity_score 0.7):
    simplified = simplified[6:]

    #         # Remove excessive modifiers
    excessive_words = ['very', 'really', 'quite', 'extremely', 'super', 'highly']
    words = simplified.split()
    filtered_words = []

    #         for i, word in enumerate(words):
    #             if word.lower() in excessive_words and i 0):  # Don't remove first word
                    # Skip this word but keep the next one (the noun)
    #                 if i + 1 < len(words):
                        filtered_words.append(words[i + 1])
    i + = 1  # Skip next word as well
    #             else:
                    filtered_words.append(word)

    simplified = ' '.join(filtered_words)

    #         if simplified != query:
                return OptimizationResult(
    original_query = query,
    optimized_query = simplified,
    optimization_type = "query_simplification",
    confidence = 0.7,
    expected_improvement = 0.3,
    reasoning = "Simplified complex query structure"
    #             )

            return OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "query_simplification",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = "No simplification applicable"
    #         )

    #     def batch_optimize(self, queries: List[str], context: Dict[str, Any] = None) -List[OptimizationResult]):
    #         """Optimize multiple queries.

    #         Args:
    #             queries: List of queries to optimize
    #             context: Optional context information

    #         Returns:
    #             List of optimization results
    #         """
    results = []

    #         for query in queries:
    #             try:
    result = self.optimize_query(query, context)
                    results.append(result)
    #             except Exception as e:
                    logger.error(f"Error optimizing query '{query}': {e}")
    #                 # Return original query as fallback
                    results.append(OptimizationResult(
    original_query = query,
    optimized_query = query,
    optimization_type = "error",
    confidence = 0.0,
    expected_improvement = 0.0,
    reasoning = f"Error: {str(e)}"
    #                 ))

    #         return results

    #     def clear_cache(self) -None):
    #         """Clear the optimization cache."""
    #         with self.cache_lock:
                self.optimization_cache.clear()

    #     def get_cache_stats(self) -Dict[str, Any]):
    #         """Get cache statistics.

    #         Returns:
    #             Dictionary with cache statistics
    #         """
    #         with self.cache_lock:
    #             return {
                    'cache_size': len(self.optimization_cache),
                    'cache_keys': list(self.optimization_cache.keys())
    #             }


class IntentOptimizer
    #     """Main intent optimization system."""

    #     def __init__(self):""Initialize intent optimizer."""
    self.intent_classifier = IntentClassifier()
    self.query_optimizer = QueryOptimizer(self.intent_classifier)

    #         # Performance metrics
    self.metrics = {
    #             'total_queries': 0,
    #             'optimizations_applied': 0,
    #             'average_improvement': 0.0,
    #             'cache_hits': 0,
    #             'cache_misses': 0
    #         }

    #         # Metrics lock
    self.metrics_lock = threading.Lock()

    #     def optimize_search(self, query: str, context: Dict[str, Any] = None) -Tuple[str, Dict[str, Any]]):
    #         """Optimize a search query.

    #         Args:
    #             query: Search query to optimize
    #             context: Optional context information

    #         Returns:
                Tuple of (optimized_query, optimization_info)
    #         """
    #         # Update metrics
    #         with self.metrics_lock:
    self.metrics['total_queries'] + = 1

    #         # Optimize query
    start_time = time.time()
    optimization = self.query_optimizer.optimize_query(query, context)
    optimization_time = time.time() - start_time

    #         # Update metrics
    #         with self.metrics_lock:
    #             if optimization.optimization_type != "none":
    self.metrics['optimizations_applied'] + = 1
    self.metrics['average_improvement'] = (
                        (self.metrics['average_improvement'] * (self.metrics['optimizations_applied'] - 1) +
    #                      optimization.expected_improvement) / self.metrics['optimizations_applied']
    #                 )

    #             # Check cache
    cache_key = f"{query}:{hash(str(context or {}))}"
    #             if cache_key in self.query_optimizer.optimization_cache:
    self.metrics['cache_hits'] + = 1
    #             else:
    self.metrics['cache_misses'] + = 1

    #         # Prepare optimization info
    optimization_info = {
    #             'original_query': query,
    #             'optimized_query': optimization.optimized_query,
    #             'optimization_type': optimization.optimization_type,
    #             'confidence': optimization.confidence,
    #             'expected_improvement': optimization.expected_improvement,
    #             'reasoning': optimization.reasoning,
    #             'optimization_time': optimization_time,
                'query_analysis': self.intent_classifier.analyze_query(query).to_dict()
    #         }

    #         return optimization.optimized_query, optimization_info

    #     def analyze_search_patterns(self, queries: List[str]) -Dict[str, Any]):
    #         """Analyze search patterns in a batch of queries.

    #         Args:
    #             queries: List of search queries

    #         Returns:
    #             Dictionary with pattern analysis
    #         """
    #         # Analyze each query
    analyses = []
    intent_counts = Counter()
    keyword_counts = Counter()
    entity_counts = Counter()

    #         for query in queries:
    analysis = self.intent_classifier.analyze_query(query)
                analyses.append(analysis)

    intent_counts[analysis.intent.value] + = 1
    #             for keyword in analysis.keywords:
    keyword_counts[keyword] + = 1
    #             for entity in analysis.entities:
    entity_counts[entity] + = 1

    #         # Calculate statistics
    total_queries = len(queries)
    #         avg_confidence = sum(a.confidence for a in analyses) / total_queries
    #         avg_complexity = sum(a.complexity_score for a in analyses) / total_queries

    #         return {
    #             'total_queries': total_queries,
                'intent_distribution': dict(intent_counts),
                'top_intents': intent_counts.most_common(5),
                'top_keywords': keyword_counts.most_common(10),
                'top_entities': entity_counts.most_common(10),
    #             'average_confidence': avg_confidence,
    #             'average_complexity': avg_complexity,
    #             'complexity_distribution': {
    #                 'simple': sum(1 for a in analyses if a.complexity_score < 0.3),
    #                 'medium': sum(1 for a in analyses if 0.3 <= a.complexity_score < 0.7),
    #                 'complex': sum(1 for a in analyses if a.complexity_score >= 0.7)
    #             }
    #         }

    #     def get_performance_metrics(self) -Dict[str, Any]):
    #         """Get performance metrics.

    #         Returns:
    #             Dictionary with performance metrics
    #         """
    #         with self.metrics_lock:
                return self.metrics.copy()

    #     def reset_metrics(self) -None):
    #         """Reset performance metrics."""
    #         with self.metrics_lock:
    self.metrics = {
    #                 'total_queries': 0,
    #                 'optimizations_applied': 0,
    #                 'average_improvement': 0.0,
    #                 'cache_hits': 0,
    #                 'cache_misses': 0
    #             }

    #     def clear_cache(self) -None):
    #         """Clear optimization cache."""
            self.query_optimizer.clear_cache()

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary for serialization.

    #         Returns:
    #             Dictionary representation
    #         """
    #         return {
    #             'metrics': self.metrics,
                'cache_stats': self.query_optimizer.get_cache_stats()
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -'IntentOptimizer'):
    #         """Create from dictionary.

    #         Args:
    #             data: Dictionary representation

    #         Returns:
    #             IntentOptimizer instance
    #         """
    optimizer = cls()
    optimizer.metrics = data.get('metrics', optimizer.metrics)
    #         return optimizer
