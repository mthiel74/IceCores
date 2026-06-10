#!/usr/bin/env wolframscript
(* ::Package:: *)

(* DEEP-TIME CO2 — putting today's CO2 in a 150-million-year context.
   Beyond the 800-kyr ice cores, CO2 comes from discontinuous old ice
   (Allan Hills, ~2 Myr) and from geochemical proxies (boron isotopes,
   alkenones, leaf stomata). Resolution and directness drop sharply with
   age and uncertainties are large, so this is a CURATED, CITED set of
   published estimates, not a fetched continuous record. The payoff:
   today's CO2 was last sustained in the mid-Pliocene, ~3 million years ago.

   Sources:
     - 0-0.8 Myr  : EPICA Dome C composite (Bereiter et al. 2015) [this repo's data]
     - ~1-2 Myr   : Allan Hills blue ice (Yan et al. 2019, Nature 574)
     - 2-66 Myr   : CenCO2PIP Cenozoic proxy synthesis (Hoenisch et al. 2023,
                    Science 382) and references therein (boron / alkenone / stomata)
     - 66-150 Myr : Phanerozoic proxy + model compilation (Foster, Royer &
                    Lunt 2017, Nat. Commun. 8; GEOCARBSULF, Berner) - Cretaceous
   Pre-ice values are representative central estimates (rounded) with
   indicative uncertainty bars; deep-time CO2 carries large uncertainty. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[];
preInd = Pick[co2["co2"], Thread[co2["age_kyr"] >= 2], True];
{iceLo, iceHi} = MinMax[preInd];     (* natural ice-core band, ppm *)

(* log-log coordinate helpers: age in Myr, CO2 in ppm *)
lx[ageMyr_] := Log10[ageMyr]; ly[co2_] := Log10[co2];
xmin = lx[0.01]; xmax = lx[155]; ymin = ly[160]; ymax = ly[2600];
today = IceViz`ModernCO2;

(* Allan Hills (~1-2 Myr): interglacial maxima ~270-285, glacial minima ~210-230 *)
allan = {{1.0, 272, 18}, {1.5, 258, 22}, {2.0, 278, 22}, {1.2, 225, 18}, {1.7, 232, 20}};

(* Cenozoic proxy CO2 (CenCO2PIP-consistent) + Mesozoic (Foster 2017 /
   GEOCARB) - central +/- indicative. The 56 Ma point is the PETM spike. *)
proxy = {{3.2, 400, 50}, {5., 345, 55}, {10., 360, 80}, {15., 470, 110},
   {23., 420, 110}, {34., 720, 200}, {40., 900, 260}, {50., 1400, 400}, {56., 1850, 500},
   {66., 700, 220}, {80., 900, 300}, {95., 1200, 380}, {115., 1050, 360}, {140., 1150, 420}};

errBar[{aMyr_, v_, e_}, col_] := {col, AbsoluteThickness[1.3],
   Line[{{lx[aMyr], ly[v - e]}, {lx[aMyr], ly[v + e]}}],
   Line[{{lx[aMyr] - 0.03, ly[v - e]}, {lx[aMyr] + 0.03, ly[v - e]}}],
   Line[{{lx[aMyr] - 0.03, ly[v + e]}, {lx[aMyr] + 0.03, ly[v + e]}}],
   Disk[{lx[aMyr], ly[v]}, Offset[3.5]]};

xticks = {lx[#[[1]]], #[[2]]} & /@ {{0.01, "10 kyr"}, {0.1, "100 kyr"}, {1, "1 Myr"}, {10, "10 Myr"}, {100, "100 Myr"}};
xticksMinor = {lx[#], ""} & /@ Flatten[Table[k 10^e, {e, -2, 2}, {k, 2, 9}]];
yticks = {ly[#], ToString[#]} & /@ {200, 300, 500, 1000, 2000};

g = Graphics[{
   (* today's level as a horizontal reference across all time *)
   Directive[IceViz`ModernColor, Opacity[0.5], AbsoluteThickness[1.4], Dashing[{6, 5}]],
   Line[{{xmin, ly[today]}, {xmax, ly[today]}}],
   (* ice-core natural band *)
   Directive[IceViz`GlacialShade, Opacity[0.4]], Rectangle[{lx[0.01], ly[iceLo]}, {lx[0.8], ly[iceHi]}],
   Directive[IceViz`CO2Color, Opacity[0.9], AbsoluteThickness[2.4]],
   Line[{{lx[0.01], ly[iceHi]}, {lx[0.8], ly[iceHi]}}],
   (* Allan Hills ice *)
   errBar[#, IceViz`CO2Color] & /@ allan,
   (* Cenozoic proxy *)
   errBar[#, IceViz`Accent] & /@ proxy,
   Directive[IceViz`Accent, Opacity[0.5], AbsoluteThickness[1.2]],
   Line[{lx[#[[1]]], ly[#[[2]]]} & /@ proxy],
   (* K-Pg boundary marker (66 Ma) *)
   Directive[GrayLevel[0.55], Opacity[0.6], AbsoluteThickness[1], Dashing[{3, 4}]],
   Line[{{lx[66], ymin}, {lx[66], ly[1500]}}],
   Text[Style["K\[Dash]Pg", 9, Italic, GrayLevel[0.45]], {lx[66], ly[185]}, {0, 0}],
   (* Pliocene crossing marker *)
   Directive[RGBColor[0.7, 0.4, 0.05]], Disk[{lx[3.2], ly[400]}, Offset[5]],
   White, Disk[{lx[3.2], ly[400]}, Offset[2]],

   (* annotations *)
   Directive[FontFamily -> "Helvetica"],
   Text[Style[Row[{"today  ", Round[today], " ppm"}], 13, Bold, IceViz`ModernColor], {lx[0.012], ly[today] + 0.022}, {-1, 0}],
   Text[Style["  ice cores\n  (direct air)  ", 10.5, Bold, IceViz`CO2Color, Background -> GrayLevel[1, 0.6]], {lx[0.09], ly[200]}, {0, 1}],
   Text[Style["Allan Hills\nold ice", 10.5, Bold, IceViz`CO2Color], {lx[1.45], ly[178]}, {0, 0}],
   Text[Style["proxy CO\:2082\n(boron \[CenterDot] alkenone \[CenterDot] stomata)", 10.5, Bold, IceViz`Accent], {lx[24], ly[260]}, {0, 0}],
   Text[Style["mid-Pliocene\n~3 Ma", 11, Bold, RGBColor[0.7, 0.4, 0.05]], {lx[3.2], ly[640]}, {0, 0}],
   Text[Style["last time CO\:2082 was this high \[LongRightArrow]", 10, Italic, RGBColor[0.7, 0.4, 0.05]], {lx[3.0], ly[480]}, {1, 0}],
   Text[Style["hothouse\nEocene", 10, Italic, GrayLevel[0.45]], {lx[44], ly[1750]}, {1, 0}],
   Text[Style["Cretaceous\ngreenhouse", 10.5, Bold, IceViz`Accent], {lx[110], ly[1750]}, {0, 0}]},
   PlotRange -> {{xmin, xmax}, {ymin, ymax}}, AspectRatio -> 0.52,
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1.1]],
   FrameTicks -> {{yticks, None}, {xticks, xticksMinor}},
   FrameLabel -> {"age before present  (log scale)", "CO\:2082 (ppm, log scale)"},
   Background -> White, ImageSize -> 1180,
   GridLines -> {xticks[[All, 1]], yticks[[All, 1]]}, GridLinesStyle -> Directive[GrayLevel[0.85], Dashing[{1, 3}]],
   LabelStyle -> Directive[FontFamily -> "Helvetica", 12, IceViz`InkColor],
   ImagePadding -> {{60, 16}, {42, 12}}];

Export[FileNameJoin[{imgDir, "deeptime_co2.png"}], g, ImageResolution -> 200];
Print["wrote deeptime_co2.png  ", Round[FileByteCount[FileNameJoin[{imgDir, "deeptime_co2.png"}]]/1024], " KB"];
Print["ice-core natural band: ", Round[{iceLo, iceHi}], " ppm; today ", Round[today]];
