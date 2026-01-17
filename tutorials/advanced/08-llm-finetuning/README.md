# 🧠 Tutorial 08: Custom LLM Fine-Tuning

> **Advanced NIP v3.0.0 Tutorial** - Building custom language models through fine-tuning techniques

## Table of Contents
- [Overview](#overview)
- [Fine-Tuning Strategies](#fine-tuning-strategies)
- [Dataset Preparation](#dataset-preparation)
- [Training Pipelines](#training-pipelines)
- [Model Evaluation](#model-evaluation)
- [Deployment Strategies](#deployment-strategies)
- [Quantization](#quantization)
- [Model Versioning](#model-versioning)
- [Cost Optimization](#cost-optimization)
- [Practical Exercises](#practical-exercises)
- [Best Practices](#best-practices)

---

## Overview

Fine-tuning large language models (LLMs) allows you to adapt pre-trained models to your specific use cases, domain knowledge, and requirements. This tutorial covers modern fine-tuning techniques using NIP v3.0.0's extensible architecture.

### What You'll Learn
- Efficient fine-tuning with PEFT, LoRA, and QLoRA
- Dataset preparation and formatting strategies
- Building robust training pipelines
- Evaluating fine-tuned models
- Deploying quantized models
- Managing model versions and costs

### Prerequisites
- Completed Tutorials 01-07
- NVIDIA GPU with 12GB+ VRAM (for QLoRA)
- 16GB+ system RAM
- Understanding of PyTorch basics

---

## Fine-Tuning Strategies

### Full Fine-Tuning vs. PEFT

**Full Fine-Tuning**: Updates all model parameters
- **Pros**: Maximum adaptation capability
- **Cons**: Requires massive compute (multiple A100 GPUs)
- **Use Case**: When you have abundant resources and need maximum performance

**PEFT (Parameter-Efficient Fine-Tuning)**: Updates small subset of parameters
- **Pros**: Trains on single GPU, faster iterations
- **Cons**: Slightly lower performance ceiling
- **Use Case**: Most practical applications (recommended for NIP)

### LoRA (Low-Rank Adaptation)

LoRA adds trainable rank decomposition matrices to existing weights:

```python
# nip/config/lora_config.py
from dataclasses import dataclass
from typing import Optional, List

@dataclass
class LoRAConfig:
    """LoRA configuration for efficient fine-tuning"""
    
    # Rank of the low-rank matrices
    r: int = 16
    
    # Scaling factor (alpha / r)
    alpha: float = 32
    
    # Target modules to apply LoRA
    target_modules: List[str] = None
    
    # Dropout probability
    dropout: float = 0.05
    
    # Bias training strategy
    bias: str = "none"  # "none", "all", "lora_only"
    
    # Task type
    task_type: str = "CAUSAL_LM"
    
    def __post_init__(self):
        if self.target_modules is None:
            # Default modules for transformer models
            self.target_modules = [
                "q_proj",
                "k_proj", 
                "v_proj",
                "o_proj",
                "gate_proj",
                "up_proj",
                "down_proj"
            ]
```

**Implementation Example:**

```python
# nip/training/lora_trainer.py
import torch
from peft import LoraConfig, get_peft_model, TaskType
from transformers import AutoModelForCausalLM, AutoTokenizer

class LoRATrainer:
    """Fine-tune models using LoRA"""
    
    def __init__(self, model_name: str, config: LoRAConfig):
        self.model_name = model_name
        self.config = config
        self.model = None
        self.tokenizer = None
        
    def prepare_model(self):
        """Load model and apply LoRA adapters"""
        # Load base model in 16-bit precision
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_name,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True
        )
        
        self.tokenizer = AutoTokenizer.from_pretrained(
            self.model_name,
            trust_remote_code=True
        )
        
        # Configure LoRA
        lora_config = LoraConfig(
            r=self.config.r,
            lora_alpha=self.config.alpha,
            target_modules=self.config.target_modules,
            lora_dropout=self.config.dropout,
            bias=self.config.bias,
            task_type=TaskType.CAUSAL_LM
        )
        
        # Apply LoRA adapters
        self.model = get_peft_model(self.model, lora_config)
        self.model.print_trainable_parameters()
        
        return self.model, self.tokenizer
        
    def train(self, train_dataset, eval_dataset, training_args):
        """Execute LoRA fine-tuning"""
        from transformers import Trainer
        
        trainer = Trainer(
            model=self.model,
            args=training_args,
            train_dataset=train_dataset,
            eval_dataset=eval_dataset,
            tokenizer=self.tokenizer,
        )
        
        return trainer.train()
```

### QLoRA (Quantized LoRA)

QLoRA combines 4-bit quantization with LoRA for maximum efficiency:

```python
# nip/training/qlora_trainer.py
from transformers import BitsAndBytesConfig

class QLoRATrainer(LoRATrainer):
    """Fine-tune models using QLoRA (4-bit quantization + LoRA)"""
    
    def prepare_model(self):
        """Load model in 4-bit and apply LoRA"""
        # Configure 4-bit quantization
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",  # Normal Float 4
            bnb_4bit_compute_dtype=torch.float16,
            bnb_4bit_use_double_quant=True,  # Double quantization
        )
        
        # Load quantized model
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_name,
            quantization_config=bnb_config,
            device_map="auto",
            trust_remote_code=True
        )
        
        self.tokenizer = AutoTokenizer.from_pretrained(
            self.model_name,
            trust_remote_code=True
        )
        
        # Configure LoRA (higher rank for QLoRA)
        lora_config = LoraConfig(
            r=64,  # Higher rank for QLoRA
            lora_alpha=128,
            target_modules=self.config.target_modules,
            lora_dropout=0.05,
            bias="none",
            task_type=TaskType.CAUSAL_LM
        )
        
        self.model = get_peft_model(self.model, lora_config)
        self.model.print_trainable_parameters()
        
        return self.model, self.tokenizer
```

### Strategy Comparison

| Strategy | VRAM Required | Training Speed | Quality | Cost |
|----------|---------------|----------------|---------|------|
| Full Fine-Tuning | 80GB+ | Very Slow | ⭐⭐⭐⭐⭐ | $$$$$ |
| LoRA | 16GB | Fast | ⭐⭐⭐⭐ | $ |
| QLoRA | 12GB | Medium | ⭐⭐⭐⭐ | $ |

**Recommendation**: Start with QLoRA for cost-effective experimentation.

---

## Dataset Preparation

### Data Collection Strategies

```python
# nip/data/dataset_collector.py
from datasets import Dataset, DatasetDict
from typing import List, Dict, Any
import json

class DatasetCollector:
    """Collect and format training data"""
    
    @staticmethod
    def from_conversations(conversations: List[Dict[str, Any]]) -> Dataset:
        """
        Format conversation data for instruction tuning.
        
        Expected format:
        [
            {
                "messages": [
                    {"role": "user", "content": "What is...?"},
                    {"role": "assistant", "content": "The answer is..."}
                ]
            }
        ]
        """
        formatted_data = []
        
        for conv in conversations:
            # Convert to training prompt
            prompt = DatasetCollector._format_prompt(conv["messages"])
            formatted_data.append({"text": prompt})
            
        return Dataset.from_list(formatted_data)
    
    @staticmethod
    def from_jsonl(file_path: str) -> Dataset:
        """Load dataset from JSONL file"""
        data = []
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                data.append(json.loads(line))
        return Dataset.from_list(data)
    
    @staticmethod
    def _format_prompt(messages: List[Dict[str, str]]) -> str:
        """Format messages into training prompt"""
        prompt = ""
        for msg in messages:
            role = msg["role"].capitalize()
            content = msg["content"]
            prompt += f"{role}: {content}\n"
        prompt += "Assistant:"
        return prompt
```

### Data Processing Pipeline

```python
# nip/data/data_processor.py
from datasets import DatasetDict
from transformers import AutoTokenizer
from typing import Callable

class DataProcessor:
    """Process and tokenize datasets"""
    
    def __init__(self, tokenizer: AutoTokenizer, max_length: int = 512):
        self.tokenizer = tokenizer
        self.max_length = max_length
        
    def prepare_dataset(
        self,
        raw_dataset: DatasetDict,
        text_column: str = "text",
        test_size: float = 0.1
    ) -> DatasetDict:
        """
        Process raw dataset into train/validation splits
        """
        # Tokenize
        tokenized = raw_dataset.map(
            self._tokenize_function,
            batched=True,
            remove_columns=raw_dataset["train"].column_names,
            desc="Tokenizing"
        )
        
        # Split into train/validation
        split_dataset = tokenized["train"].train_test_split(
            test_size=test_size,
            seed=42
        )
        
        return DatasetDict({
            "train": split_dataset["train"],
            "validation": split_dataset["test"]
        })
    
    def _tokenize_function(self, examples):
        """Tokenize batch of examples"""
        return self.tokenizer(
            examples["text"],
            truncation=True,
            max_length=self.max_length,
            padding="max_length",
            return_tensors=None
        )
```

### Quality Filters

```python
# nip/data/quality_filters.py
import re

class DatasetQualityFilter:
    """Filter low-quality data from training set"""
    
    @staticmethod
    def remove_duplicates(dataset: Dataset) -> Dataset:
        """Remove duplicate examples"""
        seen = set()
        unique_data = []
        
        for example in dataset:
            text_hash = hash(example["text"])
            if text_hash not in seen:
                seen.add(text_hash)
                unique_data.append(example)
        
        return Dataset.from_list(unique_data)
    
    @staticmethod
    def filter_by_length(dataset: Dataset, min_len: int = 50, max_len: int = 2048) -> Dataset:
        """Filter by text length"""
        filtered = dataset.filter(
            lambda x: min_len <= len(x["text"]) <= max_len
        )
        return filtered
    
    @staticmethod
    def remove_toxic_content(dataset: Dataset, toxic_words: List[str]) -> Dataset:
        """Remove examples containing toxic words"""
        def is_clean(example):
            text_lower = example["text"].lower()
            return not any(word in text_lower for word in toxic_words)
        
        return dataset.filter(is_clean)
```

### Example: Creating a Custom Dataset

```python
# examples/create_custom_dataset.py
from nip.data.dataset_collector import DatasetCollector
from nip.data.data_processor import DataProcessor
from transformers import AutoTokenizer

# Sample domain-specific data
conversations = [
    {
        "messages": [
            {"role": "user", "content": "What is NIP?"},
            {"role": "assistant", "content": "NIP is an AI orchestration framework..."}
        ]
    },
    {
        "messages": [
            {"role": "user", "content": "How do I install NIP?"},
            {"role": "assistant", "content": "Install NIP using pip: pip install nip-framework..."}
        ]
    }
]

# Collect and format
collector = DatasetCollector()
raw_dataset = collector.from_conversations(conversations)

# Process
tokenizer = AutoTokenizer.from_pretrained("microsoft/phi-3")
processor = DataProcessor(tokenizer, max_length=512)
processed_dataset = processor.prepare_dataset(raw_dataset)

# Save
processed_dataset.save_to_disk("./data/nip_tutorial_dataset")
```

---

## Training Pipelines

### Complete Training Script

```python
# scripts/train_llm.py
import argparse
import torch
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType
from datasets import load_from_disk

def parse_args():
    parser = argparse.ArgumentParser(description="Fine-tune LLM with LoRA")
    parser.add_argument("--model", type=str, required=True, help="Base model name")
    parser.add_argument("--dataset", type=str, required=True, help="Dataset path")
    parser.add_argument("--output", type=str, required=True, help="Output directory")
    parser.add_argument("--lora_r", type=int, default=16, help="LoRA rank")
    parser.add_argument("--lora_alpha", type=int, default=32, help="LoRA alpha")
    parser.add_argument("--epochs", type=int, default=3, help="Training epochs")
    parser.add_argument("--batch_size", type=int, default=4, help="Batch size")
    parser.add_argument("--learning_rate", type=float, default=2e-4, help="Learning rate")
    parser.add_argument("--quantize", action="store_true", help="Use QLoRA")
    return parser.parse_args()

def main():
    args = parse_args()
    
    print(f"🚀 Starting fine-tuning of {args.model}")
    
    # Load tokenizer
    tokenizer = AutoTokenizer.from_pretrained(args.model)
    tokenizer.pad_token = tokenizer.eos_token
    
    # Load model
    if args.quantize:
        from transformers import BitsAndBytesConfig
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16,
            bnb_4bit_use_double_quant=True,
        )
        model = AutoModelForCausalLM.from_pretrained(
            args.model,
            quantization_config=bnb_config,
            device_map="auto",
            trust_remote_code=True
        )
    else:
        model = AutoModelForCausalLM.from_pretrained(
            args.model,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True
        )
    
    # Configure LoRA
    lora_config = LoraConfig(
        r=args.lora_r,
        lora_alpha=args.lora_alpha,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
        lora_dropout=0.05,
        bias="none",
        task_type=TaskType.CAUSAL_LM
    )
    
    model = get_peft_model(model, lora_config)
    model.print_trainable_parameters()
    
    # Load dataset
    print(f"📊 Loading dataset from {args.dataset}")
    dataset = load_from_disk(args.dataset)
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir=args.output,
        num_train_epochs=args.epochs,
        per_device_train_batch_size=args.batch_size,
        per_device_eval_batch_size=args.batch_size,
        gradient_accumulation_steps=4,
        learning_rate=args.learning_rate,
        weight_decay=0.01,
        warmup_steps=100,
        logging_steps=10,
        save_steps=500,
        eval_steps=500,
        fp16=True if not args.quantize else False,
        bf16=False if not args.quantize else True,
        optim="adamw_torch",
        lr_scheduler_type="cosine",
        report_to=["tensorboard"],
        save_total_limit=3,
        load_best_model_at_end=True,
        metric_for_best_model="eval_loss",
    )
    
    # Data collator
    data_collator = DataCollatorForLanguageModeling(
        tokenizer=tokenizer,
        mlm=False,
        pad_to_multiple_of=8
    )
    
    # Trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=dataset["train"],
        eval_dataset=dataset["validation"],
        data_collator=data_collator,
        tokenizer=tokenizer,
    )
    
    # Train
    print("🎯 Starting training...")
    trainer.train()
    
    # Save
    print(f"💾 Saving model to {args.output}")
    trainer.save_model()
    tokenizer.save_pretrained(args.output)
    
    print("✅ Training complete!")

if __name__ == "__main__":
    main()
```

### Running Training

```bash
# LoRA training
python scripts/train_llm.py \
    --model microsoft/phi-3 \
    --dataset ./data/nip_tutorial_dataset \
    --output ./models/nip-phi-3-lora \
    --lora_r 16 \
    --lora_alpha 32 \
    --epochs 3 \
    --batch_size 4 \
    --learning_rate 2e-4

# QLoRA training (more memory efficient)
python scripts/train_llm.py \
    --model microsoft/phi-3 \
    --dataset ./data/nip_tutorial_dataset \
    --output ./models/nip-phi-3-qlora \
    --lora_r 64 \
    --lora_alpha 128 \
    --epochs 3 \
    --batch_size 4 \
    --learning_rate 2e-4 \
    --quantize
```

---

## Model Evaluation

### Evaluation Metrics

```python
# nip/evaluation/model_evaluator.py
from transformers import AutoModelForCausalLM, AutoTokenizer
from datasets import load_dataset
import torch
from typing import List, Dict
import numpy as np

class ModelEvaluator:
    """Evaluate fine-tuned models"""
    
    def __init__(self, model_path: str, base_model: str = None):
        self.model_path = model_path
        self.model = AutoModelForCausalLM.from_pretrained(
            model_path,
            torch_dtype=torch.float16,
            device_map="auto"
        )
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        self.base_model = base_model
    
    def generate_responses(
        self,
        prompts: List[str],
        max_length: int = 256,
        temperature: float = 0.7,
        num_return_sequences: int = 1
    ) -> List[str]:
        """Generate responses for evaluation prompts"""
        responses = []
        
        for prompt in prompts:
            inputs = self.tokenizer(
                prompt,
                return_tensors="pt",
                truncation=True,
                max_length=512
            ).to(self.model.device)
            
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_length=max_length,
                    temperature=temperature,
                    do_sample=True,
                    num_return_sequences=num_return_sequences,
                    pad_token_id=self.tokenizer.eos_token_id
                )
            
            decoded = self.tokenizer.batch_decode(outputs, skip_special_tokens=True)
            responses.extend(decoded)
        
        return responses
    
    def evaluate_perplexity(self, test_dataset) -> float:
        """Calculate perplexity on test set"""
        total_loss = 0
        total_tokens = 0
        
        for batch in test_dataset:
            inputs = {
                k: torch.tensor(v).unsqueeze(0).to(self.model.device)
                for k, v in batch.items()
            }
            
            with torch.no_grad():
                outputs = self.model(**inputs, labels=inputs["input_ids"])
                loss = outputs.loss
                
                total_loss += loss.item() * inputs["input_ids"].size(1)
                total_tokens += inputs["input_ids"].size(1)
        
        avg_loss = total_loss / total_tokens
        perplexity = np.exp(avg_loss)
        
        return perplexity
```

### Benchmark Script

```python
# scripts/evaluate_model.py
import argparse
from nip.evaluation.model_evaluator import ModelEvaluator

def parse_args():
    parser = argparse.ArgumentParser(description="Evaluate fine-tuned model")
    parser.add_argument("--model", type=str, required=True, help="Model path")
    parser.add_argument("--prompts", type=str, help="File with evaluation prompts")
    return parser.parse_args()

def main():
    args = parse_args()
    
    # Initialize evaluator
    evaluator = ModelEvaluator(args.model)
    
    # Test prompts
    test_prompts = [
        "What is NIP and what does it do?",
        "How do I create a custom tool in NIP?",
        "Explain the architecture of NIP v3.0.0",
        "What are the best practices for building NIP tools?",
    ]
    
    print("🧪 Generating responses...")
    responses = evaluator.generate_responses(
        test_prompts,
        max_length=256,
        temperature=0.7
    )
    
    # Display results
    for prompt, response in zip(test_prompts, responses):
        print(f"\n{'='*60}")
        print(f"Prompt: {prompt}")
        print(f"\nResponse:")
        print(response)
        print(f"{'='*60}\n")

if __name__ == "__main__":
    main()
```

---

## Deployment Strategies

### Merging LoRA Weights

```python
# scripts/merge_lora.py
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer
import argparse

def merge_lora_weights(base_model: str, lora_model: str, output: str):
    """Merge LoRA weights into base model for deployment"""
    
    print(f"🔧 Merging LoRA weights from {lora_model}")
    print(f"📦 Base model: {base_model}")
    
    # Load base model
    base = AutoModelForCausalLM.from_pretrained(
        base_model,
        torch_dtype=torch.float16,
        device_map="auto"
    )
    
    # Load LoRA model
    model = PeftModel.from_pretrained(base, lora_model)
    
    # Merge weights
    print("⚙️  Merging weights...")
    merged_model = model.merge_and_unload()
    
    # Save
    print(f"💾 Saving merged model to {output}")
    merged_model.save_pretrained(output)
    
    # Save tokenizer
    tokenizer = AutoTokenizer.from_pretrained(lora_model)
    tokenizer.save_pretrained(output)
    
    print("✅ Merge complete!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--base_model", required=True)
    parser.add_argument("--lora_model", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    
    merge_lora_weights(args.base_model, args.lora_model, args.output)
```

### Serving Fine-Tuned Models

```python
# nip/serving/model_server.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
from typing import List

app = FastAPI(title="NIP Fine-Tuned Model Server")

class GenerationRequest(BaseModel):
    prompt: str
    max_length: int = 256
    temperature: float = 0.7
    top_p: float = 0.9

class GenerationResponse(BaseModel):
    text: str
    model: str

# Load model at startup
@app.on_event("startup")
async def load_model():
    global model, tokenizer
    model_path = "./models/nip-phi-3-lora"
    
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16,
        device_map="auto"
    )
    
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    
    print(f"✅ Model loaded from {model_path}")

@app.post("/generate", response_model=GenerationResponse)
async def generate(request: GenerationRequest):
    """Generate text from fine-tuned model"""
    
    inputs = tokenizer(
        request.prompt,
        return_tensors="pt",
        truncation=True,
        max_length=512
    ).to(model.device)
    
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_length=request.max_length,
            temperature=request.temperature,
            top_p=request.top_p,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id
        )
    
    response_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    return GenerationResponse(
        text=response_text,
        model="nip-phi-3-lora"
    )
```

---

## Quantization

### Post-Training Quantization

```python
# scripts/quantize_model.py
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

def quantize_model(model_path: str, output_path: str, bits: int = 8):
    """Quantize model for deployment"""
    
    print(f"🔢 Quantizing model to {bits}-bit")
    
    # Load model
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16,
        device_map="auto"
    )
    
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    
    # Quantize
    if bits == 8:
        model = model.half()  # Convert to FP16
    elif bits == 4:
        from transformers import BitsAndBytesConfig
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16,
        )
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            quantization_config=bnb_config,
            device_map="auto"
        )
    
    # Save
    print(f"💾 Saving quantized model to {output_path}")
    model.save_pretrained(output_path)
    tokenizer.save_pretrained(output_path)
    
    print("✅ Quantization complete!")

if __name__ == "__main__":
    quantize_model(
        model_path="./models/nip-phi-3-lora",
        output_path="./models/nip-phi-3-quantized",
        bits=4
    )
```

---

## Model Versioning

### Version Tracking

```python
# nip/model_management/versioning.py
from dataclasses import dataclass
from datetime import datetime
import json
import hashlib

@dataclass
class ModelVersion:
    """Track model versions and metadata"""
    version: str
    base_model: str
    training_data: str
    hyperparameters: dict
    metrics: dict
    created_at: str
    checksum: str
    
    def to_dict(self) -> dict:
        return {
            "version": self.version,
            "base_model": self.base_model,
            "training_data": self.training_data,
            "hyperparameters": self.hyperparameters,
            "metrics": self.metrics,
            "created_at": self.created_at,
            "checksum": self.checksum
        }

class ModelRegistry:
    """Registry for tracking model versions"""
    
    def __init__(self, registry_path: str = "./models/registry.json"):
        self.registry_path = registry_path
        self.models = self._load_registry()
    
    def register_model(
        self,
        version: str,
        base_model: str,
        training_data: str,
        hyperparameters: dict,
        metrics: dict,
        model_path: str
    ):
        """Register a new model version"""
        
        # Calculate checksum
        checksum = self._calculate_checksum(model_path)
        
        version_info = ModelVersion(
            version=version,
            base_model=base_model,
            training_data=training_data,
            hyperparameters=hyperparameters,
            metrics=metrics,
            created_at=datetime.now().isoformat(),
            checksum=checksum
        )
        
        self.models[version] = version_info.to_dict()
        self._save_registry()
        
        print(f"✅ Registered model version {version}")
    
    def _calculate_checksum(self, path: str) -> str:
        """Calculate SHA256 checksum of model files"""
        import os
        sha256_hash = hashlib.sha256()
        
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith('.bin') or file.endswith('.safetensors'):
                    file_path = os.path.join(root, file)
                    with open(file_path, "rb") as f:
                        for byte_block in iter(lambda: f.read(4096), b""):
                            sha256_hash.update(byte_block)
        
        return sha256_hash.hexdigest()
    
    def _load_registry(self) -> dict:
        """Load existing registry"""
        try:
            with open(self.registry_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {}
    
    def _save_registry(self):
        """Save registry to disk"""
        with open(self.registry_path, 'w') as f:
            json.dump(self.models, f, indent=2)
```

---

## Cost Optimization

### Training Cost Calculator

```python
# nip/tools/cost_calculator.py
from dataclasses import dataclass

@dataclass
class TrainingCost:
    """Estimate training costs"""
    
    # AWS pricing (as of 2024)
    GPU_PRICING = {
        "g4dn.xlarge": 0.526,      # 1x T4 (16GB)
        "g4dn.2xlarge": 0.752,     # 1x T4 (16GB)
        "g5.xlarge": 1.006,        # 1x A10G (24GB)
        "g5.2xlarge": 1.326,       # 1x A10G (24GB)
        "p3.2xlarge": 3.06,        # 1x V100 (16GB)
        "p3.8xlarge": 12.24,       # 4x V100
        "p4d.24xlarge": 32.77,     # 8x A100
    }
    
    @staticmethod
    def estimate_cost(
        instance_type: str,
        hours: float,
        spot: bool = False
    ) -> dict:
        """Estimate training cost"""
        
        hourly_rate = TrainingCost.GPU_PRICING.get(instance_type, 0)
        
        if spot:
            hourly_rate *= 0.3  # ~70% discount for spot instances
        
        total_cost = hourly_rate * hours
        
        return {
            "instance_type": instance_type,
            "hourly_rate": hourly_rate,
            "hours": hours,
            "spot": spot,
            "total_cost": total_cost
        }
    
    @staticmethod
    def estimate_hours(
        num_samples: int,
        batch_size: int,
        epochs: int,
        steps_per_second: float = 2.0
    ) -> float:
        """Estimate training time in hours"""
        
        steps_per_epoch = num_samples // batch_size
        total_steps = steps_per_epoch * epochs
        total_seconds = total_steps / steps_per_second
        hours = total_seconds / 3600
        
        return hours

# Example usage
if __name__ == "__main__":
    # Estimate for fine-tuning Phi-3 on 10,000 samples
    hours = TrainingCost.estimate_hours(
        num_samples=10000,
        batch_size=4,
        epochs=3,
        steps_per_second=1.5
    )
    
    cost = TrainingCost.estimate_cost(
        instance_type="g5.xlarge",
        hours=hours,
        spot=True
    )
    
    print(f"Estimated training time: {hours:.2f} hours")
    print(f"Estimated cost: ${cost['total_cost']:.2f}")
```

### Cost-Saving Tips

1. **Use Spot Instances**: Save up to 70% on AWS
2. **Start with QLoRA**: 4x less VRAM required
3. **Hyperparameter Optimization**: Find optimal settings before full training
4. **Early Stopping**: Stop training when validation loss plateaus
5. **Gradient Accumulation**: Simulate larger batch sizes
6. **Mixed Precision Training**: Use FP16/BF16 when possible

---

## Practical Exercises

### Exercise 1: Fine-Tune a Small Model

**Task**: Fine-tune a small model (Phi-3-mini) on a custom dataset

**Steps**:
1. Collect 50-100 examples in your domain
2. Format data for instruction tuning
3. Train using QLoRA
4. Evaluate results

**Solution**: See `examples/exercise1_finetune.py`

```python
# examples/exercise1_finetune.py
# Your solution here
```

### Exercise 2: Compare LoRA vs. QLoRA

**Task**: Train the same dataset with both LoRA and QLoRA, compare:
- Training time
- VRAM usage
- Model quality (perplexity)

**Deliverable**: Report with findings

### Exercise 3: Deploy Fine-Tuned Model

**Task**:
1. Merge LoRA weights
2. Quantize to 4-bit
3. Set up inference server
4. Benchmark latency

**Deliverable**: Working API endpoint

---

## Best Practices

### Data Quality
- ✅ Start with 1,000-10,000 high-quality examples
- ✅ Remove duplicates and low-quality data
- ✅ Balance your dataset across different topics
- ✅ Use domain-specific terminology
- ❌ Avoid copyrighted content without permission

### Training
- ✅ Use QLoRA for initial experiments
- ✅ Monitor validation loss for overfitting
- ✅ Save checkpoints regularly
- ✅ Use gradient accumulation for larger effective batch sizes
- ❌ Don't train on test data

### Evaluation
- ✅ Use held-out test set
- ✅ Evaluate with multiple metrics (perplexity, human eval)
- ✅ Test on edge cases
- ✅ Compare against base model
- ❌ Don't rely on automated metrics alone

### Deployment
- ✅ Quantize models for production
- ✅ Monitor model performance in production
- ✅ Set up A/B testing
- ✅ Have rollback plan ready
- ❌ Don't deploy without testing

---

## Summary

This tutorial covered:

1. **Fine-Tuning Strategies**: PEFT, LoRA, QLoRA for efficient adaptation
2. **Dataset Preparation**: Collection, processing, and quality filtering
3. **Training Pipelines**: Complete scripts for LoRA/QLoRA training
4. **Model Evaluation**: Metrics and benchmarking approaches
5. **Deployment**: Merging weights, serving, and quantization
6. **Model Versioning**: Tracking model iterations and metadata
7. **Cost Optimization**: Reducing compute costs while maintaining quality

### Next Steps
- Explore [Tutorial 09: Multi-Modal Models](../09-multimodal/README.md)
- Read [NIP Model Management Guide](../../docs/model-management.md)
- Join the [NIP Community](https://github.com/noodle-ai/nip)

### Resources
- [PEFT Documentation](https://huggingface.co/docs/peft)
- [QLoRA Paper](https://arxiv.org/abs/2305.14314)
- [NIP Model Zoo](https://github.com/noodle-ai/nip-models)

---

**🧠 Tutorial Complete!** You now have the skills to fine-tune custom LLMs for your specific use cases using NIP v3.0.0.
