#!/usr/bin/env bash

# Read-only validation for the Docker Security LAB.
# Usage: ./scripts/validate-lab.sh host|ubuntu|kali

set -uo pipefail

MODE="${1:-}"
FAILURES=0
WARNINGS=0

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; FAILURES=$((FAILURES + 1)); }
warn() { printf 'WARN: %s\n' "$1"; WARNINGS=$((WARNINGS + 1)); }
info() { printf 'INFO: %s\n' "$1"; }

require_command() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  fi
  fail "Missing required command: $1"
  return 1
}

check_no_default_route() {
  if ip -4 route show default | grep -q .; then
    fail 'IPv4 default route is present'
  else
    pass 'IPv4 default route is absent'
  fi

  if ip -4 route get 1.1.1.1 >/dev/null 2>&1; then
    fail 'An external IPv4 route is resolvable'
  else
    pass 'External IPv4 route is absent'
  fi
}

check_exact_ip() {
  local expected="$1"
  if ip -4 -o address show | awk -v expected="$expected" '$4 == expected {found=1} END {exit !found}'; then
    pass "LAB address $expected is configured"
  else
    fail "LAB address $expected is missing"
  fi
}

check_ping() {
  local target="$1"
  local label="$2"
  if ping -c 2 -W 2 "$target" >/dev/null 2>&1; then
    pass "$label is reachable"
  else
    fail "$label is not reachable"
  fi
}

validate_ubuntu() {
  require_command ip || true
  require_command docker || true
  require_command ss || true
  require_command ping || true

  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${ID:-}" == ubuntu && "${VERSION_ID:-}" == 24.04 ]]; then
      pass 'OS is Ubuntu 24.04'
    else
      fail 'OS is not Ubuntu 24.04'
    fi
  else
    fail '/etc/os-release is unavailable'
  fi

  info "Kernel: $(uname -srmo)"

  local engine_version compose_version network_state
  engine_version="$(docker version --format '{{.Server.Version}}' 2>/dev/null || true)"
  if [[ "$engine_version" == 28.5.2 ]]; then
    pass 'Docker Engine server is 28.5.2'
  else
    fail "Docker Engine server expected 28.5.2, found ${engine_version:-unavailable}"
  fi

  compose_version="$(docker compose version --short 2>/dev/null || true)"
  compose_version="${compose_version#v}"
  if [[ "$compose_version" == 2.40.3 ]]; then
    pass 'Docker Compose Plugin is 2.40.3'
  else
    fail "Docker Compose Plugin expected 2.40.3, found ${compose_version:-unavailable}"
  fi

  network_state="$(docker network inspect docker-security-lab --format '{{.Internal}}|{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null || true)"
  if [[ "$network_state" == 'true|172.30.0.0/24' ]]; then
    pass 'Docker network is internal with subnet 172.30.0.0/24'
  else
    fail 'Docker network docker-security-lab does not match baseline'
  fi

  check_exact_ip '192.168.100.10/24'
  check_no_default_route
  check_ping '192.168.100.20' 'Kali LAB VM'

  if ss -H -lnt | awk '$4 ~ /:(2375|2376)$/ {found=1} END {exit !found}'; then
    fail 'Docker TCP API listener exists on 2375 or 2376'
  else
    pass 'Docker TCP API listeners 2375/2376 are absent'
  fi

  local container_count
  container_count="$(docker ps -aq 2>/dev/null | wc -l)"
  if [[ "$container_count" -eq 0 ]]; then
    pass 'No containers exist in baseline state'
  else
    warn "Baseline currently contains $container_count container(s)"
  fi
}

validate_kali() {
  require_command ip || true
  require_command ping || true

  check_exact_ip '192.168.100.20/24'
  check_no_default_route
  check_ping '192.168.100.10' 'Ubuntu Docker VM'
}

domain_nat_link_down() {
  local domain="$1"
  local nic_id persistent_state live_state domain_state

  nic_id="$(virsh -c qemu:///system domiflist "$domain" --inactive 2>/dev/null | awk '$3 == "default" {print $5; exit}')"
  if [[ -z "$nic_id" ]]; then
    fail "$domain has no persistent default-network NIC to verify"
    return
  fi

  persistent_state="$(virsh -c qemu:///system dumpxml "$domain" --inactive 2>/dev/null | awk -v target="$nic_id" 'BEGIN {RS="</interface>"} index($0,target) {print ($0 ~ /<link state=.down.\/>/ ? "down" : "up")}')"
  if [[ "$persistent_state" == down ]]; then
    pass "$domain persistent NAT NIC is down"
  else
    fail "$domain persistent NAT NIC is not down"
  fi

  domain_state="$(virsh -c qemu:///system domstate "$domain" 2>/dev/null | tr -d '\r' || true)"
  if [[ "$domain_state" == running ]]; then
    live_state="$(virsh -c qemu:///system domif-getlink "$domain" "$nic_id" 2>/dev/null | awk '{print $NF}')"
    if [[ "$live_state" == down ]]; then
      pass "$domain live NAT NIC is down"
    else
      fail "$domain live NAT NIC is not down"
    fi
  else
    warn "$domain is not running; live NIC state was not checked"
  fi
}

validate_host() {
  require_command virsh || true
  require_command ip || true

  local network_xml active autostart bridge
  network_xml="$(virsh -c qemu:///system net-dumpxml docker-security-isolated 2>/dev/null || true)"
  if [[ -z "$network_xml" ]]; then
    fail 'Libvirt network docker-security-isolated is unavailable'
    return
  fi

  active="$(virsh -c qemu:///system net-info docker-security-isolated | awk '/^Active:/ {print $2}')"
  autostart="$(virsh -c qemu:///system net-info docker-security-isolated | awk '/^Autostart:/ {print $2}')"
  bridge="$(awk -F"'" '/<bridge / {print $2}' <<<"$network_xml")"

  [[ "$active" == yes ]] && pass 'Isolated libvirt network is active' || fail 'Isolated libvirt network is inactive'
  [[ "$autostart" == yes ]] && pass 'Isolated libvirt network autostart is enabled' || fail 'Isolated libvirt network autostart is disabled'
  [[ "$bridge" == virbr100 ]] && pass 'Isolated bridge is virbr100' || fail 'Isolated bridge is not virbr100'

  if grep -Eq '<forward|<ip[ >]' <<<"$network_xml"; then
    fail 'Isolated network XML contains forwarding or host IP configuration'
  else
    pass 'Isolated network XML has no forwarding, host IP, DHCP, DNS, or gateway'
  fi

  if ip -o address show dev virbr100 scope global 2>/dev/null | grep -q .; then
    fail 'virbr100 has a global host address'
  else
    pass 'virbr100 has no global host address'
  fi

  if ip route show | awk '$0 ~ /virbr100/ {found=1} END {exit !found}'; then
    fail 'Host has a route through virbr100'
  else
    pass 'Host has no route through virbr100'
  fi

  domain_nat_link_down 'docker-security-ubuntu2404'
  domain_nat_link_down 'kali-linux'
}

case "$MODE" in
  host) validate_host ;;
  ubuntu) validate_ubuntu ;;
  kali) validate_kali ;;
  *)
    printf 'Usage: %s host|ubuntu|kali\n' "$0" >&2
    exit 2
    ;;
esac

printf '\nSummary: failures=%d warnings=%d\n' "$FAILURES" "$WARNINGS"
if (( FAILURES > 0 )); then
  exit 1
fi

printf 'RESULT: PASS\n'
