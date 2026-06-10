(* ::Package:: *)

(* Shared loaders for the tidy CSVs produced by the fetchers.
   Usage:  Get[FileNameJoin[{repoRoot, "wolfram", "load_data.wl"}]]
   All "age" fields are years (or kyr) before present, present = 1950 AD,
   EXCEPT the modern instrumental series which are in calendar year AD. *)

BeginPackage["IceData`"];

DataDirectory::usage = "DataDirectory[] -> absolute path of data/.";
LoadCO2::usage       = "LoadCO2[] -> <|age_kyr, co2, sigma|> (ice-core gas-age composite).";
LoadTemp::usage      = "LoadTemp[] -> <|age_kyr, depth, dD, dT|> (EDC deuterium temperature).";
LoadModernMLO::usage = "LoadModernMLO[] -> <|year, co2, unc|> (Mauna Loa annual).";
LoadModernGlobal::usage = "LoadModernGlobal[] -> <|year, co2, unc|> (global annual).";
LoadOrbital::usage   = "LoadOrbital[] -> <|age_kyr, ecc, obliquity, perihelion, precession|>.";
LoadLR04::usage      = "LoadLR04[] -> <|age_kyr, d18O, err|> (Lisiecki & Raymo 2005 benthic stack, 5.3 Myr).";
YearToKyrBP::usage   = "YearToKyrBP[yr] converts a calendar year AD to kyr before present (1950).";

Begin["`Private`"];

(* Capture this package file's location at load time — $InputFileName is
   only bound while Get is reading the file, not when a loader is later
   called (e.g. from wolframscript -code). *)
$thisDir = DirectoryName[$InputFileName];

DataDirectory[] := FileNameJoin[{ParentDirectory[$thisDir], "data"}];

load[file_] := Module[{csv = Import[FileNameJoin[{DataDirectory[], file}], "CSV"]},
   N[csv[[2 ;;]]]];

LoadCO2[] := Module[{r = load["co2_composite_800k.csv"]},
   <|"age_kyr" -> r[[All, 1]]/1000., "co2" -> r[[All, 2]], "sigma" -> r[[All, 3]]|>];

LoadTemp[] := Module[{r = load["edc_temperature_800k.csv"]},
   <|"age_kyr" -> r[[All, 1]]/1000., "depth" -> r[[All, 2]],
     "dD" -> r[[All, 3]], "dT" -> r[[All, 4]]|>];

LoadModernMLO[] := Module[{r = load["modern_co2_mlo.csv"]},
   <|"year" -> r[[All, 1]], "co2" -> r[[All, 2]], "unc" -> r[[All, 3]]|>];

LoadModernGlobal[] := Module[{r = load["modern_co2_global.csv"]},
   <|"year" -> r[[All, 1]], "co2" -> r[[All, 2]], "unc" -> r[[All, 3]]|>];

LoadOrbital[] := Module[{r = load["orbital_la2004_800k.csv"]},
   <|"age_kyr" -> r[[All, 1]], "ecc" -> r[[All, 2]],
     "obliquity" -> r[[All, 3]], "perihelion" -> r[[All, 4]],
     "precession" -> r[[All, 5]]|>];

LoadLR04[] := Module[{r = load["lr04_benthic_5myr.csv"]},
   <|"age_kyr" -> r[[All, 1]], "d18O" -> r[[All, 2]], "err" -> r[[All, 3]]|>];

YearToKyrBP[yr_] := (1950 - yr)/1000.;

End[];
EndPackage[];
