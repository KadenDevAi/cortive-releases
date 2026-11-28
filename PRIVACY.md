# Privacy

Cortive keeps what you capture on your computer. It has no account, no cloud service and no
telemetry: no analytics, crash reports or usage statistics are sent anywhere.

**On Windows, one connection is outside Cortive's control.** When Cortive starts, Windows'
own Microsoft sign-in service contacts Microsoft's sign-in server (`login.live.com`) once.
Cortive gives it nothing from your library, but the connection is made by Windows and
encrypted, so Cortive can neither read it nor stop it. The Microsoft component that draws
Cortive's windows would also contact Microsoft on its own, so Cortive's installer blocks it
from the internet. Both are explained in
[On Windows](#on-windows-the-part-of-windows-that-draws-cortives-windows).

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
**Check Now**. An update is installed only if it's signed with Cortive's key; one that
isn't is refused and nothing changes.

Things that open in your browser only when you click them, and are then ordinary browsing:
- **Open source** on a capture, which reopens the page it came from.
- The help link in the extension's settings.
- **Report a Problem** (Settings → Help, or the menu bar icon), which opens a draft email
  to cortiveai@gmail.com in your mail app with Cortive's version, macOS version and whether
  search, Screen Recording and the extension are working. You see the draft and send it
  yourself; Cortive sends nothing and attaches nothing.

There is no license check yet. If one is added, it will be listed here before it ships,
with a way to turn it off where that is possible.

### On Windows: the part of Windows that draws Cortive's windows

On Windows, Cortive's windows are drawn by Microsoft Edge WebView2. Left alone, WebView2
contacts Microsoft on its own, and an app can't switch all of that off: Microsoft's
documentation says apps have no control over WebView2's diagnostic data. So Cortive doesn't
rely on switches alone. It shuts WebView2 off from the internet:

- **Cortive brings its own copy of WebView2**, in the `webview2-fixed` folder inside Cortive's
  own folder, instead of using the copy Windows shares between apps.
- **The installer has Windows Firewall block that copy.** For each program in that folder it
  adds an outgoing block rule named `Cortive WebView2 offline - …`. Adding a firewall rule
  needs administrator rights, so this is the one step where Windows asks for permission; the
  installer says so first. Updates find the rules in place and don't ask again. Uninstalling
  removes them (and asks once more).
- Cortive also turns off what it can inside WebView2: **SmartScreen**, which would send the
  addresses of pages shown to Microsoft, and **background networking and component
  downloads**.

Nothing else changes. Cortive's pages are built into the app and never come from the network,
so its windows work the same. The connections in the table above are made by
`cortive-desktop.exe`, not WebView2, and still work. The WebView2 that other apps use is a
different file, and its rules and updates are untouched. Measured on Windows 10 with the block
in place, over two and a half minutes from launch: WebView2 made no connections at all, and
the window, search and the browser extension worked as before.

What the block doesn't cover:

- **If you choose No at the permission prompt**, Cortive installs and works, but its WebView2
  is not blocked. The installer tells you, and running it again asks again. Measured on
  Windows 10 without the block, with Windows' **Diagnostic data** setting at **Required**,
  over two and a half minutes from launch: WebView2 connected to a Microsoft 365 server
  within 15 seconds every time, and in one run also to an address in the range
  `edge.microsoft.com` uses. Cortive gives WebView2 nothing from your library to send, but
  the connections are encrypted, so their contents can't be checked.
- **If the installer is started from inside a Microsoft Store app** instead of File Explorer
  or your browser's downloads, Windows can keep the installed files in that app's private
  storage, where its permission prompt can't find them. The block isn't added and the
  installer says so; uninstall, then run the installer from File Explorer.
- **If Windows Firewall is turned off**, or another security product has taken over from it,
  the rules exist but nothing enforces them.
- **Windows' own sign-in service.** WebView2 can't reach the internet, but it can still ask
  other parts of Windows for things, and one of them goes online itself. Measured on Windows
  10 by watching every connection on the PC: about 7 seconds after Cortive starts, the
  Windows service "Microsoft Account Sign-in Assistant" (`wlidsvc`) connected to Microsoft's
  sign-in server, `login.live.com`, in 31 of 32 launches. It did not when Cortive wasn't
  started, nor when Cortive was started without WebView2. WebView2 starts that service
  itself each time, and none of eleven sets of WebView2 switches stopped it, including the
  names its own files use for this request. The request is the service's own (WebView2 most likely asks it for a
  token that identifies the device for diagnostic data, which then can't be sent). Cortive
  hands WebView2 nothing from your library, but the connection is encrypted and made by
  Windows, so Cortive can neither read it nor block it without breaking Microsoft sign-in
  for the whole PC. In 3 of those launches Windows' diagnostics service (`DiagTrack`) also
  connected to Microsoft within half a minute; it does that on its own schedule too, so
  whether Cortive's start caused it is not known. Windows' **Diagnostic data viewer**
  (Settings → Privacy → Diagnostics & feedback) shows what that service sends.
- **Looking up a name.** WebView2 asks your local network for a machine named `wpad` (how
  Windows looks for a proxy), and before connecting it may ask your network's DNS service for
  the address of a Microsoft server. The firewall stops the connections that would follow,
  but not the lookups, which carry a name and nothing else.

A crash report from WebView2 would be sent by those same blocked programs, so it can't leave
either: with one WebView2 process ended abruptly, nothing in Cortive connected anywhere in the
70 seconds that followed. WebView2's own network log of a launch lists only Cortive's built-in
pages and no outside address. Because this copy is Cortive's, Microsoft doesn't update it; each Cortive release
ships the newest one.

To check it yourself: the rules are listed in **Windows Defender Firewall with Advanced
Security → Outbound Rules**, and Resource Monitor (Network tab) or Microsoft's TCPView shows
the connections of the `msedgewebview2.exe` processes Cortive starts. There should be none.

## Connections inside your computer

The browser extension and the app talk over `http://127.0.0.1`, on the first free port
between 3456 and 3471. This traffic never leaves your computer.

- The app accepts connections only from this computer, only for the host names
  `127.0.0.1`, `localhost` and `::1`, and only from browser extensions: web pages are
  refused, and so is the app's own window, which doesn't need this connection. Other programs
  running as you could reach it, but they could already read your library file directly.
- A search returns at most 50 results.
- On first contact the extension asks the app for a pairing secret. The browser tells the
  app which extension is asking, and a web page can't pretend to be one. Cortive's own
  extension from the Chrome Web Store is trusted when it asks; any other extension, even the
  first to ask (a copy added by hand, or someone else's), has to be allowed by you in
  Settings → Chrome Extension, and Cortive tells you when one asks.
  Every later request is signed with the secret. Reset in Settings disconnects every
  browser and makes a new secret.

The extension reads no page and sends nothing until you press **Allow** on its welcome page,
which opens when it's installed and says what it reads. After that, it reads a page only
when you save it, unless you turn on "Tell me when I've already saved a page" (on the
welcome page or in the extension's settings), which is off until you do. The extension has
no access to any website until you save from one; turning the check on asks Chrome to let it
read the sites you visit, and turning it off gives that access back.

What the extension sends to the app:

| What | When | What is sent |
|---|---|---|
| A capture | When you save a page, a selection or a link | The page address and title, the text you chose (a page's readable text or a selection), the text fragment that leads back to the passage, and the browser's name. For a link: the link's address and text and the page it was on; the linked page itself is not opened |
| "You saved this" check | Only if you turned on "Tell me when I've already saved a page": about 1.5 s after a page finishes loading | The page address, title and up to 12,000 characters of its text. The app compares it with your library and answers; it does **not** store the page |
| Duplicate check | Before a capture is sent | A hash of the capture's text and address |
| Search | When you search from the extension | Your search text |
| Health check | Every 30 seconds while the browser runs, and before each of the above | Only that it is the Cortive extension |

### Search for AI agents on your computer

While the app runs, it also answers searches from AI agents on the same computer. The Cortive
memory plugin for the Hermes agent uses it so its searches understand meaning, ranked exactly
like the app's own.

- **On a Mac** it is a private socket file,
  `~/Library/Application Support/Cortive/agent/search.sock`. Only your macOS account can use
  it: the folder and the socket are readable by you alone, and connections from any other user
  are refused.
- **On Windows** it is a named pipe with a random name, which Cortive writes to
  `%LOCALAPPDATA%\cortive-ai\agent\search.pipe`, a file only your Windows account can read.
  The pipe itself admits only your account, refuses connections from other computers, drops a
  connection from a program running as anyone else, and won't start if another program has
  already taken its name.
- Either way, that is the same set of programs that can already read your library file, so it
  opens nothing new. It is not a network port: web pages and other computers can't reach it.
- It does one thing: search. It can't save, change or delete anything, and its answer is only
  capture ids and match scores, never titles, text or file paths.
- What is sent to it is the search text. Searches through it aren't counted in your search
  history, and the search text is never written to the log.

## What is stored, and where

On your Mac, in your user account:

- **Library:** `~/Library/Application Support/cortive-ai/cortive.db` (SQLite). It holds the
  text of your captures, screenshots, notes, links, collections and the search vectors.
- **Upgrade backups:** before Cortive changes the library's format it saves a copy next to
  it (`cortive.db.bak…`); the three newest are kept, and none longer than 30 days, so a
  capture you delete doesn't outlive Recently Deleted in a backup.
- **Deleting:** a capture deleted for good (Delete Now, Empty, or after its 30 days in
  Recently Deleted) is overwritten in the library file, not just marked free, and its words
  are removed from the keyword index at once. Your disk itself may still hold old copies of
  any file (SSDs move data around); FileVault or BitLocker protects those.
- **Usage counts:** per day, how many searches you made, how many saved items you opened
  and how often you opened a source, in the library. Never what you searched for, saved or
  opened, and never sent anywhere. Settings → Your Use shows them.
- **Search files:** `~/Library/Application Support/Cortive/models`.
- **Pairing secret, paired extensions, shortcuts and logs:** `~/Library/Application Support/Cortive/`.
  The secret and pairing files are readable only by your user. Logs (`cortive.<date>.log`,
  the last 7 days) hold timings, counts, errors and file names, never the text you saved or
  searched for.
- **Open at login**, if on, is listed in System Settings → General → Login Items.
- **Card previews:** a picture of the first page of each PDF and each recording's waveform,
  so the Library doesn't redraw them every time. They are kept in the window's own storage
  (`~/Library/WebKit/com.cortive.desktop`), not in the folders above. A preview is forgotten
  when its capture is deleted for good (at once, or after its 30 days in Recently Deleted,
  the next time the Library opens), and all of them by Delete All Data.

On Windows, in your user account:

- **Library and upgrade backups:** `%APPDATA%\cortive-ai\` (the same files as on a Mac).
- **Search files, pairing secret, paired extensions, shortcuts and logs:**
  `%LOCALAPPDATA%\cortive-ai\`, with the search files in its `models` folder. Cortive sets
  both `cortive-ai` folders, and the pairing files, so that only your Windows account can open
  them, whatever other programs have allowed on your user folder. (An administrator can still
  take them over, as on any PC.)
- **The window component's own storage** (WebView2): `%LOCALAPPDATA%\com.cortive.desktop\`.
- **Cortive itself**, with its own copy of WebView2: `%LOCALAPPDATA%\Cortive\`, plus the
  Windows Firewall rules named `Cortive WebView2 offline - …` (see
  [On Windows](#on-windows-the-part-of-windows-that-draws-cortives-windows)).
- **Open at login**, if on, is listed in Settings → Apps → Startup.

Cortive does not encrypt the library itself. It is protected the way other files in your
account are: by your macOS login and, if you turn it on, FileVault; on Windows, by your
Windows sign-in and, if it's on, BitLocker or device encryption. Exports you save
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

## What the app reads on your computer

- **Screenshots:** only the region you pick in the macOS screenshot tool. The app also
  reads the name of the app in front and the title of its front window, so the capture can
  say where it came from. macOS requires Screen Recording permission for both the
  screenshot and the window title; that is the only reason Cortive asks for it.
- **Clipboard:** only when you press the clipboard shortcut.
- **Files:** only files you import and folders you choose to watch.
- **Text in images and scanned PDFs** is read with Apple's Vision framework, on your Mac.

On Windows:

- **Screenshots:** only the area you pick in Windows' own screen picker. Windows hands the
  picture over on the clipboard, so after a screenshot the clipboard holds that picture.
  Cortive also reads the name of the program in front and the title of its window, so the
  capture can say where it came from; Windows doesn't ask permission for that.
- **Text in images and scanned PDFs** is read with Windows' own text recognition, and voice
  memos are decoded with Windows' own audio support, all on your PC.

## Removing everything

In Cortive: **Settings → Delete All Data** removes the library, backups, pairing, settings,
logs and card previews (and, if you choose, the search files), turns off opening at login,
and quits. On Windows it also removes the window component's storage
(`%LOCALAPPDATA%\com.cortive.desktop`) a few seconds after Cortive has closed: WebView2 keeps
copies of the card previews in its files until then.
Then, in the extension's settings, **Reset Local History**, remove the extension, and drag
Cortive to the Trash.

By hand: quit Cortive, delete `~/Library/Application Support/cortive-ai`,
`~/Library/Application Support/Cortive` and `~/Library/WebKit/com.cortive.desktop` (the card
previews), remove the app, and remove the browser extension.

On Windows: after **Delete All Data** and the extension steps, uninstall Cortive in
**Settings → Apps → Installed apps**. Windows asks for permission once more, to remove the
firewall rules. Or skip Delete All Data and tick **Delete the application data** in the
uninstaller: it removes the library, the search files and the window component's storage too.
Unticked, the uninstaller leaves them, so a reinstall finds your library. By hand: quit Cortive, delete `%APPDATA%\cortive-ai`,
`%LOCALAPPDATA%\cortive-ai` and `%LOCALAPPDATA%\com.cortive.desktop`, uninstall Cortive, and
remove the browser extension.
