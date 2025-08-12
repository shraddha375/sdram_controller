# SDRAM Controller

SDRAM (Synchronous Dynamic Random-Access Memory) is widely used in embedded systems, FPGAs, and CPUs due to its high-speed data access capabilities. SDRAM cannot be directly interfaced with most processors, FPGAs, or other digital systems without proper control logic. SDRAM has a complex timing and command sequence that must be carefully managed to ensure correct operation.

An SDRAM Controller is a hardware block that:
- Interfaces between the system (CPU, FPGA, etc.) and the SDRAM.
- Converts simple read/write requests into the detailed command sequences required by the SDRAM.
- Manages all the timing, refresh, and bus control automatically.

---

## How does a DRAM work?

The fundamental memory cell within a DRAM consists of a transistor and a capacitor. 

<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_1.jpg" width=100% height=100%>

When you want to **write** to a memory cell:
- Enable the Wordline
- Apply VDD/GND on the Bitline

<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_2.jpg" width=100% height=100%>

 When you want to **read** from a memory cell:
- Precharge Bitline to VDD/2
- Enable Wordline
- Sense value on the Bitline
- Apply Refresh 

<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_3.jpg" width=50% height=50%>
## Concept of Refresh

Read is a destructive process because it removes or adds extra charge to the capacitor. Hence we need to perform refresh which essentially restores the original charge on the capacitor. This is usually done by reading the cell value and writing the same value back.

Switches are made from transistors and over a period of time the charges on the capapcitirs leak. To ensure data integrity, we need to perform refresh periodically.

There are two types of refresh: 
- *Auto-Refresh*: Refreshes the capacitors during a normal operation with the SDRAM
- *Self-Refresh*: Refreshes the SDRAM in a power down mode when the clock enable is 0.

## Generartions of DRAM

### First Generation of DRAM

The first generation of DRAM looks like this as shown below: 
![DRAM CELL](https://github.com/shraddha375/sdram_controller/blob/main/images/image_4.jpg)

![DRAM CELL](https://github.com/shraddha375/sdram_controller/blob/main/images/image_5.jpg)

![DRAM CELL](https://github.com/shraddha375/sdram_controller/blob/main/images/image_6.jpg)

![DRAM CELL](https://github.com/shraddha375/sdram_controller/blob/main/images/image_7.jpg)

![DRAM CELL](https://github.com/shraddha375/sdram_controller/blob/main/images/image_8.jpg)

![DRAM CELL](https://github.com/shraddha375/sdram_controller/blob/main/images/image_9.jpg)

![DRAM CELL](https://github.com/shraddha375/sdram_controller/blob/main/images/image_10.jpg)






## References
