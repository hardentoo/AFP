AFP
===

How to create a cabal library
-----------------------------
Create a file _package_.cabal and include something like this:

```
Name:               BeimersBrinke
Version:            1.0
Cabal-Version:      >= 1.2
Author:             Chiel ten Brinke and Mattias Beimers
Category:           Educational Assignment
Description:        This is the first set of assignments
Build-Type:         Simple

Library
  Build-Depends:    base, criterion
  Exposed-modules:
  A2_5, A7_1, A8_1, profiling
```

Then run `cabal sdist` to produce a compressed package that can be easily distributed.
