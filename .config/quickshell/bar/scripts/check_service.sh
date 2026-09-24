#!/usr/bin/env bash
# Service health check used by the desktop ServiceMonitor widget.
# Usage: check_service.sh <type> <target> [user]
# Prints "up" or "down". To add a new check type, add a branch to check().

type="$1"
target="$2"
scope="$3"

check() {
    case "$type" in
        http)
            # Any 2xx/3xx response counts as up; curl prints 000 on failure.
            local code
            code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$target")
            [[ "$code" =~ ^[23] ]]
            ;;
        tcp)
            # target is host:port
            timeout 3 bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "${target%:*}" "${target##*:}" 2>/dev/null
            ;;
        systemd)
            local flags=()
            [[ "$scope" == "user" ]] && flags=(--user)
            systemctl "${flags[@]}" is-active --quiet "$target"
            ;;
        ping)
            ping -c1 -W2 "$target" >/dev/null 2>&1
            ;;
        cmd)
            # Arbitrary shell command; exit code 0 = up.
            bash -c "$target" >/dev/null 2>&1
            ;;
        *)
            echo "check_service.sh: unknown type '$type'" >&2
            return 1
            ;;
    esac
}

if check; then echo up; else echo down; fi
