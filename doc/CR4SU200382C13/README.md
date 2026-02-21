# K1C-2025 Mainboard (CR4SU200382C13)

*!!! ENCRYPTED (Ingenic Secure Boot enabled) !!!*

*!!! No known recovery method !!!*

https://store.creality.com/products/k1c-2025-motherboard-kit

There are blue and black boards, both marked "V13".

## Hardware specs

* Ingenic XBurst2 X2600E SoC
* 256MB DDR3
* [3.3V UART on GND/RX2/TX2 header, 3Mbps 8bit, parity none, 1 stop bit, lsb-fist](serial.md)
* USB-C (shared contacts with USB0) 
* WiFi (aic8800dc)

## Firmware

### V1.0.0.26

MD5(CR4SU200382C13_ota_K1C-2025_V1.0.0.26.20251024S.img)= b4306fe87d75ad94525fb73b4905a52e

* `k1c-2025-exploit.py` works (to get root access)
* recovery/unbricking procedure unknow/unavailable

#### Boot sequence

- u-Boot SPL
- u-Boot
- Linux kernel
- `/linuxrc` (busybox init)
- `/etc/init.d/rcS` starts `/etc/init.d/S*` (`dropbear`, ...)
- `/bin/seed.sh`
- `/usr/apps/etc/init.d/S*` (wifi, ...)
- `/usr/apps/etc/init.d/CS*` as `creality` user (Klipper, GUI, ...) 
- getty on UART

#### MMC layout

```
[root@K1C-XXXX ~] # dmesg
...
[    1.103086] mmc0: new HS200 MMC card at address 0001
[    1.104234] mmcblk0: mmc0:0001 C9A391 7.28 GiB 
[    1.104736] mmcblk0boot0: mmc0:0001 C9A391 partition 1 4.00 MiB
[    1.105295] mmcblk0boot1: mmc0:0001 C9A391 partition 2 4.00 MiB
[    1.105977] mmcblk0rpmb: mmc0:0001 C9A391 partition 3 16.0 MiB, chardev (248:0)
[    1.108530]  mmcblk0: p1 p2 p3 p4 p5 p6 p7 p8 p9 p10
...

[root@K1C-XXXX ~] # fdisk -l
Found valid GPT with protective MBR; using GPT

Disk /dev/mmcblk0: 15269888 sectors, 3360M
Logical sector size: 512
Disk identifier (GUID): XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
Partition table holds up to 11 entries
First usable sector is 34, last usable sector is 15269887

Number  Start (sector)    End (sector)  Size Name
     1            2048            4095 1024K ota
     2            4096            6143 1024K sn_mac
     3            6144           14335 4096K rtos
     4           14336           22527 4096K rtos2
     5           22528           38911 8192K kernel
     6           38912           55295 8192K kernel2
     7           55296          669695  300M rootfs
     8          669696         1284095  300M rootfs2
     9         1284096         1488895  100M rootfs_data
    10         1488896        15269887 6729M userdata
```

- First 1MB of MMC contains GPT table, u-Boot SPL (encrypted), u-Boot (encrypted)
- `ota` - ???
- `sn_mac` - encrypted model, board and uniq unit info
- `rtos` - not encrypted firmware (likely video related)
- `rtos2` - likely used by klipper (reference found in `/usr/data/printer_data/logs/klippy.log`)
- `kernel` - encrypted kernel with initial RAMfs
- `kernel2` - encrypted older kernel with RAMfs
- `rootfs` - "signed" squashfs at 2048 byte offset, verified and loop-mounted on `/usr/deplibs`, by `/bin/seed.sh` on boot 
- `rootfs2` - not encrypted ext4, mounted on `/usr/apps` on boot
- `rootfs_data` - likely unused (currently `0x00` fileld)
- `userdata` - not ncrypted ext4, mounted on /usr/data (g-code files, logs ...)

`/dev/mmcblk0boot0` (4MB) and `/dev/mmcblk0boot1` (4MB) likely unused (0x00 filled).

`/dev/mmcblk0rpmb` (16MB) should be write-only [RPMB](https://en.wikipedia.org/wiki/Replay_Protected_Memory_Block) partition likely related to "secure boot".


#### MMC dump

To make a backup copy (in case recovery method will be available in the future)

`ssh root@k1c 'dd if=/devmmcblk0 bs=1M' > mmc.dump`

MMC of the fresh machine is mostly 0x00 filled, so You can convert it to sparse file (shoult take ~430MB real disk space).

Most analysis can be done on `mmc.dump` to minimize the risk of bricking k1c.

#### Decryption

`/bin/seed.sh` loads `/lib/modules/soc_security.ko` module, which is responsible for `/dev/sc` device used to verify/decrypt binaries.
Client tool is `/bin/cmd_sc`, used by the same `seed.sh`.

Most encrypted binaries have `SCBT` as the first 4 bytes.

u-Boot SPL:
```
dd if=mmc.dump bs=1 skip=17920 seek=512 count=18944 of=spl.encrypted
echo -n SCBT | dd of=spl.encrypted conv=notrunc
cmd_sc src=spl.encrypted dst=spl
```

u-Boot:
```
dd if=mmc.dump of=u-boot.encoded bs=1 skip=41984 count=195184
cmd_sc src=u-boot.encrypted dst=u-boot
```

Linux and RAMfs:

- dump `kernel` or `kernel2` partiton from `mmc.dump` to `kernel.encrypted`
- `cmd_sc src=kernel.encrypted dst=kernel.img

```
binwalk --extract kernel.img
zcat < Linux-5.10.186.bin > Linux-5.10.186.bin.extracted
binwalk --extract Linux-5.10.186.bin.extracted
cpio -it < decompressed.bin
```

Applications:

Eight binaried are decrypted by `/bin/seed.sh` to `/tmp/apps` (You can download from there or decrypt using `cmd_sc`):

- `alchemistp` - golang, likely responsible for most housekeeping, network communications with Creality at `api.crealitycloud.com`, etc.
- `mdns` - multicast DNS, :TODO: - no clear reason to encrypt it 
- `nexusp` - [Moonriker](https://github.com/Arksine/moonraker) alternative implementation (?), the same API (?), likely required by `vectorp` (listens on 7125/tcp, active tcp connection with `vectorp`), reported as usable from remote Fluidd.
- `onyxp` - :TODO:
- `quintusp` - LED on/off (if stopped - light switching from GUI has no effect), maybe something more
- `solusp` - :TODO:
- `thirteenthp` - ?is it doing anything? (startup script `CS59thirteenthp` likely has errors) video stream related
- `vectorp` - main and biggest, responsible for GUI, likely C++ uning LVGL (https://lvgl.io/) for graphics, plaintext mqtt reporting to Creality (`mqtt.crealitycloud.com`, ...)

Klipper is available in python bytecode (`.pyc` files), some configs are plaintext.

#### Network

Current status: `ss -nap`

IPtables rules: `iptables-save` 
  - `-A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8081` - forwards 80/tcp to `vectorpp`

Live traffic: `tcpdump -n` (or `tcpdump -n not port 22` to filter-out ssh traffic)`

# References

* https://gist.github.com/C0DEbrained/c6f508109e34f43a39f4c22e901408dd
