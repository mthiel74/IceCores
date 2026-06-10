#!/usr/bin/env wolframscript
(* ::Package:: *)

(* Modern instrumental atmospheric CO2 (NOAA GML / Scripps).
   Two annual-mean series:
     - Mauna Loa  (1959 -> present)  co2_annmean_mlo.csv
     - Global     (1979 -> present)  co2_annmean_gl.csv
   These provide the instrumental "Keeling" record that splices onto
   the ice-core composite and rockets above the natural 800 kyr band.
   Columns: year, mean (ppm), unc (ppm).
*)

Get[FileNameJoin[{DirectoryName[$InputFileName], "fetcher_common.wl"}]];

grab[url_, raw_, out_, label_] := Module[{res, text, lines, rows},
  IceFetch`Banner[label];
  res = IceFetch`FetchText[url, raw, 24];
  Print["  raw: ", res["savedTo"], "  (", res["bytes"], " B, cached=", res["cached"], ", ok=", res["ok"], ")"];
  If[!res["ok"], Print["  ERROR: ", res["error"]]; Return[$Failed]];
  text  = Import[raw, "Text"];
  lines = Select[StringSplit[text, {"\r\n", "\n", "\r"}], StringStartsQ[#, DigitCharacter] &];
  rows  = (ToExpression /@ StringSplit[#, ","]) & /@ lines;
  rows  = Select[rows, Length[#] >= 3 &][[All, 1 ;; 3]];
  rows  = SortBy[rows, First];
  Export[out, Prepend[rows, {"year", "co2_ppm", "unc_ppm"}], "CSV"];
  Print["  parsed: ", Length[rows], " rows  (", First@rows[[All,1]], "-", Last@rows[[All,1]], ")"];
  Print["  latest: ", Last[rows][[2]], " ppm (", Last[rows][[1]], ")"];
  rows];

grab[
  "https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_annmean_mlo.csv",
  FileNameJoin[{IceFetch`RawDir[], "co2_annmean_mlo.csv"}],
  FileNameJoin[{IceFetch`DataDir[], "modern_co2_mlo.csv"}],
  "Modern CO2 — Mauna Loa annual mean (NOAA GML)"];

grab[
  "https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_annmean_gl.csv",
  FileNameJoin[{IceFetch`RawDir[], "co2_annmean_gl.csv"}],
  FileNameJoin[{IceFetch`DataDir[], "modern_co2_global.csv"}],
  "Modern CO2 — Global annual mean (NOAA GML)"];
