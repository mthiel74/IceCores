#!/usr/bin/env wolframscript
(* ::Package:: *)

(*  Build community/ice_cores.nb — the educational Wolfram Community
    notebook. Opens an invisible FrontEnd, assembles fully-formed cells
    (text + embedded Image / AnimatedImage), saves .nb + .pdf.
    Style: blue "Roboto Condensed" Title/Sections (see ice_cores_helpers.wl),
    matching the reference notebook. No "how to cite" section. *)

repoRoot = ParentDirectory@DirectoryName[$InputFileName];
Get[FileNameJoin[{repoRoot, "wolfram", "load_data.wl"}]];
Get[FileNameJoin[{repoRoot, "community", "ice_cores_helpers.wl"}]];
imgDir = FileNameJoin[{repoRoot, "docs", "images"}];
IceCells`SetImgDir[imgDir];
outNb  = FileNameJoin[{repoRoot, "community", "ice_cores.nb"}];
outPdf = FileNameJoin[{repoRoot, "community", "ice_cores.pdf"}];

(* live numbers from the data so prose never drifts from the figures *)
co2 = IceData`LoadCO2[]; mlo = IceData`LoadModernMLO[];
natMax = Round[Max[Pick[co2["co2"], Thread[co2["age_kyr"] >= 2], True]], 0.1];
natMin = Round[Min[co2["co2"]], 0.1];
modern = Round[Last[mlo["co2"]]];
modernYr = Round[Last[mlo["year"]]];
excess = Round[modern - natMax];
modStr = ToString[modern]; natMaxStr = ToString[Round[natMax]];

(* convenient aliases *)
title = IceCells`title; subtitle = IceCells`subtitle; sec = IceCells`sec;
sub = IceCells`sub; subsub = IceCells`subsub; para = IceCells`para;
item = IceCells`item; abstract = IceCells`abstract; callout = IceCells`callout;
bold = IceCells`bold; ital = IceCells`ital; mono = IceCells`mono; lnk = IceCells`lnk;
displayMath = IceCells`displayMath; figCell = IceCells`figCell;
animCell = IceCells`animCell; spacer = IceCells`spacer;

co2s = "CO\:2082";

$allCells = Flatten[{

  title["800,000 Years of Climate"],
  subtitle["CO\:2082, temperature, and the rhythm of the ice ages \[LongDash] read from the EPICA Dome C ice core in the Wolfram Language"],

  abstract[
    bold["A single column of Antarctic ice holds a continuous 800,000-year diary of Earth's atmosphere."],
    " Bubbles trapped in the ice preserve ancient air; the ice itself records temperature through its hydrogen isotopes. From two published EPICA Dome C records we reconstruct the ", bold["eight glacial\[Dash]interglacial cycles"],
    ", expose their ", bold["~100,000-year Milankovitch rhythm"], " with a power spectrum, rebuild the ", bold["orbital pacemakers"],
    " from first principles, ask ", bold["which moves first"], " (CO\:2082 or temperature), and follow the rhythm back ", bold["five million years"], " through the Mid-Pleistocene Transition. Today's ", bold[modStr <> " ppm of CO\:2082"], " sits about ", bold[ToString[excess] <> " ppm above anything"],
    " in the 800,000-year record \[LongDash] reached in a century and a half, not ten thousand years \[LongDash] and was last matched some ", bold["3 million years ago"], "."],

  figCell["hero.png", "Eight hundred millennia of CO\:2082 (red) and Antarctic temperature (blue silhouette). The grey band is the natural range over the whole record; the orange spike at right is the modern instrumental rise to today.", 700],

  (* ============================================================= *)
  sec["1.  The frozen archive"],
  para["Snow that falls on the East Antarctic plateau rarely melts. It compresses, layer on layer, into ice up to three kilometres thick. The European Project for Ice Coring in Antarctica (EPICA) drilled a core at ", bold["Dome C"], " (75\[Degree]S, 123\[Degree]E) that reaches back ", bold["~800,000 years"], " \[LongDash] eight complete ice-age cycles. Two quantities are read from it:"],
  item[bold["Atmospheric CO\:2082"], " from air bubbles sealed in the ice. As snow turns to ice, it traps a sample of the contemporary atmosphere. We use the 800 kyr Antarctic composite of ", lnk["Bereiter et al. (2015)", "https://doi.org/10.1002/2014GL061957"], "."],
  item[bold["Temperature"], " from the ", bold["deuterium"], " (heavy hydrogen, \[Delta]D) content of the ice. Colder air delivers isotopically lighter snow, so \[Delta]D is a thermometer. We use the reconstruction of ", lnk["Jouzel et al. (2007)", "https://doi.org/10.1126/science.1141038"], " on the EDC3 age scale."],
  callout[
    bold["Read the temperature honestly. "],
    "This is a ", bold["deuterium-derived Antarctic temperature anomaly"], " \[LongDash] not \[Delta]\:00b9\:2078O, and ", bold["not a global mean"], ". It tracks the glacial\[Dash]interglacial structure superbly but is a regional, isotope-based estimate relative to the mean of the last 1,000 years. Also, CO\:2082 is dated by the age of the ", ital["trapped gas"], ", whereas temperature is dated by the age of the ", ital["ice"], "; the offset between them (\[CapitalDelta]age) means overlaying the two curves is an excellent ", bold["visual"], " comparison, not a precise phasing analysis. \"Before present\" means before 1950."],

  (* ============================================================= *)
  sec["2.  Eight glacial\[Dash]interglacial cycles"],
  para["Plotted across the full 800,000 years, both records march in a striking sawtooth: a slow, ragged slide into each glacial maximum followed by an abrupt ", bold["termination"], " into a warm interglacial. The interglacials are the odd-numbered marine isotope stages (MIS) \[LongDash] our own Holocene is MIS 1, the last interglacial (the Eemian, ~123 kyr ago) is MIS 5."],
  figCell["cycles.png", "CO\:2082 (top) and Antarctic temperature (bottom) over 800 kyr, present at right. Dotted guides mark the interglacial peaks (MIS stages, after the LR04 chronology); the grey band is the natural CO\:2082 range. The two curves rise and fall almost in lockstep.", 690],
  para["Watch the record assemble itself, oldest to youngest \[LongDash] and then watch the present arrive:"],
  animCell["anim_sweep.gif", "Sweeping through 800,000 years. The ice-core CO\:2082 stays inside its band for the whole record; only at the very end does the instrumental curve leave the chart.", 560],

  (* ============================================================= *)
  sec["3.  The 100,000-year rhythm"],
  para["The cycles are not random. Taking a power spectrum of each record \[LongDash] resampling to an even 2-kyr grid, detrending, Hann-windowing and an FFT \[LongDash] concentrates the power at the ", bold["Milankovitch periods"], " of Earth's orbit:"],
  item[bold["~100 kyr"], " \[LongDash] eccentricity (the shape of Earth's orbit);"],
  item[bold["~41 kyr"], " \[LongDash] obliquity (the tilt of its axis);"],
  item[bold["~19\[Dash]23 kyr"], " \[LongDash] precession (the wobble of the axis)."],
  figCell["spectral.png", "Power spectra of CO\:2082 (left) and Antarctic temperature (right). CO\:2082 is dominated by the ~100 kyr eccentricity band; temperature carries both the 100 kyr and a strong ~41 kyr obliquity peak, with a precession bump near 23 kyr.", 690],
  para["The late-Pleistocene cycles are ", bold["paced near 100 kyr"], ". This is the famous \"100 kyr problem\": the eccentricity ", ital["forcing"], " is itself weak, so the dominant 100 kyr beat reflects eccentricity-modulated pacing amplified by ice-sheet and carbon-cycle feedbacks rather than direct orbital energy. Temperature's strong 41 kyr peak is the fingerprint of axial tilt. (These are simple illustrative periodograms \[LongDash] enough to reveal the bands, not formal red-noise significance tests.)"],

  (* ============================================================= *)
  sec["4.  The orbital pacemakers"],
  para["We can rebuild the pacemakers themselves. From the ", lnk["La2004 astronomical solution", "https://doi.org/10.1051/0004-6361:20041335"], " (Laskar et al. 2004) we take eccentricity, obliquity and the longitude of perihelion, and compute the classic orbital pacing index \[LongDash] the ", bold["65\[Degree]N summer-solstice daily-mean insolation"], " (Berger 1978), the sunlight available to melt northern ice sheets (a pacing index, not the sole driver \[LongDash] feedbacks and ice-sheet dynamics matter too):"],
  displayMath[
    RowBox[{"Q", "=", FractionBox["S", "\[Pi]"],
      SuperscriptBox[RowBox[{"(", FractionBox["a", "r"], ")"}], "2"],
      RowBox[{"(", RowBox[{SubscriptBox["H", "0"], " ", "sin\[Phi]", " ", "sin\[Delta]", "+",
        "cos\[Phi]", " ", "cos\[Delta]", " ", RowBox[{"sin", " ", SubscriptBox["H", "0"]}]}], ")"}]}]],
  figCell["orbital.png", "The La2004 orbital parameters \[LongDash] eccentricity (~100 kyr), obliquity (~41 kyr), climatic precession (~23 kyr) \[LongDash] and the computed 65\[Degree]N summer insolation, above the Antarctic temperature response. Present at right.", 690],
  callout[
    bold["Pacing, not a simple cause. "],
    "Orbital changes set the ", ital["timing"], " of the glacial cycles, but the temperature swings are far larger than insolation alone can explain. CO\:2082 acts as a powerful ", bold["amplifying feedback"], ": warming oceans and shifting circulation release CO\:2082, which warms the planet further. At deglaciations Antarctic temperature often ", bold["leads"], " CO\:2082 by several centuries \[LongDash] so this is a coupled feedback system, not \"CO\:2082 caused the ice ages\" nor the reverse."],

  (* ============================================================= *)
  sec["5.  The tight CO\:2082\[Dash]temperature coupling"],
  para["Plotting CO\:2082 against temperature, with the 800-kyr trajectory coloured by age, the natural climate states collapse onto a tight diagonal \[LongDash] a linear fit gives roughly ", bold["8 ppm of CO\:2082 per \[Degree]C"], " of Antarctic change (a descriptive slope, not a physical sensitivity). Glacial and interglacial worlds are two ends of one well-worn groove."],
  figCell["phase.png", "CO\:2082 versus Antarctic temperature anomaly; the path is coloured from oldest (dark) to youngest. Every one of the last eight cycles lives in the same diagonal cloud \[LongDash] and today's CO\:2082 sits far above all of it.", 640],
  para["And then there is today. The orange point floats high above a phase space that 800,000 years of natural variability never came close to entering."],

  (* ============================================================= *)
  sec["6.  Does CO\:2082 lead or follow temperature?"],
  para["If the two are so tightly coupled, which moves first? Two standard tools answer this \[LongDash] ", bold["lagged cross-correlation"], " in the time domain, and ", bold["cross-spectral phase"], " in the frequency domain. On our resampled records the cross-correlation peaks at ", bold["r \[TildeTilde] 0.89"], " essentially at ", bold["zero lag"], ", and the phase at every Milankovitch band (100, 41, 23 kyr) sits within ", bold["~1 kyr of zero"], ", with high coherence."],
  figCell["leadlag.png", "Left: lagged cross-correlation of CO\:2082 and temperature \[LongDash] a smooth peak at essentially zero lag (positive = CO\:2082 leads). Right: cross-spectral phase as a lag at each Milankovitch band; all three sit within ~1 kyr of zero \[LongDash] the scale of the gas-/ice-age chronology offset \[LongDash] with coherence \[Gamma]\.b2 labelled.", 760],
  callout[
    bold["Why our data can't settle it \[LongDash] and what does. "],
    "Our CO\:2082 sits on a ", bold["gas-age"], " scale and our temperature on an ", bold["ice-age"], " scale (different chronologies, offset by the modelled \[CapitalDelta]age of order ~1 kyr at Dome C). The apparent ~1 kyr lag is comparable to that offset, so these data show tight, in-phase coupling but ", bold["cannot resolve the true centennial lead/lag"], ". That requires CO\:2082 and temperature from the ", ital["same"], " core on a synchronised timescale. When that is done: Antarctic temperature can ", ital["slightly lead"], " CO\:2082 at deglaciations (Caillon 2003 found ~800 yr; Parrenin 2013 / Pedro 2012 revised it to near-synchrony, 0\[PlusMinus]200 yr); and during the last deglaciation CO\:2082 rose ", bold["before most of the global-mean warming"], " (Shakun et al. 2012). The consistent picture: orbital pacing \[RightArrow] Southern-Ocean warming \[RightArrow] CO\:2082 release \[RightArrow] global amplification. A coupled feedback, with CO\:2082 the great amplifier."],
  para["The clearest way to ", ital["see"], " it is to zoom into the deglaciations themselves. Overlaying CO\:2082 and Antarctic temperature (each normalised within the window) across the last two terminations, the two ", bold["rise essentially together"], " \[LongDash] so close that the order of the first few centuries is, in these records, lost inside the \[CapitalDelta]age uncertainty rather than plainly visible."],
  figCell["terminations.png", "The last two deglaciations, CO\:2082 (red) and Antarctic temperature (blue) on a common grid with identical smoothing, each normalised within the window, younger at right. A shape comparison (not a timing measurement): they climb almost on top of each other, any residual offset being within the gas-/ice-age chronology offset.", 760],

  (* ============================================================= *)
  sec["7.  The modern breakout"],
  para["Over the whole ice-core record, CO\:2082 ranged from about ", bold[ToString[Round[natMin]] <> " ppm"], " in the depths of glacials to about ", bold[natMaxStr <> " ppm"], " in the warmest interglacials. In ", ToString[modernYr], " the instrumental Mauna Loa value was ", bold[modStr <> " ppm"], " \[LongDash] roughly ", bold[ToString[excess] <> " ppm above"], " the highest natural level in 800,000 years."],
  para["The ", bold["rate"], " is as startling as the level. The natural deglacial rise out of the last ice age \[LongDash] about 90 ppm \[LongDash] took some ten thousand years (~0.01 ppm/yr). The rise since ~1850 has run more than ", bold["seventy times faster"], "."],
  figCell["modern.png", "The last 24,000 years. The gradual deglacial rise of CO\:2082 (red) gives way to the near-vertical instrumental \"blade\" (orange) to today's value \[LongDash] off the top of the natural band.", 680],
  para["Seen as a gauge filling through time, the picture is visceral: the column tracks the natural band for the entire record, then bursts straight through the ceiling."],
  animCell["anim_breakout.gif", "A CO\:2082 gauge swept through 800,000 years. Crimson is the natural range; the orange is the present-day excess that carries CO\:2082 far past anything in the record.", 560],

  (* ============================================================= *)
  sec["8.  Beyond the ice: five million years"],
  para["The ice cores stop at 800 kyr, but the ", bold["LR04 benthic \[Delta]\:00b9\:2078O stack"], " (Lisiecki & Raymo 2005) \[LongDash] a global proxy for ice volume and deep-ocean temperature \[LongDash] reaches back ", bold["5.3 million years"], ". It exposes a striking change in the climate's rhythm: before about ", bold["1 million years ago the world ran on a ~41 kyr (obliquity) beat"], "; afterwards it switched to the ", bold["~100 kyr rhythm"], " of our eight cycles. This is the ", bold["Mid-Pleistocene Transition"], "."],
  figCell["deeptime_temp.png", "Top: 5.3 Myr of LR04 benthic \[Delta]\:00b9\:2078O (warmer up), present at right; the cycles grow larger and longer across the Mid-Pleistocene Transition (shaded). Bottom: power spectra in two windows recover the switch \[LongDash] a 41 kyr peak before the transition, a 100 kyr peak after.", 760],
  para["Re-running our spectrum in two windows recovers it directly: ", bold["before"], " the transition the dominant period is ", bold["~41 kyr"], "; ", bold["after"], " it is ", bold["~100 kyr"], " \[LongDash] the same beat we measured in the ice cores."],

  (* ============================================================= *)
  sec["9.  Deep time: CO\:2082 over 150 million years"],
  para["How unusual is ", modStr, " ppm on the longest view? Beyond the ice we rely on discontinuous old ice (", bold["Allan Hills"], ", ~2 Myr; Yan et al. 2019) and geochemical ", bold["proxies"], " \[LongDash] boron isotopes, alkenones, fossil-leaf stomata \[LongDash] synthesised across the Cenozoic by the ", lnk["CenCO\:2082PIP project", "https://doi.org/10.1126/science.adi5177"], " (H\[ODoubleDot]nisch et al. 2023) and across the wider Phanerozoic by ", lnk["Foster, Royer & Lunt (2017)", "https://doi.org/10.1038/ncomms14845"], ". On a logarithmic time axis the whole sweep fits in one frame \[LongDash] out to the ", bold["Cretaceous greenhouse"], " ~100 million years ago, when CO\:2082 ran near 1,000\[Dash]1,500 ppm."],
  figCell["deeptime_co2.png", "CO\:2082 from 10 kyr to 150 Myr on log axes (curated published estimates beyond the ice; see caveat). The narrow ice-core band (blue) and Allan Hills ice (red) stay below ~300 ppm; geochemical proxies (blue, with uncertainties) climb past the Eocene hothouse to the Cretaceous greenhouse. The K\[Dash]Pg boundary (66 Ma) is marked. Today's level (orange line) was last seen, within proxy uncertainty, in the mid-Pliocene ~3 million years ago.", 720],
  callout[
    bold["The Pliocene benchmark. "],
    "The last time CO\:2082 was comparable to today's ", modStr, " ppm (within proxy uncertainty) was the ", bold["mid-Pliocene, roughly 3 million years ago"], " \[LongDash] a world ~2\[Dash]3\[Degree]C warmer with seas an estimated 10\[Dash]20 m higher. Deep-time CO\:2082 estimates carry ", bold["large uncertainties"], " and are far sparser than the ice cores; the values shown are ", bold["representative published estimates, hand-compiled from the cited sources"], " \[LongDash] not fetched data or a continuous measured record."],

  (* ============================================================= *)
  sec["10.  Conclusions"],
  para["From Antarctic ice and the records that reach beyond it, the picture is clear:"],
  item["CO\:2082 and Antarctic temperature have cycled together through ", bold["eight glacial\[Dash]interglacial cycles"], " over 800,000 years, tightly coupled (~8 ppm/\[Degree]C)."],
  item["Those cycles are ", bold["paced by Earth's orbit"], " \[LongDash] the 100 / 41 / 23 kyr Milankovitch bands appear directly in the spectra, and the ", bold["Mid-Pleistocene Transition"], " from a 41 kyr to a 100 kyr world is visible in the 5-Myr LR04 record."],
  item["Lead/lag analysis shows the two are ", bold["essentially in phase"], " within the chronological uncertainty; CO\:2082 is the great ", bold["amplifier"], " of orbitally-paced change and globally leads temperature."],
  item["Today's CO\:2082 is ", bold["entirely outside the 800,000-year experience"], " \[LongDash] and was last sustained ", bold["~3 million years ago"], ", in a far warmer, higher-sea world."],

  (* ============================================================= *)
  sec["11.  Data & methods"],
  callout[
    bold["Scope. "], "This is a data-visualisation notebook. It shows published, openly-archived records ", bold["as their authors released them"], " \[LongDash] no re-tuning or gap-filling beyond the resampling noted \[LongDash] together with standard, reproducible analyses. It makes ", bold["no projections and advocates no position"], "; the aim is simply to let the measurements be examined directly, and any interpretation is left to the reader."],
  para[bold["All pure Wolfram Language. "], "Every record except the deep-time CO\:2082 panel is ", bold["fetched live"], " with ", mono["URLRead"], ", cached as CSV, and loaded by a shared package; the \[Section]9 deep-time CO\:2082 points are hand-compiled from the cited literature (flagged there). Figures display age as ", mono["800 - age"], " so the present is at the right; spectra resample to an even grid before the FFT; lead/lag uses lagged correlation and a smoothed cross-spectrum; insolation follows Berger (1978)."],
  item[bold["CO\:2082 (800 kyr): "], "Bereiter et al. (2015), Antarctic composite (NOAA WDS Paleo)."],
  item[bold["Temperature: "], "Jouzel et al. (2007), EPICA Dome C deuterium temperature, EDC3 scale (NOAA WDS Paleo)."],
  item[bold["Modern CO\:2082: "], "NOAA Global Monitoring Laboratory, Mauna Loa & global annual means."],
  item[bold["Orbital forcing: "], "Laskar et al. (2004), La2004 solution (IMCCE)."],
  item[bold["Deep-time temperature: "], "Lisiecki & Raymo (2005), LR04 benthic \[Delta]\:00b9\:2078O stack (NOAA WDS Paleo)."],
  item[bold["Deep-time CO\:2082: "], "Yan et al. (2019, Allan Hills), CenCO\:2082PIP (H\[ODoubleDot]nisch et al. 2023) and Foster, Royer & Lunt (2017, Phanerozoic) \[LongDash] curated published estimates (see \[Section]9 caveat)."],
  para["Source, build scripts and this notebook: ", lnk["github.com/mthiel74/IceCores", "https://github.com/mthiel74/IceCores"], "."],

  sec["12.  References"],
  para[ital["Bereiter, B. et al."], " (2015). Revision of the EPICA Dome C CO\:2082 record from 800 to 600 kyr before present. ", bold["Geophys. Res. Lett. 42"], ", 542\[Dash]549."],
  para[ital["Jouzel, J. et al."], " (2007). Orbital and millennial Antarctic climate variability over the past 800,000 years. ", bold["Science 317"], ", 793\[Dash]796."],
  para[ital["Laskar, J. et al."], " (2004). A long-term numerical solution for the insolation quantities of the Earth. ", bold["Astron. Astrophys. 428"], ", 261\[Dash]285."],
  para[ital["Lisiecki, L. E. & Raymo, M. E."], " (2005). A Pliocene-Pleistocene stack of 57 globally distributed benthic \[Delta]\:00b9\:2078O records (LR04). ", bold["Paleoceanography 20"], ", PA1003."],
  para[ital["Berger, A. L."], " (1978). Long-term variations of daily insolation and Quaternary climatic changes. ", bold["J. Atmos. Sci. 35"], ", 2362\[Dash]2367."],
  para[ital["Caillon, N. et al."], " (2003). Timing of atmospheric CO\:2082 and Antarctic temperature changes across Termination III. ", bold["Science 299"], ", 1728\[Dash]1731."],
  para[ital["Parrenin, F. et al."], " (2013). Synchronous change of atmospheric CO\:2082 and Antarctic temperature during the last deglacial warming. ", bold["Science 339"], ", 1060\[Dash]1063."],
  para[ital["Shakun, J. D. et al."], " (2012). Global warming preceded by increasing CO\:2082 during the last deglaciation. ", bold["Nature 484"], ", 49\[Dash]54."],
  para[ital["Yan, Y. et al."], " (2019). Two-million-year-old snapshots of atmospheric gases from Antarctic ice. ", bold["Nature 574"], ", 663\[Dash]666."],
  para[ital["H\[ODoubleDot]nisch, B. et al."], " (2023). Toward a Cenozoic history of atmospheric CO\:2082. ", bold["Science 382"], ", eadi5177."],
  para[ital["Foster, G. L., Royer, D. L. & Lunt, D. J."], " (2017). Future climate forcing potentially without precedent in the last 420 million years. ", bold["Nature Communications 8"], ", 14845."],

  (* ============================================================= *)
  sec["13.  Acknowledgements"],
  para["This notebook rests entirely on measurements generously made public by others. The Dome C records are the work of the ", bold["EPICA community"], " and the investigators cited above; the orbital solution is from the ", bold["IMCCE"], " (Laskar and colleagues); the deep-time compilations are the work of the CenCO\:2082PIP consortium and the authors cited in \[Section]9. Data were obtained from the ", bold["NOAA World Data Service for Paleoclimatology"], " and the ", bold["NOAA Global Monitoring Laboratory"], ", whose long-term archiving makes work like this possible. All analysis, figures and animations are pure Wolfram Language."]
}];

Print["assembled ", Length[$allCells], " cells"];

ss = IceCells`IceStylesheet[];
TimeConstrained[
  UsingFrontEnd[
    nb = CreateDocument[$allCells, Visible -> False,
       WindowSize -> {1000, 820}, WindowMargins -> Automatic,
       StyleDefinitions -> ss];
    NotebookSave[nb, outNb];
    Print["wrote ", outNb, " (", Round[FileByteCount[outNb]/1024], " KB)"];
    Quiet@Check[Export[outPdf, nb]; Print["wrote ", outPdf, " (", Round[FileByteCount[outPdf]/1024], " KB)"],
       Print["warn: PDF export failed"]];
    NotebookClose[nb];],
  900,
  Print["warn: notebook save timed out"]];
