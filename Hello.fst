module Hello

#lang-pulse
open Pulse

fn test (x:unit)
  requires emp
  ensures emp
{
  ()
}
