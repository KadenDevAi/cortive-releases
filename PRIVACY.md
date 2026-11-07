# Privacy

Cortive keeps what you capture on your Mac. It has no account, no cloud service and no
telemetry: no analytics, crash reports or usage statistics are sent anywhere.

This page lists every network connection Cortive makes, so you can check it yourself (for
example with Little Snitch, LuLu or `nettop`). If you see a connection that isn't listed
here, it's a bug; please report it.

## Connections to the internet

| What | When | Where | What is sent |
|---|---|---|---|
| Search files download | First launch, and again only if the files are missing or damaged | `huggingface.co` (files `embeddinggemma-2-Q8_0.gguf`, 310 MB, and `mmproj-embeddinggemma-2-Q8_0.gguf`, 555 MB, from a fixed commit of `ggml-org/embeddinggemma-2-GGUF`) | An ordinary file request with the user agent `Cortive/<version>`. Nothing from your library. |
| Update check | A minute after launch, then every 12 hours while Cortive is open, if **Look for updates automatically** is on (Settings → About); and when you press **Check Now** | `github.com` (the public `KadenDevAi/cortive-releases` repository's `latest.json`, a small file naming the newest version) | An ordinary file request with the user agent `tauri-plugin-updater/<its version>`. Not your Cortive version, no ID, nothing from your library. |
| Update download | Only when you press **Restart to Update** | `github.com` (that release's `Cortive.app.tar.gz`) | An ordinary file request, as above. |

Those are the only connections the app makes on its own. Each search file is checked against a
SHA-256 checksum before it is used. To turn the download off, start Cortive with
`CORTIVE_NO_MODEL_DOWNLOAD=1` and place the files in
`~/Library/Application Support/Cortive/models` yourself. Without them, search by exact words
still works; search by meaning and by image do not.

Hugging Face sees your IP address and the time of the download, like any website. Its
privacy policy applies to that request. The same goes for GitHub and the update check;
turn **Look for updates automatically** off and Cortive only checks when you press
**Check Now**. An update is installed only if it's signed with Cortive's key; one that isn't is refused and nothing changes.

Things that open in your browser only when you click them, and are then ordinary browsing:
- **Open source** on a capture, which reopens the page it came from.
- The help link in the extension's settings.
- **Report a Problem** (Settings → Help, or the menu bar icon), which opens a draft email
  to cortiveai@gmail.com in your mail app with Cortive's version, macOS version and whether
  search, Screen Recording and the extension are working. You see the draft and send it
  yourself; Cortive sends nothing and attaches nothing.

There is no license check yet. If one is added, it will be listed here before it ships,
with a way to turn it off where that is possible.

## Connections inside your Mac

The browser extension and the app talk over `http://127.0.0.1`, on the first free port
between 3456 and 3471. This traffic never leaves your computer.

- The app accepts connections only from this computer, only for the host names
  `127.0.0.1`, `localhost` and `::1`, and only from the app's own window or a browser extension
  (ordinary web pages are refused).
- On first contact the extension asks the app for a pairing secret. The browser tells the
  app which extension is asking, and a web page can't pretend to be one. The first
  extension is trusted; any other (another Chrome profile, another browser) has to be
  allowed by you in Settings → Browser Extension, and Cortive tells you when one asks.
  Every later request is signed with the secret. Reset in Settings disconnects every
  browser and makes a new secret.

The extension reads no page and sends nothing until you press **Allow** on its welcome page,
which opens when it's installed and says what it reads. After that, it reads a page only
when you save it, unless you turn on "Tell me when I've already saved a page" (on the
welcome page or in the extension's settings), which is off until you do.

What the extension sends to the app:

| What | When | What is sent |
|---|---|---|
| A capture | When you save a page, a selection or a link | The page address and title, the text you chose (a page's readable text or a selection), the text fragment that leads back to the passage, and the browser's name. For a link: the link's address and text and the page it was on; the linked page itself is not opened |
| "You saved this" check | Only if you turned on "Tell me when I've already saved a page": about 1.5 s after a page finishes loading | The page address, title and up to 12,000 characters of its text. The app compares it with your library and answers; it does **not** store the page |
| Duplicate check | Before a capture is sent | A hash of the capture's text and address |
| Search | When you search from the extension | Your search text |
| Health check | Every 30 seconds while the browser runs, and before each of the above | Only that it is the Cortive extension |

### Search for AI agents on your Mac

While the app runs, it also answers searches on a private socket file,
`~/Library/Application Support/Cortive/agent/search.sock`. The Cortive memory plugin for the
Hermes agent uses it so its searches understand meaning, ranked exactly like the app's own.

- Only your macOS account can use it: the folder and the socket are readable by you alone, and
  connections from any other user are refused. That is the same set of programs that can already
  read your library file, so it opens nothing new. It is a file, not a network port: web pages and
  other computers can't reach it.
- It does one thing: search. It can't save, change or delete anything, and its answer is only
  capture ids and match scores, never titles, text or file paths.
- What is sent to it is the search text. Searches through it aren't counted in your search
  history, and the search text is never written to the log.

## What is stored, and where

On your Mac, in your user account:

- **Library:** `~/Library/Application Support/cortive-ai/cortive.db` (SQLite). It holds the
  text of your captures, screenshots, notes, links, collections and the search vectors.
- **Upgrade backups:** before Cortive changes the library's format it saves a copy next to
  it (`cortive.db.bak…`); the three newest are kept.
- **Usage counts:** per day, how many searches you made, how many saved items you opened
  and how often you opened a source, in the library. Never what you searched for, saved or
  opened, and never sent anywhere. Settings → Your Use shows them.
- **Search files:** `~/Library/Application Support/Cortive/models`.
- **Pairing secret, paired extensions, shortcuts and logs:** `~/Library/Application Support/Cortive/`.
  The secret and pairing files are readable only by your user. Logs (`cortive.<date>.log`,
  the last 7 days) hold timings, counts, errors and file names, never the text you saved or
  searched for.
- **Open at login**, if on, is listed in System Settings → General → Login Items.

Cortive does not encrypt the library itself. It is protected the way other files in your
account are: by your macOS login and, if you turn it on, FileVault. Exports you save
(Markdown, JSON, images) are ordinary files in the folder you choose.

In the browser, in the extension's own storage (`chrome.storage.local`):

- **Unsent captures**, in full, until the app has received them (for example while the app
  is closed). The extension tries again every 30 seconds.
- **A short copy of sent captures:** the address, title and the first 2,000 characters of
  text, used for the extension's own search and counts when the app isn't running.
- Settings, and the address of the app on this computer.

These copies stay until you clear them: extension settings, **Reset Local History**.
Removing the extension removes them too. Deleting a capture in the app does not delete the
extension's short copy.

## What the app reads on your Mac

- **Screenshots:** only the region you pick in the macOS screenshot tool. The app also
  reads the name of the app in front and the title of its front window, so the capture can
  say where it came from. macOS requires Screen Recording permission for both the
  screenshot and the window title; that is the only reason Cortive asks for it.
- **Clipboard:** only when you press the clipboard shortcut.
- **Files:** only files you import and folders you choose to watch.
- **Text in images and scanned PDFs** is read with Apple's Vision framework, on your Mac.

## Removing everything

In Cortive: **Settings → Delete All Data** removes the library, backups, pairing, settings
and logs (and, if you choose, the search files), turns off opening at login, and quits.
Then, in the extension's settings, **Reset Local History**, remove the extension, and drag
Cortive to the Trash.

By hand: quit Cortive, delete `~/Library/Application Support/cortive-ai` and
`~/Library/Application Support/Cortive`, remove the app, and remove the browser extension.
