#!/usr/bin/env wolframscript
(* ::Package:: *)

(* DEEP-TIME TEMPERATURE — 5.3 million years and the Mid-Pleistocene
   Transition. The LR04 benthic d18O stack (global ice volume / deep-ocean
   temperature) reaches far beyond the ice cores. Around 1.25-0.7 Myr ago
   the world switched from a ~41 kyr (obliquity-paced) rhythm to the
   ~100 kyr rhythm of the last eight cycles. We show the record and prove
   the switch with two windowed power spectra. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

lr = IceData`LoadLR04[];
ageMyr = lr["age_kyr"]/1000.;
xt[a_] := 5.32 - a;                       (* Myr; present at right *)
mptLo = 0.7; mptHi = 1.25;                (* Mid-Pleistocene Transition, Myr *)

(* d18O: higher = colder/more ice. Plot -d18O so warm is up, with custom
   ticks showing the real d18O values. Light smoothing tames 1-kyr noise. *)
pts = IceViz`SmoothSeries[SortBy[{xt[#[[1]]/1000.], -#[[2]]} & /@ Transpose[{lr["age_kyr"], lr["d18O"]}], First], 2];
ageTk = Table[{xt[a], If[a == 0, "0", ToString[a]]}, {a, 0, 5, 1}];
d18Tk = {-#, ToString[#]} & /@ {3, 4, 5};
ylo = -5.2; yhi = -2.45;

timeline = ListLinePlot[pts,
   PlotStyle -> Directive[IceViz`TempColor, AbsoluteThickness[1]],
   Filling -> Bottom, FillingStyle -> Directive[IceViz`TempColor, Opacity[0.1]],
   PlotRange -> {{0, 5.32}, {ylo, yhi}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
   FrameTicks -> {{d18Tk, None}, {ageTk, None}},
   FrameLabel -> {"millions of years before present", "benthic \[Delta]\:00b9\:2078O (\:2030)"},
   Background -> White, AspectRatio -> 0.3, ImageSize -> 1300,
   GridLines -> {Table[xt[a], {a, 0, 5}], None}, GridLinesStyle -> Directive[GrayLevel[0.85], Dashing[{1, 3}]],
   Prolog -> {Directive[RGBColor[0.9, 0.55, 0.15], Opacity[0.18]], Rectangle[{xt[mptHi], ylo}, {xt[mptLo], yhi}],
     Directive[RGBColor[0.8, 0.45, 0.1], Opacity[0.5], AbsoluteThickness[1], Dashing[{4, 4}]],
     Line[{{xt[mptHi], ylo}, {xt[mptHi], yhi}}], Line[{{xt[mptLo], ylo}, {xt[mptLo], yhi}}]},
   Epilog -> {Directive[FontFamily -> "Helvetica"],
     Text[Rotate[Style["Mid-Pleistocene Transition", 10.5, Bold, RGBColor[0.7, 0.4, 0.05]], 90 Degree], {xt[(mptLo + mptHi)/2], -3.9}, {0, 0}],
     Text[Style["  \[LeftArrow] 41 kyr \"obliquity world\"  ", 12, Bold, IceViz`Accent, Background -> GrayLevel[1, 0.6]], {xt[3.3], -2.58}, {0, 1}],
     Text[Style["  100 kyr \"eccentricity world\" \[RightArrow]  ", 12, Bold, IceViz`Accent, Background -> GrayLevel[1, 0.6]], {xt[0.33], -2.58}, {1, 1}],
     Text[Style["warmer \[UpArrow]  (less ice)", 9, Italic, GrayLevel[0.45]], {xt[5.15], -2.95}, {-1, 0}]},
   ImagePadding -> {{66, 14}, {38, 8}}, LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor]];

(* ---- windowed power spectra in two epochs ---- *)
spectrum[a0_, a1_] := Module[{sub, ages, vals, dt = 2., g, y, w, p, freqs, half},
   sub = Select[Transpose[{lr["age_kyr"], lr["d18O"]}], a0 <= #[[1]] <= a1 &];
   {ages, vals} = IceViz`ResampleGrid[sub[[All, 1]], sub[[All, 2]], {a0, a1, dt}];
   y = vals - (Fit[Transpose[{ages, vals}], {1, x}, x] /. x -> # & /@ ages);
   w = 0.5 (1 - Cos[2 Pi Range[0, Length[y] - 1]/(Length[y] - 1)]);
   p = Abs[Fourier[y w, FourierParameters -> {-1, 1}]]^2;
   freqs = Range[0, Length[y] - 1]/(Length[y] dt); half = Floor[Length[y]/2];
   sub = Select[Transpose[{1/freqs[[2 ;; half]], p[[2 ;; half]]}], 14 <= #[[1]] <= 160 &];
   sub[[All, 2]] /= Max[sub[[All, 2]]]; sub];

bands = {{80, 125}, {37, 47}};
pTicks = {Log[#], ToString[#]} & /@ {20, 41, 60, 100, 150};
specPanel[s_, lab_, col_] := ListLinePlot[{Log[#[[1]]], #[[2]]} & /@ s,
   PlotStyle -> Directive[col, AbsoluteThickness[1.8]], Filling -> Axis,
   FillingStyle -> Directive[col, Opacity[0.2]], InterpolationOrder -> 2,
   Prolog -> {Directive[IceViz`Accent, Opacity[0.13]], Rectangle[{Log[#[[1]]], 0}, {Log[#[[2]]], 10}] & /@ bands},
   PlotRange -> {{Log[15], Log[160]}, {0, 1.12}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
   FrameTicks -> {{None, None}, {pTicks, None}}, FrameLabel -> {"period (kyr)", None},
   PlotLabel -> Style[lab, 12, Bold, col], Background -> White,
   GridLines -> {Log /@ {41, 100}, None}, GridLinesStyle -> Directive[GrayLevel[0.8], Dashing[{2, 3}]],
   Epilog -> {Directive[FontFamily -> "Helvetica"],
     Text[Style["100", 9, Bold, IceViz`Accent], {Log[100], 1.06}, {0, 1}],
     Text[Style["41", 9, Bold, IceViz`Accent], {Log[41], 1.06}, {0, 1}]},
   AspectRatio -> 0.62, ImageSize -> 640, LabelStyle -> Directive[FontFamily -> "Helvetica", 10, IceViz`InkColor],
   ImagePadding -> {{40, 12}, {40, 24}}];

late  = spectrum[0, 700];       Print["late Pleistocene peak: ", Round[late[[First@Ordering[late[[All,2]],-1],1]],1], " kyr"];
early = spectrum[1600, 2600];   Print["early Pleistocene peak: ", Round[early[[First@Ordering[early[[All,2]],-1],1]],1], " kyr"];

specRow = GraphicsRow[{
   specPanel[late, "after the MPT  (0\[Dash]0.7 Myr)", IceViz`CO2Color],
   specPanel[early, "before the MPT  (1.6\[Dash]2.6 Myr)", IceViz`Accent]}, Spacings -> 8, ImageSize -> 1300];

out = Column[{timeline, specRow}, Spacings -> 1, Alignment -> Center];
Export[FileNameJoin[{imgDir, "deeptime_temp.png"}], out, ImageResolution -> 200];
Print["wrote deeptime_temp.png  ", Round[FileByteCount[FileNameJoin[{imgDir, "deeptime_temp.png"}]]/1024], " KB"];
