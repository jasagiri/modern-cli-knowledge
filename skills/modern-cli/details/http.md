# Build and send HTTP requests: xh

## Intent

Write an HTTP request as `METHOD URL items…` instead of a long `curl` command with quoting, and
check what will be sent before sending it.

Every example on this page uses `--offline`: xh builds the request and prints it, and no network
connection is made. Without `--offline` the same command sends it.

## Classic and modern

| classic | modern |
|---|---|
| `curl 'https://h/search?q=cli&page=2'` | `xh https://h/search q==cli page==2` |
| `curl -X POST -H 'Content-Type: application/json' -d '{"name":"demo"}' URL` | `xh POST URL name=demo` |
| `curl -X POST -d a=1 -d b=2 URL` | `xh -f POST URL a=1 b=2` |
| `curl -H 'X-Token: abc' URL` | `xh URL X-Token:abc` |
| `curl -H 'Authorization: Bearer tok' URL` | `xh URL --bearer tok` |
| `curl -X POST --data-binary @f.json -H 'Content-Type: application/json' URL` | `xh POST URL @f.json` |
| `curl -v …` (shows the request) | `xh --offline …` / `xh -v …` |

## Commands

Request items decide where each value goes: `name==value` is a query parameter. Print only the
request line (`-p H` prints the request headers, `head -1` keeps the first line):

```sh
xh --offline --ignore-stdin -p H example.org/search q==cli page==2 | head -1
```
```text
GET /search?q=cli&page=2 HTTP/1.1
```

`key=value` is a JSON string field and `key:=json` is raw JSON (a number, boolean, array or object).
`-p B` prints the request body:

```sh
# spec: CLI-XH-03
xh --offline --ignore-stdin -p B POST example.org/api name=demo n=1 m:=1 ports:=[1,2] debug:=false | head -1
```
```text
{"name":"demo","n":"1","m":1,"ports":[1,2],"debug":false}
```

`Name:value` is a header. The JSON body also sets `Content-Type` and `Accept` for you:

```sh
# spec: CLI-XH-02
xh --offline --ignore-stdin -p H POST example.org name=x X-Token:abc | grep -E '^(POST|X-Token|Content-Type|Accept:)'
```
```text
POST / HTTP/1.1
Accept: application/json, */*;q=0.5
Content-Type: application/json
X-Token: abc
```

With `-f` the items become a form body instead:

```sh
# spec: CLI-XH-02
xh --offline --ignore-stdin -f -p B POST example.org a=1 b=2 | head -1
```
```text
a=1&b=2
```

Send a file as the body with `@path`; here the body is read back with jq to show it is the file:

```sh
# spec: CLI-XH-06
xh --offline --ignore-stdin -p B POST example.org @data/people.json | jq -c 'map(.name)'
```
```text
["Alice","Bob","Carol"]
```

The method is POST as soon as there is a body and GET otherwise, unless it is written first:

```sh
# spec: CLI-XH-04
xh --offline --ignore-stdin -p H example.org name=x | head -1; xh --offline --ignore-stdin -p H PUT example.org id==1 | head -1
```
```text
POST / HTTP/1.1
PUT /?id=1 HTTP/1.1
```

A query value is percent-encoded: `b==c%d` is sent as `b=c%25d`. A file that is not JSON gets the
content type of its kind (`blob.bin` here is `application/octet-stream`):

```sh
# spec: CLI-XH-05 CLI-XH-06
xh --offline --ignore-stdin -p H example.org b==c%d | head -1
xh --offline --ignore-stdin -p H POST example.org @data/blob.bin | grep -i '^content-type'
```
```text
GET /?b=c%25d HTTP/1.1
Content-Type: application/octet-stream
```

Without `--ignore-stdin`, standard input that is not a terminal (here `/dev/null`) is the body: a
plain GET becomes a POST, and request items are refused with status 1:

```sh
# spec: CLI-XH-01
xh --offline -p H example.org | head -1
xh --offline POST example.org name=x > /dev/null 2>&1; echo "status: $?"
```
```text
POST / HTTP/1.1
status: 1
```

`--curl` prints the equivalent `curl` command instead of the request (`--offline` is ignored with a
warning on standard error, and nothing is sent). Use it to translate a command into the classic form
or to learn what xh adds:

```sh
# spec: CLI-XH-11
xh --ignore-stdin --curl POST example.org/api name=demo X-Token:abc q==1 2>/dev/null
```
```text
curl -X POST 'http://example.org/api?q=1' -H 'x-token: abc' -H 'content-type: application/json' -H 'accept: application/json, */*;q=0.5' -d '{"name":"demo"}'
```

A bearer token goes into the `Authorization` header (use `-a user:password` for basic auth):

```sh
xh --offline --ignore-stdin -p H example.org --bearer tok | grep Authorization
```
```text
Authorization: Bearer tok
```

## Differences that change results

- **Standard input is the body.** When standard input is not a terminal (a pipe, a file, `/dev/null`,
  cron, CI, `xargs`, an agent's shell) xh reads it as the request body. With `key=value` items it
  stops with an error; without items a plain GET becomes a POST with an empty body. Add
  `--ignore-stdin` (`-I`) in scripts. `curl` never reads standard input unless asked (`-d @-`).
- **JSON is the default.** `key=value` builds JSON and adds `Content-Type: application/json` and
  `Accept: application/json, */*;q=0.5`; `curl -d` sends a form (`application/x-www-form-urlencoded`)
  and no `Accept`. Use `-f` for a form.
- **Types.** `n=1` is the string `"1"`; `n:=1` is the number 1. `curl -d` has no types: you write
  the JSON yourself.
- **Method.** Guessed from the presence of a body (see above); `curl -d` also implies POST.
- **Query values are encoded.** `b==c%d` is sent as `b=c%25d`; in `curl` the URL is sent as given.
- **Body from a file.** `@file` sends the file as is, with a JSON content type here; check the
  `Content-Type` line of `-p H` when the file is not JSON.
- **Output.** xh formats and colours the response on a terminal, and prints the request only with
  `-v`/`--print`. When piped it prints the body without formatting; `curl` prints the body only
  and the status line with `-i`.
- **Exit status.** By its own help text xh exits with an error status when the server replies with
  an error (`--check-status`, the default); `curl` exits 0 for an HTTP error unless `-f`/`--fail`.
  Not run here (`--offline` sends nothing).
- **Redirects.** Neither follows them by default: `curl -L`, `xh --follow` (`-F`).
- **Header order is not stable.** The headers print in an order the examples do not rely on; pick
  lines with `grep` rather than comparing the whole request.
- **Scheme.** With no scheme xh uses `http://` (see the `--curl` output); write `https://` for TLS.
- **Version.** The examples were checked with `xh 0.26.3`.

## When to keep the classic command

- POSIX scripts, CI images and servers without xh: `curl` is almost always present.
- Uploads, resumable downloads, proxies, client certificates, or protocols other than HTTP (FTP,
  SMTP): `curl` has more options and is the documented tool for them.
- Anything where the exact bytes of the request must be controlled (`--data-binary`, a hand-written
  header order or a non-JSON content type): `curl` sends only what you wrote.

## Pitfalls

With standard input redirected (as in a script, CI or this test), xh reads it as the body and
rejects the request items:

```sh bad
xh --offline POST example.org name=x
```
```sh
# spec: CLI-XH-01
xh --offline --ignore-stdin -p B POST example.org name=x | head -1
```
```text
{"name":"x"}
```

## Sources

- `2e7ca995f972a659` xh
- `0fcd5e4bf264865c` Data Science at the Command Line
