# Pro Voice Chain Development Plan

## Research Summary

Target chain from `reference/deep-research-report.md`:

`Trim/DC/HPF -> optional denoise -> expander -> corrective EQ -> split-band de-esser -> compressor -> dynamic EQ -> optional leveler -> limiter`

MVP scope:

`Trim/DC/HPF -> expander -> corrective EQ -> split-band de-esser -> compressor -> limiter`

Design bias:

- Low-latency time-domain DSP first.
- Small cumulative gain moves instead of one aggressive stage.
- Broad, stable VO defaults: HPF 70-90 Hz, expander range 6-12 dB, de-ess 4-10 kHz, compressor 2:1-4:1, limiter doing 1-3 dB.
- Avoid spectral denoise and true-peak oversampling until base chain is stable.

## JSFXClones Notes

Repository inspected: `https://github.com/JClones/JSFXClones`

Useful patterns:

- `JClones_FabModern_Limiter.jsfx`: compact lookahead limiter shape with delay line, min hold, moving-average smoothing, slow gain-release stage.
- `JClones_L2.jsfx`: more advanced lookahead limiter and adaptive release; useful later, but too large for first MVP.
- `JClones_Molot.jsfx`: sidechain filter + envelope + soft-knee transfer organization.
- `JClones_CA2A.jsfx`: blended peak/RMS detection and stereo-linked gain reduction.

MVP borrows design ideas, not code:

- Object-style JSFX functions.
- Stereo-linked detectors for dynamics.
- Detector HPF before compressor gain computer.
- Simple limiter first; lookahead limiter planned next.

## Current Implementation

File: `Pro_Voice_Chain.jsfx`

Implemented:

- Input trim.
- DC blocker.
- 12/24 dB/oct high-pass filter.
- Gentle linked expander with threshold, ratio, range, hold, release.
- Three corrective EQ bells: low mud, nasal, presence.
- Split-band de-esser using high-band attenuation.
- Linked feed-forward compressor with soft knee and detector HPF.
- Optional voice saturation with drive, mix, and model controls.
- Sample-peak limiter with ceiling and release.
- Rough but usable `@gfx` display with stage gain-reduction meters, saturation state, and output peak.

Known limitations:

- Limiter has no lookahead yet.
- De-esser split uses simple IIR high-band subtraction, so phase is rough but usable for MVP.
- No dynamic EQ, slow leveler, true-peak mode, or denoise yet.
- Saturation now offers multiple JClones-inspired candidates: Atan, TapeHead, SatChannel, TubeDriver, OInflator, Molot, DaTube, Fattener, and VBL. These are compact in-chain models rather than full standalone clone ports.
- No automated audio regression harness yet.

## Next Milestones

1. Stabilize MVP in REAPER.
   - Load JSFX, verify no compile errors.
   - Test bypass, silence, sine sweep, speech, plosive burst, sibilant burst.
   - Tune defaults for 48 kHz spoken voice.

2. Improve limiter.
   - Add optional 1 ms lookahead.
   - Use delay line + min gain hold from `JClones_FabModern_Limiter` style.
   - Keep tracking mode zero/near-zero latency if lookahead off.

3. Improve de-esser.
   - Add detector audition mode.
   - Add lower/higher voice presets by changing split frequency and threshold.
   - Consider matched crossover or wideband mode.

4. Add dynamic EQ.
   - Start with one post-compressor harshness band around 3-5 kHz.
   - Optional second nasal band around 700 Hz-1.2 kHz.

5. Add validation.
   - Build small offline test harness if JSFX runner available.
   - Track peak ceiling, silence stability, impulse stability, rough CPU, and gain reduction ranges.

6. UI pass.
   - Keep UI secondary until DSP settles.
   - Add per-stage GR meters and bypass toggles.
   - Add compact presets: Lower Voice, Higher Voice, Audiobook, Broadcast, Tracking.
