# Tidal2D
Simple game engine

![Linux](https://github.com/EmperorPenguin18/tidal2d/actions/workflows/linux.yml/badge.svg)
![Windows](https://github.com/EmperorPenguin18/tidal2d/actions/workflows/windows.yml/badge.svg)
![Web](https://github.com/EmperorPenguin18/tidal2d/actions/workflows/web.yml/badge.svg)
![macOS](https://github.com/EmperorPenguin18/tidal2d/actions/workflows/macos.yml/badge.svg)

## Features
- Supports Linux, Windows, Web and probably macOS too
- Many different asset file formats can be loaded
- Easy event-action system for object behaviour
- Scripting in Lua for complete control
- Graphical front-end with [tidal-gtk](https://github.com/EmperorPenguin18/tidal-gtk)

Features will be added to suit other projects I'm working on.

## Dependencies

CMake and git, everything else will be built automatically

## Install
Arch Linux
```
git clone https://github.com/EmperorPenguin18/tidal2d
cd tidal2d
makepkg -si
```
Or just install from the [AUR](https://aur.archlinux.org/packages/tidal2d)

Web
```
git clone https://github.com/EmperorPenguin18/tidal2d
cd tidal2d
emcmake cmake -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

Everything else
```
git clone https://github.com/EmperorPenguin18/tidal2d
cd tidal2d
cmake -DCMAKE_BUILD_TYPE=Release
cmake --build .
```
## Documentation
See the [wiki](https://github.com/EmperorPenguin18/tidal2d/wiki/)
## Games using Tidal2D
[Example: The Game](https://github.com/EmperorPenguin18/tidal2d/tree/main/example)
