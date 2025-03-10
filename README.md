# Game of Life

## Overview

Implementation of John Conway's Game of life in VHDL on Artix-7 (Nexis 4 DDR) with VGA 640x480px at 60Hz output.

## Key features

- Iterates at 30 or 60 iterations per second, or step by step.
- 640 x 480 VGA display.
- Cell states can be changed anytime with PS/2 Mouse.

## Performances

- Celullar automaton: 325 iterations/s max @100MHz (651 ite/s max @200MHz,...).
- VGA display: 60 fps.
- PS/2 mouse update: 500 Hz.

### Resource Utilization (for AMD Xilinx Nexys-A7 (xc7a100t))

| Resource | Utilization |
|----------|-------------|
| LUTs     | 665         |
| FFs      | 492         |
| BRAMs    | 30          |

_BRAMs usage depends on screen size._

_Resource utilization for 100MHz implementation with Vivado 2020_

## v2

**status**: Work In Progress (WIP)

**highlights**:
- Higher iteration rate.
- Reduce BRAMs usage with a new approach for VGA display.
- Structure pasting.
- Add new updating rules.

## Disclaimer

This project is few years old. Please note that codes, comments and documentation quality might be low and/or outdated.

While efforts were made to ensure functionality and clarity, there may be areas that require improvement or further optimization.

I intend to update and clean the project when I have the opportunity.

## External sources :

- VGA module : http://bornat.vvv.enseirb.fr/wiki/doku.php?id=en202:vga_bitmap
- PS/2 Mouse module: https://www.digikey.com/eewiki/pages/viewpage.action?pageId=70189075
