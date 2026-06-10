#!/usr/bin/env wolframscript
(* ::Package:: *)

(* PHASE — the CO2-temperature coupling.
   Antarctic temperature anomaly (x) vs CO2 (y), the 800 kyr trajectory
   coloured by age. The natural climate states form a tight diagonal
   cloud; today's CO2 sits far above the entire historical phase space. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; tmp = IceData`LoadTemp[];

(* common age grid, pre-industrial only *)
{ag, c} = IceViz`ResampleGrid[co2["age_kyr"], co2["co2"], {2, 800, 1}];
{ag2, t} = IceViz`ResampleGrid[tmp["age_kyr"], tmp["dT"], {2, 800, 1}];
pts = Transpose[{t, c}];                 (* {dT, CO2} *)
ages = ag;

cf = ColorData["SunsetColors"];
ncol = Rescale[ages];
line = Line[pts, VertexColors -> (cf /@ ncol)];

(* linear fit for the coupling slope *)
fit = LinearModelFit[pts, x, x];
slope = fit["BestFitParameters"][[2]];
Print["coupling: ", Round[slope, 0.1], " ppm per degC"];

todayT = 0.0; todayCO2 = IceViz`ModernCO2;

g = Graphics[{
   (* fit line *)
   Directive[GrayLevel[0.6], Dashing[{4, 5}], AbsoluteThickness[1]],
   Line[{{-9, fit[-9]}, {4, fit[4]}}],
   (* trajectory *)
   AbsoluteThickness[1.6], line,
   (* today *)
   Directive[IceViz`ModernColor, Opacity[0.25]], Disk[{todayT, todayCO2}, {0.5, 11}],
   Directive[IceViz`ModernColor], Disk[{todayT, todayCO2}, {0.18, 4}],
   White, Disk[{todayT, todayCO2}, {0.06, 1.4}],
   Directive[FontFamily -> "Helvetica"],
   Text[Style[Row[{"TODAY  ", Round[IceViz`ModernCO2], " ppm"}], 13, Bold, IceViz`ModernColor], {todayT - 0.4, todayCO2}, {1, 0}],
   Text[Style["natural states\nglacial \[LongRightArrow] interglacial", 11, Italic, GrayLevel[0.35]], {-7, 263}, {0, 0}],
   Text[Style[Row[{"coupling \[TildeTilde] ", Round[slope], " ppm / \[Degree]C"}], 11, Bold, GrayLevel[0.45]], {2.0, 214}, {0, 0}],
   Text[Style["nothing in 800,000 years\ncomes close to today", 11, Italic, IceViz`ModernColor], {-6.6, 405}, {0, 0}]},
   PlotRange -> {{-10, 4.5}, {165, 445}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1.1]],
   FrameLabel -> {"Antarctic temperature anomaly (\[Degree]C)", "CO\:2082 (ppm)"},
   Background -> White,
   LabelStyle -> Directive[FontFamily -> "Helvetica", 12, IceViz`InkColor],
   GridLines -> {{0}, {IceViz`NaturalMax}},
   GridLinesStyle -> Directive[GrayLevel[0.8], Dashing[{2, 3}]],
   AspectRatio -> 0.85, ImageSize -> 820,
   ImagePadding -> {{60, 18}, {46, 12}},
   Epilog -> Inset[BarLegend[{cf, {0, 800}}, LegendLabel -> Style["age (kyr BP)", 9],
       LabelStyle -> 8.5], Scaled[{0.12, 0.62}], Automatic, Scaled[{0.42, 0.5}]]];

Export[FileNameJoin[{imgDir, "phase.png"}], g, ImageResolution -> 200];
Print["wrote phase.png  ", FileByteCount[FileNameJoin[{imgDir, "phase.png"}]], " B"];
