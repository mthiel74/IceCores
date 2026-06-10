# Ice Cores — CO₂ and Temperature over 800,000 Years

An educational, reproducible Wolfram Language analysis of the EPICA Dome C
ice core: **800,000 years of atmospheric CO₂ and Antarctic temperature**,
the **eight glacial–interglacial cycles**, the **~100 kyr Milankovitch
rhythm**, and **where today's CO₂ sits relative to the entire record**.

The natural range of CO₂ over 800,000 years was about **173–300 ppm**.
Today it is **~427 ppm** (Mauna Loa, 2025) — roughly **128 ppm above
anything in the ice-core record**, reached in ~150 years rather than the
~10,000 years a natural deglaciation takes.

The end product is a self-contained **Wolfram Community notebook**
(`community/ice_cores.nb`).

## What the project does

1. **Pulls the canonical published data** (pure Wolfram Language, cached
   for offline rebuilds):
   - **CO₂**: Antarctic 800 kyr composite, Bereiter et al. 2015 (NOAA WDS Paleo).
   - **Temperature**: EPICA Dome C deuterium temperature, Jouzel et al. 2007
     (EDC3 age scale) — the Antarctic temperature *anomaly*, derived from
     δD (deuterium), *not* δ¹⁸O and *not* a global mean.
   - **Modern instrumental CO₂**: NOAA GML Mauna Loa & global annual means.
   - **Orbital forcing**: the La2004 solution (Laskar et al. 2004, IMCCE) —
     eccentricity, obliquity and precession.
2. **Shows the eight glacial–interglacial cycles** in a dual CO₂ +
   temperature timeline, with the marine-isotope-stage interglacials marked.
3. **Demonstrates the ~100 kyr periodicity** with windowed-FFT power spectra
   of both records, against shaded 100 / 41 / 23 kyr Milankovitch bands.
4. **Reconstructs the orbital pacemakers** and the 65°N summer-solstice
   insolation (Berger 1978) from La2004, beside the climate response.
5. **Tests CO₂ lead/lag vs temperature** with lagged cross-correlation and a
   smoothed cross-spectrum — finding tight, in-phase coupling within the
   gas-age/ice-age (Δage) uncertainty, and explaining what the published
   same-core studies (Caillon, Parrenin, Shakun) actually resolve.
6. **Reaches beyond the ice**: the LR04 benthic δ¹⁸O stack back **5.3 Myr**
   exposes the **Mid-Pleistocene Transition** (41 kyr → 100 kyr world), and a
   curated proxy compilation (cited; not fetched) places today's CO₂ in a
   **150-million-year** context — last sustained in the mid-Pliocene, ~3 Myr
   ago, with the Cretaceous greenhouse far higher still.
7. **Places today's CO₂** above the entire 800 kyr range, in a dual-axis
   "breakout" hero, a phase-space plot, and two animations.

## Scientific caveats (stated honestly in the notebook)

- The temperature record is a **deuterium-derived Antarctic anomaly**, not
  δ¹⁸O and not global temperature.
- CO₂ is dated by **gas age**, temperature by **ice age**; the Δage offset
  makes direct overlays an *approximate* visual comparison, not a precise
  phasing analysis.
- Orbital forcing **paces** the glacial cycles; CO₂ acts as a powerful
  **amplifying feedback** (Antarctic temperature often leads CO₂ by
  centuries at deglaciations) — not a simple one-way cause.
- "Before present" means **before 1950**.

## Repository layout

| path | what lives there |
| --- | --- |
| `wolfram/fetch_*.wls` | live-data fetchers (CO₂, temperature, modern, orbital) |
| `wolfram/*_common.wl`, `load_data.wl` | shared fetch / load / visual-style packages |
| `wolfram/hero.wls`, `cycles.wls`, `spectral.wls`, `phase.wls`, `modern.wls`, `orbital.wls` | figure renderers |
| `wolfram/leadlag.wls`, `deeptime_temp.wls`, `deeptime_co2.wls` | lead/lag + deep-time figures |
| `wolfram/anim_*.wls` | GIF animations |
| `wolfram/run_all.wls` | render everything into `docs/images/` |
| `data/*.csv` | tidy committed data (regenerable) |
| `data/raw/` | bulk raw downloads (git-ignored) |
| `docs/images/` | rendered figures + GIFs |
| `community/build_notebook.wls` | assembles the Wolfram Community notebook |
| `community/ice_cores.nb` / `.pdf` | the deliverable (committed) |

## Reproducing

```sh
# 1. Fetch the data (writes data/*.csv)
wolframscript -file wolfram/fetch_all.wls

# 2. Render every figure + animation (writes docs/images/)
wolframscript -file wolfram/run_all.wls

# 3. Build the community notebook (writes community/ice_cores.nb + .pdf)
wolframscript -file community/build_notebook.wls
```

Everything is pure Wolfram Language — no Python anywhere in the pipeline.

## Data sources

- Bereiter, B. et al. (2015). *Revision of the EPICA Dome C CO₂ record from
  800 to 600 kyr before present.* Geophys. Res. Lett. 42. doi:10.1002/2014GL061957
- Jouzel, J. et al. (2007). *Orbital and millennial Antarctic climate
  variability over the past 800,000 years.* Science 317. doi:10.1126/science.1141038
- Lüthi, D. et al. (2008); Lisiecki, L.E. & Raymo, M.E. (2005, LR04 stack).
- Laskar, J. et al. (2004). *A long-term numerical solution for the
  insolation quantities of the Earth.* A&A 428. (La2004, IMCCE.)
- NOAA Global Monitoring Laboratory — Mauna Loa & global annual mean CO₂.
- Lisiecki, L.E. & Raymo, M.E. (2005). *LR04 benthic δ¹⁸O stack.*
  Paleoceanography 20, PA1003. (Deep-time temperature, 5.3 Myr.)
- Yan, Y. et al. (2019). *Two-million-year-old snapshots of atmospheric
  gases from Antarctic ice.* Nature 574. (Allan Hills.)
- Hönisch, B. et al. (2023). *Toward a Cenozoic history of atmospheric CO₂.*
  Science 382, eadi5177. (CenCO2PIP — deep-time proxy CO₂; curated values.)
- Lead/lag context: Caillon et al. (2003), Parrenin et al. (2013),
  Shakun et al. (2012).

## Scope

This is a data-visualisation project. It shows published, openly-archived
records **as their authors released them** — no re-tuning or gap-filling
beyond the resampling described — together with standard, reproducible
analyses. It makes **no projections and advocates no position**; the data are
presented "as is" so they can be examined directly, and any interpretation is
left to the reader.

## License

Code (the Wolfram Language scripts and notebook) is released under the
**MIT License** — see [`LICENSE`](LICENSE). The scientific datasets remain the
property of their respective producers and archives and are redistributed in
tidy form only for reproducibility, under those providers' own open terms and
with attribution (see Data sources above).
