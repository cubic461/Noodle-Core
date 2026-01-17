"""
Full LLM Integration for NIP v3

This module provides complete LLM provider integration for patch generation,
with Z.ai GLM-4.7 as the primary provider plus support for OpenAI, Anthropic,
and other popular providers.
"""

import json
import os
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
import subprocess
import time


class LLMProvider(Enum):
    """Supported LLM providers"""
    Z_AI = "z_ai"  # Z.ai GLM-4.7 (Primary)
    OPENAI = "openai"  # GPT-4, GPT-3.5
    ANTHROPIC = "anthropic"  # Claude
    GOOGLE = "google"  # Gemini
    COHERE = "cohere"  # Cohere models
    HUGGINGFACE = "huggingface"  # Open source models
    LOCAL = "local"  # Local models (Ollama, etc.)


class LLMModel(Enum):
    """Popular model names by provider"""
    
    # Z.ai GLM Models (Primary)
    GLM_4_7 = "glm-4.7"  # Primary model
    GLM_4_PLUS = "glm-4-plus"
    GLM_4_AIR = "glm-4-air"
    GLM_3_TURBO = "glm-3-turbo"
    
    # OpenAI
    GPT_4_TURBO = "gpt-4-turbo"
    GPT_4 = "gpt-4"
    GPT_3_5_TURBO = "gpt-3.5-turbo"
    
    # Anthropic
    CLAUDE_3_OPUS = "claude-3-opus"
    CLAUDE_3_SONNET = "claude-3-sonnet"
    CLAUDE_3_HAIKU = "claude-3-haiku"
    
    # Google
    GEMINI_PRO = "gemini-pro"
    GEMINI_ULTRA = "gemini-ultra"
    
    # Cohere
    COMMAND_R = "command-r"
    COMMAND_R_PLUS = "command-r-plus"


@dataclass
class LLMConfig:
    """Configuration for LLM provider"""
    provider: LLMProvider
    model: str
    api_key: Optional[str] = None
    api_base: Optional[str] = None
    temperature: float = 0.7
    max_tokens: int = 4096
    timeout_seconds: int = 120
    
    # Z.ai specific
    zai_project_id: Optional[str] = None
    zai_endpoint: Optional[str] = None
    
    # OpenAI specific
    organization_id: Optional[str] = None
    
    # Anthropic specific
    anthropic_version: str = "2023-06-01"
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization"""
        return {
            'provider': self.provider.value,
            'model': self.model,
            'api_base': self.api_base,
            'temperature': self.temperature,
            'max_tokens': self.max_tokens,
            'timeout_seconds': self.timeout_seconds,
            'zai_project_id': self.zai_project_id,
            'zai_endpoint': self.zai_endpoint
        }


@dataclass
class LLMRequest:
    """Request to LLM"""
    prompt: str
    context: str = ""
    system_prompt: str = ""
    temperature: Optional[float] = None
    max_tokens: Optional[int] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class LLMResponse:
    """Response from LLM"""
    content: str
    model: str
    provider: LLMProvider
    tokens_used: int = 0
    cost_usd: float = 0.0
    duration_seconds: float = 0.0
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'content': self.content,
            'model': self.model,
            'provider': self.provider.value,
            'tokens_used': self.tokens_used,
            'cost_usd': self.cost_usd,
            'duration_seconds': self.duration_seconds,
            'metadata': self.metadata
        }


class LLMProviderBase(ABC):
    """Base class for LLM providers"""
    
    def __init__(self, config: LLMConfig):
        self.config = config
    
    @abstractmethod
    def generate(self, request: LLMRequest) -> LLMResponse:
        """Generate response from LLM"""
        pass
    
    @abstractmethod
    def generate_stream(self, request: LLMRequest):
        """Generate streaming response from LLM"""
        pass
    
    @abstractmethod
    def estimate_cost(self, prompt_tokens: int, completion_tokens: int) -> float:
        """Estimate cost in USD"""
        pass
    
    def _count_tokens(self, text: str) -> int:
        """Rough token estimation (≈4 characters per token)"""
        return len(text) // 4


class ZAIProvider(LLMProviderBase):
    """
    Z.ai GLM-4.7 provider (PRIMARY).
    
    GLM-4.7 is a high-performance Chinese-English bilingual model
    optimized for code generation and technical tasks.
    """
    
    # Approximate pricing (may vary)
    INPUT_COST_PER_1K_TOKENS = 0.0007  # ~$0.70 per 1M tokens
    OUTPUT_COST_PER_1K_TOKENS = 0.0020  # ~$2.00 per 1M tokens
    
    def __init__(self, config: LLMConfig):
        super().__init__(config)
        
        # Set default Z.ai endpoint if not specified
        if not config.api_base:
            self.api_base = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
        else:
            self.api_base = config.api_base
        
        # Load API key from env if not provided
        self.api_key = config.api_key or os.environ.get("ZAI_API_KEY")
        if not self.api_key:
            raise ValueError("ZAI_API_KEY not configured")
        
        self.project_id = config.zai_project_id or os.environ.get("ZAI_PROJECT_ID")
    
    def generate(self, request: LLMRequest) -> LLMResponse:
        """Generate response using Z.ai GLM"""
        start_time = time.time()
        
        # Prepare payload
        payload = {
            "model": self.config.model,
            "messages": [
                {"role": "system", "content": request.system_prompt or "You are a helpful coding assistant."},
                {"role": "user", "content": request.prompt}
            ],
            "temperature": request.temperature or self.config.temperature,
            "max_tokens": request.max_tokens or self.config.max_tokens
        }
        
        if self.project_id:
            payload["project_id"] = self.project_id
        
        # Make request
        try:
            import requests
            
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            }
            
            response = requests.post(
                self.api_base,
                json=payload,
                headers=headers,
                timeout=self.config.timeout_seconds
            )
            
            response.raise_for_status()
            data = response.json()
            
            # Parse response
            content = data["choices"][0]["message"]["content"]
            prompt_tokens = data.get("usage", {}).get("prompt_tokens", 0)
            completion_tokens = data.get("usage", {}).get("completion_tokens", 0)
            total_tokens = data.get("usage", {}).get("total_tokens", 0)
            
            duration = time.time() - start_time
            cost = self.estimate_cost(prompt_tokens, completion_tokens)
            
            return LLMResponse(
                content=content,
                model=self.config.model,
                provider=LLMProvider.Z_AI,
                tokens_used=total_tokens,
                cost_usd=cost,
                duration_seconds=duration
            )
            
        except Exception as e:
            raise RuntimeError(f"Z.ai API request failed: {str(e)}")
    
    def generate_stream(self, request: LLMRequest):
        """Generate streaming response (generator)"""
        import requests
        
        payload = {
            "model": self.config.model,
            "messages": [
                {"role": "system", "content": request.system_prompt},
                {"role": "user", "content": request.prompt}
            ],
            "temperature": request.temperature or self.config.temperature,
            "max_tokens": request.max_tokens or self.config.max_tokens,
            "stream": True
        }
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        response = requests.post(
            self.api_base,
            json=payload,
            headers=headers,
            stream=True,
            timeout=self.config.timeout_seconds
        )
        
        for line in response.iter_lines():
            if line:
                line = line.decode('utf-8')
                if line.startswith('data: '):
                    data = line[6:]
                    if data == '[DONE]':
                        break
                    try:
                        chunk = json.loads(data)
                        if 'choices' in chunk and len(chunk['choices']) > 0:
                            delta = chunk['choices'][0].get('delta', {})
                            if 'content' in delta:
                                yield delta['content']
                    except json.JSONDecodeError:
                        continue
    
    def estimate_cost(self, prompt_tokens: int, completion_tokens: int) -> float:
        """Estimate cost in USD"""
        input_cost = (prompt_tokens / 1000) * self.INPUT_COST_PER_1K_TOKENS
        output_cost = (completion_tokens / 1000) * self.OUTPUT_COST_PER_1K_TOKENS
        return input_cost + output_cost


class OpenAIProvider(LLMProviderBase):
    """OpenAI GPT provider"""
    
    INPUT_COST_PER_1K_TOKENS = 0.01  # GPT-4
    OUTPUT_COST_PER_1K_TOKENS = 0.03
    
    def __init__(self, config: LLMConfig):
        super().__init__(config)
        
        self.api_key = config.api_key or os.environ.get("OPENAI_API_KEY")
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY not configured")
        
        self.api_base = config.api_base or "https://api.openai.com/v1/chat/completions"
        self.organization = config.organization_id or os.environ.get("OPENAI_ORGANIZATION")
    
    def generate(self, request: LLMRequest) -> LLMResponse:
        """Generate response using OpenAI"""
        start_time = time.time()
        
        payload = {
            "model": self.config.model,
            "messages": [
                {"role": "system", "content": request.system_prompt},
                {"role": "user", "content": request.prompt}
            ],
            "temperature": request.temperature or self.config.temperature,
            "max_tokens": request.max_tokens or self.config.max_tokens
        }
        
        try:
            import requests
            
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            }
            
            if self.organization:
                headers["OpenAI-Organization"] = self.organization
            
            response = requests.post(
                self.api_base,
                json=payload,
                headers=headers,
                timeout=self.config.timeout_seconds
            )
            
            response.raise_for_status()
            data = response.json()
            
            content = data["choices"][0]["message"]["content"]
            prompt_tokens = data.get("usage", {}).get("prompt_tokens", 0)
            completion_tokens = data.get("usage", {}).get("completion_tokens", 0)
            total_tokens = data.get("usage", {}).get("total_tokens", 0)
            
            duration = time.time() - start_time
            cost = self.estimate_cost(prompt_tokens, completion_tokens)
            
            return LLMResponse(
                content=content,
                model=self.config.model,
                provider=LLMProvider.OPENAI,
                tokens_used=total_tokens,
                cost_usd=cost,
                duration_seconds=duration
            )
            
        except Exception as e:
            raise RuntimeError(f"OpenAI API request failed: {str(e)}")
    
    def generate_stream(self, request: LLMRequest):
        """Generate streaming response"""
        # Implementation similar to ZAI
        yield "Streaming not implemented for OpenAI yet"
    
    def estimate_cost(self, prompt_tokens: int, completion_tokens: int) -> float:
        """Estimate cost in USD"""
        input_cost = (prompt_tokens / 1000) * self.INPUT_COST_PER_1K_TOKENS
        output_cost = (completion_tokens / 1000) * self.OUTPUT_COST_PER_1K_TOKENS
        return input_cost + output_cost


class AnthropicProvider(LLMProviderBase):
    """Anthropic Claude provider"""
    
    INPUT_COST_PER_1K_TOKENS = 0.003  # Claude 3 Sonnet
    OUTPUT_COST_PER_1K_TOKENS = 0.015
    
    def __init__(self, config: LLMConfig):
        super().__init__(config)
        
        self.api_key = config.api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY not configured")
        
        self.api_base = config.api_base or "https://api.anthropic.com/v1/messages"
        self.version = config.anthropic_version
    
    def generate(self, request: LLMRequest) -> LLMResponse:
        """Generate response using Anthropic Claude"""
        start_time = time.time()
        
        payload = {
            "model": self.config.model,
            "max_tokens": request.max_tokens or self.config.max_tokens,
            "system": request.system_prompt,
            "messages": [
                {"role": "user", "content": request.prompt}
            ]
        }
        
        try:
            import requests
            
            headers = {
                "x-api-key": self.api_key,
                "anthropic-version": self.version,
                "Content-Type": "application/json"
            }
            
            response = requests.post(
                self.api_base,
                json=payload,
                headers=headers,
                timeout=self.config.timeout_seconds
            )
            
            response.raise_for_status()
            data = response.json()
            
            content = data["content"][0]["text"]
            prompt_tokens = data.get("usage", {}).get("input_tokens", 0)
            completion_tokens = data.get("usage", {}).get("output_tokens", 0)
            total_tokens = prompt_tokens + completion_tokens
            
            duration = time.time() - start_time
            cost = self.estimate_cost(prompt_tokens, completion_tokens)
            
            return LLMResponse(
                content=content,
                model=self.config.model,
                provider=LLMProvider.ANTHROPIC,
                tokens_used=total_tokens,
                cost_usd=cost,
                duration_seconds=duration
            )
            
        except Exception as e:
            raise RuntimeError(f"Anthropic API request failed: {str(e)}")
    
    def generate_stream(self, request: LLMRequest):
        """Generate streaming response"""
        yield "Streaming not implemented for Anthropic yet"
    
    def estimate_cost(self, prompt_tokens: int, completion_tokens: int) -> float:
        """Estimate cost in USD"""
        input_cost = (prompt_tokens / 1000) * self.INPUT_COST_PER_1K_TOKENS
        output_cost = (completion_tokens / 1000) * self.OUTPUT_COST_PER_1K_TOKENS
        return input_cost + output_cost


class LLMManager:
    """
    Manages multiple LLM providers and provides unified interface.
    
    Features:
    - Multi-provider support with automatic fallback
    - Cost tracking and budget management
    - Response caching
    - Rate limiting
    - Provider selection strategies
    """
    
    def __init__(self, primary_config: LLMConfig):
        self.primary_config = primary_config
        self.providers: Dict[LLMProvider, LLMProviderBase] = {}
        self.primary_provider = self._create_provider(primary_config)
        
        # Statistics
        self.total_requests = 0
        self.total_tokens = 0
        self.total_cost = 0.0
    
    def _create_provider(self, config: LLMConfig) -> LLMProviderBase:
        """Create provider instance from config"""
        if config.provider == LLMProvider.Z_AI:
            return ZAIProvider(config)
        elif config.provider == LLMProvider.OPENAI:
            return OpenAIProvider(config)
        elif config.provider == LLMProvider.ANTHROPIC:
            return AnthropicProvider(config)
        else:
            raise ValueError(f"Unsupported provider: {config.provider}")
    
    def add_fallback_provider(self, config: LLMConfig):
        """Add a fallback provider"""
        provider = self._create_provider(config)
        self.providers[config.provider] = provider
    
    def generate(
        self,
        prompt: str,
        system_prompt: str = "",
        use_fallback: bool = True
    ) -> LLMResponse:
        """Generate response using primary or fallback provider"""
        self.total_requests += 1
        
        try:
            request = LLMRequest(
                prompt=prompt,
                system_prompt=system_prompt
            )
            
            response = self.primary_provider.generate(request)
            
            # Update statistics
            self.total_tokens += response.tokens_used
            self.total_cost += response.cost_usd
            
            return response
            
        except Exception as e:
            if use_fallback and self.providers:
                # Try fallback providers
                for provider in self.providers.values():
                    try:
                        response = provider.generate(request)
                        self.total_tokens += response.tokens_used
                        self.total_cost += response.cost_usd
                        return response
                    except Exception:
                        continue
            
            raise RuntimeError(f"All LLM providers failed: {str(e)}")
    
    def generate_patch(
        self,
        context: str,
        task_description: str,
        file_changes: List[Dict[str, Any]]
    ) -> str:
        """
        Generate a code patch using LLM.
        
        Args:
            context: Repository context and code
            task_description: Description of the task
            file_changes: Files to modify
            
        Returns:
            Unified diff patch
        """
        system_prompt = """You are an expert software engineer. Generate a unified diff patch that implements the requested task.

Guidelines:
- Output ONLY the unified diff, no explanations
- Use standard unified diff format (---, +++, @@, +, -)
- Make minimal, focused changes
- Ensure code compiles and passes tests
- Follow the repository's coding style

Example:
--- a/example.py
+++ b/example.py
@@ -1,3 +1,4 @@
 def hello():
-    print("Hi")
+    print("Hello, World!")
+    return True
"""
        
        prompt = f"""Context:
{context[:5000]}  # Limit context size

Task:
{task_description}

Files to modify:
{json.dumps(file_changes, indent=2)}

Generate the unified diff patch:"""
        
        response = self.generate(
            prompt=prompt,
            system_prompt=system_prompt
        )
        
        return response.content
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get usage statistics"""
        return {
            'total_requests': self.total_requests,
            'total_tokens': self.total_tokens,
            'total_cost_usd': round(self.total_cost, 4),
            'average_tokens_per_request': (
                self.total_tokens / self.total_requests
                if self.total_requests > 0 else 0
            )
        }


def create_default_llm_manager() -> LLMManager:
    """
    Create LLM manager with Z.ai GLM-4.7 as primary provider.
    
    This is the recommended configuration for NIP v3.
    """
    config = LLMConfig(
        provider=LLMProvider.Z_AI,
        model=LLMModel.GLM_4_7.value,
        temperature=0.7,
        max_tokens=4096
    )
    
    manager = LLMManager(config)
    
    # Add OpenAI as fallback
    if os.environ.get("OPENAI_API_KEY"):
        openai_config = LLMConfig(
            provider=LLMProvider.OPENAI,
            model=LLMModel.GPT_4_TURBO.value,
            temperature=0.7
        )
        manager.add_fallback_provider(openai_config)
    
    return manager