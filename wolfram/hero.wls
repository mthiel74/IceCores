#!/usr/bin/env wolframscript
(* ::Package:: *)

(* HERO — "the modern breakout".
   800 kyr of ice-core CO2 sitting inside its natural band, with the
   instrumental record rocketing off the top of the chart to today's
   ~427 ppm. Temperature shown as a cool silhouette behind. Designed as
   the thumbnail: title baked in, readable small.
   x is displayed as xt = 800 - age so PRESENT is at the RIGHT edge
   (past -> present reads left -> right) and the spike has room. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; tmp = IceData`LoadTemp[]; mlo = IceData`LoadModernMLO[];

xt[age_] := 800 - age;                          (* present (age 0) -> 800 (right) *)
xmin = 0; xmax = 800; ymin = 165; ymax = 448;

(* natural ice-core curve: pre-industrial only (older than ~1750 AD = 0.2 kyr BP) *)
natPts = Select[Transpose[{co2["age_kyr"], co2["co2"]}], #[[1]] >= 0.2 &];
natPts = IceViz`SmoothSeries[natPts, 2];
natPts = {xt[#[[1]]], #[[2]]} & /@ natPts;

(* modern breakout: recent composite tail + instrumental Mauna Loa *)
recent = Select[Transpose[{co2["age_kyr"], co2["co2"]}], #[[1]] < 0.6 &];
mloPts = Transpose[{IceData`YearToKyrBP /@ mlo["year"], mlo["co2"]}];
breakout = SortBy[Select[Join[recent, mloPts], #[[1]] <= 0.6 &], First];
breakout = {xt[#[[1]]], #[[2]]} & /@ breakout;   (* climbs toward right edge *)

(* temperature silhouette mapped into a lower strip *)
tband = {173, 300}; {dTlo, dThi} = {-11., 6.};
mapT[v_] := Rescale[v, {dTlo, dThi}, tband];
tLine = {xt[#[[1]]], mapT[#[[2]]]} & /@
         Select[IceViz`SmoothSeries[Transpose[{tmp["age_kyr"], tmp["dT"]}], 3], xmin <= #[[1]] <= xmax &];
tLine = SortBy[tLine, First];
tPoly = Join[{{xmin, tband[[1]]}}, tLine, {{xmax, tband[[1]]}}];
tempTicks = Table[{mapT[v], ToString[v] <> "\[Degree]C"}, {v, {-8, -4, 0, 4}}];

todayY = IceViz`ModernCO2;
glow[col_, pts_, w_] := {Directive[col, Opacity[0.16], AbsoluteThickness[w + 7], CapForm["Round"], JoinForm["Round"]], Line[pts],
                          Directive[col, AbsoluteThickness[w], CapForm["Round"], JoinForm["Round"]], Line[pts]};

hero = Graphics[{
   (* icy gradient backdrop *)
   Raster[{{{0.91,0.95,0.99}},{{1,1,1}}}, {{xmin, ymin}, {xmax, ymax}}],
   (* natural CO2 band *)
   Directive[IceViz`GlacialShade, Opacity[0.32]],
   Rectangle[{xmin, IceViz`NaturalMin}, {xmax, IceViz`NaturalMax}],
   (* temperature silhouette behind *)
   Directive[IceViz`TempColor, Opacity[0.13]], Polygon[tPoly],
   Directive[IceViz`TempColor, Opacity[0.5], AbsoluteThickness[1]], Line[tLine],
   (* natural-ceiling guide *)
   Directive[IceViz`InkColor, Opacity[0.4], AbsoluteThickness[1], Dashing[{6, 6}]],
   Line[{{xmin, IceViz`NaturalMax}, {xmax, IceViz`NaturalMax}}],
   (* ice-core CO2 curve *)
   glow[IceViz`CO2Color, natPts, 2.4],
   (* the breakout spike *)
   glow[IceViz`ModernColor, breakout, 3.4],
   (* leap arrow: from the natural ceiling up to today *)
   Directive[IceViz`ModernColor, Opacity[0.55], AbsoluteThickness[1.4], Arrowheads[0.022]],
   Arrow[{{xmax - 30, IceViz`NaturalMax + 4}, {xmax - 30, todayY - 8}}],
   (* today marker at right edge *)
   Directive[IceViz`ModernColor, Opacity[0.22]], Disk[{xmax, todayY}, {16, 9}],
   Directive[IceViz`ModernColor], Disk[{xmax, todayY}, {6, 3.4}],
   White, Disk[{xmax, todayY}, {2.1, 1.2}],

   (* ---- annotations ---- *)
   Directive[FontFamily -> "Helvetica"],
   Text[Style[Row[{Round[IceViz`ModernCO2], " ppm"}], 17, Bold, IceViz`ModernColor], {xmax - 20, todayY + 16}, {1, 0}],
   Text[Style[Row[{IceViz`ModernYear, " \[Bullet] TODAY"}], 13, Bold, IceViz`ModernColor], {xmax - 20, todayY + 3}, {1, 0}],
   Text[Style["  +128 ppm above anything  \n  in 800,000 years  ", 13, Bold, IceViz`ModernColor, Background -> GrayLevel[1, 0.72]], {xmax - 48, 360}, {1, 0}],
   Text[Style["  natural range over 800,000 years  ", 13, Italic, GrayLevel[0.32], Background -> GrayLevel[1, 0.6]], {300, 236}],
   Text[Style["  8 glacial\[Dash]interglacial cycles  ", 12, Bold, IceViz`CO2Color, Background -> GrayLevel[1, 0.6]], {300, 178}],
   Text[Style["  Antarctic temperature  ", 11, IceViz`TempColor, Background -> GrayLevel[1, 0.55]], {310, 207}],
   (* baked-in title block, top-left *)
   Directive[Darker[IceViz`Accent, 0.28]], Rectangle[{14, 426}, {past = 168, 429}],
   Text[Style["800,000 YEARS OF CO\:2082", 34, Bold, Darker[IceViz`Accent, 0.28], FontFamily -> "Helvetica"], {12, 442}, {-1, 1}],
   Text[Style["where today's air sits in the entire ice-core record", 14.5, Darker[IceViz`Accent, 0.05], FontFamily -> "Helvetica"], {14, 419}, {-1, 1}]
   },
   PlotRange -> {{xmin, xmax}, {ymin, ymax}},
   AspectRatio -> 0.52,
   ImagePadding -> {{64, 70}, {46, 18}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1.1]],
   Background -> White,
   FrameLabel -> {"thousands of years before present (1950)", Style["CO\:2082  (ppm)", IceViz`CO2Color]},
   FrameTicks -> {{Automatic, tempTicks},
                  {Table[{xt[a], ToString[a]}, {a, 0, 800, 100}], None}},
   LabelStyle -> Directive[FontFamily -> "Helvetica", 12, IceViz`InkColor],
   ImageSize -> {1400, 740}
];

Export[FileNameJoin[{imgDir, "hero.png"}], hero, ImageResolution -> 200];
Print["wrote hero.png  ", FileByteCount[FileNameJoin[{imgDir, "hero.png"}]], " B"];
