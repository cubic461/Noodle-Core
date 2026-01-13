# Converted from Python to NoodleCore
# Original file: src

# """
# Data Extractor for ALE Training Pipeline
# Extracts usage events from DB and generates training data for transpiler model.
# """

import json
import typing.Any

import ..db.ALEDatabase


def extract_training_data(num_samples: int = 1000) -List[Dict[str, Any]]):
#     """
#     Extract usage events and generate training pairs.
#     Returns list of {'input': str, 'output': str} for code generation.
#     """
db = ALEDatabase()
events = db.get_frequent_calls("default", min_calls=5, days=30)[:num_samples]

training_data = []
#     for event in events:
#         # Get sample args from DB or generate
sample_args = [{"type": "ndarray", "value": "[[1,2],[3,4]]"}]  # Mock
#         input_str = f"Transpile {event} with args {json.dumps(sample_args)}"
output_str = f"let a = tensor.from_python({sample_args[0]['value']}); a.dot(a)"  # Mock Noodle code

        training_data.append({"input": input_str, "output": output_str})

#     return training_data


if __name__ == "__main__"
    data = extract_training_data()
    #     with open("training_data.json", "w") as f:
    json.dump(data, f, indent = 2)
        print(f"Extracted {len(data)} training samples.")
