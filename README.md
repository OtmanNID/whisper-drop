# 🎙️ WhisperDrop

**Drop an audio. Get the text.**

WhisperDrop is a free, open-source macOS utility that automatically transcribes voice messages and audio files dropped into a folder. Transcription is performed **locally on your Mac** with [`whisper.cpp`](https://github.com/ggml-org/whisper.cpp).

It is especially convenient for long WhatsApp voice notes, but also works with Telegram exports, Voice Memos, meetings and common audio/video formats.

## What it does

```text
Voice note / audio file
        ↓
Watched folder
        ↓
FFmpeg converts audio temporarily
        ↓
whisper.cpp transcribes locally
        ↓
Transcript.txt
        ↓ optional
macOS Shortcut → ChatGPT summary
```

### Highlights

- ✅ Automatic folder monitoring with native macOS `launchd`
- ✅ Local transcription: audio does not need to leave your Mac
- ✅ OPUS, MP3, M4A, WAV, MP4, MOV, AAC, OGG, FLAC, WEBM
- ✅ Apple Silicon and Intel Homebrew setups
- ✅ `large-v3-turbo` by default
- ✅ French, English, Arabic or automatic language detection
- ✅ Optional ChatGPT summary through macOS Shortcuts
- ✅ Optional archiving of processed audio
- ✅ macOS notifications
- ✅ Logs and built-in diagnostics
- ✅ No Python environment required

## Requirements

- macOS
- [Homebrew](https://brew.sh)
- Around 2 GB free disk space for the default Whisper model

## Install

```bash
git clone https://github.com/YOUR_USERNAME/whisperdrop.git
cd whisperdrop
./install.sh
```

The installer will:

1. install `ffmpeg` and `whisper-cpp` with Homebrew if necessary;
2. ask which folder you want to monitor;
3. download the default Whisper model;
4. create the configuration file;
5. install a native `launchd` watcher;
6. optionally connect the workflow to a ChatGPT macOS Shortcut.

By default, the suggested folder is:

```text
~/Documents/WhatsApp Audios
```

After installation, simply save an audio file into the watched folder. A `.txt` transcript will appear next to it.

## Commands

```bash
whisperdrop status
whisperdrop doctor
whisperdrop scan
whisperdrop transcribe "/path/to/audio.opus"
whisperdrop logs
```

## ChatGPT summaries (optional)

WhisperDrop itself does not require an OpenAI API key. On compatible Macs, you can create a macOS Shortcut that receives the generated `.txt`, sends it to ChatGPT through Apple Intelligence, and saves a summary next to the transcript.

See **[docs/CHATGPT.md](docs/CHATGPT.md)**.

## Privacy

The core transcription workflow is local. `ffmpeg` and `whisper.cpp` process the audio on your Mac.

If you enable the optional ChatGPT Shortcut, the transcript is sent to the AI service configured in Apple Intelligence. Do not enable this mode for content you are not permitted to send to an external provider.

See **[docs/PRIVACY.md](docs/PRIVACY.md)**.

## Configuration

Configuration lives at:

```text
~/.config/whisperdrop/config
```

Example:

```bash
LANGUAGE="fr"
SUMMARY_PROVIDER="none"
ARCHIVE_AUDIO="false"
NOTIFICATIONS="true"
```

See [`config.example`](config.example) for all options.

## Troubleshooting

Run:

```bash
whisperdrop doctor
```

Then inspect logs:

```bash
whisperdrop logs
```

More help: **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**.

## Uninstall

```bash
./uninstall.sh
```

The uninstaller does not delete your audio/transcript folder.

## Security note

WhisperDrop never stores API keys and does not need administrator privileges. The installer uses Homebrew for its two runtime dependencies and installs user-level files under your home directory.

## License

MIT. Free to use, modify and redistribute.
