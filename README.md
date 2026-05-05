# Pro Voice Chain

Professional voice-over channel strip for REAPER JSFX.

Current plugin:

```text
JS: Pro Voice Chain v1.0 - VoiceOver Unified Chain
```

## Chain

```text
Input Trim
-> Smart Input Gain
-> DC Block + HPF cleanup
-> Plosive control
-> Downward Expander
-> Smart split-band De-esser
-> 1175 compressor
-> LA2 compressor
-> MajorTom compressor
-> Brown Guard dynamic tone control
-> Voice Limiter / VoiceSat saturation
-> Output LUFS/RMS/L+R auto trim
-> Final safety limiter
```

## Features

- Voice-over focused channel strip for spoken word, podcast, narration, audiobook, and broadcast-style delivery.
- Dynamic plosive control for P/B pops before compression.
- Downward expander for room tone and noise control between phrases.
- Smart de-esser with Auto, S, SH, and T/C modes. It works independently from the expander and stays active when the expander is bypassed.
- Three-stage compression stack: fast 1175, opto-style LA2, and MajorTom program-dependent compression.
- Brown Guard dynamic tone shaping for low/mid/high balance.
- VoiceSat saturation with selectable modes:
  - Hybrid
  - Atan
  - Tape
  - Channel
  - Tube
  - Inflate
  - Molot
  - DaTube
  - Fat
  - VBL
- Output auto trim for LUFS, RMS, or combined L+R targets.
- Final safety limiter, enabled by default.
- Resizable JSFX UI with vertical scrolling and dynamic width.

## De-esser

The de-esser is in the **Expander** panel as a `DE-ESS` mini section.

Controls:

- `ON/OFF`: enables or bypasses the de-esser.
- `MODE`: cycles Auto, S, SH, and T/C detection.
- `THR`: sibilance threshold. Lower values reduce more.
- `FRQ`: split/detector frequency for S, SH, and T sounds.
- `RNG`: maximum high-band reduction.

The de-esser is after the expander and before the compressors. If the expander is off, the de-esser still works.

## Plosive Control

The plosive control is in the **Expander** panel as a `PLOSIVE` mini section.

- `ON/OFF`: enables or bypasses low-pop reduction.
- `AMT`: maximum reduction applied to the low pop band.
- `HZ`: low-band detector frequency for P/B thumps.

It runs before the expander and compression stack, so pops do not over-trigger later dynamics.

## Expander

The expander is **downward**. It reduces signal below threshold; it does not lift quiet audio upward.

Controls:

- `THRS`: threshold where expansion starts.
- `RANGE`: maximum reduction below threshold.
- `HYST`: hysteresis to avoid chatter.
- `ATTK`: how fast reduction begins.
- `REL`: how fast level returns.
- `Curve`: soft knee/transition shape.
- `SC`: sidechain high-pass, useful so plosives/rumble do not drive detection.

## Saturation

Saturation is in the **Voice Limiter** panel.

- `SAT`: saturation amount.
- `MODE`: click to cycle saturation model.

Recommended starting points for voice-over:

- `Hybrid`: default general-purpose warmth.
- `Tape`: gentle narration warmth.
- `Channel`: subtle console-style edge.
- `Inflate`: density/presence with care.
- `Molot`: stronger color, use low `SAT`.

## UI Notes

- The plugin window can be resized horizontally.
- Panels expand with window width.
- Vertical scrolling remains enabled for the module stack.
- If the window is narrower than the minimum layout, horizontal scrolling appears.

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

If ReaPack does not show the package immediately, run `Extensions -> ReaPack -> Synchronize packages` again or use the manual install method.

## Suggested Starting Point

- Set input trim so normal speech has healthy level without slamming the limiter.
- Tune expander threshold just above room tone.
- Keep expander range moderate, often `-6` to `-12 dB`.
- Aim de-esser reduction around `2-5 dB` on sibilants.
- Use compression in stages rather than forcing one compressor to do all the work.
- Use `SAT` subtly for professional voice-over; `5-15%` is often enough.
- Keep final limiter on for delivery safety.

## Development Notes

See `DEVELOPMENT_PLAN.md` for research summary, implementation notes, and next milestones.
