# Azan Sound Files

These are placeholder silent audio files. Replace them with real azan recordings.

## Requirements
- Format: CAF (Core Audio Format)
- Duration: ≤ 30 seconds (iOS notification sound limit)
- Channels: Mono or Stereo
- Sample Rate: 44100 Hz

## Files
- `azan_makkah.caf` — Makkah style azan
- `azan_madinah.caf` — Madinah style azan
- `azan_alaqsa.caf` — Al-Aqsa style azan
- `azan_mishary.caf` — Mishary Rashid Alafasy style

## Converting Audio
```bash
# From MP3 (trim to 30s first):
ffmpeg -i input.mp3 -t 30 -ar 44100 trimmed.wav
afconvert trimmed.wav output.caf -d LEI16 -f caff
```
