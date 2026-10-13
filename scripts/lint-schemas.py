#!/usr/bin/env python3

# Validates this repo's YAML files against their schemas.
# Requires the `jsonschema` and `pyyaml` Python packages.
# (Install `python3-jsonschema` and `python3-yaml`).

import json
import sys
from pathlib import Path

import jsonschema
import yaml

ROOT = Path(__file__).resolve().parent.parent

SCHEMAS = {
    "schemas/testing.schema.json": ["source/testing.yml"],
    "schemas/demo.schema.json": ["source/demos/*.yml"],
}

failed = False
for schema_path, patterns in SCHEMAS.items():
    schema = json.loads((ROOT / schema_path).read_text())
    validator = jsonschema.Draft202012Validator(schema)
    files = sorted(file for pattern in patterns for file in ROOT.glob(pattern))
    if not files:
        print(f"Error: no files match {patterns}")
        failed = True
    for file in files:
        name = file.relative_to(ROOT)
        errors = list(validator.iter_errors(yaml.safe_load(file.read_text())))
        for error in errors:
            print(f"{name}: {error.json_path}: {error.message}")
        if errors:
            failed = True
        else:
            print(f"ok: {name}")

sys.exit(1 if failed else 0)
