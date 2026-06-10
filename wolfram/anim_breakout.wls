#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ANIMATION 2 — the gauge that breaks.
   A vertical CO2 "column" gauge (150-450 ppm) with the natural 800 kyr
   band shaded and its ceiling marked. As time sweeps from 800 kyr ago
   to the present, the column tracks ice-core CO2 inside the band; on
   reaching the industrial era it bursts past the ceiling, turns orange
   and climbs to today's ~427 ppm. A sparkline shows where we are. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; mlo = IceData`LoadModernMLO[];

natSeq = SortBy[Select[Transpose[{co2["age_kyr"], co2["co2"]}], #[[1]] >= 0.2 &], First]; (* old..young by age desc *)
natSeq = Reverse[natSeq];                          (* young..old: but we sweep old->young *)
fCO2 = Interpolation[SortBy[Select[Transpose[{co2["age_kyr"], co2["co2"]}], #[[1]] >= 0.2 &], First], InterpolationOrder -> 1];
mloMax = Last[mlo["co2"]];

(* sparkline data (age, co2) present-right *)
sx[age_] := 800 - age;
sparkPts = SortBy[{sx[#[[1]]], #[[2]]} & /@ Select[Transpose[{co2["age_kyr"], co2["co2"]}], #[[1]] >= 0.2 &], First];

gmin = 150; gmax = 450; gx0 = 0; gx1 = 1.4;   (* gauge column geometry *)
ceil = IceViz`NaturalMax;

gc = (gx0 + gx1)/2;
frame[age_, modVal_] := Module[{v, col, isMod},
   isMod = modVal =!= None;
   v = If[isMod, modVal, fCO2[Clip[age, {0.2, 800}]]];
   col = If[v > ceil, IceViz`ModernColor, IceViz`CO2Color];
   Graphics[{
     (* natural band on gauge *)
     Directive[IceViz`GlacialShade, Opacity[0.35]], Rectangle[{gx0, IceViz`NaturalMin}, {gx1, ceil}],
     (* column: natural part crimson, excess-over-ceiling orange *)
     Directive[IceViz`CO2Color, Opacity[1]], Rectangle[{gx0, gmin}, {gx1, Min[v, ceil]}],
     If[v > ceil, {Directive[IceViz`ModernColor, Opacity[1]], Rectangle[{gx0, ceil}, {gx1, v}]}, {}],
     Directive[IceViz`InkColor, Opacity[0.5], Dashing[{5, 5}], AbsoluteThickness[1]], Line[{{gx0 - 0.12, ceil}, {gx1 + 0.12, ceil}}],
     Directive[GrayLevel[0.2], AbsoluteThickness[1.2]], Line[{{gx0, gmin}, {gx0, gmax}, {gx1, gmax}, {gx1, gmin}, {gx0, gmin}}],
     (* fixed readout zone above column *)
     Directive[FontFamily -> "Helvetica"],
     Text[Style[ToString[Round[v]], 44, Bold, col], {gc, gmax + 34}, {0, 0}],
     Text[Style["ppm CO\:2082", 14, Bold, col], {gc, gmax + 12}, {0, 0}],
     Text[Style[If[isMod, "TODAY", ToString[Round[age]] <> " kyr ago"], 17, Bold, If[isMod, IceViz`ModernColor, IceViz`InkColor]], {gc, gmin - 18}, {0, 0}],
     Text[Style["natural\nceiling", 9.5, Italic, GrayLevel[0.4]], {gx1 + 0.14, ceil}, {-1, 0}],
     (* sparkline panel, scaled placement *)
     Inset[Graphics[{
        Directive[IceViz`GlacialShade, Opacity[0.35]], Rectangle[{0, IceViz`NaturalMin}, {800, ceil}],
        Directive[IceViz`CO2Color, AbsoluteThickness[1.4]], Line[sparkPts],
        If[isMod, {Directive[IceViz`ModernColor, AbsoluteThickness[2.6]], Line[{{798, ceil}, {800, mloMax}}]}, {}],
        Directive[col], Disk[{sx[age], If[isMod, mloMax, v]}, Offset[4.5]]},
        PlotRange -> {{0, 800}, {165, 450}}, AspectRatio -> 0.55, Frame -> True,
        FrameStyle -> GrayLevel[0.55], FrameTicks -> None, Background -> White, PlotRangePadding -> 0],
       Scaled[{0.74, 0.6}], {Center, Center}, Scaled[{0.5, 0.42}]],
     Text[Style["where we are in the 800,000-year record", 10, Italic, GrayLevel[0.45]], {gc + 3.2, gmin - 8}, {0, 0}]},
    PlotRange -> {{-0.6, 5.4}, {gmin - 30, gmax + 52}}, AspectRatio -> 0.6,
    Background -> White, ImageSize -> {760, 470}, ImagePadding -> 6]];

(* sweep ages old->young (logarithmic-ish so recent gets more frames) *)
sweepAges = Reverse@Union[Round[Join[Range[800, 60, -20], Range[60, 2, -3]]]];
sweepAges = Sort[sweepAges, Greater];
modVals = Rescale[Range[1, 10], {0, 10}, {ceil + 5, mloMax}];
frames = Join[frame[#, None] & /@ sweepAges, frame[0.1, #] & /@ modVals, ConstantArray[frame[0.1, mloMax], 5]];
Print["frames: ", Length[frames]];

gif = FileNameJoin[{imgDir, "anim_breakout.gif"}];
Export[gif, frames, "GIF",
   "DisplayDurations" -> Join[ConstantArray[0.1, Length[sweepAges]], ConstantArray[0.14, 10], {2.2}, ConstantArray[0.3, 4]],
   AnimationRepetitions -> Infinity];
Print["wrote ", gif, "  ", Round[FileByteCount[gif]/1024], " KB"];
Export[FileNameJoin[{imgDir, "anim_breakout_still.png"}], Last[frames], ImageResolution -> 130];
