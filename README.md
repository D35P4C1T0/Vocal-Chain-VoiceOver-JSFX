# Pro Voice Chain

Professional voice-over channel strip for REAPER JSFX.

## Current Chain

`Trim -> DC Block -> HPF -> Downward Expander -> Corrective EQ -> Split De-esser -> Compressor -> Saturation -> Limiter`

## Features

- Low-latency time-domain voice processing.
- Downward expander for room tone control.
- Corrective EQ bands for low mud, nasal range, and presence.
- Split-band de-esser.
- Feed-forward compressor with soft knee and detector HPF.
- Multiple saturation models inspired by JSFXClones candidates:
  - Atan
  - TapeHead
  - SatChannel
  - TubeDriver
  - OInflator
  - Molot
  - DaTube
  - Fattener
  - VBL
- Sample-peak limiter.
- Custom UI with stage meters, input/output meters, and key parameter readouts.

## Manual Install

Copy `Pro_Voice_Chain.jsfx` into your REAPER `Effects` folder, then restart REAPER or rescan JSFX and search for `Pro Voice Chain`.

### macOS

```text
~/Library/Application Support/REAPER/Effects/Codex/Pro_Voice_Chain.jsfx
```

### Windows

```text
%APPDATA%\REAPER\Effects\Codex\Pro_Voice_Chain.jsfx
```

Usually expands to:

```text
C:\Users\<you>\AppData\Roaming\REAPER\Effects\Codex\Pro_Voice_Chain.jsfx
```

### Linux

```text
~/.config/REAPER/Effects/Codex/Pro_Voice_Chain.jsfx
```

Some portable or distro-specific installs may use a different REAPER resource path. In REAPER, open:

```text
Options -> Show REAPER resource path in explorer/finder
```

Then put the file inside:

```text
Effects/Codex/Pro_Voice_Chain.jsfx
```

## ReaPack Install

This repository can also be installed through ReaPack by importing it as a repository.

1. Install ReaPack from [reapack.com](https://reapack.com/) if it is not already installed.
2. In REAPER, open:

```text
Extensions -> ReaPack -> Import repositories...
```

3. Add this repository URL:

```text
https://github.com/D35P4C1T0/Vocal-Chain-VoiceOver-JSFX/raw/main/index.xml
```

4. Open:

```text
Extensions -> ReaPack -> Browse packages...
```

5. Search for `Pro Voice Chain`, install it, then run:

```text
Extensions -> ReaPack -> Synchronize packages
```

This repository includes a basic `index.xml` for ReaPack. If ReaPack does not show the package immediately, run `Extensions -> ReaPack -> Synchronize packages` again or use the manual install method.

## Suggested Starting Point

- Set input trim so normal speech hits the compressor cleanly without slamming the limiter.
- Tune expander threshold just above the room tone.
- Aim for modest gain reduction:
  - Expander: only between phrases
  - De-esser: about 2-5 dB on sibilants
  - Compressor: about 3-6 dB on average speech peaks
  - Limiter: about 1-3 dB max
- For voice-over saturation, try `TapeHead` first, then `SatChannel`, then low-mix `OInflator`.

## Development Notes

See `DEVELOPMENT_PLAN.md` for research summary, implementation notes, and next milestones.
