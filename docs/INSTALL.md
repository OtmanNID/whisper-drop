# Installation details

## Files installed

Application:

```text
~/.local/share/whisperdrop/app
```

Model and state:

```text
~/.local/share/whisperdrop/
```

Configuration:

```text
~/.config/whisperdrop/config
```

Command symlink:

```text
~/.local/bin/whisperdrop
```

LaunchAgent:

```text
~/Library/LaunchAgents/com.whisperdrop.watcher.plist
```

Logs:

```text
~/Library/Logs/WhisperDrop/
```

## Why launchd?

`launchd` is built into macOS. WhisperDrop uses a user LaunchAgent with `WatchPaths`, so no extra folder-watching dependency is required.
