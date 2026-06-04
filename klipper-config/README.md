# Klipper Config Patches

Standalone `.cfg` snippets to add to your K1C's `printer.cfg`. Each file is self-contained - apply one, several, or all of them.

## Applying a patch

**Option A - scp + include:**
```bash
scp <patch>.cfg root@<PRINTER_IP>:/usr/data/printer_data/config/
ssh root@<PRINTER_IP> \
  "echo '[include <patch>.cfg]' >> /usr/data/printer_data/config/printer.cfg"
```

Then restart Klipper (only safe when not printing):
```bash
curl -X POST http://<PRINTER_IP>:7125/printer/gcode/script \
  -H "Content-Type: application/json" \
  -d '{"script":"RESTART"}'
```

**Option B - paste inline:**
Copy the section from the `.cfg` file and append it to `/usr/data/printer_data/config/printer.cfg` directly, then restart using the curl command above.

---

## led-lighting.cfg - Chassis LED / Fluidd Lights control

**What it does:**
Registers the chassis LED as a Klipper `[led]` object named `lighting`. This enables:

- **Fluidd**: a "Lights" panel with a dimming slider and a `TOGGLE_LED` button in the Macros panel
- **Touchscreen**: the printer's built-in LED brightness control works correctly (it already sends `SET_LED LED=lighting WHITE=<value>` internally - this config is what it's talking to)
- **G-code**: `SET_LED LED=lighting WHITE=0.5` sets brightness to 50%, `TOGGLE_LED` flips on/off

**Hardware:** GPIO PA8 on the X2600E main MCU (K1C 2025). Verified on firmware version shipped 2025.
