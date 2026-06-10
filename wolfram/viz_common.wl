(* ::Package:: *)

(* Shared visual identity + helpers for every figure script.
   One palette, one plot theme, one definition of the "natural band",
   so the hero, the timeline, the phase plot and the animations all
   look like one coherent piece. *)

BeginPackage["IceViz`"];

CO2Color::usage    = "Crimson family — atmospheric CO2.";
TempColor::usage   = "Blue family — Antarctic temperature anomaly.";
ModernColor::usage = "Bright signal colour — the modern instrumental spike.";
Accent::usage      = "RGBColor[0.153,0.51,0.64] — the blue section accent of the notebook.";
GlacialShade::usage = "Translucent cool fill for glacial intervals.";
InkColor::usage    = "Near-black ink for frames / text.";
PaperColor::usage  = "Warm off-white background.";

NaturalMin::usage = "Lowest natural (pre-industrial) CO2 over 800 kyr, ppm.";
NaturalMax::usage = "Highest natural (interglacial) CO2 over 800 kyr, ppm.";
ModernCO2::usage  = "Latest instrumental annual-mean Mauna Loa CO2, ppm.";
ModernYear::usage = "Year of ModernCO2.";

BaseStyle800::usage = "BaseStyle800[opts] — common Frame/ticks styling for an age axis.";
SmoothSeries::usage = "SmoothSeries[{age,val}, n] — display-only Gaussian smoothing.";
ResampleGrid::usage = "ResampleGrid[ages, vals, {amin,amax,step}] -> {grid, resampled} for spectral work.";
AgeTicks::usage   = "AgeTicks[] -> FrameTicks for 0..800 kyr BP (present at right).";
Titlebar::usage   = "Titlebar[txt, sub] -> a styled hero caption Graphics overlay row.";

Begin["`Private`"];

CO2Color    = RGBColor[0.80, 0.16, 0.13];
TempColor   = RGBColor[0.13, 0.42, 0.67];
ModernColor = RGBColor[0.95, 0.45, 0.05];
Accent      = RGBColor[0.153, 0.51, 0.64];
GlacialShade = RGBColor[0.74, 0.83, 0.92];
InkColor    = RGBColor[0.12, 0.13, 0.15];
PaperColor  = RGBColor[0.985, 0.975, 0.955];

NaturalMin = 173.7;   (* pinned to the Bereiter 2015 pre-industrial range *)
NaturalMax = 298.6;

(* Read the latest instrumental annual mean live from the fetched CSV so it
   never goes stale; fall back to the 2025 value if the file is absent. *)
$vizDir = DirectoryName[$InputFileName];
$mloCsv = FileNameJoin[{ParentDirectory[$vizDir], "data", "modern_co2_mlo.csv"}];
{ModernYear, ModernCO2} = If[FileExistsQ[$mloCsv],
   With[{r = Import[$mloCsv, "CSV"][[-1]]}, {Round[r[[1]]], N[r[[2]]]}],
   {2025, 427.35}];

BaseStyle800[opts___] := Sequence[
   Frame -> True,
   FrameStyle -> Directive[InkColor, AbsoluteThickness[1.1]],
   LabelStyle -> Directive[FontFamily -> "Helvetica", 12, InkColor],
   Background -> PaperColor,
   GridLinesStyle -> Directive[GrayLevel[0.8], AbsoluteThickness[0.4]],
   opts];

(* present (age 0) at the RIGHT, oldest at the LEFT, in kyr BP *)
AgeTicks[] := {
   Table[{a, If[a == 0, "0", ToString[a]]}, {a, 0, 800, 100}],
   Automatic};

SmoothSeries[pts_, n_:5] := Module[{srt = SortBy[pts, First]},
   Transpose[{srt[[All, 1]], GaussianFilter[srt[[All, 2]], n]}]];

ResampleGrid[ages_, vals_, {amin_, amax_, step_}] := Module[
   {f, grid},
   f = Interpolation[Transpose[{ages, vals}], InterpolationOrder -> 1];
   grid = Range[amin, amax, step];
   {grid, f /@ grid}];

End[];
EndPackage[];
