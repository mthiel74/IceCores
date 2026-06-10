#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ANIMATION 1 — the 800 kyr sweep.
   A cursor travels from 800 kyr ago to the present, drawing the CO2
   record (with a temperature silhouette) as it goes, with a live
   readout. When it reaches the present the instrumental record shoots
   off the top of the chart to today's ~427 ppm. Exported as GIF
   (Wolfram Community plays AnimatedImage; it drops Video). *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; tmp = IceData`LoadTemp[]; mlo = IceData`LoadModernMLO[];
xt[age_] := 800 - age;
ymin = 165; ymax = 448;

natPts = SortBy[{xt[#[[1]]], #[[2]]} & /@ IceViz`SmoothSeries[Select[Transpose[{co2["age_kyr"], co2["co2"]}], # [[1]] >= 0.2 &], 2], First];
recent = Select[Transpose[{co2["age_kyr"], co2["co2"]}], #[[1]] < 0.6 &];
mloPts = Transpose[{IceData`YearToKyrBP /@ mlo["year"], mlo["co2"]}];
breakout = SortBy[{xt[#[[1]]], #[[2]]} & /@ Select[Join[recent, mloPts], #[[1]] <= 0.6 &], First];

tband = {173, 300}; {dTlo, dThi} = {-11., 6.};
mapT[v_] := Rescale[v, {dTlo, dThi}, tband];
tLine = SortBy[{xt[#[[1]]], mapT[#[[2]]]} & /@ IceViz`SmoothSeries[Transpose[{tmp["age_kyr"], tmp["dT"]}], 3], First];
fCO2 = Interpolation[natPts, InterpolationOrder -> 1];

base = {Raster[{{{0.91, 0.95, 0.99}}, {{1, 1, 1}}}, {{0, ymin}, {800, ymax}}],
   Directive[IceViz`GlacialShade, Opacity[0.3]], Rectangle[{0, IceViz`NaturalMin}, {800, IceViz`NaturalMax}],
   Directive[IceViz`InkColor, Opacity[0.35], AbsoluteThickness[1], Dashing[{6, 6}]],
   Line[{{0, IceViz`NaturalMax}, {800, IceViz`NaturalMax}}]};

frame[cx_, spikeFrac_] := Module[{rev, cursAge, curCO2, tShown, bShown},
   rev = Select[natPts, #[[1]] <= cx &];
   tShown = Select[tLine, #[[1]] <= cx &];
   cursAge = 800 - cx; curCO2 = fCO2[Clip[cx, {natPts[[1, 1]], natPts[[-1, 1]]}]];
   bShown = If[spikeFrac > 0, Take[breakout, Max[2, Ceiling[spikeFrac Length[breakout]]]], {}];
   Graphics[{base,
     Directive[IceViz`TempColor, Opacity[0.13]],
     If[Length[tShown] > 2, Polygon[Join[{{tShown[[1, 1]], tband[[1]]}}, tShown, {{tShown[[-1, 1]], tband[[1]]}}]], {}],
     Directive[IceViz`TempColor, Opacity[0.5], AbsoluteThickness[1]], Line[tShown],
     Directive[IceViz`CO2Color, Opacity[0.16], AbsoluteThickness[8], CapForm["Round"]], Line[rev],
     Directive[IceViz`CO2Color, AbsoluteThickness[2], CapForm["Round"]], Line[rev],
     If[Length[bShown] > 1, {Directive[IceViz`ModernColor, AbsoluteThickness[3], CapForm["Round"]], Line[bShown],
        Directive[IceViz`ModernColor], Disk[bShown[[-1]], {7, 4}], White, Disk[bShown[[-1]], {2.4, 1.3}]}, {}],
     (* cursor *)
     If[spikeFrac == 0, {Directive[IceViz`InkColor, Opacity[0.5], AbsoluteThickness[1.2]],
        Line[{{cx, ymin}, {cx, ymax}}], IceViz`CO2Color, Disk[{cx, curCO2}, {6, 3.6}]}, {}],
     (* readout *)
     Directive[FontFamily -> "Helvetica"],
     Text[Style[If[spikeFrac > 0, "TODAY", ToString[Round[cursAge]] <> " kyr ago"], 20, Bold, If[spikeFrac > 0, IceViz`ModernColor, IceViz`InkColor]], {40, 430}, {-1, 1}],
     Text[Style[Row[{Round[If[spikeFrac > 0, IceViz`ModernCO2, curCO2]], " ppm CO\:2082"}], 16, Bold, If[spikeFrac > 0, IceViz`ModernColor, IceViz`CO2Color]], {40, 412}, {-1, 1}],
     Text[Style["800,000 years of CO\:2082", 13, Italic, GrayLevel[0.4]], {760, 178}, {1, 0}]},
    PlotRange -> {{0, 800}, {ymin, ymax}}, AspectRatio -> 0.5,
    Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
    FrameTicks -> {{Range[200, 400, 50], None}, {Table[{xt[a], ToString[a]}, {a, 0, 800, 200}], None}},
    FrameLabel -> {"thousands of years before present", "CO\:2082 (ppm)"}, Background -> White,
    LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor],
    ImageSize -> {760, 430}, ImagePadding -> {{52, 14}, {38, 10}}]];

nRev = 44; nSpike = 9; nHold = 5;
cxs = Rescale[Range[0, nRev], {0, nRev}, {natPts[[1, 1]], 800}];
frames = Join[
   frame[#, 0] & /@ cxs,
   frame[800, #] & /@ Rescale[Range[1, nSpike], {0, nSpike}, {0, 1}],
   ConstantArray[frame[800, 1], nHold]];
Print["frames: ", Length[frames]];

gif = FileNameJoin[{imgDir, "anim_sweep.gif"}];
Export[gif, frames, "GIF", "DisplayDurations" -> Join[ConstantArray[0.09, nRev + 1], ConstantArray[0.13, nSpike], {2.0}, ConstantArray[0.3, nHold - 1]], AnimationRepetitions -> Infinity];
Print["wrote ", gif, "  ", Round[FileByteCount[gif]/1024], " KB"];
Export[FileNameJoin[{imgDir, "anim_sweep_still.png"}], Last[frames], ImageResolution -> 130];
