# Converted from Python to NoodleCore
# Original file: src

# """
# AI Adapter Manager Module

# This module provides a centralized adapter management system with:
# - Provider selection and failover logic
# - Response quality scoring and comparison
# - Performance monitoring and metrics
# - Adapter hot-swapping and configuration updates
# """

import asyncio
import logging
import time
import typing.Dict
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import json
import collections.defaultdict

import .adapter_base.(
#     AdapterBase, ChatMessage, ChatResponse, ModelInfo,
#     AdapterError, AdapterErrorCode
# )
import .ai_config.AIConfigManager
import .zai_adapter.ZaiAdapter
import .openrouter_adapter.OpenRouterAdapter
import .anthropic_adapter.AnthropicAdapter
import .openai_adapter.OpenAIAdapter
import .ollama_adapter.OllamaAdapter


class ProviderStatus(Enum)
    #     """Provider status enumeration."""
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"
    DISABLED = "disabled"


class SelectionStrategy(Enum)
    #     """Provider selection strategy."""
    ROUND_ROBIN = "round_robin"
    BEST_PERFORMANCE = "best_performance"
    LOWEST_COST = "lowest_cost"
    HIGHEST_QUALITY = "highest_quality"
    PREFERRED_FIRST = "preferred_first"


dataclass
class ProviderMetrics
    #     """Metrics for a provider."""
    #     provider_name: str
    total_requests: int = 0
    successful_requests: int = 0
    failed_requests: int = 0
    average_response_time: float = 0.0
    total_cost: float = 0.0
    quality_scores: List[float] = field(default_factory=list)
    last_success: Optional[datetime] = None
    last_failure: Optional[datetime] = None
    consecutive_failures: int = 0
    status: ProviderStatus = ProviderStatus.HEALTHY
    response_times: deque = field(default_factory=lambda: deque(maxlen=100))

    #     @property
    #     def success_rate(self) -float):
    #         """Calculate success rate."""
    #         if self.total_requests = 0:
    #             return 0.0
    #         return self.successful_requests / self.total_requests

    #     @property
    #     def average_quality_score(self) -float):
    #         """Calculate average quality score."""
    #         if not self.quality_scores:
    #             return 0.0
            return sum(self.quality_scores) / len(self.quality_scores)

    #     def update_response_time(self, response_time: float):
    #         """Update response time metrics."""
            self.response_times.append(response_time)
    self.average_response_time = math.divide(sum(self.response_times), len(self.response_times))

    #     def record_success(self, response_time: float, cost: float = 0.0, quality_score: float = 0.0):
    #         """Record a successful request."""
    self.total_requests + = 1
    self.successful_requests + = 1
    self.total_cost + = cost
    self.last_success = datetime.utcnow()
    self.consecutive_failures = 0
            self.update_response_time(response_time)
    #         if quality_score 0):
                self.quality_scores.append(quality_score)

    #         # Update status based on performance
            self._update_status()

    #     def record_failure(self):
    #         """Record a failed request."""
    self.total_requests + = 1
    self.failed_requests + = 1
    self.last_failure = datetime.utcnow()
    self.consecutive_failures + = 1

    #         # Update status based on failures
            self._update_status()

    #     def _update_status(self):
    #         """Update provider status based on metrics."""
    #         if self.consecutive_failures >= 3:
    self.status = ProviderStatus.UNHEALTHY
    #         elif self.success_rate < 0.8:
    self.status = ProviderStatus.DEGRADED
    #         elif self.average_response_time 2.0):  # 2 seconds threshold
    self.status = ProviderStatus.DEGRADED
    #         else:
    self.status = ProviderStatus.HEALTHY


dataclass
class QualityScore
    #     """Quality scoring parameters."""
    relevance: float = 0.0
    coherence: float = 0.0
    completeness: float = 0.0
    accuracy: float = 0.0
    overall: float = 0.0

    #     def calculate_overall(self) -float):
    #         """Calculate overall quality score."""
    weights = {
    #             'relevance': 0.3,
    #             'coherence': 0.25,
    #             'completeness': 0.25,
    #             'accuracy': 0.2
    #         }

    self.overall = (
    #             self.relevance * weights['relevance'] +
    #             self.coherence * weights['coherence'] +
    #             self.completeness * weights['completeness'] +
    #             self.accuracy * weights['accuracy']
    #         )

    #         return self.overall


class AIAdapterManager
    #     """Centralized AI adapter manager with failover and monitoring."""

    #     def __init__(self, config_manager: Optional[AIConfigManager] = None):""
    #         Initialize the adapter manager.

    #         Args:
    #             config_manager: AI configuration manager instance
    #         """
    self.config_manager = config_manager or AIConfigManager()
    self.logger = logging.getLogger("noodlecore.ai_adapter_manager")

    #         # Adapter registry
    self.adapters: Dict[str, AdapterBase] = {}
    self.adapter_configs: Dict[str, Dict[str, Any]] = {}

    #         # Metrics and monitoring
    self.metrics: Dict[str, ProviderMetrics] = {}
    self.global_metrics = {
    #             'total_requests': 0,
    #             'total_cost': 0.0,
                'start_time': datetime.utcnow()
    #         }

    #         # Selection strategy
    self.selection_strategy = SelectionStrategy.ROUND_ROBIN
    self.preferred_providers: List[str] = []
    self.current_provider_index = 0

    #         # Failover configuration
    self.max_failures = 3
    self.failover_timeout = 300  # 5 minutes
    self.disabled_providers: Dict[str, datetime] = {}

    #         # Quality scoring
    self.quality_threshold = 0.7
    self.enable_quality_scoring = True

    #         # Initialize adapters
            self._initialize_adapters()

    #     def _initialize_adapters(self):
    #         """Initialize all available adapters."""
    adapter_classes = {
    #             'zai': ZaiAdapter,
    #             'openrouter': OpenRouterAdapter,
    #             'anthropic': AnthropicAdapter,
    #             'openai': OpenAIAdapter,
    #             'ollama': OllamaAdapter
    #         }

    #         for provider_name, adapter_class in adapter_classes.items():
    #             try:
    config = self.config_manager.get_provider_config(provider_name)
    #                 if config:
    api_key = self.config_manager.get_api_key(provider_name)
    #                     if api_key:
    adapter = adapter_class(
    api_key = api_key,
    base_url = config.base_url,
    config = {
    #                                 'requests_per_minute': config.requests_per_minute,
    #                                 'tokens_per_minute': config.tokens_per_minute,
    #                                 'timeout': config.timeout
    #                             }
    #                         )
    self.adapters[provider_name] = adapter
    self.adapter_configs[provider_name] = config
    self.metrics[provider_name] = ProviderMetrics(provider_name=provider_name)
    #                         self.logger.info(f"Initialized adapter for provider: {provider_name}")
    #                     else:
    #                         self.logger.warning(f"No API key configured for provider: {provider_name}")
    #                 else:
    #                     self.logger.warning(f"No configuration found for provider: {provider_name}")
    #             except Exception as e:
    #                 self.logger.error(f"Failed to initialize adapter for {provider_name}: {str(e)}")

    #     async def chat(
    #         self,
    #         messages: List[ChatMessage],
    provider: Optional[str] = None,
    model: Optional[str] = None,
    temperature: float = 0.7,
    max_tokens: int = 1000,
    stream: bool = False,
    enable_failover: bool = True,
    #         **kwargs
    #     ) -Union[ChatResponse, AsyncGenerator[str, None]]):
    #         """
    #         Send a chat request with automatic failover.

    #         Args:
    #             messages: List of chat messages
                provider: Preferred provider (optional)
    #             model: Specific model to use
    #             temperature: Temperature for response generation
    #             max_tokens: Maximum tokens in response
    #             stream: Whether to stream the response
    #             enable_failover: Whether to enable failover logic
    #             **kwargs: Additional parameters

    #         Returns:
    #             ChatResponse or AsyncGenerator for streaming
    #         """
    self.global_metrics['total_requests'] + = 1

    #         # Determine provider order
    providers_to_try = self._get_provider_order(provider)

    last_error = None
    responses = []

    #         for current_provider in providers_to_try:
    #             try:
    #                 # Check if provider is disabled
    #                 if self._is_provider_disabled(current_provider):
                        self.logger.debug(f"Provider {current_provider} is disabled, skipping")
    #                     continue

    #                 # Check if provider is healthy
    #                 if self.metrics[current_provider].status == ProviderStatus.UNHEALTHY:
                        self.logger.debug(f"Provider {current_provider} is unhealthy, skipping")
    #                     continue

    adapter = self.adapters[current_provider]
    start_time = time.time()

    #                 # Make the request
    response = await adapter.chat(
    messages = messages,
    model = model,
    temperature = temperature,
    max_tokens = max_tokens,
    stream = stream,
    #                     **kwargs
    #                 )

    response_time = time.time() - start_time

    #                 # Calculate cost
    cost = self._calculate_cost(current_provider, response)

    #                 # Score quality if enabled
    quality_score = 0.0
    #                 if self.enable_quality_scoring and not stream:
    quality_score = await self._score_response_quality(
    #                         messages, response, current_provider
    #                     )

    #                 # Record metrics
                    self.metrics[current_provider].record_success(
    #                     response_time, cost, quality_score
    #                 )
    self.global_metrics['total_cost'] + = cost

    #                 # For non-streaming, check quality threshold
    #                 if not stream and self.enable_quality_scoring:
    #                     if quality_score >= self.quality_threshold:
    #                         return response
    #                     else:
                            responses.append((response, quality_score))
                            self.logger.warning(f"Response quality {quality_score} below threshold {self.quality_threshold}")
    #                         continue

    #                 return response

    #             except Exception as e:
    last_error = e
    #                 self.logger.error(f"Request failed for provider {current_provider}: {str(e)}")
                    self.metrics[current_provider].record_failure()

    #                 # Disable provider if too many failures
    #                 if self.metrics[current_provider].consecutive_failures >= self.max_failures:
                        self._disable_provider(current_provider)

    #                 if not enable_failover:
    #                     raise

    #         # If we get here, all providers failed
    #         if last_error:
    #             raise last_error

    #         # If we have responses but none met quality threshold, return the best one
    #         if responses:
    best_response, best_score = max(responses, key=lambda x: x[1])
    #             self.logger.warning(f"Returning best response with quality score {best_score}")
    #             return best_response

            raise AdapterError(
    #             "All providers failed to generate a response",
    #             AdapterErrorCode.PROVIDER_ERROR,
    #             "AdapterManager"
    #         )

    #     async def chat_stream(
    #         self,
    #         messages: List[ChatMessage],
    provider: Optional[str] = None,
    model: Optional[str] = None,
    temperature: float = 0.7,
    max_tokens: int = 1000,
    #         **kwargs
    #     ) -AsyncGenerator[str, None]):
    #         """
    #         Stream a chat response with failover.

    #         Args:
    #             messages: List of chat messages
                provider: Preferred provider (optional)
    #             model: Specific model to use
    #             temperature: Temperature for response generation
    #             max_tokens: Maximum tokens in response
    #             **kwargs: Additional parameters

    #         Yields:
    #             Response chunks as strings
    #         """
    #         async for chunk in self.chat(
    messages = messages,
    provider = provider,
    model = model,
    temperature = temperature,
    max_tokens = max_tokens,
    stream = True,
    #             **kwargs
    #         ):
    #             yield chunk

    #     def _get_provider_order(self, preferred_provider: Optional[str] = None) -List[str]):
    #         """Get the order of providers to try based on selection strategy."""
    available_providers = [
    #             name for name in self.adapters.keys()
    #             if not self._is_provider_disabled(name)
    #         ]

    #         if not available_providers:
    #             return []

    #         if preferred_provider and preferred_provider in available_providers:
    #             if self.selection_strategy == SelectionStrategy.PREFERRED_FIRST:
    #                 return [preferred_provider] + [p for p in available_providers if p != preferred_provider]

    #         if self.selection_strategy == SelectionStrategy.ROUND_ROBIN:
    providers = available_providers[self.current_provider_index:] + available_providers[:self.current_provider_index]
    self.current_provider_index = (self.current_provider_index + 1 % len(available_providers))
    #             return providers

    #         elif self.selection_strategy == SelectionStrategy.BEST_PERFORMANCE:
                return sorted(
    #                 available_providers,
    key = lambda p: self.metrics[p].average_response_time
    #             )

    #         elif self.selection_strategy == SelectionStrategy.LOWEST_COST:
                return sorted(
    #                 available_providers,
    key = math.divide(lambda p: self.metrics[p].total_cost, max(1, self.metrics[p].successful_requests))
    #             )

    #         elif self.selection_strategy == SelectionStrategy.HIGHEST_QUALITY:
                return sorted(
    #                 available_providers,
    key = lambda p: self.metrics[p].average_quality_score,
    reverse = True
    #             )

    #         return available_providers

    #     def _is_provider_disabled(self, provider: str) -bool):
    #         """Check if a provider is temporarily disabled."""
    #         if provider not in self.disabled_providers:
    #             return False

    disable_time = self.disabled_providers[provider]
    #         if datetime.utcnow() - disable_time timedelta(seconds=self.failover_timeout)):
    #             # Re-enable provider
    #             del self.disabled_providers[provider]
    self.metrics[provider].status = ProviderStatus.HEALTHY
                self.logger.info(f"Re-enabling provider: {provider}")
    #             return False

    #         return True

    #     def _disable_provider(self, provider: str):
    #         """Temporarily disable a provider."""
    self.disabled_providers[provider] = datetime.utcnow()
    self.metrics[provider].status = ProviderStatus.DISABLED
            self.logger.warning(f"Disabling provider due to failures: {provider}")

    #     def _calculate_cost(self, provider: str, response: ChatResponse) -float):
    #         """Calculate the cost of a response."""
    config = self.adapter_configs.get(provider)
    #         if not config:
    #             return 0.0

    usage = response.usage
    input_cost = usage.get('prompt_tokens', 0) * config.input_cost_per_1k / 1000
    output_cost = usage.get('completion_tokens', 0) * config.output_cost_per_1k / 1000

    #         return input_cost + output_cost

    #     async def _score_response_quality(
    #         self,
    #         messages: List[ChatMessage],
    #         response: ChatResponse,
    #         provider: str
    #     ) -float):
    #         """
    #         Score the quality of a response.

    #         Args:
    #             messages: Original messages
    #             response: Generated response
    #             provider: Provider that generated the response

    #         Returns:
                Quality score (0.0 - 1.0)
    #         """
    #         try:
    #             # Simple quality scoring based on various factors
    score = QualityScore()

    #             # Relevance: Check if response addresses the prompt
    #             last_message = messages[-1].content.lower() if messages else ""
    response_content = response.content.lower()

    #             # Simple relevance check
    common_words = set(last_message.split()) & set(response_content.split())
    score.relevance = math.divide(min(1.0, len(common_words), max(1, len(last_message.split()))))

    #             # Coherence: Check sentence structure and flow
    sentences = response.content.split('.')
    score.coherence = math.divide(min(1.0, len(sentences), max(1, len(response.content) / 100)))

    #             # Completeness: Check if response is substantial
    word_count = len(response.content.split())
    score.completeness = math.divide(min(1.0, word_count, 50)  # Target 50 words)

    #             # Accuracy: Basic checks for common issues
    issues = 0
    #             if response.content.count('?') len(response.content) / 50):
    issues + = 1  # Too many questions
    #             if len(response.content) < 10:
    issues + = 1  # Too short

    score.accuracy = max(0.0 * 1.0 - issues, 0.2)

                return score.calculate_overall()

    #         except Exception as e:
                self.logger.error(f"Error scoring response quality: {str(e)}")
    #             return 0.5  # Default score

    #     def set_selection_strategy(self, strategy: SelectionStrategy):
    #         """Set the provider selection strategy."""
    self.selection_strategy = strategy
            self.logger.info(f"Changed selection strategy to: {strategy.value}")

    #     def set_preferred_providers(self, providers: List[str]):
    #         """Set preferred providers."""
    self.preferred_providers = providers
            self.logger.info(f"Set preferred providers: {providers}")

    #     def get_provider_metrics(self, provider: str) -Optional[ProviderMetrics]):
    #         """Get metrics for a specific provider."""
            return self.metrics.get(provider)

    #     def get_all_metrics(self) -Dict[str, Any]):
    #         """Get comprehensive metrics for all providers."""
    #         return {
    #             'global': {
    #                 **self.global_metrics,
                    'uptime_seconds': (datetime.utcnow() - self.global_metrics['start_time']).total_seconds()
    #             },
    #             'providers': {
    #                 name: {
    #                     'total_requests': metrics.total_requests,
    #                     'success_rate': metrics.success_rate,
    #                     'average_response_time': metrics.average_response_time,
    #                     'total_cost': metrics.total_cost,
    #                     'average_quality_score': metrics.average_quality_score,
    #                     'status': metrics.status.value,
    #                     'consecutive_failures': metrics.consecutive_failures
    #                 }
    #                 for name, metrics in self.metrics.items()
    #             },
                'disabled_providers': list(self.disabled_providers.keys()),
    #             'selection_strategy': self.selection_strategy.value
    #         }

    #     async def health_check_all(self) -Dict[str, Any]):
    #         """Perform health checks on all providers."""
    health_results = {}

    #         for provider_name, adapter in self.adapters.items():
    #             try:
    is_healthy = await adapter.validate_connection()
    self.metrics[provider_name].status = (
    #                     ProviderStatus.HEALTHY if is_healthy else ProviderStatus.UNHEALTHY
    #                 )

    health_results[provider_name] = {
    #                     'status': 'healthy' if is_healthy else 'unhealthy',
                        'last_check': datetime.utcnow().isoformat()
    #                 }

    #             except Exception as e:
    self.metrics[provider_name].status = ProviderStatus.UNHEALTHY
    health_results[provider_name] = {
    #                     'status': 'error',
                        'error': str(e),
                        'last_check': datetime.utcnow().isoformat()
    #                 }

    #         return health_results

    #     def enable_provider(self, provider: str):
    #         """Manually enable a provider."""
    #         if provider in self.disabled_providers:
    #             del self.disabled_providers[provider]
    self.metrics[provider].status = ProviderStatus.HEALTHY
            self.logger.info(f"Manually enabled provider: {provider}")

    #     def disable_provider_manually(self, provider: str):
    #         """Manually disable a provider."""
    self.disabled_providers[provider] = datetime.utcnow()
    self.metrics[provider].status = ProviderStatus.DISABLED
            self.logger.info(f"Manually disabled provider: {provider}")

    #     async def reload_configurations(self):
    #         """Reload adapter configurations."""
            self.logger.info("Reloading adapter configurations...")

    #         # Close existing adapters
    #         for adapter in self.adapters.values():
                await adapter.close()

    #         # Reinitialize
            self.adapters.clear()
            self.adapter_configs.clear()
            self.metrics.clear()
            self.disabled_providers.clear()

            self._initialize_adapters()
            self.logger.info("Adapter configurations reloaded")

    #     async def close(self):
    #         """Close all adapter connections."""
    #         for adapter in self.adapters.values():
                await adapter.close()
            self.logger.info("All adapter connections closed")

    #     async def __aenter__(self):
    #         """Async context manager entry."""
    #         return self

    #     async def __aexit__(self, exc_type, exc_val, exc_tb):
    #         """Async context manager exit."""
            await self.close()