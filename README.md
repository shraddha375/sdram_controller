# SDRAM Controller

SDRAM (Synchronous Dynamic Random-Access Memory) is widely used in embedded systems, FPGAs, and CPUs due to its high-speed data access capabilities. SDRAM cannot be directly interfaced with most processors, FPGAs, or other digital systems without proper control logic. SDRAM has a complex timing and command sequence that must be carefully managed to ensure correct operation.

<mark style="background-color: lightblue">An SDRAM Controller is a hardware block that:</mark>
- <mark style="background-color: lightblue">Interfaces between the system (CPU, FPGA, etc.) and the SDRAM.</mark>
- <mark style="background-color: lightblue">Converts simple read/write requests into the detailed command sequences required by the SDRAM.</mark>
- <mark style="background-color: lightblue">Manages all the timing, refresh, and bus control automatically.</mark>

---

## How does a DRAM work?

The fundamental memory cell within a DRAM consists of a transistor and a capacitor. 

<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_1.jpg" width=100% height=100%>

Reeason why it is called a *Wordline* : Multiple transistors are conected to this line as you increase the capacity of the memory.

When you want to **write** to a memory cell:
- Enable the Wordline
- Apply VDD/GND on the Bitline

<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_2.jpg" width=100% height=100%>

 When you want to **read** from a memory cell:
- Precharge Bitline to VDD/2
- Enable Wordline
- Sense value on the Bitline
- Apply Refresh 

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_3.jpg" width=50% height=50%>
</p>

## Concept of Refresh

Read is a destructive process because it removes or adds extra charge to the capacitor. Hence we need to perform refresh which essentially restores the original charge on the capacitor. This is usually done by reading the cell value and writing the same value back.

Switches are made from transistors and over a period of time the charges on the capapcitirs leak. To ensure data integrity, we need to perform refresh periodically.

<mark style="background-color: lightblue">There are two types of refresh:</mark>
- <mark style="background-color: lightblue">*Auto-Refresh*: Refreshes the capacitors during a normal operation with the SDRAM.</mark>
- <mark style="background-color: lightblue">*Self-Refresh*: Refreshes the SDRAM in a power down mode when the clock enable is 0.</mark>

To give an example, let's say we have 4096 rows in a DRAM and we need to perform refresh for all the rows within 64 ms. That means each row needs to be refreshed in 64 ms/4096 = 15.62 us.

## Generations of DRAM

### First Generation of DRAM

The first generation of DRAM looks as shown below:

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_4.jpg" width=50% height=50%>
</p>

5 bits for determining the row within 32 rows and 5 bits for determining column within 32 coulmns.

Inside the cell matrix, each memory bit uses one of the many outputs from Row and Column decoders:

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_5.jpg" width=50% height=50%>
</p>

To get an idea on how row and column decoders enable one cell inside the cell matrix:

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_6.jpg" width=25% height=25%>
</p>

In an actual 1st generation DRAM, each cell conists of 3 transistors: 

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_10.jpg" width=50% height=50%>
</p>

When we want to carry out a Write operation, Write rowline is made high. M1 transistor turns on and whatever data present is on the Write columnline is passed to the gate of M2. The information either discharges or charges the input capacitor at the gate of M2. If we want to carry out a READ operation, precharge the Read columnline to a known value and then driving the Row rowline to high. Driving the Read rowline high turnd M3 on, and allows M2 to pull the Read coulmnline low or to not chnage the precharge voltage of the Read columnline (If the voltage at M2 is zero then M2 is OFF and the precharged value will not change whereas if the voltage at M2 is high then M2 is ON and it will pull the precharged value to zero).

The main drawback of using the 3-transistor DRAM cell is that it requires two pairs of column and rowlines. This consumes large layout area. Modern DRAM cells use only 1-transistor and 1-capacitor.

First Generation DRAM does not have clock. For READ and WRITE operations, first row address is applied then column address is applied. For REFRESH operation, first column address is applied then row address is applied.

#### READ Operation
---
To read a bit, one applies the row and the column addres, then wait for the data to appear on the dout pin. 

**Read cycle time(t<sub>RC</sub>)** : Specifies how fast the memory can be read.

**Access time (t<sub>AC</sub>)** : Specifies maximum length of time after the input address is changed before the output data is valid.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_7.jpg" width=50% height=50%>
</p>

#### WRITE Operation
---
**Write cycle time(t<sub>WC</sub>)** : Specifies the maximum frequency at which we can write data into the DRAM. 

**Address to Write Delay time(t<sub>AW</sub>)** : Specifies the time between the address changing and R/W̅ input going LOW. 

**Write pulse width(t<sub>WP</sub>)** : Specifies for how long the input data must be present before the R/W̅ input can go back HIGH in preparation for another Read or Write to DRAM.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_8.jpg" width=50% height=50%>
</p>

#### REFRESH Operation
---
Here C̅E̅ is made HIGH while R/W̅  is used as a clock signal. To refresh the DRAM, we periodically access the memory with every possible row address combination. The data is read out and then written back into the same location at full voltage. 

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_9.jpg" width=50% height=50%>
</p>

### Second Generation of DRAM

We distinguish 2nd generation DRAMs from 1st generation DRAMs by the introduction of multiplexed address inputs, multi-memory arrays, and the 1-transistor/1-capacitor memory cell.

**Difference 1**
<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_11.jpg" width=50% height=50%>
</p>

**Difference 2**

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_12.jpg" width=50% height=50%>
</p>

We cannot go on increasing the number of transistors like this, because when wordline is enabled, it needs to travel long distance (increases resistance and capacitance; reducing frequency of operation). Instead we use arrays as follows:

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_13.jpg" width=50% height=50%>
</p>

**Difference 3**

We also multiplex our address inputs using R̅A̅S̅(Row Addresss Strobe) and C̅A̅S̅(Column Address Strobe), thus reducing the number of pins required. We use the same pins for row address and column address.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_14.jpg" width=50% height=50%>
</p>


### Third Generation of DRAM

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_15.jpg" width=50% height=50%>
</p>

In third generation of DRAM, we have clock and hence it is called a Synchronous DRAM. It supports parallel memory operation. When one of the banks is doing preprocessing, other banks could be initiated for READ/WRITE.

Here we work at command level instead of signal level, where the combination of different signals used for specific operation is grouped into a command. User needs to send the command, the controller will handle the translation of a command to the signal level.

---

## Design of SDRAM Controller

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_16.jpg" width=50% height=50%>
</p>

Why do we need a SDRAM controller: find [here](#SDRAM-Controller)

<mark style="background-color: lightblue">SDRAM controller consists of:</mark>
- <mark style="background-color: lightblue">Initialization Module</mark>
- <mark style="background-color: lightblue">Self-Refresh Generator</mark>
- <mark style="background-color: lightblue">Auto-Refresh Generator</mark>
- <mark style="background-color: lightblue">Load Mode Register</mark>
- <mark style="background-color: lightblue">Read Module</mark>
- <mark style="background-color: lightblue">Write Module</mark>
- <mark style="background-color: lightblue">Controller</mark>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_24.jpg" width=100% height=100%>
</p>

### <mark style="background-color: lightblue">Initialization module</mark>

- <mark style="background-color: lightblue">As soon as we apply power to SDRAM, we need to perform initialization.</mark>
- <mark style="background-color: lightblue">Each memory cell stores data as an electric charge in a capacitor.</mark>
- <mark style="background-color: lightblue">Charge leaks over time hence memory requires periodic refresh cycles to maintain data integrity.</mark>
- <mark style="background-color: lightblue">Initialization ensures that all memory cells are pre-charged and refreshed, setting a known state before use.</mark>
- <mark style="background-color: lightblue">SDRAM is synchronous hence need to wait for the clock to be stable before starting operation (wait for 100 µs for clock stabalization).</mark>
- <mark style="background-color: lightblue">Control register must be programmed explicitly during initialization for correct SDRAM operation.</mark>
- <mark style="background-color: lightblue">Each bank must be precharged before use.</mark>
- <mark style="background-color: lightblue">Loading mode register is done at the end of initialization.</mark>

Initialization Module consists of:
- Counter that measures a duration of 150us after which it flags the power_on_wait_done flag
- A single counter that to keep track of different time periods: TRP, TRFC and TMRD
- FSM that changes states: WAIT_150US -> PRECHARGE -> WAIT_TRP -> AUTOREFRESH -> WAIT_TRFC -> LOAD_MODE -> WAIT_TMRD -> INIT_DONE

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_19.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_20.jpg" width=50% height=50%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_23.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_17.jpg" width=100% height=100%>
</p>

Inputs:
- sys_clk -> System clock signal (1 bit)
- sys_rst_n -> System reset signal (1 bit)

Outputs:
- commands -> Commands (containing CS#, RAS#, CAS# and WE# details) needed by SDRAM (4 bits)
- banks -> Selection of banks (2 bits)
- address -> Address line (12 bits)
- init_done -> Marks completion of SDRAM initialization (1 bit)

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_18.jpg" width=25% height=25%>
</p>

### <mark style="background-color: lightblue">Auto Refresh Generator Module</mark>

*Refreshing:*
- DRAM requires refreshing because data is stored in capacitors, which leak charge over time.
- To prevent data losses, each row must be periodically refreshed.
- Refreshing DRAM means sequentially opening and reading each row to restore the charge in capacitors.
- The entire DRAM must be refreshed within specific time (typically every 64 milliseconds for a 64 Mbit DRAM).
- In older DRAMs (conventional DRAMs), refresh was done using the CBR refresh method.
- <mark style="background-color: lightblue">CAS# Before RAS# Refresh </mark>
  - The CAS# (Column Address Strobe) signal is LOW before RAS# (Row Address Strobe).
  - Signals the DRAM to perform an internal refresh cycle.
  - The memory controller must manually cycle through all the rows.
- <mark style="background-color: lightblue">Normal read/write operation → RAS# before CAS#</mark>
  - To distinguish between R/W and refresh.
- Auto-refresh in SDRAM
  - <mark style="background-color: lightblue">Works similarly to CBR refresh, but SDRAM automatically handles row cycling.</mark>
  - The memory controller only issues a single auto-refresh command, and SDRAM completes the refresh process internally.

 **SDRAM refresh:**
   1. Auto Refresh
   2. Self Refresh

- Regardless of Refresh mode:
  - No row address is required to perform select row refresh.
  - <mark style="background-color: lightblue">**Refresh Counter** → Automatically generates row addresses.</mark>
- AUTO REFRESH is a built-in refresh mechanism in SDRAM.
- <mark style="background-color: lightblue">The memory controller issues a single command, and the SDRAM itself cycles through all the row addresses automatically.</mark>
- <mark style="background-color: lightblue">This reduces the burden on the memory controller.</mark>
- <mark style="background-color: lightblue">Since the refresh is performed on all storage cells in a row, there is no need for column addressing.</mark>


Auto-Refresh Module consists of:
- Counter that measures a duration of ~15.5us for a single row refresh
- A single counter that to keep track of different time periods: TRP and TRFC
- FSM that changes states: IDLE -> PRECHARGE -> WAIT_TRP -> AUTOREFRESH -> WAIT_TRFC -> END

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_26.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_30.jpg" width=100% height=100%>
</p>

To avoid Row Hammer, we issue two AUTOREFRESH command.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_27.jpg" width=100% height=100%>
</p>


<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_29.jpg" width=25% height=25%>
</p>

### Self Refresh Generator Module


<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_34.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_33.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_31.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_32.jpg" width=50% height=50%>
</p>



### Commands
<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_25.jpg" width=50% height=50%>
</p>

## Time Period

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_21.jpg" width=50% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_22.jpg" width=50% height=50%>
</p>


## References
