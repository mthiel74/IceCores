#!/usr/bin/env wolframscript
(* ::Package:: *)

(* LEAD / LAG — does CO2 lead or follow temperature?
   Two standard tools applied to the resampled records:
     (left)  lagged cross-correlation rho(tau)
     (right) cross-spectral phase -> lag at each Milankovitch band, with
             coherence
   The honest punchline: both put the lag within ~1 kyr of zero, which is
   ALSO the size of the gas-age/ice-age (Delta-age) chronological offset.
   So these two records (on different age scales) show tight in-phase
   coupling but CANNOT resolve the true centennial lead/lag — that needs
   same-core, synchronised proxies (see notebook text). *)

dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "load_data.wl"}]];
Get[FileNameJoin[{dir, "viz_common.wl"}]];
imgDir = FileNameJoin[{ParentDirectory[dir], "docs", "images"}];

co2 = IceData`LoadCO2[]; tmp = IceData`LoadTemp[];
dt = 0.5;
{ag, c} = IceViz`ResampleGrid[co2["age_kyr"], co2["co2"], {2, 800, dt}];
{ag2, t} = IceViz`ResampleGrid[tmp["age_kyr"], tmp["dT"], {2, 800, dt}];
std[x_] := (x - Mean[x])/StandardDeviation[x];
(* ResampleGrid returns arrays ordered by age (recent -> old). Reverse to
   FORWARD time (old -> recent) so a positive lag = CO2 best matches FUTURE
   temperature = CO2 leads. Without this the lead/lag direction is inverted. *)
c = Reverse[std[c]]; t = Reverse[std[t]]; n = Length[c];

(* ---- lagged cross-correlation: corr(CO2[i], T[i+k]) ----
   k>0 (lag>0) => CO2 today best matches FUTURE temperature => CO2 LEADS *)
xcorr[k_] := If[k >= 0, Correlation[c[[1 ;; n - k]], t[[1 + k ;; n]]],
                        Correlation[c[[1 - k ;; n]], t[[1 ;; n + k]]]];
ks = Range[-30, 30]; lags = ks dt; vals = xcorr /@ ks;
bestLag = lags[[First@Ordering[vals, -1]]];
Print["zero-lag r = ", Round[xcorr[0], 0.001], ";  peak r = ", Round[Max[vals], 0.001], " at lag ", bestLag, " kyr"];

dage = 1.0;  (* illustrative +/-1 kyr chronological-resolution band, kyr *)
xc = ListLinePlot[Transpose[{lags, vals}],
   PlotStyle -> Directive[IceViz`InkColor, AbsoluteThickness[2]],
   Filling -> Axis, FillingStyle -> Directive[IceViz`Accent, Opacity[0.12]],
   PlotRange -> {{-15, 15}, {-0.2, 1}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
   FrameLabel -> {"lag (kyr)", "correlation"}, PlotLabel -> Style["Lagged cross-correlation", 13, Bold, IceViz`InkColor],
   Background -> White, AspectRatio -> 0.8, ImageSize -> 560,
   GridLines -> {{0}, {}}, GridLinesStyle -> Directive[GrayLevel[0.7]],
   Prolog -> {Directive[RGBColor[0.8, 0.45, 0.1], Opacity[0.16]], Rectangle[{-dage, -1}, {dage, 2}]},
   Epilog -> {Directive[IceViz`CO2Color], Disk[{bestLag, Max[vals]}, Offset[3.5]],
     Directive[FontFamily -> "Helvetica"],
     Text[Style["peak r = " <> ToString[Round[Max[vals], 0.01]] <> "\nat " <> ToString[bestLag] <> " kyr", 11, Bold, IceViz`CO2Color], {3.2, 0.83}, {-1, 1}],
     Text[Style["\[LeftArrow] CO\:2082 lags", 10, GrayLevel[0.4]], {-13.5, -0.13}, {-1, 0}],
     Text[Style["CO\:2082 leads \[RightArrow]", 10, GrayLevel[0.4]], {13.5, -0.13}, {1, 0}],
     Text[Style["\[PlusMinus]1 kyr chronology", 9, Italic, RGBColor[0.7, 0.4, 0.05]], {0, 0.97}, {0, 1}]},
   ImagePadding -> {{54, 14}, {40, 28}}, LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor]];

(* ---- cross-spectrum: smoothed Pxx, Pyy, Pxy -> coherence + phase ---- *)
w = 0.5 (1 - Cos[2 Pi Range[0, n - 1]/(n - 1)]);
Fc = Fourier[c w, FourierParameters -> {-1, 1}]; Ft = Fourier[t w, FourierParameters -> {-1, 1}];
sm[x_] := GaussianFilter[x, 6];
half = Floor[n/2];
Pxx = sm[Abs[Fc]^2][[2 ;; half]]; Pyy = sm[Abs[Ft]^2][[2 ;; half]];
Pxy = sm[Fc Conjugate[Ft]][[2 ;; half]];   (* complex, smoothed *)
freqs = (Range[0, n - 1]/(n dt))[[2 ;; half]];
per = 1/freqs;
coh = Abs[Pxy]^2/(Pxx Pyy);
phase = Arg[Pxy];
(* With FourierParameters {-1,1} (forward-time arrays), a delay of temperature
   relative to CO2 gives phase<0, so negate to make lag>0 == CO2 leads,
   matching the cross-correlation panel's convention. *)
lagOf = -phase/(2 Pi) per;

bandPer = {100., 41., 23.};
idxOf[p0_] := First@Ordering[Abs[per - p0], 1];
Do[Print["  ", Round[bandPer[[i]]], " kyr:  coherence ", Round[coh[[idxOf[bandPer[[i]]]]], 0.01],
    ",  lag ", Round[lagOf[[idxOf[bandPer[[i]]]]], 0.1], " kyr"], {i, 3}];

bandPts = Table[{Log[bandPer[[i]]], lagOf[[idxOf[bandPer[[i]]]]]}, {i, 3}];
cohPts = Table[coh[[idxOf[bandPer[[i]]]]], {i, 3}];
pTicks = {Log[#], ToString[#]} & /@ {23, 41, 100};

phasePlot = ListPlot[Callout[bandPts[[#]],
     Style[ToString[Round[bandPer[[#]]]] <> " kyr\n\[Gamma]\.b2=" <> ToString[Round[cohPts[[#]], 0.01]], 10, Bold, IceViz`Accent], Above] & /@ {1, 2, 3},
   PlotStyle -> Directive[IceViz`Accent, PointSize[0.03]],
   PlotRange -> {{Log[19], Log[140]}, {-6, 6}},
   Frame -> True, FrameStyle -> Directive[IceViz`InkColor, AbsoluteThickness[1]],
   FrameTicks -> {{Automatic, None}, {pTicks, None}},
   FrameLabel -> {"period (kyr)", "phase lag (kyr)"}, PlotLabel -> Style["Cross-spectral phase", 13, Bold, IceViz`InkColor],
   Background -> White, AspectRatio -> 0.8, ImageSize -> 560,
   GridLines -> {Log /@ bandPer, {0}}, GridLinesStyle -> Directive[GrayLevel[0.82], Dashing[{2, 3}]],
   Prolog -> {Directive[RGBColor[0.8, 0.45, 0.1], Opacity[0.16]], Rectangle[{Log[19], -dage}, {Log[140], dage}]},
   Epilog -> {Directive[FontFamily -> "Helvetica"],
     Text[Style["in phase", 10, Italic, GrayLevel[0.4]], {Log[125], 0.5}, {1, 0}],
     Text[Style["\[PlusMinus]1 kyr chronology", 9, Italic, RGBColor[0.7, 0.4, 0.05]], {Log[21], dage + 0.4}, {-1, 0}],
     Text[Style["\[Gamma]\.b2 = coherence", 9, Italic, GrayLevel[0.45]], {Log[125], -5.4}, {1, 0}]},
   ImagePadding -> {{54, 14}, {40, 28}}, LabelStyle -> Directive[FontFamily -> "Helvetica", 11, IceViz`InkColor]];

out = GraphicsRow[{xc, phasePlot}, Spacings -> 10, ImageSize -> 1240];
Export[FileNameJoin[{imgDir, "leadlag.png"}], out, ImageResolution -> 200];
Print["wrote leadlag.png  ", Round[FileByteCount[FileNameJoin[{imgDir, "leadlag.png"}]]/1024], " KB"];
