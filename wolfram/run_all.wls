#!/usr/bin/env wolframscript
(* ::Package:: *)

(* Render every figure + animation into docs/images/. *)

dir = DirectoryName[$InputFileName];
Do[
  Print["\n############ ", f];
  Run["wolframscript -file " <> FileNameJoin[{dir, f}]],
  {f, {"hero.wls", "cycles.wls", "spectral.wls", "phase.wls",
       "modern.wls", "orbital.wls", "leadlag.wls", "terminations.wls",
       "deeptime_temp.wls", "deeptime_co2.wls", "anim_sweep.wls", "anim_breakout.wls"}}];
Print["\nAll figures + animations rendered to docs/images/."];
