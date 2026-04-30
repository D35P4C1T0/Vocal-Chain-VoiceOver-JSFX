# Optimal JSFX Voice-Over Plugin Chain

## Executive Summary

This report synthesizes guidance from entity["organization","Audio Engineering Society","audio standards body"], entity["company","iZotope","audio software company"], entity["company","Waves Audio","audio software company"], entity["company","FabFilter","audio software company"], entity["company","Cockos","reaper developer"], and entity["organization","Xiph.Org Foundation","audio codec foundation"]. The highest-confidence conclusion is that the best **default** professional voice-over chain for JSFX is a **mostly time-domain, low-latency** chain, not a heavy multiband or ML-first strip: **Trim/DC block + HPF → optional denoise → gentle expander → corrective EQ → split-band de-esser → main compressor → light dynamic EQ → optional slow leveler → limiter**. This ordering removes low-frequency junk and noise before dynamics, prevents sibilance from being exaggerated, uses single-band compression for most level control, and reserves surgical dynamic processing for the few frequency regions that still move too much. citeturn12view1turn30view0turn31view0turn12view8turn18view0turn18view1

For a **JSFX MVP**, implement these first: **HPF/DC blocker, expander, corrective EQ, split-band de-esser, single-band compressor with detector HPF, and a limiter**. They map cleanly to JSFX’s `@slider`, `@block`, and `@sample` execution model; keep latency at or near zero unless lookahead is enabled; and avoid the CPU and buffering costs of STFT or neural noise suppression. JSFX also exposes FFT/MDCT and local-memory primitives, so spectral modules are possible, but they should be optional rather than the core path. citeturn12view0turn27view0turn19view0turn19view1

The practical gain-staging target is simple: trim audio so the first dynamics stage sees **healthy but not hot** speech, keep roughly **6 dB of margin before the limiter**, and let the limiter perform only **small finishing work**. If true-peak limiting is implemented, a **-1 dBTP** ceiling is the safest general default; if only sample-peak limiting is available, leave extra safety, such as about **-1.5 dBFS**, because inter-sample peaks can exceed sample peaks. citeturn24search2turn24search7turn12view2

## Professional Voice-Over Targets

Professional VO processing is not just “make it louder.” It should protect the speech cues that make words understandable—voice onset timing, pitch movement, and spectral envelope—while improving perceived clarity, presence, warmth, level consistency, and noise control. That favors **small, cumulative moves** over any single aggressive stage. AES’s recent dialogue-intelligibility guidance explicitly frames intelligibility around preserving speech cues, and speech-compression literature shows that fast, strong multichannel compression can reduce temporal and spectral contrast, making speech less natural and sometimes harder to parse. Longer release times are often clearer than very fast ones in reverberant speech. citeturn26search0turn18view0turn18view1

For tuning, the most useful frequency zones are stable enough to bake into defaults: excess low end often sits **below roughly 100–250 Hz**, nasal or pinched energy often appears around **500 Hz to 1.2 kHz**, harshness often lives around **3–5 kHz** or **5–8 kHz**, and air starts around **8–10 kHz and above**. Sibilance is usually in the **4–10 kHz** area for lower-pitched voices and tends to start slightly higher for higher-pitched voices. FabFilter’s de-esser documentation also notes that normal vocal S sounds often sit around **8–10 kHz**. citeturn30view0turn31view0turn28view3

## Recommended Signal Chain

The cited sources do not prescribe one universal VO order; the chain below is a **synthesized recommendation** optimized for transparent spoken-word results and straightforward JSFX implementation. It favors zero-latency or very low-latency stages first, and keeps FFT or ML processing optional. citeturn30view0turn31view0turn12view1turn12view9turn12view16turn24search2

```mermaid
flowchart LR
    A[Trim / DC block / HPF] --> B[Optional denoise]
    B --> C[Gentle expander]
    C --> D[Corrective EQ]
    D --> E[Split-band de-esser]
    E --> F[Main compressor]
    F --> G[Dynamic EQ]
    G --> H[Optional slow leveler]
    H --> I[Limiter]
```

The design brief below turns that chain into JSFX-ready modules. The values are **starting points**, not absolutes; threshold should usually be set by **target gain reduction**, not by a fixed numeric dBFS value. The ranges synthesize manufacturer control models and speech-processing literature. citeturn28view1turn28view3turn28view4turn29view0turn29view2turn32view0turn24search0

| Element | Purpose | JSFX-friendly algorithm | Minimal viable parameter set | Typical defaults and ranges | Key interactions |
|---|---|---|---|---|---|
| Trim + DC block + HPF | Remove DC, rumble, plosives before detectors | 1-pole DC blocker + 1–2 minimum-phase biquads | trim, cutoff, slope | HPF **60–100 Hz**, usually **12–24 dB/oct**; start around **70 Hz** for lower-pitched voices and **90 Hz** for higher-pitched voices | If compressor still pumps on plosives, raise detector HPF before raising threshold |
| Optional denoise | Lower steady or complex background noise before compression | Start with adaptive spectral suppressor; keep RNNoise-class processing optional | amount, adapt/learn, floor, wet | Keep real-time reduction modest: **2–6 dB** | Too much denoise causes lisping, “swirl,” and can confuse de-esser and limiter |
| Expander / soft gate | Reduce room tone between phrases without chopping words | Peak or pseudo-RMS envelope + dual threshold / hysteresis | threshold, ratio, range, hold, release, detector HPF | Threshold ≈ **room floor + 6 to 12 dB**; ratio **1.3:1 to 2:1**; range **6–12 dB**; attack **1–3 ms**; hold **30–80 ms**; release **80–200 ms** | Place before compression; if chatter occurs, lengthen hold/release before touching ratio |
| Corrective EQ | Remove mud, boxiness, nasal resonances before compression | Minimum-phase RBJ-style bells/shelves | freq, Q, gain, bypass | Common cuts: **120–250 Hz**, **500 Hz–1.2 kHz**, **3–5 kHz**; keep broad boosts to **≤2 dB** | Subtractive EQ before compressor reduces detector bias from mud and plosives |
| De-esser | Tame S/SH/T/CH spikes transparently | **Split-band** de-esser preferred; wideband fallback | threshold, range/max GR, detector HP/LP or center/Q, lookahead, mode | Detector focus: **4–10 kHz** lower-pitched voices, **5–12 kHz** higher-pitched voices; lookahead **5–10 ms**; typical GR **2–5 dB** | Pre-compression de-essing stops the compressor from re-emphasizing sibilance |
| Main compressor | Primary level consistency and density | Feed-forward single-band compressor with soft knee; detector HPF; pseudo-RMS or smoothed peak follower | threshold, ratio, attack, release/auto, knee, makeup, detector HPF | Threshold for **3–6 dB** GR; ratio **2:1–4:1**; attack **5–20 ms**; release **60–150 ms** or auto; detector HPF **70–120 Hz** | If one compressor needs hard, constant GR, split the work across two stages |
| Dynamic EQ | Catch moving harshness/resonance after compression | 1–3 bell bands whose gain is modulated by band-limited detectors | freq, Q, dynamic range, threshold, attack/release | Typical bands: **700 Hz–1.2 kHz** and/or **3–5 kHz**; dynamic cut **1–3 dB**; Q **1–3** | Better than full multiband when only a few speech regions misbehave |
| Optional slow leveler | Final smoothing for audiobook / very consistent VO | Slow RMS-ish compressor or gentle upward compressor | threshold, ratio, attack, release | Ratio **1.3:1–2:1**; attack **15–30 ms**; release **100–250 ms**; GR **1–3 dB** | Use only if needed; don’t make limiter do this job |
| Limiter | Delivery ceiling and peak safety | Sample-peak limiter for MVP; optional true-peak version with 4x OS detector | ceiling, threshold/input gain, lookahead, release | Lookahead **0.5–2 ms**; release **30–100 ms**; routine GR **1–3 dB**; ceiling **-1 dBTP** true-peak or about **-1.5 dBFS** sample-peak | If limiter is busy, reduce upstream makeup |

If you need extreme consistency, **serial compression** is preferable to one hard stage: use the first compressor as a mild peak tamer and the second as a slower leveler. That matches iZotope’s serial-vocal advice and is consistent with literature warning that fast, aggressive multichannel compression reduces temporal and spectral contrast. Likewise, for VO, **dynamic EQ usually beats full multiband compression** unless many regions must move independently; FabFilter explicitly positions dynamic EQ as a more surgical alternative to multiband-style control. citeturn30view0turn18view0turn12view8

## JSFX-Friendly Algorithms

JSFX is well suited to this chain because EEL2 offers high runtime performance, REAPER exposes sample-accurate automation and automatic plug-in delay compensation, and JSFX supports both sample-by-sample processing and block-level FFT work. The practical pattern is: use `@slider` for coefficient recomputation, `@block` for simple control housekeeping or FFT frame management, and `@sample` for the low-latency signal path. JSFX FFT sizes run from **16 to 32768**, MDCT sizes from **64 to 4096**, and FFT/MDCT buffers must respect **65,536-item local-memory boundaries**. citeturn19view0turn19view1turn12view0turn27view0

A good implementation rule is **peak-style detectors for expander, de-esser, and limiter; pseudo-RMS or blended detectors for the main compressor; minimum-phase IIR filters almost everywhere; oversampling only where nonlinear or ultra-fast processing makes aliasing/inter-sample behavior a real risk**. A simple rectified envelope follower with separate attack and release coefficients is especially attractive in JSFX because it is cheap, smooth, and close enough to RMS behavior on speech timescales. citeturn29view0turn29view2turn28view1turn24search2

| Candidate implementation | CPU cost | Latency | Suitability for JSFX | Recommendation |
|---|---:|---:|---|---|
| Time-domain expander / gate | Very low | 0 ms; small lookahead optional | Excellent | Make this the first line of defense against room tone |
| Spectral subtraction / adaptive spectral floor | Medium | Frame-based; typically several ms to tens of ms | Fair | Good optional denoise for stationary noise; watch musical-noise artefacts citeturn20search0turn21search12turn27view0 |
| RNNoise-style hybrid DSP/RNN | Medium-high | Windowed; RNNoise uses **20 ms** windows with **10 ms** hop, and common plug-ins report fixed **480-sample** frames and about **13 ms** intrinsic latency | Poor in pure JSFX, good in native extension | Best for ugly non-stationary noise, but not the best first pure-JSFX target citeturn16view1turn15view13turn5search1 |
| Single-band compressor | Very low | 0 ms; optional lookahead | Excellent | Default dynamics processor for VO |
| Two serial single-band compressors | Low-medium | Same as above | Excellent | Better than one aggressive compressor when you need more control |
| Dynamic EQ with 1–3 bands | Low-medium | 0 ms | Excellent | Preferred surgical finisher for harshness/nasal movement |
| Multiband compressor | Medium-high | 0 ms in minimum/dynamic phase, more in linear phase | Fair | Use sparingly; more phase/crossover complexity than VO usually needs citeturn32view0turn18view0 |
| True-peak limiter with 4x oversampled detector | Medium | A few ms; FabFilter reports about **5 ms** extra for TP processing | Good late-stage only | Worth it at the end, not across the whole chain citeturn24search0turn24search2 |

## Example Settings

Because voice gender was unspecified, the table below gives **typical lower-pitched / male** and **typical higher-pitched / female** starting points. In practice, use the lower-pitched row for a lower voice and the higher-pitched row for a higher voice; actual voice type matters more than gender labels. Sidechain audition is important. citeturn22search11turn31view0turn28view3

**Recommended final chain:** `Trim/DC+HPF → optional denoise → expander → corrective EQ → de-esser → compressor → dynamic EQ → optional leveler → limiter`. citeturn30view0turn31view0turn12view1

| Stage | Lower-pitched / male example | Higher-pitched / female example |
|---|---|---|
| HPF | **70 Hz**, **18 dB/oct** | **90 Hz**, **18 dB/oct** |
| Optional denoise | Adaptive; amount **3 dB** | Adaptive; amount **3 dB** |
| Expander | Threshold **room floor + 8 dB**; ratio **1.5:1**; range **8 dB**; attack **2 ms**; hold **50 ms**; release **120 ms**; detector HPF **120 Hz** | Same, but threshold often a bit higher because higher voices often have less LF energy |
| Corrective EQ | **-2 dB @ 180 Hz, Q 0.8**; **-1.5 dB @ 800 Hz, Q 1.2**; optional **+1 dB @ 3 kHz, Q 0.7** | **-2 dB @ 250 Hz, Q 0.8**; **-1.5 dB @ 1 kHz, Q 1.2**; optional **+1 dB @ 3.5 kHz, Q 0.7** |
| De-esser | Split band; detector **4.5–9 kHz**; lookahead **7 ms**; range **4 dB**; threshold for about **3 dB** GR | Split band; detector **5.5–11 kHz**; lookahead **7 ms**; range **4 dB**; threshold for about **3 dB** GR |
| Main compressor | Threshold for **4 dB** GR; ratio **2.5:1**; attack **10 ms**; release **90 ms**; knee **4 dB**; detector HPF **100 Hz** | Threshold for **4 dB** GR; ratio **2.5:1**; attack **8 ms**; release **80 ms**; knee **4 dB**; detector HPF **100 Hz** |
| Dynamic EQ | Bell **3.5 kHz, Q 1.6, range -1.5 dB**; optional bell **700 Hz, Q 1.4, range -1 dB** | Bell **4.5 kHz, Q 1.8, range -2 dB**; optional bell **1 kHz, Q 1.4, range -1 dB** |
| Optional leveler | Ratio **1.5:1**; attack **25 ms**; release **150 ms**; GR **1–2 dB** | Same |
| Limiter | Ceiling **-1 dBTP**; lookahead **1 ms**; release **50 ms**; routine GR **≤2 dB** | Same |

If you want a **smaller first release**, the exact minimal chain to code is: **HPF/DC → expander → corrective EQ → split-band de-esser → compressor → limiter**. Add dynamic EQ only after the compressor and de-esser sound stable.

## Validation and Testing

Validate on both **clean reference speech** and **clean speech plus controlled noise**. For loudness compliance, use LUFS/true-peak measurements aligned with **EBU R128** when relevant; REAPER can already report peak and LUFS/loudness statistics over time, which makes it convenient for automated regression checks. For broadcast-style delivery, **-23 LUFS** is the EBU reference; for general VO file delivery, use the client’s target loudness but still keep a conservative true-peak ceiling. citeturn12view2turn19view1turn24search2

Suggested automated tests are straightforward. Measure **SNR improvement** on speech-in-noise pairs at several starting SNRs. Measure **integrated LUFS**, **short-term LUFS stability**, and **true/sample peak compliance** after limiting. Track **crest factor** before and after processing, and flag large collapses that correlate with flattened consonants. Track **spectral balance** in the specific VO bands that matter here—sub-250 Hz, 500 Hz–1.2 kHz, 3–5 kHz, sibilance band, and air band—against a chosen reference corpus. Add regression tests for bypass-null behavior, impulse/step stability, plosive bursts, synthetic sibilant bursts, CPU at 44.1/48/96 kHz, and latency assertions for tracking mode versus render mode.

## Open Questions and Limitations

This report focuses on the **real-time insert chain**. It does **not** include offline forensic repair stages such as mouth click removal, de-plosive editing, breath editing, or clip-gain word riding, all of which can outperform real-time DSP for difficult material. Also, the sources strongly support the control models and ordering logic above, but they do not define one universal “VO standard chain”; the exact winners still depend on mic choice, room noise, narrator style, and delivery target. For a pure JSFX implementation, the only major feature I would defer is **RNNoise-class suppression**, which is better suited to a compiled extension than to the first-pass EEL script.