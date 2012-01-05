auf der Suche nach der Ursache warum am AHB mit mehreren Mastern
und rrobin = 0 nix mehr geht

offenbar baut XST Mist

Testszenario:

* zwei Master, die eine GPIO-LED umschalten
* Hardware: Board SP601

Problem: im Testszenario funktioniert alles erwartungsgemäß :-(


Versuch auf neuer (alter) Hardware: Digilent S3E-Starterkit

-use_new_parser No
mit rrobin = 1 --> work         testflow ca. 180 sek
mit rrobin = 0 --> fail         testflow ca. 180 sek

-use_new_parser Yes
mit rrobin = 1 --> work         testflow ca. 85 sek
mit rrobin = 0 --> work         testflow ca. 65 sek


Ergo: Problem tritt nur auf Spartan3E-Board mit "rrobin = 0" auf.
evtl. testen Funktion auf Spartan 3
