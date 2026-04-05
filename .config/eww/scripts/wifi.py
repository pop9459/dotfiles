#!/usr/bin/env python3

import argparse
import base64
import json
import shutil
import subprocess
import sys
from typing import Dict, List, Optional


def run_nmcli(args: List[str]) -> subprocess.CompletedProcess:
    return subprocess.run(["nmcli", *args], capture_output=True, text=True, check=False)


def split_escaped(line: str, sep: str = ":") -> List[str]:
    parts: List[str] = []
    current: List[str] = []
    escaped = False

    for ch in line:
        if escaped:
            current.append(ch)
            escaped = False
            continue

        if ch == "\\":
            escaped = True
            continue

        if ch == sep:
            parts.append("".join(current))
            current = []
            continue

        current.append(ch)

    if escaped:
        current.append("\\")

    parts.append("".join(current))
    return parts


def json_out(payload: object, exit_code: int = 0) -> int:
    print(json.dumps(payload, ensure_ascii=True))
    return exit_code


def error_payload(message: str, code: str = "error") -> Dict[str, object]:
    return {"ok": False, "code": code, "message": message}


def nmcli_available() -> bool:
    return shutil.which("nmcli") is not None


def wifi_enabled() -> bool:
    result = run_nmcli(["radio", "wifi"])
    return result.returncode == 0 and result.stdout.strip().lower() == "enabled"


def wifi_iface() -> Optional[str]:
    result = run_nmcli(["-t", "-f", "DEVICE,TYPE", "device", "status"])
    if result.returncode != 0:
        return None

    for raw in result.stdout.splitlines():
        if not raw:
            continue
        fields = split_escaped(raw)
        if len(fields) < 2:
            continue
        dev, dev_type = fields[0], fields[1]
        if dev and dev_type == "wifi":
            return dev
    return None


def signal_icon(enabled: bool, connected: bool, signal: int) -> str:
    if not enabled:
        return "󰤮"
    if not connected:
        return "󰤯"
    if signal >= 80:
        return "󰤨"
    if signal >= 60:
        return "󰤥"
    if signal >= 40:
        return "󰤢"
    if signal >= 20:
        return "󰤟"
    return "󰤯"


def parse_network_list(rescan: str = "auto") -> List[Dict[str, object]]:
    result = run_nmcli([
        "-t",
        "-f",
        "IN-USE,SSID,SIGNAL,SECURITY,BARS",
        "device",
        "wifi",
        "list",
        "--rescan",
        rescan,
    ])

    if result.returncode != 0:
        return []

    dedup: Dict[str, Dict[str, object]] = {}

    for raw in result.stdout.splitlines():
        if not raw:
            continue

        fields = split_escaped(raw)
        while len(fields) < 5:
            fields.append("")

        in_use, ssid, signal_raw, security, bars = fields[:5]
        ssid = ssid.strip()
        if not ssid:
            continue

        try:
            signal = int(signal_raw)
        except ValueError:
            signal = 0

        secure = security.strip() not in ("", "--")
        active = in_use.strip() == "*"
        ssid_b64 = base64.b64encode(ssid.encode("utf-8")).decode("ascii")

        entry = {
            "ssid": ssid,
            "ssid_b64": ssid_b64,
            "signal": signal,
            "security": security.strip(),
            "secure": secure,
            "active": active,
            "bars": bars.strip(),
        }

        prev = dedup.get(ssid)
        if prev is None:
            dedup[ssid] = entry
            continue

        if active and not bool(prev.get("active")):
            dedup[ssid] = entry
            continue

        if signal > int(prev.get("signal", 0)):
            dedup[ssid] = entry

    networks = list(dedup.values())
    networks.sort(key=lambda n: (not bool(n["active"]), -int(n["signal"]), str(n["ssid"]).lower()))
    return networks


def cmd_status() -> int:
    if not nmcli_available():
        return json_out(
            {
                "available": False,
                "enabled": False,
                "connected": False,
                "ssid": "",
                "signal": 0,
                "icon": "󰤭",
                "label": "Wi-Fi N/A",
                "error": "nmcli not found",
            }
        )

    iface = wifi_iface()
    enabled = wifi_enabled()
    networks = parse_network_list("no")

    active = next((n for n in networks if bool(n["active"])), None)
    connected = active is not None
    ssid = str(active["ssid"]) if active else ""
    signal = int(active["signal"]) if active else 0
    icon = signal_icon(enabled, connected, signal)

    if iface is None:
        label = "Wi-Fi N/A"
    elif not enabled:
        label = f"{icon} off"
    elif connected:
        label = f"{icon} {ssid}"
    else:
        label = f"{icon} disconnected"

    return json_out(
        {
            "available": iface is not None,
            "enabled": enabled,
            "connected": connected,
            "ssid": ssid,
            "signal": signal,
            "icon": icon,
            "label": label,
            "error": "" if iface is not None else "No Wi-Fi adapter detected",
        }
    )


def cmd_list() -> int:
    if not nmcli_available():
        return json_out([])
    return json_out(parse_network_list("auto"))


def decode_ssid(ssid: Optional[str], ssid_b64: Optional[str]) -> Optional[str]:
    if ssid:
        return ssid
    if not ssid_b64:
        return None

    try:
        return base64.b64decode(ssid_b64).decode("utf-8")
    except Exception:
        return None


def cmd_toggle() -> int:
    if not nmcli_available():
        return json_out(error_payload("nmcli not found", "missing_nmcli"), 1)

    enabled = wifi_enabled()
    desired = "off" if enabled else "on"
    result = run_nmcli(["radio", "wifi", desired])
    if result.returncode != 0:
        msg = (result.stderr or result.stdout or "Failed to toggle Wi-Fi").strip()
        return json_out(error_payload(msg, "toggle_failed"), 1)

    return json_out({"ok": True, "enabled": not enabled})


def cmd_disconnect() -> int:
    iface = wifi_iface()
    if iface is None:
        return json_out(error_payload("No Wi-Fi adapter detected", "no_adapter"), 1)

    result = run_nmcli(["device", "disconnect", iface])
    if result.returncode != 0:
        msg = (result.stderr or result.stdout or "Failed to disconnect").strip()
        return json_out(error_payload(msg, "disconnect_failed"), 1)

    return json_out({"ok": True})


def cmd_connect(ssid: Optional[str], ssid_b64: Optional[str], password: str) -> int:
    if not nmcli_available():
        return json_out(error_payload("nmcli not found", "missing_nmcli"), 1)

    resolved_ssid = decode_ssid(ssid, ssid_b64)
    if not resolved_ssid:
        return json_out(error_payload("Missing or invalid SSID", "invalid_ssid"), 1)

    cmd = ["device", "wifi", "connect", resolved_ssid]
    if password:
        cmd += ["password", password]

    result = run_nmcli(cmd)
    if result.returncode != 0:
        msg = (result.stderr or result.stdout or "Failed to connect").strip()
        lowered = msg.lower()
        code = "connect_failed"
        if "secrets were required" in lowered or "password" in lowered or "802-11-wireless-security" in lowered:
            code = "auth_failed"
        return json_out(error_payload(msg, code), 1)

    return json_out({"ok": True, "ssid": resolved_ssid})


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Wi-Fi helper for Eww widgets")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("status")
    sub.add_parser("list")
    sub.add_parser("toggle")
    sub.add_parser("disconnect")

    connect = sub.add_parser("connect")
    connect.add_argument("--ssid", default=None)
    connect.add_argument("--ssid-b64", default=None)
    connect.add_argument("--password", default="")

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "status":
        return cmd_status()
    if args.command == "list":
        return cmd_list()
    if args.command == "toggle":
        return cmd_toggle()
    if args.command == "disconnect":
        return cmd_disconnect()
    if args.command == "connect":
        return cmd_connect(args.ssid, args.ssid_b64, args.password)

    return json_out(error_payload("Unknown command", "invalid_command"), 1)


if __name__ == "__main__":
    sys.exit(main())
