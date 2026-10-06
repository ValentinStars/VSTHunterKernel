# Passive A51 battery audit

The root recorder keeps minute samples and compressed system snapshots every ten
samples or when charging status changes. It does not acquire a wake lock, set
alarms, wake the display, change charging controls or suppress log messages.
Deep sleep can delay sampling; graphs use actual times. Collection itself has
some overhead; deep snapshots cost additional time. `sample_cost_s` records wall
time and can include suspend during a sample. It is not recorder CPU time or
an independent measurement of the recorder's energy use.

Captured: SOC, battery voltage/temperature, current readings, power connections,
charging state, available RAM/swap, CPU frequencies, wakefulness, wake-source
counters, process CPU time/RSS, disk/network/interrupt counters, pressure stats,
Android batterystats, ANR, kernel messages and recent warnings/errors.

The first USB-connected samples returned zero current. During the later
discharge cycle current readings worked (including negative discharge current).
The SM5713 driver computes charge_counter from full capacity and SOC. It is not
a hardware coulomb counter. Current times voltage gives sampled battery power,
not USB input power or an independent per-app energy measurement.
Raw SOC resolution is 0.1%. The report shows true
samples, >=5 minute average SOC rates and measurement limits. Identifying a
particular app as the cause requires comparing CPU/wakelock deltas and repeating
the workload, not assigning power from a package name alone.

Rate windows stop at charging-state, power-source or charging-type changes and
sampling gaps over ten minutes. Fastest and slowest charging summaries require
positive SOC rise while Charging with external power; discharge or flat samples
are not labelled charging. Snapshots are published by rename after compression;
an unfinished `.partial` file from shutdown is excluded from the report.

## On-phone controls

Scripts live in `/data/adb/vst-power-audit`; logs in `sessions/` (root-only).
The optional service.d hook resumes an enabled audit after reboot. The logger
continues until stopped, the phone shuts down, or storage protection stops it:
256 MiB log cap / 150 MiB minimum free space. No old logs are silently deleted.

```sh
su -c 'sh /data/adb/vst-power-audit/control.sh status'
su -c 'sh /data/adb/vst-power-audit/control.sh stop'
su -c 'sh /data/adb/vst-power-audit/control.sh start'
```

Unplug the cable and use/idle the phone normally for a discharge baseline.
Plug it back in for a charge cycle. No fake battery state is set. Charging speed
is the net SOC rise at the battery, not USB input power; a USB meter is needed
for accurate adapter wattage/efficiency measurements.

## Local report

Copy the private sessions directory through a root shell into a local archive,
then extract it locally. Install matplotlib in a local virtual environment if
needed; do not copy phone logs into the public repository or release assets.

```sh
python3 tools/power-audit/report.py /path/to/sessions /path/to/report
# Optional Android model estimates and package names:
python3 tools/power-audit/report.py /path/to/sessions /path/to/report \
  --android-stats /private/batterystats.txt --uid-map /private/uid-packages.txt
```

Outputs: HTML report, PNG/SVG plots, measurements.csv, wake-sources.csv and
summary.json. Raw snapshot files remain available for follow-up CPU, radio,
sensor and ANR investigations. With only a few minutes of data, the report will
not invent long-term autonomy or reliable rate comparisons.
