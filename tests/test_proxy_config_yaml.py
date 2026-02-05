import yaml
from pathlib import Path


def test_proxy_server_config_loads():
    p = Path(__file__).resolve().parents[1] / "proxy_server_config.yaml"
    assert p.exists(), f"Config file not found: {p}"
    with p.open("r", encoding="utf-8") as f:
        cfg = yaml.safe_load(f)
    assert isinstance(cfg, dict), "Parsed config is not a mapping"
    assert "model_list" in cfg, "model_list missing from config"
    assert isinstance(cfg["model_list"], list), "model_list is not a sequence"
