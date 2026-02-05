"""
Configuration module for GitHub Enterprise Copilot.

This module provides environment-based configuration for using
GitHub Copilot with a custom GitHub Enterprise instance.
"""
import os
from typing import Optional


def get_github_enterprise_domain() -> Optional[str]:
    """
    Get the GitHub Enterprise domain from environment.
    
    Returns:
        Optional[str]: The GHE domain (e.g., 'bmw.ghe.com') or None for default github.com
    """
    return os.getenv("GITHUB_ENTERPRISE_DOMAIN")


def get_github_base_url() -> str:
    """
    Get the base GitHub URL (either github.com or custom GHE).
    
    Returns:
        str: The base URL for GitHub API
    """
    custom_domain = get_github_enterprise_domain()
    if custom_domain:
        return f"https://{custom_domain}"
    return "https://github.com"


def get_github_api_url() -> str:
    """
    Get the GitHub API URL.
    
    Returns:
        str: The API URL for GitHub
    """
    custom_domain = get_github_enterprise_domain()
    if custom_domain:
        return f"https://{custom_domain}/api/v3"
    return "https://api.github.com"


def get_github_device_code_url() -> str:
    """
    Get the GitHub device code URL.
    
    Returns:
        str: The device code URL for GitHub OAuth
    """
    base_url = get_github_base_url()
    return f"{base_url}/login/device/code"


def get_github_access_token_url() -> str:
    """
    Get the GitHub access token URL.
    
    Returns:
        str: The access token URL for GitHub OAuth
    """
    base_url = get_github_base_url()
    return f"{base_url}/login/oauth/access_token"


def get_github_copilot_api_key_url() -> str:
    """
    Get the GitHub Copilot API key URL.
    
    Returns:
        str: The Copilot API key URL
    """
    api_base = get_github_api_url()
    return f"{api_base}/copilot_internal/v2/token"
