#!/usr/bin/env bash

# Simple latency checker for a download URL using curl metrics
#
# Usage:
#   check_latency.sh -u <url> [-n <iterations>]
#   check_latency.sh <url>                # positional URL supported
#   check_latency.sh -h | --help
#
# Options:
#   -u, --url <url>         The full URL to download and measure.
#   -n, --iterations <num>  Number of times to repeat (default: 10).
#   -h, --help              Show this help and exit.

set -euo pipefail

ITERATIONS=10
URL=""

usage() {
	cat <<USAGE
Latency checker

Examples:
	$(basename "$0") -u https://example.com/file.bin -n 5
	$(basename "$0") https://example.com/file.bin

Options:
	-u, --url <url>         The full URL to download and measure (required unless provided positionally).
	-n, --iterations <num>  Number of times to repeat (default: 10).
	-h, --help              Show this help and exit.
USAGE
}

if ! command -v curl >/dev/null 2>&1; then
	echo "Error: curl is required but not installed." >&2
	exit 1
fi

# Parse args (supports both short and long options, plus positional URL)
while [[ $# -gt 0 ]]; do
	case "$1" in
		-u|--url)
			[[ $# -ge 2 ]] || { echo "Error: missing value for $1" >&2; usage; exit 1; }
			URL="$2"; shift 2;;
		-n|--iterations)
			[[ $# -ge 2 ]] || { echo "Error: missing value for $1" >&2; usage; exit 1; }
			ITERATIONS="$2"; shift 2;;
		-h|--help)
			usage; exit 0;;
		--)
			shift; break;;
		-*)
			echo "Error: unknown option: $1" >&2; usage; exit 1;;
		*)
			# Positional URL (only if not set yet)
			if [[ -z "$URL" ]]; then
				URL="$1"; shift
			else
				echo "Error: unexpected positional argument: $1" >&2; usage; exit 1
			fi;;
	esac
done

if [[ -z "${URL}" ]]; then
	echo "Error: URL is required." >&2
	usage
	exit 1
fi

# Basic validation for iterations being a positive integer
if ! [[ "$ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
	echo "Error: iterations must be a positive integer (got: $ITERATIONS)" >&2
	exit 1
fi

echo "Measuring latency for: $URL"
echo "Iterations: $ITERATIONS"
echo "---"

for i in $(seq 1 "$ITERATIONS"); do
	echo -n "Run $i: "
	curl -s -o /dev/null \
		--write-out "size_download: %{size_download} // time_total: %{time_total} // time_starttransfer: %{time_starttransfer}\n" \
		"$URL"
done
