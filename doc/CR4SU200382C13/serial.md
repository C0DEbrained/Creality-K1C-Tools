Serial interface on the board is available on GND/RX2/TX2 connector in the center of the board: 3.3V UART, 3Mbps (3Mhz), 8-bit, parity none, 1 stop bit, lsb-first.
Used PL2303 USB-to-serial converter. No changes needed to get a login prompt. To be able to login You need to fix `/tmp/shadow` file.


```
U-Boot SPL 2013.07 (Aug 26 2025 - 05:43:32)
ERROR EPC 8e11a37f
CPA_CPAPCR:0300490d
CPM_CPMPCR:04b0490d
CPM_CPEPCR:0190510d
CPM_CPCCR:9a0b5410
DDR: W632GU6QG-11 type is : DDR3
Security boot...


U-Boot 2013.07 (Aug 26 2025 - 05:43:32)

Board: x2600e_creality (Ingenic XBurst2 X2600E SoC)
DRAM:  256 MiB
Top of RAM usable for U-Boot at: 90000000
Reserving 496k for U-Boot at: 8ff80000
Reserving 16416k for malloc() at: 8ef58000
Reserving 32 Bytes for Board Info at: 8ef57fe0
Reserving 128k for boot params() at: 8ff60000
Reserving 124 Bytes for Global Data at: 8ef57f64
Stack Pointer at: 8ef57f48
Now running in RAM - U-Boot at: 8ff80000
MMC:   MSC: 0
[CMD8]: Error detected in status(0x18000)!
[CMD55]: Error detected in status(0x18000)!
*** Warning - bad CRC, using default environment

In:    serial
Out:   serial
Err:   serial
Net:   GMAC-9161
mmc0(part 0) is current device
Security boot...
## Booting kernel from Legacy Image at 80a00800 ...
   Image Name:   Linux-5.10.186
   Image Type:   MIPS Linux Kernel Image (gzip compressed)
   Data Size:    8221324 Bytes = 7.8 MiB
   Load Address: 80010000
   Entry Point:  80972ca0
   Verifying Checksum ... OK
   Uncompressing Kernel Image ... OK

Starting kernel ...

[    0.000000] Linux version 5.10.186 (root@b62d0822127a) (mips-linux-gnu-gcc (Ingenic Linux-Release5.1.8-Default_xburst2_glibc2.29 Optimize: jr base on 5.1.6 2023.07-18 08:46:58) 7.2.0, GNU
 ld (Ingenic Linux-Release5.1.8-Default_xburst2_glibc2.29 Optimize: jr base on 5.1.6 2023.07-18 08:46:58) 2.27) #1 SMP PREEMPT Fri Oct 24 11:22:56 CST 2025
[    0.000000] CPU0 RESET ERROR PC:8E11A37F
[    0.000000] printk: bootconsole [early0] enabled
...

Welcome to creality
K1C-XXXX login:
```

NOTE: any key pressed before login apears leads to kernel crash and authomatic reboot.
