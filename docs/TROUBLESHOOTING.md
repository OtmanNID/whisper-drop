# Troubleshooting

## Start with diagnostics

```bash
whisperdrop doctor
```

## View logs

```bash
whisperdrop logs
```

## Audio is not processed

Check that the file extension is listed in:

```text
~/.config/whisperdrop/config
```

Then force a scan:

```bash
whisperdrop scan
```

## Watcher is stopped

Try:

```bash
launchctl kickstart -k "gui/$(id -u)/com.whisperdrop.watcher"
```

If necessary, reinstall WhisperDrop.

## `whisper-cli` not found

```bash
brew install whisper-cpp
```

## `ffmpeg` not found

```bash
brew install ffmpeg
```

## Model missing

Re-run `./install.sh`, or download `ggml-large-v3-turbo.bin` into:

```text
~/.local/share/whisperdrop/models/
```

## ChatGPT summary does not run

First verify that macOS can see the Shortcut:

```bash
shortcuts list | grep "Résumer vocal avec ChatGPT"
```

Then test it directly:

```bash
shortcuts run "Résumer vocal avec ChatGPT" -i "/full/path/to/transcript.txt"
```

File paths containing spaces must be quoted.
