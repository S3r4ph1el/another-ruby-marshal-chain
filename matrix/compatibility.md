# Compatibility matrix

Each ActiveSupport release was tested in a clean container, with the chain firing
`system()` end-to-end. The latest stack covered is **Ruby 4.0.5 + ActiveSupport
8.1.3 + erb 6.0.4** (the CVE-2026-41316-patched ERB), which `lab/` pins, and it fires
anyway, because it never deserialises an ERB.

| ActiveSupport | 2-gadget | 5-gadget | how |
|---------------|:--------:|:--------:|-----|
| 7.0.8.7 | RCE | RCE | ephemeral container |
| 7.1.6   | RCE | RCE | ephemeral container |
| 7.2.2.1 | RCE | RCE | ephemeral container |
| 8.0.2   | RCE | RCE | ephemeral container |
| 8.1.3   | RCE | RCE | lab build (Ruby 4.0.5) + host |

The gem version isn't the limiter, since the code paths are identical across the range.
What sets the reach is what's loaded on the target:

- **2-gadget** needs only ActiveSupport (present in every Rails app) plus ERB. Works on Rails 8 / Propshaft too.
- **5-gadget** needs Sprockets, plus OpenStruct (`ostruct`) on Ruby 4.0+ (it left the default gems). Doesn't apply to a default Rails 8 (Propshaft) app.

Generate the payload with the same ActiveSupport/rubygems versions as the target, so the Marshal class layout matches.
