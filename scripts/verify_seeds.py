#!/usr/bin/env python3
"""Verify preprocess_seeds.py output matches committed seed_manifest.json."""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "scripts" / "seed_manifest.json"
PREPROCESS = ROOT / "scripts" / "preprocess_seeds.py"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    if not MANIFEST.is_file():
        print(f"Missing manifest: {MANIFEST}", file=sys.stderr)
        return 1

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    expected = manifest.get("outputs", {})
    if not expected:
        print("Manifest has no outputs", file=sys.stderr)
        return 1

    with tempfile.TemporaryDirectory() as tmp:
        tmp_root = Path(tmp)
        tmp_seeds = tmp_root / "seeds"
        tmp_scripts = tmp_root / "scripts"
        tmp_scripts.mkdir(parents=True)
        tmp_seeds.mkdir(parents=True)

        env = {
            **dict(__import__("os").environ),
            "VERIFY_SEEDS_TMP": str(tmp_root),
        }
        # Run preprocess in isolated tmp by patching OUT via subprocess env is not supported;
        # invoke module logic with patched paths instead.
        import importlib.util

        spec = importlib.util.spec_from_file_location("preprocess_seeds", PREPROCESS)
        mod = importlib.util.module_from_spec(spec)
        assert spec and spec.loader
        spec.loader.exec_module(mod)
        orig_out = mod.OUT
        orig_manifest = mod.MANIFEST
        mod.OUT = tmp_seeds
        mod.MANIFEST = tmp_scripts / "seed_manifest.json"
        try:
            mod.main()
        finally:
            mod.OUT = orig_out
            mod.MANIFEST = orig_manifest

        mismatches: list[str] = []
        for name, meta in expected.items():
            path = tmp_seeds / name
            if not path.is_file():
                mismatches.append(f"{name}: missing after preprocess")
                continue
            got_rows = sum(1 for _ in path.open(encoding="utf-8")) - 1
            got_hash = sha256_file(path)
            exp_rows = meta.get("rows")
            exp_hash = meta.get("sha256")
            if exp_rows is not None and got_rows != exp_rows:
                mismatches.append(f"{name}: rows expected {exp_rows} got {got_rows}")
            if exp_hash and got_hash != exp_hash:
                mismatches.append(
                    f"{name}: sha256 expected {exp_hash} got {got_hash}"
                )

        if mismatches:
            for line in mismatches:
                print(line, file=sys.stderr)
            return 1

        n = len(expected)
        print(f"OK: {n}/{n} seeds match manifest")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
