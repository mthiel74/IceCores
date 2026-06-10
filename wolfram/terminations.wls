#!/usr/bin/env wolframscript
(* ::Package:: *)

(* TERMINATIONS — seeing the lead/lag directly.
   Zoom into the two most recent deglaciations (Termination I, the last
   ice age -> Holocene; Termination II, the penultimate) and overlay CO2
   and Antarctic temperature, each normalised 0..1 within the window, so
   the eye can judge which rises first. They rise essentially TOGETHER at
   ice-core resolution; the residual offset is within the gas-age/ice-age
   (Delta-age) uncertainty, which is why our two records (on different age
   scales) cannot settle the centennial order. Same-core studies can:
   CO2 within ~0+/-200 yr of Antarctic T (Parrenin 2013), and CO2 leading
   GLOBAL temperature (Shakun 2012). *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; tmp = IceData`LoadTemp[];
co2P = Transpose[{co2["age_kyr"], co2["co2"]}];
tmpP = Transpose[{tmp["age_kyr"], tmp["dT"]}];

(* Put BOTH series on the same 0.25-kyr grid and apply the SAME ~1-kyr
   Gaussian smoothing, so neither is filtered more than the other -- an
   unequal smooth could artificially align (or offset) the two curves. *)
panel[{a0_, a1_}, label_] := Module[{cg, cv, tg, tv, cn, tn, xw},
   xw[age_] := a1 - age;                              (* old left, young right *)
   {cg, cv} = IceViz`ResampleGrid[co2P[[All, 1]], co2P[[All, 2]], {a0, a1, 0.25}];
   {tg, tv} = IceViz`ResampleGrid[tmpP[[All, 1]], tmpP[[All, 2]], {a0, a1, 0.25}];
   cv = GaussianFilter[cv, 4]; tv = GaussianFilter[tv, 4];
   cn = Transpose[{xw /@ cg, Rescale[cv]}];
   tn = Transpose[{xw /@ tg, Rescale[tv]}];
   Graphics[{
     Directive[IceViz`TempColor, Opacity[0.2], AbsoluteThickness[7], CapForm["Round"]], Line[tn],
     Directive[IceViz`TempColor, AbsoluteThickness[2.2]], Line[tn],
     Directive[IceViz`CO2Color, AbsoluteThickness[2.6]], Line[cn],
     Directive[FontFamily -> "Helvetica"],
     Text[Style["  CO\:2082  ", 13, Bold, IceViz`CO2Color, Background -> GrayLevel[1, 0.7]], {(a1 - a0)*0.16, 0.96}, {0, 0}],
     Text[Style["  Antarctic temperature  ", 12, Bold, IceViz`TempColor, Background -> GrayLevel[1, 0.7]], {(a1 - a0)*0.62, 0.12}, {0, 0}]},
     PlotRange -> {{0, a1 - a0}, {-0.05, 1.08}}, AspectRatio -> 0.78,
     Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
     FrameTicks -> {{None, None}, {Table[{xw[a], ToString[a]}, {a, Ceiling[a0/5]*5, a1, 5}], None}},
     FrameLabel -> {"thousands of years before present", "normalised (0\[Dash]1)"},
     PlotLabel -> Style[label, 13, Bold, IceViz`InkColor], Background -> White,
     LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor],
     ImageSize -> 560, ImagePadding -> {{50, 12}, {40, 26}}]];

out = GraphicsRow[{
   panel[{5, 25}, "Termination I  (last deglaciation)"],
   panel[{120, 142}, "Termination II  (penultimate)"]},
   Spacings -> 12, ImageSize -> 1240];

Export[FileNameJoin[{imgDir, "terminations.png"}], out, ImageResolution -> 200];
Print["wrote terminations.png  ", Round[FileByteCount[FileNameJoin[{imgDir, "terminations.png"}]]/1024], " KB"];
