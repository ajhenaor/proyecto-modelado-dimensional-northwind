#!/usr/bin/env python3
"""Run dbt with Snowflake OAuth caching patch applied before adapters load."""
from __future__ import annotations

import sys
from pathlib import Path


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    sys.path.insert(0, str(root))
    import dbt_snowflake_oauth_patch  # noqa: F401 — side effect: monkey-patch

    from dbt.cli.main import cli

    raise SystemExit(cli())


if __name__ == "__main__":
    main()
