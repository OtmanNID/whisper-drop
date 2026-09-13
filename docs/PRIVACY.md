# Privacy

## Local transcription

WhisperDrop uses `ffmpeg` and `whisper.cpp` locally. In the default transcription-only configuration, the audio is processed on your Mac and WhisperDrop does not intentionally upload it anywhere.

## Temporary files

WhisperDrop creates a temporary 16 kHz mono WAV file in the macOS temporary directory while transcribing. It is deleted immediately after processing.

## Optional AI summaries

If `SUMMARY_PROVIDER="shortcuts"` is enabled, WhisperDrop passes the transcript file to the macOS Shortcut configured by the user. That Shortcut may send the transcript to ChatGPT or another AI provider depending on how the user configured macOS.

Only enable this mode when you have permission to process the transcript with that external service.

## Logs

Logs are stored under:

```text
~/Library/Logs/WhisperDrop/
```

WhisperDrop logs file paths and processing status. It does not intentionally copy full transcript contents into its own log file, although output from third-party command-line tools may appear there.
