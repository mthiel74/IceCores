#!/usr/bin/env wolframscript
(* ::Package:: *)

(* ORBITAL — the Milankovitch pacemakers.
   The La2004 orbital solution: eccentricity (~100/400 kyr), obliquity
   (~41 kyr), climatic precession (~23 kyr), and the 65 N summer-solstice
   daily-mean insolation computed from them (Berger 1978), shown above
   the ice-core temperature record so the orbital pacing is visible. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

orb = IceData`LoadOrbital[]; tmp = IceData`LoadTemp[];
xt[age_] := 800 - age;
ageTk = Table[{xt[a], If[a == 0, "0", ToString[a]]}, {a, 0, 800, 100}];

(* ---- 65N summer-solstice daily-mean insolation (Berger 1978) ---- *)
s0 = 1361.; phi = 65. Degree; lam = 90. Degree;   (* NH summer solstice *)
insol[ecc_, oblDeg_, periDeg_] := Module[{eps, peri, sinDecl, decl, dist, cosH0, h0},
   eps = oblDeg Degree; peri = periDeg Degree;
   sinDecl = Sin[eps] Sin[lam]; decl = ArcSin[sinDecl];
   (* a/r at solar longitude lam; the +180 deg puts NH summer solstice near
      APHELION today (perihelion is early January), giving the correct
      ~479 W/m^2 rather than ~510. *)
   dist = (1 - ecc Cos[lam - peri])/(1 - ecc^2);    (* a/r *)
   cosH0 = -Tan[phi] Tan[decl];
   h0 = Which[cosH0 >= 1, 0., cosH0 <= -1, Pi, True, ArcCos[cosH0]];
   (s0/Pi) dist^2 (h0 Sin[phi] Sin[decl] + Cos[phi] Cos[decl] Sin[h0])];

insolSeries = MapThread[insol, {orb["ecc"], orb["obliquity"], orb["perihelion"]}];
Print["65N summer insolation: modern=", Round[First@insolSeries, 1],
   " W/m^2,  range=", Round[MinMax@insolSeries, 1]];

mk[xy_, col_, lab_, opts___] := ListLinePlot[xy,
   PlotStyle -> Directive[col, AbsoluteThickness[1.4]],
   Filling -> Bottom, FillingStyle -> Directive[col, Opacity[0.12]],
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[0.9]],
   FrameTicks -> {{Automatic, None}, {ageTk, None}},
   FrameLabel -> {None, lab}, Background -> White,
   LabelStyle -> Directive[FontFamily -> "Helvetica", 10, IceViz`InkColor],
   GridLines -> {Table[xt[a], {a, 0, 800, 100}], None},
   GridLinesStyle -> Directive[GrayLevel[0.85], Dashing[{1, 3}]],
   PlotRange -> {{0, 800}, All}, AspectRatio -> 0.13, ImageSize -> 1300,
   ImagePadding -> {{72, 12}, {2, 8}}, opts];

ecc = mk[{xt[#[[1]]], #[[2]]} & /@ Transpose[{orb["age_kyr"], orb["ecc"]}], IceViz`Accent, "eccentricity\n(~100 kyr)"];
obl = mk[{xt[#[[1]]], #[[2]]} & /@ Transpose[{orb["age_kyr"], orb["obliquity"]}], RGBColor[0.3,0.55,0.3], "obliquity \[Degree]\n(~41 kyr)"];
pre = mk[{xt[#[[1]]], #[[2]]} & /@ Transpose[{orb["age_kyr"], orb["precession"]}], RGBColor[0.55,0.4,0.7], "precession\n(~23 kyr)"];
ins = mk[{xt[#[[1]]], #[[2]]} & /@ Transpose[{orb["age_kyr"], insolSeries}], IceViz`ModernColor, "65\[Degree]N summer\ninsol. W/m\.b2"];
tsm = IceViz`SmoothSeries[Transpose[{tmp["age_kyr"], tmp["dT"]}], 4];
tp = mk[{xt[#[[1]]], #[[2]]} & /@ Select[tsm, #[[1]] <= 800 &], IceViz`TempColor, "Antarctic\n\[CapitalDelta]T \[Degree]C",
   FrameTicks -> {{Automatic, None}, {ageTk, None}},
   FrameLabel -> {"thousands of years before present", "Antarctic\n\[CapitalDelta]T \[Degree]C"},
   ImagePadding -> {{72, 12}, {34, 8}}, AspectRatio -> 0.16];

out = Column[{
   Style["The orbital pacemakers vs the climate response", 15, Bold, Darker[IceViz`Accent, 0.2], FontFamily -> "Helvetica"],
   ecc, obl, pre, ins, tp}, Spacings -> {0, {1.4, 0.2, 0.2, 0.2, 0.2}}, Alignment -> Left];

Export[FileNameJoin[{imgDir, "orbital.png"}], out, ImageResolution -> 200];
Print["wrote orbital.png  ", FileByteCount[FileNameJoin[{imgDir, "orbital.png"}]], " B"];
