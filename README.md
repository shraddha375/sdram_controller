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

It is a module that initializes the SDRAM after we apply power to it. Initialization ensures that all memory cells are pre-charged and refreshed, setting a known state before use.

- As soon as we apply power to SDRAM, we need to perform initialization.
- Each memory cell stores data as an electric charge in a capacitor.
- Charge leaks over time hence memory requires periodic refresh cycles to maintain data integrity.
- Initialization ensures that all memory cells are pre-charged and refreshed, setting a known state before use.
- SDRAM is synchronous hence need to wait for the clock to be stable before starting operation (wait for 100 µs for clock stabalization).
- Control register must be programmed explicitly during initialization for correct SDRAM operation.</mark>
- Each bank must be precharged before use.
- Loading mode register is done at the end of initialization.

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

It is a module that is responsible for periodic refresh of the SDRAM rows during its normal operation.

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

Inputs:
- sys_clk -> System clock signal (1 bit)
- sys_rst_n -> System reset signal (1 bit)
- init_end -> Indicates initialization is done (1 bit)
- aref_en -> Enables the auto-refresh generator, it is assertrd by the controller (1 bit)

Outputs:
- aref_req -> When a period of sigle row refresh is lapsed, this will send an auto refresh request to the controller. Then the controller will suspend any on-going task and enable auto-refresh generator. (1 bit)
- commands -> Commands (containing CS#, RAS#, CAS# and WE# details) needed by SDRAM (4 bits)
- banks -> Selection of banks (2 bits)
- address -> Address line (12 bits)
- aref_end -> When auto-refresh has completed for a single row (1 bit)

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_29.jpg" width=25% height=25%>
</p>

### <mark style="background-color: lightblue">Self Refresh Generator Module</mark>

It is a module that is refreshes the SDRAM rows when it is powered down. 

Powered down means the clock is turned off and the SDRAM is powered at minimal standby voltage enough to keep the capacitors charged.


Self-Refresh Module consists of:
- FSM that changes states: IDLE -> PRECHARGE -> WAIT_TRP -> ENTRY -> WAIT_TRFC1 -> WAIT -> POST-REFRESH -> WAIT_TRFC2 -> EXIT


<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_34.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_33.jpg" width=100% height=100%>
</p>

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_31.jpg" width=100% height=100%>
</p>

Inputs:
- sys_clk -> System clock signal (1 bit)
- sys_rst_n -> System reset signal (1 bit)
- init_end -> Indicates initialization is done (1 bit)
- self_ref_en -> Enables self refresh module. Comes from the controller (1 bit)

Outputs:
- sdram_cke -> Clock enable. Starts and stops self refresh (1 bit)
- commands -> Commands (containing CS#, RAS#, CAS# and WE# details) needed by SDRAM (4 bits)
- banks -> Selection of banks (2 bits)
- address -> Address line (12 bits)
- self_ref_done -> Marks the end of completion of a self-refresh (1 bit)

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_32.jpg" width=50% height=50%>
</p>

### <mark style="background-color: lightblue">Load Mode Register module</mark>

The module programs the LOAD MODE REGISTER. The mode register is used to define the specific mode of operation of the SDRAM. It includes the selection of:
- burst length (M0-M2)
- burst type (M3)
- CAS Latency (M4-M6)
- operating mode (M7-M8)
- write burst mode (M9)

Moed register is programmed via the LOAD MODE REGISTER. The register retains the information until it is programmed again or the device loses power. 
The mode register must be loaded when all banks are idle, and the controller must wait for the specified time before initiating the subsequent operation.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_36.JPG" width==75% height=75%>
</p>

**Burst Length**: 
- READ and WRITE accesses to the SDRAM are burst oriented; accesses start at a selected location and continue for a programmed number of locations in a programmed sequence.
- Burst Length determines the maximum number of column locations that can be accessed for a given READ or WRITE command.
- When a READ or WRITE command is issued, a block of columns equal to the burst length is effectively selected.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_40.JPG" width=100% height=100%>
</p>

The block is uniquely selected by:
- When BL = 2 -> A1–A9 (x4) : A1–A8 (x8) : A1–A7 (x16)
- When BL = 4 -> A2–A9 (x4) : A2–A8 (x8) : A2–A7 (x16)
- When BL = 8 -> A3–A9 (x4) : A3–A8 (x8) : A3–A7 (x16)
- The remaining (least significant) address bit(s) is (are) used to select the starting location within the block.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_39.JPG" width=100% height=100%>
</p>

**Burst Type:**
- Accesses within a given burst may be programmed to be either sequential or interleaved; this is referred to as the burst type and is selected via bit M3
- The ordering of accesses within a burst is determined by the burst length, the burst type and the starting column address.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_37.JPG" width=75% height=75%>
</p>

**CAS Latency:**
- CL is the delay, in clock cycles, between the registration of a READ command and the availability of the first piece of output data. The latency can be set to two or three clocks.
- If a READ command is registered at clock edge n and the latency is m clocks, the data will be available by clock edge n + m. The DQs will start driving as a result of the clock
edge one cycle earlier (n + m - 1), and provided that the relevant access times are met, the data will be valid by clock edge n + m.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_38.JPG" width=75% height=75%>
</p>

**Operating Mode**
- The normal operating mode is selected by setting M7 and M8 to zero; the other combinations of values for M7 and M8 are reserved for future use and/or test modes.

**Write Burst Mode**
- When M9 = 0, the burst length programmed via M0–M2 applies to both read and write bursts
- When M9 = 1, the programmed burst length applies to read bursts, but write accesses are single-location (nonburst) accesses.

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_41.JPG" width=50% height=50%>
</p

Load Mode Register Module consists of:
- FSM that changes states: IDLE -> PRECHARGE -> WAIT_TRP -> LOAD_MODE -> WAIT_TMRD -> EXIT

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_42.JPG" width=100% height=100%>
</p>


Inputs:
- sys_clk -> System clock signal (1 bit)
- sys_rst_n -> System reset signal (1 bit)
- init_end -> Indicates initialization is done (1 bit)
- mode_reg_en -> Enables load mode register module. Comes from the controller (1 bit)
- mode_reg_val -> Value of load mode register to be programmed. Comes from the controller (12 bits)

Outputs:
- commands -> Commands (containing CS#, RAS#, CAS# and WE# details) needed by SDRAM (4 bits)
- banks -> Selection of banks (2 bits)
- address -> Address line (12 bits)
- mode_reg_done -> Marks the end of completion of loading the mode register (1 bit)

<p align="center">
<img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_35.JPG" width=25% height=25%>
</p>

### <mark style="background-color: lightblue">Read Module</mark>

The module is responsible for reading from the SDRAM. Before any READ or WRITE commands can be issued to a bank within the SDRAM, a row in that bank must be “opened.” This is accomplished via the ACTIVE command, which selects both the bank and the row to be activated. The value on the BA0, BA1 inputs selects the bank, and the address provided on inputs A0–A11 selects the row. This row remains active (or open) for accesses until a precharge command is issued to that bank. A precharge command must be issued before opening a different row in the same bank.

The PRECHARGE command is used to deactivate the open row in a particular bank or the open row in all banks.

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_50.JPG" width=50% height=50%>
</p>

After opening a row (issuing an ACTIVE command), a READ or WRITE command may be issued to that row. The READ command is used to initiate a burst read access to an active row. The value on the BA0, BA1 inputs selects the bank, and the address provided on inputs A0–A9 (x4), A0–A8 (x8), or A0–A7 (x16) selects the starting column location. The value on input A10 determines whether auto precharge is used. If auto precharge is selected, the row being accessed will be precharged at the end of the read burst; if auto precharge is not selected, the row will remain open for subsequent accesses.

During READ bursts, the valid data-out element from the starting column address will be available following the CL after the READ command.


<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_48.JPG" width=50% height=50%>
</p>

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_49.JPG" width=50% height=50%>
</p>

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_47.JPG" width=100% height=100%>
</p>

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_46.JPG" width=100% height=100%>
</p>

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_45.JPG" width=100% height=100%>
</p>

Full-page READ bursts can be truncated with the BURST TERMINATE command, and fixed-length READ bursts may be truncated with a BURST TERMINATE command, provided that auto precharge was not activated. The BURST TERMINATE command should be issued x cycles before the clock edge at which the last desired data element is valid, where x = CL - 1.

The BURST TERMINATE command is used to truncate either fixed-length or full-page bursts. The BURST TERMINATE command does not precharge the row; the row will remain open until a PRECHARGE command is issued.

Read Module consists of:
- FSM that changes states: IDLE -> ACTIVE -> WAIT_TRCD -> READ -> WAIT_CAS -> READ_DATA -> PRECHARGE -> WAIT_TRP -> EXIT

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_43.JPG" width=100% height=100%>
</p>

Inputs:
- sys_clk -> System clock signal (1 bit)
- sys_rst_n -> System reset signal (1 bit)
- rd_en -> Read enable signal (1 bit)
- rd_addri -> Read address: (24:23) - Bank, (22:11) - Row, (10) - Auto-precharge, (9:8) - Reserved, (7:0) - Column (25 bits)
- rd_din -> Data input from SDRAM (16 bits)
- rd_blength -> SDRAM read burst length (8 bits)

Outputs:
- commands -> Commands (containing CS#, RAS#, CAS# and WE# details) needed by SDRAM (4 bits)
- banks -> Selection of banks (2 bits)
- address -> Address line (12 bits)
- output_data -> Output read data (16 bits)
- valid -> Read valid signal (data ready) (1 bit)
- end -> Read operation end signal (1 bit)

<p align="center">
 <img src="https://github.com/shraddha375/sdram_controller/blob/main/images/image_44.JPG" width=50% height=50%>
</p>

### <mark style="background-color: lightblue">Write Module</mark>

The module is responsible for writing to the SDRAM. The WRITE command is used to initiate a burst write access to an active row. The value on the BA0, BA1 inputs selects the bank, and the address provided on inputs A0–A9 (x4), A0–A8 (x8), or A0–A7 (x16) selects the starting column location. The value on input A10 determines whether auto precharge is used. If auto precharge is selected, the row being accessed will be precharged at the end of the write burst; if auto precharge is not selected, the row will remain open for subsequent accesses.

The starting column and bank addresses are provided with the WRITE command, and auto precharge is either enabled or disabled for that access. During WRITE bursts, the first valid data-in element will be registered coincident with the WRITE command. Subsequent data elements will be registered on each successive positive clock edge.

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
