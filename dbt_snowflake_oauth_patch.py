"""
Patches dbt-snowflake OAuth (authorization code) connect() kwargs for Snowflake.

When oauth_enable_refresh_tokens is True, snowflake-connector-python appends the
`offline_access` scope so it can store refresh tokens. Many identity providers
(Snowflake SSO via Azure AD, Okta, etc.) do **not** allow that scope and the
browser shows: "The requested scope is invalid."

Default: do **not** enable refresh tokens (no `offline_access`). Re-enable only
if your IdP explicitly allows it — see README in .env.example.
"""

import os


def apply() -> None:
    from dbt.adapters.snowflake.connections import SnowflakeCredentials

    _orig = SnowflakeCredentials.auth_args

    def auth_args(self):  # type: ignore[no-untyped-def]
        result = _orig(self)
        if (self.authenticator or "").upper() == "OAUTH_AUTHORIZATION_CODE":
            # Opt-in: export SNOWFLAKE_OAUTH_ENABLE_REFRESH_TOKENS=1
            enable_refresh = os.environ.get(
                "SNOWFLAKE_OAUTH_ENABLE_REFRESH_TOKENS", ""
            ).lower() in ("1", "true", "yes")
            result["oauth_enable_refresh_tokens"] = enable_refresh
            result.setdefault("client_store_temporary_credential", True)
            # Optional override when default session:role:<role> is wrong for your integration
            scope = os.environ.get("SNOWFLAKE_OAUTH_SCOPE", "").strip()
            if scope:
                result["oauth_scope"] = scope
            # Connector default is 120s — SSO / MFA often exceeds that → OAuth timeout errors.
            # Seconds; override via SNOWFLAKE_EXTERNAL_BROWSER_TIMEOUT (e.g. 600 for 10 min).
            try:
                timeout_s = int(
                    os.environ.get("SNOWFLAKE_EXTERNAL_BROWSER_TIMEOUT", "600")
                )
            except ValueError:
                timeout_s = 600
            result["external_browser_timeout"] = max(60, timeout_s)
        return result

    SnowflakeCredentials.auth_args = auth_args  # type: ignore[method-assign]


apply()
