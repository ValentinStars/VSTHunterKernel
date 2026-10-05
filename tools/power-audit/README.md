# Passive A51 battery audit

The root recorder keeps minute samples and compressed system snapshots every ten
samples or when charging status changes. It does not acquire a wake lock, set
alarms, wake the display, change charging controls or suppress log messages.
Deep sleep can delay sampling; graphs use actual times. Collection itself has
some overhead, recorded as sample_cost_s; deep snapshots cost additional time.

Captured: SOC, battery voltage/temperature, current readings, power connections,
charging state, available RAM/swap, CPU frequencies, wakefulness, wake-source
counters, process CPU time/RSS, disk/network/interrupt counters, pressure stats,
Android batterystats, ANR, kernel messages and recent warnings/errors.

The inspected SM5713 driver reports current readings of zero and computes
charge_counter from full capacity and SOC. These are not a precise wattmeter or
hardware coulomb counter. Raw SOC resolution is 0.1%. The report shows true
samples, >=5 minute average SOC rates and measurement limits. Identifying a
particular app as the cause requires comparing CPU/wakelock deltas and repeating
the workload, not assigning power from a package name alone.

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
```

Outputs: HTML report, PNG/SVG plots, measurements.csv, wake-sources.csv and
summary.json. Raw snapshot files remain available for follow-up CPU, radio,
sensor and ANR investigations. With only a few minutes of data, the report will
not invent long-term autonomy or reliable rate comparisons.
