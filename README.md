# fmh-tunnel

Find My Home CMS(봇 관리)는 맥미니에서 cloudflare quick tunnel로 노출된다.
quick tunnel 주소는 맥미니 재시작마다 바뀐다.

`tunnel.json`은 맥미니의 launchd 워처(`com.findmyhome.tunnelpub`)가
`~/findmyhome/logs/tunnel_url.txt` 변경을 감지할 때마다 자동으로 갱신·push 한다.

김반장 런처(sgkim-project.vercel.app)가 이 파일을 raw로 읽어 FMH CMS 링크를 최신으로 유지한다.

형식: `{"cms":"https://...trycloudflare.com","updated":"<UTC ISO8601>"}`
