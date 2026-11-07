# Cortive

**Save what you read. Find it again by what it meant.**

Cortive is a private knowledge base for your Mac. It keeps the pages, passages, PDFs, screenshots, documents, voice memos and clipboard snippets you choose to save, and finds them again by meaning, with an on-device model. Everything stays on your Mac: no account, no cloud, no telemetry.

This repository holds Cortive's downloads and release notes. Cortive is free during the public beta.

## Install

Needs an Apple silicon Mac (M1 or later) with macOS 14 Sonoma or later.

**One line in Terminal** (recommended):

```bash
curl -fsSL https://raw.githubusercontent.com/KadenDevAi/cortive-releases/main/install.sh | bash
```

It downloads the latest release from this page, checks it against its SHA-256 checksum, puts Cortive in Applications and opens it. [Read the script](install.sh) first if you like; it's short.

**Or download the DMG** from [Releases](https://github.com/KadenDevAi/cortive-releases/releases/latest), open it and drag Cortive to Applications. The beta isn't signed with an Apple Developer ID yet, so the first time you open it macOS says it can't check it for malware. Then:

1. Open **System Settings → Privacy & Security**.
2. Scroll to the message about Cortive and click **Open Anyway**.
3. Confirm with **Open**. You only do this once.

On first launch Cortive downloads its on-device search files (about 865 MB, from Hugging Face) and asks for Screen Recording, which it uses only when you take a screenshot capture.

## Use Cortive as your AI agent's memory

The [Cortive memory plugin for Hermes Agent](https://github.com/KadenDevAi/hermes-cortive) lets Hermes recall what you saved, read-only, with meaning search while Cortive is running:

```bash
hermes plugins install KadenDevAi/hermes-cortive
hermes config set memory.provider cortive
```

## Privacy

[PRIVACY.md](PRIVACY.md) lists every connection Cortive makes. In short: the one-time search-files download, an optional update check against this repository, and nothing else. Your library never leaves your Mac.

## Feedback

Report problems in [Issues](https://github.com/KadenDevAi/cortive-releases/issues), or use **Report a Problem** in Cortive (Settings → Help), which drafts an email to cortiveai@gmail.com.

© 2026 Kaden Desmarais. Cortive is free to use during the beta; the app's source code is not public.
