#!/usr/bin/env wolframscript
(* ::Package:: *)

(* MODERN — the speed of the spike.
   Zoom on the last 24 kyr: the natural deglacial CO2 rise (~190 -> ~280
   ppm over ~10,000 years) followed by the instrumental blade to ~427
   ppm in ~150 years. Rates annotated to make the contrast visceral. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; mlo = IceData`LoadModernMLO[];

(* x = years before present (1950); 0 at right. use kyr for axis *)
xt[ageKyr_] := 24 - ageKyr;            (* 24 kyr ago -> 0 ; present -> 24 *)
ice = Select[Transpose[{co2["age_kyr"], co2["co2"]}], #[[1]] <= 24.2 &];
ice = SortBy[ice, First];
icePts = {xt[#[[1]]], #[[2]]} & /@ ice;
modPts = SortBy[{xt[IceData`YearToKyrBP[#[[1]]]], #[[2]]} & /@ Transpose[{mlo["year"], mlo["co2"]}], First];

(* deglacial rate: from ~18 kyr (190 ppm) to ~11 kyr (265 ppm) *)
fI = Interpolation[ice, InterpolationOrder -> 1];
degRate = (fI[11] - fI[18])/((18 - 11)*1000);     (* ppm per yr *)
modRate = (Last[mlo["co2"]] - 280)/(IceViz`ModernYear - 1850.);
Print["deglacial rate \[TildeTilde] ", Round[degRate, 0.001], " ppm/yr"];
Print["industrial rate \[TildeTilde] ", Round[modRate, 0.01], " ppm/yr  (",
   Round[modRate/degRate], "x faster)"];

ageTk = Table[{xt[a], If[a == 0, "0", ToString[a]]}, {a, 0, 24, 4}];

g = Graphics[{
   Directive[IceViz`GlacialShade, Opacity[0.3]], Rectangle[{0, IceViz`NaturalMin}, {24, IceViz`NaturalMax}],
   Directive[IceViz`InkColor, Opacity[0.4], Dashing[{6, 6}], AbsoluteThickness[1]],
   Line[{{0, IceViz`NaturalMax}, {24, IceViz`NaturalMax}}],
   (* ice-core deglacial rise *)
   Directive[IceViz`CO2Color, Opacity[0.16], AbsoluteThickness[9], CapForm["Round"]], Line[icePts],
   Directive[IceViz`CO2Color, AbsoluteThickness[2.2], CapForm["Round"]], Line[icePts],
   (* instrumental blade *)
   Directive[IceViz`ModernColor, Opacity[0.18], AbsoluteThickness[9], CapForm["Round"]], Line[modPts],
   Directive[IceViz`ModernColor, AbsoluteThickness[2.6], CapForm["Round"]], Line[modPts],
   Directive[IceViz`ModernColor], Disk[{Last[modPts][[1]], Last[modPts][[2]]}, {0.16, 5}],
   White, Disk[{Last[modPts][[1]], Last[modPts][[2]]}, {0.05, 1.6}],
   Directive[FontFamily -> "Helvetica"],
   Text[Style[Row[{Round[IceViz`ModernCO2], " ppm \[Bullet] ", IceViz`ModernYear}], 14, Bold, IceViz`ModernColor], {24, Last[modPts][[2]]}, {1.05, 0}],
   Text[Style["  end of last ice age  \n  ~0.01 ppm / yr  ", 12, Bold, IceViz`CO2Color, Background -> GrayLevel[1, 0.7]], {7, 300}, {0, -1}],
   Text[Style[Row[{"  recent rise \[Bullet] \[TildeTilde] ", Round[modRate/degRate], "\[Times] faster  "}], 13, Bold, IceViz`ModernColor, Background -> GrayLevel[1, 0.75]], {19, 360}, {1, 0}],
   Text[Style["  natural interglacial ceiling  ", 11, Italic, GrayLevel[0.35], Background -> GrayLevel[1, 0.6]], {12, IceViz`NaturalMax + 6}, {0, 0}]},
   PlotRange -> {{0, 24}, {180, 440}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1.1]],
   FrameTicks -> {{Range[200, 420, 40], None}, {ageTk, None}},
   FrameLabel -> {"thousands of years before present (1950)", "CO\:2082 (ppm)"},
   Background -> White,
   LabelStyle -> Directive[FontFamily -> "Helvetica", 12, IceViz`InkColor],
   AspectRatio -> 0.5, ImageSize -> 1100, ImagePadding -> {{58, 70}, {44, 14}}];

Export[FileNameJoin[{imgDir, "modern.png"}], g, ImageResolution -> 200];
Print["wrote modern.png  ", FileByteCount[FileNameJoin[{imgDir, "modern.png"}]], " B"];
