#!/bin/bash
# FMH CMS quick-tunnel 주소 자동 발행 워처 (launchd: com.findmyhome.tunnelpub)
# ~/findmyhome/logs/tunnel_url.txt 가 바뀌면 fmh-tunnel 레포의 tunnel.json 을 갱신·push.
# 런처(sgkim-project.vercel.app)가 raw 로 읽어 FMH CMS 링크를 최신으로 유지한다.
set -u
REPO="/Users/markkim/fmh-tunnel"
URL_FILE="/Users/markkim/findmyhome/logs/tunnel_url.txt"
KEY="/Users/markkim/.ssh/id_ed25519"
export GIT_SSH_COMMAND="ssh -i $KEY -o BatchMode=yes -o StrictHostKeyChecking=accept-new"
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/local/bin:$PATH"
cd "$REPO" || exit 1

log(){ echo "[$(date '+%F %T')] $*"; }

# 재시작 시 원격이 이미 최신이면 재푸시 안 하도록 현재 발행값을 기준선으로 잡는다
last=$(grep -Eo 'https://[a-z0-9-]+\.trycloudflare\.com' "$REPO/tunnel.json" 2>/dev/null | tail -1)
log "watcher start; baseline=[$last]"

while true; do
  url=$(cat "$URL_FILE" 2>/dev/null)
  if [ -n "$url" ] && [ "$url" != "$last" ]; then
    log "change detected: [$url]"
    ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    printf '{"cms":"%s","updated":"%s"}\n' "$url" "$ts" > "$REPO/tunnel.json"
    git add tunnel.json
    if git diff --cached --quiet; then
      last="$url"
    elif git -c user.email="sgkim.mixit@gmail.com" -c user.name="kim-banjang" commit -q -m "tunnel: $url" && git push -q origin main; then
      last="$url"; log "published [$url]"
    else
      log "push failed; retry next tick"
    fi
  fi
  sleep 15
done
