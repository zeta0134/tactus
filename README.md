# Tactus

A rhythm-based dungeon crawler for original NES and FamiCom. Explore mysterious ruins, find powerful weapons, and **slay to the beat**. Maps and enemy placement are randomized each time you play, so no two runs are quite the same.

- Screenshot 

This was my contest entry for the [NESDev Compo 2022](https://itch.io/jam/nesdev-2022). It is currently a demo, featuring a fairly basic zone with open rooms, and four floors of increasingly difficult combat encounters. You can check out the [contest entry](https://zeta0134.itch.io/tactus) with a released (and slightly buggy) build ready to play in most reasonably accurate NES emulators. Also there is a [live demo](https://rusticnes.reploid.cafe/wasm/?cartridge=tactus.nes) that should run in most modern browsers.

# How to Play

- D-Pad: Move around and attack enemies.

You can move freely in any direction, but when there's enemies onscreen, everyone moves to the beat of the music. Enemies _move to the groove_, so learn their patterns and try to avoid their attacks. When you move **towards** an enemy, you'll swing your weapon. Each weapon works a little differently, so try them all and find your favorite.

# Building

Tactus depends on the cc65 compiler suite, GNU make, and python3. With all of those installed on your path, it should be as simple as:

```
make clean
make
```

If you're actively developing, be sure to clean regularly, as I don't have dependency generation working for the ca65 header files. Fortunately it's pretty quick to build. The art was all drawn using Aseprite, but it's the output `.png` files that the build tools consume, so in theory you can edit them using any image tool that supports 4-color palettes. Room layouts are all done in [Tiled](https://www.mapeditor.org/) mostly because the XML format it uses to save levels is rather easy to parse.






