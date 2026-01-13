# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Lib Store for ALE
# Stores validated Noodle implementations with metadata.
# """

import json
import pathlib.Path
import typing.Any,


class LibStore
    #     """
    #     Stores and retrieves Noodle library implementations with metadata.
    #     """

    #     def __init__(self, store_path: str = "noodle/lib_store"):
    self.store_path = Path(store_path)
    self.store_path.mkdir(parents = True, exist_ok=True)

    #     def store_lib(self, lib_name: str, source_code: str, metadata: Dict[str, Any]):
    #         """
    #         Store a Noodle library with metadata.
    #         """
    lib_dir = math.divide(self.store_path, lib_name)
    lib_dir.mkdir(exist_ok = True)

    #         # Store source code
    code_file = lib_dir / "impl.noodle"
    #         with open(code_file, "w") as f:
                f.write(source_code)

    #         # Store metadata
    meta_file = lib_dir / "metadata.json"
    #         with open(meta_file, "w") as f:
    json.dump(metadata, f, indent = 2)

    #     def get_lib(self, lib_name: str) -> Optional[Dict[str, Any]]:
    #         """
    #         Retrieve a library and its metadata.
    #         """
    lib_dir = math.divide(self.store_path, lib_name)
    #         if not lib_dir.exists():
    #             return None

    code_file = lib_dir / "impl.noodle"
    meta_file = lib_dir / "metadata.json"

    #         if not code_file.exists() or not meta_file.exists():
    #             return None

    #         with open(code_file, "r") as f:
    source_code = f.read()

    #         with open(meta_file, "r") as f:
    metadata = json.load(f)

    #         return {"source_code": source_code, "metadata": metadata}

    #     def list_libs(self) -> List[str]:
    #         """
    #         List all stored libraries.
    #         """
    #         if not self.store_path.exists():
    #             return []

    #         return [
    #             d.name
    #             for d in self.store_path.iterdir()
    #             if (self.store_path / d / "metadata.json").exists()
    #         ]


# Global instance
lib_store = LibStore()
