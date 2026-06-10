#!/usr/bin/env wolframscript
(* ::Package:: *)

(* CYCLES — the eight glacial-interglacial cycles.
   Two stacked panels sharing an age axis: CO2 (top) and Antarctic
   temperature (bottom). Interglacials highlighted; the well-dated
   marine-isotope-stage interglacial peaks (MIS 1,5,7,9,11,13,15,17,19)
   marked with dotted guides. Present at the RIGHT. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; tmp = IceData`LoadTemp[];
xt[age_] := 800 - age;
ageTk = Table[{xt[a], ToString[a]}, {a, 0, 800, 100}];

co2s = IceViz`SmoothSeries[Select[Transpose[{co2["age_kyr"], co2["co2"]}], 2 <= #[[1]] <= 800 &], 3];

(* Canonical interglacial (odd marine-isotope-stage) peak ages, kyr BP,
   after the LR04 benthic stack (Lisiecki & Raymo 2005) and the EPICA
   chronology. These are the eight pre-Holocene interglacials. *)
mis = {{123, "5"}, {200, "7"}, {325, "9"}, {405, "11"},
       {490, "13"}, {565, "15"}, {690, "17"}, {787, "19"}};

(* interglacial shading where smoothed CO2 > 245 ppm (data-driven) *)
fgrid = Range[3, 798, 0.5];
f = Interpolation[co2s, InterpolationOrder -> 1];
vals = f /@ fgrid;
warm = Split[Transpose[{fgrid, vals}], (#2[[2]] > 245) == (#1[[2]] > 245) &];
warmRanges = Select[Select[warm, #[[1, 2]] > 245 &], (#[[-1, 1]] - #[[1, 1]]) > 3 &][[All, {1, -1}, 1]];

shade[ymin_, ymax_] := {Directive[IceViz`CO2Color, Opacity[0.06]],
   Rectangle[{xt[#[[2]]], ymin}, {xt[#[[1]]], ymax}] & /@ warmRanges};
guides[ymin_, ymax_] := {Directive[GrayLevel[0.55], Dashing[{2, 4}], AbsoluteThickness[0.6]],
   Line[{{xt[#[[1]]], ymin}, {xt[#[[1]]], ymax}}] & /@ mis};

co2line = {xt[#[[1]]], #[[2]]} & /@ co2s;
co2panel = Graphics[{
   shade[170, 305],
   Directive[IceViz`GlacialShade, Opacity[0.35]], Rectangle[{0, IceViz`NaturalMin}, {800, IceViz`NaturalMax}],
   guides[170, 305],
   Directive[IceViz`CO2Color, AbsoluteThickness[1.6]], Line[co2line],
   Directive[FontFamily -> "Helvetica"],
   Text[Style["MIS", 9, Bold, GrayLevel[0.45]], {xt[mis[[1, 1]]] + 20, 304}, {1, 1}],
   (Text[Style[#[[2]], 10, Bold, GrayLevel[0.4]], {xt[#[[1]]], 304}, {0, 1}] & /@ mis),
   Text[Style["1", 10, Bold, GrayLevel[0.4]], {xt[6], 304}, {0, 1}],
   Text[Style["CO\:2082", 13, Bold, IceViz`CO2Color], {xt[792], 290}, {-1, 1}]},
   PlotRange -> {{0, 800}, {170, 308}}, AspectRatio -> 0.26,
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
   FrameTicks -> {{Range[180, 300, 40], None}, {ageTk, None}},
   FrameLabel -> {None, "CO\:2082 (ppm)"}, Background -> White,
   LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor],
   ImagePadding -> {{60, 14}, {6, 24}}, ImageSize -> 1300];

tmps = IceViz`SmoothSeries[Transpose[{tmp["age_kyr"], tmp["dT"]}], 4];
tline = SortBy[{xt[#[[1]]], #[[2]]} & /@ Select[tmps, #[[1]] <= 800 &], First];
tpoly = Join[{{0, -11}}, tline, {{800, -11}}];
tpanel = Graphics[{
   shade[-12, 7],
   guides[-12, 7],
   Directive[IceViz`TempColor, Opacity[0.18]], Polygon[tpoly],
   Directive[IceViz`TempColor, AbsoluteThickness[1.4]], Line[tline],
   Directive[GrayLevel[0.4], Dashing[{4, 4}], AbsoluteThickness[0.6]], Line[{{0, 0}, {800, 0}}],
   Directive[FontFamily -> "Helvetica"],
   Text[Style["warmer \[RightArrow]", 9, Italic, IceViz`TempColor], {xt[792], 4.5}, {-1, 0}],
   Text[Style["temperature anomaly", 13, Bold, IceViz`TempColor], {xt[792], -8}, {-1, 0}]},
   PlotRange -> {{0, 800}, {-12, 7}}, AspectRatio -> 0.20,
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
   FrameTicks -> {{Range[-8, 4, 4], None}, {ageTk, None}},
   FrameLabel -> {"thousands of years before present", "\[CapitalDelta]T (\[Degree]C)"}, Background -> White,
   LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor],
   ImagePadding -> {{60, 14}, {38, 6}}, ImageSize -> 1300];

out = Column[{co2panel, tpanel}, Spacings -> 0, Alignment -> Left];
Export[FileNameJoin[{imgDir, "cycles.png"}], out, ImageResolution -> 200];
Print["wrote cycles.png  ", FileByteCount[FileNameJoin[{imgDir, "cycles.png"}]], " B"];
