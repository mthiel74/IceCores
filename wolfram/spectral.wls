#!/usr/bin/env wolframscript
(* ::Package:: *)

(* SPECTRAL — the orbital fingerprint.
   Power spectra of the CO2 and Antarctic-temperature records. Each
   record is first put on an even 2-kyr grid (the raw cores are densest
   in their youngest part), linearly detrended and Hann-windowed, then a
   periodogram is taken via the FFT. The Milankovitch bands (100 / 41 /
   23 kyr) are shaded so the eccentricity, obliquity and precession
   peaks are unmistakable. *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; tmp = IceData`LoadTemp[];

(* windowed-FFT power spectrum of an evenly sampled, detrended series *)
spectrum[ages_, vals_] := Module[{dt, n, y, w, p, freqs, half},
   dt = ages[[2]] - ages[[1]]; n = Length[vals];
   y = vals - (Fit[Transpose[{ages, vals}], {1, x}, x] /. x -> # & /@ ages);
   w = 0.5 (1 - Cos[2 Pi Range[0, n - 1]/(n - 1)]);          (* Hann *)
   p = Abs[Fourier[y w, FourierParameters -> {-1, 1}]]^2;
   freqs = Range[0, n - 1]/(n dt);
   half = Floor[n/2];
   Select[Transpose[{1/freqs[[2 ;; half]], p[[2 ;; half]]}], 14 <= #[[1]] <= 320 &]];

{agC, vC} = IceViz`ResampleGrid[co2["age_kyr"], co2["co2"], {2, 800, 2}];
{agT, vT} = IceViz`ResampleGrid[tmp["age_kyr"], tmp["dT"], {2, 800, 2}];
sCO2 = spectrum[agC, vC]; sT = spectrum[agT, vT];
sCO2[[All, 2]] /= Max[sCO2[[All, 2]]];
sT[[All, 2]] /= Max[sT[[All, 2]]];

peakAt[s_] := s[[First@Ordering[s[[All, 2]], -1], 1]];
Print["CO2  dominant period: ", Round[peakAt[sCO2], 1], " kyr"];
Print["Temp dominant period: ", Round[peakAt[sT], 1], " kyr"];

bands = {{80, 125, "100 kyr\neccentricity"}, {37, 47, "41 kyr\nobliquity"}, {18, 26, "23 kyr\nprecession"}};
bandShade = {Directive[IceViz`Accent, Opacity[0.13]],
   Rectangle[{Log[#[[1]]], 0}, {Log[#[[2]]], 100}] & /@ bands};
bandLabel[ymax_] := {Directive[FontFamily -> "Helvetica"],
   Text[Style[#[[3]], 9, Bold, Darker[IceViz`Accent, 0.1]], {Log[Sqrt[#[[1]] #[[2]]]], ymax}, {0, 1}] & /@ bands};
pTicks = {Log[#], ToString[#]} & /@ {20, 23, 41, 60, 100, 150, 230};

panel[s_, col_, lab_] := ListLinePlot[{Log[#[[1]]], #[[2]]} & /@ s,
   PlotStyle -> Directive[col, AbsoluteThickness[1.9]],
   Filling -> Axis, FillingStyle -> Directive[col, Opacity[0.2]], InterpolationOrder -> 2,
   Prolog -> bandShade, Epilog -> bandLabel[1.05],
   PlotRange -> {{Log[15], Log[300]}, {0, 1.12}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
   FrameTicks -> {{Automatic, None}, {pTicks, None}},
   FrameLabel -> {"period (kyr)", "relative power"},
   PlotLabel -> Style[lab, 13, Bold, col], Background -> White,
   GridLines -> {Log /@ {23, 41, 100}, None},
   GridLinesStyle -> Directive[GrayLevel[0.8], Dashing[{2, 3}]],
   LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor],
   AspectRatio -> 0.55, ImageSize -> 640, ImagePadding -> {{52, 12}, {42, 26}}];

out = GraphicsRow[{panel[sCO2, IceViz`CO2Color, "CO\:2082"],
                   panel[sT, IceViz`TempColor, "Antarctic temperature"]},
   Spacings -> 6, ImageSize -> 1300];

Export[FileNameJoin[{imgDir, "spectral.png"}], out, ImageResolution -> 200];
Print["wrote spectral.png  ", FileByteCount[FileNameJoin[{imgDir, "spectral.png"}]], " B"];
