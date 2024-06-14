module PulseTutorial.SpinLock

open Pulse.Lib.Pervasives
module Box = Pulse.Lib.Box
module U32 = FStar.UInt32

let maybe (b:bool) (p:vprop) =
  if b then p else emp

let lock_inv (r:ref U32.t) (p:vprop) : v:vprop{is_big p ==> is_big v} =
  exists* v. pts_to r v ** maybe (v = 0ul) p

noeq
type lock (p:vprop) = {
  r:ref U32.t;
  i:iref;
}

let lock_alive #p (l:lock p) = inv l.i (lock_inv l.r p)

```pulse
fn new_lock (p:vprop)
requires p ** pure (is_big p)
returns  l:lock p
ensures  lock_alive l
{
   let r = Box.alloc 0ul;
   Box.to_ref_pts_to r;
   fold (maybe (0ul = 0ul) p);
   fold (lock_inv (Box.box_to_ref r) p);
   let i = new_invariant (lock_inv (Box.box_to_ref r) p);
   let l = { r = Box.box_to_ref r; i } <: lock p;
   rewrite each i as l.i;
   fold (lock_alive l);
   l
}
```

```pulse
fn rec acquire #p (l:lock p)
requires lock_alive l
ensures  lock_alive l ** p
{
  unfold (lock_alive l);
  let b = 
    with_invariants l.i
    returns b:bool
    ensures maybe b p ** inv l.i (lock_inv l.r p)
    {
      unfold lock_inv;
      let b = cas l.r 0ul 1ul;
      if b
      { 
        elim_cond_true _ _ _;
        with _b. rewrite (maybe _b p) as p;
        fold (maybe false p);
        rewrite (maybe false p) as (maybe (1ul = 0ul) p);
        fold (lock_inv l.r p);
        fold (maybe true p);
        true
      }
      else
      {
        elim_cond_false _ _ _;
        fold (lock_inv l.r p);
        fold (maybe false p);
        false
      }
    };
  fold (lock_alive l);
  if b { rewrite (maybe b p) as p; }
  else { rewrite (maybe b p) as emp; acquire l }
}
```

```pulse
fn release #p (l:lock p)
requires lock_alive l ** p
ensures  lock_alive l
{
  unfold (lock_alive l);
  with_invariants l.i
    returns _:unit
    ensures inv l.i (lock_inv l.r p)
  {
    unfold lock_inv;
    write_atomic l.r 0ul;
    drop_ (maybe _ _); // NB: Possible double release
    fold (maybe (0ul = 0ul) p);
    fold (lock_inv l.r p);
  };
  fold (lock_alive l);
}
```
