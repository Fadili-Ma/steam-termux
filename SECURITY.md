# Security Policy

## Supported versions

Only the latest version of `steam-termux.sh` on the `main` branch is supported.

## Reporting a vulnerability

Please do **not** open a public issue for security problems.

Report them privately through GitHub:
**Security tab, then "Report a vulnerability"** on this repository.

Include what you found, how to reproduce it, and which version or commit you tested.
I will try to reply within a few days.

## What counts as a security issue here

- The script leaking or storing credentials (Steam password, Steam Guard code, tokens)
- Command injection through the script arguments (`<steam_user>`, `<appid>`, `<installdir>`)
- Downloading or running code from an untrusted source

## Reminder

Never post your Steam password, Steam Guard codes, or access tokens in issues or pull requests.
