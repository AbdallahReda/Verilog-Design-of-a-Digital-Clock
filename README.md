# Design of a Digital Clock

## Design Objective
The overall objective is to design a counter that goes from 00 to 59 in EXACTLY one minute. And display the current count on two SSD displays.

Detailed objectives include
- to design a ring counter that controls on/off of individual SSD display digits
- to design clock dividers that can slow down system clock frequency
- to design a timer that can calculate from 00 to 59
- to design a SSD deriver mechanism that displays two-digit decimal numbers 

## Compilation & Testing
The verilog code was complied with software
```
Xilinx ISE 10.1
```

and tested on hardware
```FPGA
Model: Digilent NEXYS2
Family: Spartan3E
Device: XC3s1200E
Package: FG320
Speed: -4
```

with an executable BIT file generated **specifically** for the hardware listed above. Download BIT file [here](https://undergrad.hxing.me/VE270/VE270_Lab_VI.bit?x-source=site).

## Manual, Report and Demo Video
The code was designed for a school project.
- [Project Manual](https://undergrad.hxing.me/VE270/Lab+VI+Manual.pdf?x-source=site)
- [Project Report](https://undergrad.hxing.me/VE270/Lab+VI+Report.pdf?x-source=site)
- FPGA Board PIN Assignment based on [Digilent Nexys2 Board Manual](https://undergrad.hxing.me/VE270/Digilent+Nexys2+Manual.pdf?x-source=site)
- and [a demonstrative video is available on YouTube](https://youtu.be/M_Ml6MK7oH0?t=2m5s)

## Credits
This project is done in a two-person team. Special thanks goes to my teammate Desmond (Chengyan) Qi. I had a wonderful time working with him.

## Additional Resources
For projects just like this one, please visit my webiste at [http://www.hxing.me/academics](http://www.hxing.me/academics).

