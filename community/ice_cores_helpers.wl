(* ::Package:: *)

(* Cell builders, the blue "Roboto Condensed" stylesheet (matching the
   reference notebook 125916155.nb) and image / animation embedders for
   community/build_notebook.wls. *)

BeginPackage["IceCells`"];

IceStylesheet::usage = "IceStylesheet[] -> the private Notebook stylesheet (blue accents).";
title; subtitle; sec; sub; subsub; para; abstract; callout; item;
bold; ital; mono; lnk; imath; isub; displayMath; spacer;
imgCell; animCell; figCell; caption; SetImgDir;

Begin["`Private`"];

accent = RGBColor[0.153, 0.51, 0.64];

IceStylesheet[] := Notebook[{
   Cell[StyleData[StyleDefinitions -> "Default.nb"]],
   Cell[StyleData["Text"], CellMargins -> {{27, 10}, {7, 8}}, FontSize -> 13,
      LineSpacing -> {1, 3}],
   Cell[StyleData["Title"], CellMargins -> {{27, 3}, {15, 0}},
      FontFamily -> "Roboto Condensed", FontColor -> accent, FontSize -> 42],
   Cell[StyleData["Subtitle"], CellMargins -> {{27, 3}, {18, 4}},
      FontFamily -> "Roboto Condensed", FontColor -> GrayLevel[0.35], FontSize -> 19],
   Cell[StyleData["Section"], CellMargins -> {{27, 3}, {12, 26}},
      FontFamily -> "Roboto Condensed", FontSize -> 30, FontColor -> accent],
   Cell[StyleData["Subsection"], CellMargins -> {{27, 3}, {8, 18}},
      FontFamily -> "Roboto Condensed", FontColor -> Darker[accent, 0.1], FontSize -> 22],
   Cell[StyleData["Subsubsection"], CellMargins -> {{27, 3}, {8, 12}},
      FontFamily -> "Roboto Condensed", FontColor -> GrayLevel[0.3], FontSize -> 16],
   Cell[StyleData["Item"], CellMargins -> {{40, 10}, {4, 6}}, FontSize -> 13],
   Cell[StyleData["DisplayFormula"], CellMargins -> {{60, 10}, {10, 10}}]},
   Visible -> False, StyleDefinitions -> "PrivateStylesheetFormatting.nb"];

(* ---- headings & text ---- *)
title[t_]    := Cell[t, "Title"];
subtitle[t_] := Cell[t, "Subtitle"];
sec[t_]      := Cell[t, "Section"];
sub[t_]      := Cell[t, "Subsection"];
subsub[t_]   := Cell[t, "Subsubsection"];
para[stuff__] := Cell[TextData[Flatten[{stuff}]], "Text"];
item[stuff__] := Cell[TextData[Flatten[{stuff}]], "Item"];
spacer[]     := Cell["", "Text", CellMargins -> {{0, 0}, {2, 2}}];

abstract[stuff__] := Cell[TextData[Flatten[{stuff}]], "Text",
   FontSize -> 14, CellMargins -> {{40, 40}, {10, 14}},
   Background -> RGBColor[0.95, 0.97, 0.985],
   CellFrame -> {{4, 0}, {0, 0}}, CellFrameColor -> accent,
   CellFrameMargins -> 16, LineSpacing -> {1, 4}];

(* tinted "scientific note" callout *)
callout[stuff__] := Cell[TextData[Flatten[{Cell[BoxData@StyleBox["\:26a0  ", FontColor -> RGBColor[0.78, 0.5, 0.1]]], stuff}]], "Text",
   FontSize -> 12.5, CellMargins -> {{40, 40}, {8, 10}},
   Background -> RGBColor[0.99, 0.965, 0.9],
   CellFrame -> {{4, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.85, 0.6, 0.15],
   CellFrameMargins -> 14, LineSpacing -> {1, 3}];

(* ---- inline styles ---- *)
bold[s_] := StyleBox[s, FontWeight -> Bold];
ital[s_] := StyleBox[s, FontSlant -> Italic];
mono[s_] := StyleBox[s, FontFamily -> "Courier", FontSize -> 12];
lnk[txt_, url_] := ButtonBox[StyleBox[txt, FontColor -> accent, FontWeight -> "SemiBold"],
   BaseStyle -> "Hyperlink", ButtonData -> {URL[url], None},
   ButtonNote -> url];

imath[boxes_] := Cell[BoxData@FormBox[boxes, TraditionalForm], "InlineFormula"];
isub[base_, k_] := imath@SubscriptBox[base, k];
displayMath[expr_] := Cell[BoxData@FormBox[expr, TraditionalForm], "DisplayFormula"];

(* ---- images ---- *)
$imgDir = ".";
SetImgDir[d_] := ($imgDir = d);
(* $imgDir = repoRoot/docs/images -> cache at repoRoot/community/.img-cache *)
$cacheDir := FileNameJoin[{ParentDirectory[$imgDir, 2], "community", ".img-cache"}];

resizedCopy[path_, target_] := Module[{cached, im, w},
   If[!DirectoryQ[$cacheDir], CreateDirectory[$cacheDir]];
   cached = FileNameJoin[{$cacheDir, IntegerString[Hash[{path, target}], 36] <> "_" <> FileNameTake[path]}];
   If[FileExistsQ[cached] && FileDate[cached, "Modification"] > FileDate[path, "Modification"],
     Return[cached]];
   im = Import[path]; w = First@ImageDimensions[im];
   If[w > target, im = ImageResize[im, target]];
   Export[cached, im, "PNG"]; cached];

(* Embed at ~2x the on-page display width (retina-crisp) and let ImageSize
   set the display size in points. NOTE: embedding the full ~4000px source
   made the Front End choke and render the raster boxes as raw data text on
   open (headless PDF export tolerated it, the interactive FE did not).
   ~1500 px is the sweet spot: clearly sharper than 1x, opens reliably. *)
$embedCap = 1500;
imgCell[file_, width_:760] := Module[{path = FileNameJoin[{$imgDir, file}], im},
   If[!FileExistsQ[path],
     Return@Cell[TextData[{bold["[ missing figure: " <> file <> " ]"]}], "Text",
        FontColor -> RGBColor[0.7, 0.1, 0.1], TextAlignment -> Center]];
   im = Image[Import[resizedCopy[path, $embedCap]], ImageSize -> width];
   Cell[BoxData@ToBoxes[im], "Output", ShowCellLabel -> False,
      CellMargins -> {{Automatic, Automatic}, {6, 12}}, TextAlignment -> Center]];

caption[txt_] := Cell[TextData[{ital[txt]}], "Text", FontSize -> 11.5,
   FontColor -> GrayLevel[0.4], TextAlignment -> Center,
   CellMargins -> {{40, 40}, {12, 2}}];

figCell[file_, cap_, width_:760] := {imgCell[file, width], caption[cap]};

(* AnimatedImage GIF — Community plays it, drops Video[]. ColorQuantize
   per frame keeps the embedded notebook small. *)
animCell[file_, cap_:"", width_:600] := Module[{path = FileNameJoin[{$imgDir, file}], frames, fw, anim},
   If[!FileExistsQ[path],
     Return@Cell[TextData[{bold["[ missing animation: " <> file <> " ]"]}], "Text",
        FontColor -> RGBColor[0.7, 0.1, 0.1], TextAlignment -> Center]];
   frames = Import[path, {"GIF", "ImageList"}];
   (* keep the source frame resolution (only downsize if huge), 256 colours,
      and let ImageSize set the on-page display width -> sharper than 1:1 *)
   fw = First@ImageDimensions[frames[[1]]];
   If[fw > 760, frames = ImageResize[#, {760}] & /@ frames];
   frames = ColorQuantize[#, 256] & /@ frames;
   anim = AnimatedImage[frames, FrameRate -> 8, ImageSize -> width, AnimationRepetitions -> Infinity];
   {Cell[BoxData@ToBoxes[anim], "Output", ShowCellLabel -> False,
       CellMargins -> {{Automatic, Automatic}, {6, 12}}, TextAlignment -> Center],
    If[cap === "", Nothing, caption[cap]]}];

figCell; caption;

End[];
EndPackage[];
