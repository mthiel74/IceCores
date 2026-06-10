#!/usr/bin/env wolframscript
(* ::Package:: *)

(* One-shot driver: fetch every dataset into data/*.csv. *)

dir = DirectoryName[$InputFileName];
Do[
  Print["\n############ ", f];
  Run["wolframscript -file " <> FileNameJoin[{dir, f}]],
  {f, {"fetch_co2.wls", "fetch_temperature.wls", "fetch_modern.wls", "fetch_orbital.wls", "fetch_lr04.wls"}}];
Print["\nAll fetchers done."];
