"""
Quick debug script to check input tensor for simulation bug
"""
import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer


def load_gpt2_model(model_name="gpt2"):
    tokenizer = GPT2Tokenizer.from_pretrained(model_name)
    model = GPT2LMHeadModel.from_pretrained(model_name)
    model.eval()
    return model, tokenizer


def print_tensor_info(name, tensor):
    print(f"{name}:")
    print(f"  Shape: {tensor.shape}")
    print(f"  Dtype: {tensor.dtype}")
    print(f"  Min: {tensor.min()}")
    print(f"  Max: {tensor.max()}")
    print()


# Load model
model, tokenizer = load_gpt2_model('gpt2')
print(f"Vocab Size: {model.config.vocab_size}")
print()

# Create input
prompt = "test"
encoded = tokenizer(
    prompt,
    padding="max_length",
    truncation=True,
    max_length=128,
    return_tensors="pt",
)

print_tensor_info("Original input_ids", encoded['input_ids'])

# Simulate what happens in simulator._execute_stage
activations = encoded['input_ids'][0]  # Get first sequence
print_tensor_info("Activations (stage input)", activations)

# Try to convert
try:
    activations_long = activations.long()
    print_tensor_info("Activations (long)", activations_long)
    print("Long conversion OK")
except Exception as e:
    print(f"Long conversion FAILED: {e}")
    exit(1)

# Try embedding lookup
try:
    input_ids_long = activations_long.unsqueeze(0)
    print_tensor_info("For model input", input_ids_long)
    output = model(input_ids=input_ids_long)
    print("Model forward pass OK")
except Exception as e:
    print(f"Model forward pass FAILED: {e}")
    print(f"Error type: {type(e)}")
    print()
    print("Tensor checks:")
    print(f"  vocab_size: {model.config.vocab_size}")
    print(f"  input max: {input_ids_long.max()}")
    print(f"  Valid indices: 0 to {model.config.vocab_size - 1}")
    if input_ids_long.max() >= model.config.vocab_size:
        print(f"  ERROR: index {input_ids_long.max()} >= vocab_size {model.config.vocab_size}!")
    exit(1)
