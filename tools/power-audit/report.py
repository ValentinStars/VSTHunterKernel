#!/usr/bin/env python3
"""Build local battery charts and wake-source summaries from passive phone logs."""
import argparse
import csv
import datetime as dt
import html
import json
import math
import tarfile
from collections import Counter
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


def number(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return math.nan


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('sessions', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    rows = []
    for source in sorted(args.sessions.rglob('samples.tsv')):
        with source.open() as f:
            for row in csv.DictReader(f, delimiter='\t'):
                # Discard an incomplete final row from shutdown/power loss.
                if row.get('sample_cost_s') is not None and math.isfinite(number(row['epoch_s'])):
                    rows.append(row)
    rows.sort(key=lambda r: number(r['epoch_s']))
    if not rows:
        parser.error('No complete battery samples found')
    for i, row in enumerate(rows):
        row['net_soc_pct_per_h'] = math.nan
        # Derive a >=5 minute average from the same boot; no instantaneous peak claims.
        for previous in reversed(rows[:i]):
            if previous['boot_id'] != row['boot_id']:
                break
            elapsed = number(row['epoch_s']) - number(previous['epoch_s'])
            if elapsed > 1800:
                break
            if elapsed >= 300:
                delta = number(row['raw_soc_x100']) - number(previous['raw_soc_x100'])
                row['net_soc_pct_per_h'] = delta / 100 * 3600 / elapsed
                break
    with (args.output / 'measurements.csv').open('w') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    times = [dt.datetime.fromtimestamp(number(r['epoch_s']), dt.timezone.utc) for r in rows]
    fig, axes = plt.subplots(6, 1, figsize=(14, 17), sharex=True, layout='constrained')
    series = [
        (0, 'raw_soc_x100', .01, 'Raw SOC (%)', '#2463ab'),
        (0, 'capacity_pct', 1, 'Android capacity (%)', '#69a93a'),
        (1, 'net_soc_pct_per_h', 1, 'Net SOC rate (%/h, >=5 min average)', '#7a3da0'),
        (2, 'voltage_uv', .000001, 'Battery voltage (V)', '#c17719'),
        (3, 'temp_deci_c', .1, 'Battery temperature (°C)', '#b73834'),
        (4, 'mem_available_kb', 1/1024, 'Available RAM (MiB)', '#237d72'),
        (5, 'current_ua', .001, 'Driver battery current (mA)', '#444444'),
    ]
    boots = list(dict.fromkeys(r['boot_id'] for r in rows))
    for axis, key, scale, label, color in series:
        for boot in boots:
            values = [number(r.get(key))*scale if r['boot_id']==boot else math.nan for r in rows]
            # Missing measurements and >10 minute sampling gaps are not interpolated.
            segments = []
            start = 0
            for i in range(1, len(rows)):
                if number(rows[i]['epoch_s'])-number(rows[i-1]['epoch_s']) > 600:
                    segments.append((start,i));start=i
            segments.append((start,len(rows)))
            for start,end in segments:
                axes[axis].plot(times[start:end], values[start:end], '.-', ms=3, lw=1,
                                color=color, label=label if boot==boots[0] and start==0 else None)
        axes[axis].set_ylabel(label.split(' (')[0])
    for axis in axes:
        axis.grid(alpha=.25)
        axis.legend(loc='upper left', fontsize=8)
        for i in range(1, len(rows)):
            if rows[i]['boot_id'] == rows[i-1]['boot_id'] and any(number(rows[i].get(k))==1 for k in ['usb_online','ac_online','wireless_online']):
                axis.axvspan(times[i-1], times[i], color='#bcd7ec', alpha=.2)
    axes[1].axhline(0, color='gray', lw=.7)
    current_present = any(number(r['current_ua']) != 0 and math.isfinite(number(r['current_ua'])) for r in rows)
    if not current_present:
        axes[5].text(.5,.5,'All driver current readings are zero: consumption is NOT zero.',
                     transform=axes[5].transAxes, ha='center', va='center', color='darkred')
    axes[-1].xaxis.set_major_formatter(mdates.DateFormatter('%d %H:%M', tz=dt.timezone.utc))
    axes[-1].set_xlabel('UTC; blue shading = external power connected, not necessarily charging')
    fig.suptitle('Galaxy A51 passive battery audit — measured samples and SOC-derived rates')
    fig.savefig(args.output / 'battery.png', dpi=160)
    fig.savefig(args.output / 'battery.svg')
    plt.close(fig)
    wake_totals = Counter()
    warning_lines = Counter()
    previous_wakes = {}
    previous_cpu = {}
    cpu_totals = Counter()
    for archive in sorted(args.sessions.rglob('snapshot-*.tar.gz')):
        with tarfile.open(archive, 'r:gz') as t:
            wakes = {}
            cpu = {}
            for member in t.getmembers():
                if not member.isfile() or member.size > 20_000_000:
                    continue
                if member.name.endswith('/wakeup.tsv'):
                    content=t.extractfile(member).read().decode(errors='replace')
                    for line in content.splitlines():
                        cells=line.split('\t')
                        if len(cells)==7:
                            value=number(cells[5])
                            if math.isfinite(value):wakes[(cells[0],cells[1])]=value
                elif member.name.endswith('/processes.txt'):
                    content=t.extractfile(member).read().decode(errors='replace')
                    for line in content.splitlines()[1:]:
                        fields=line.split()
                        if len(fields)==5 and fields[0].isdigit():
                            try:
                                elapsed=0
                                for chunk in fields[4].split(':'): elapsed=elapsed*60+float(chunk)
                                cpu[(fields[0],fields[1],fields[2])]=elapsed
                            except ValueError:
                                pass
                elif member.name.endswith('/logcat-warnings.txt'):
                    content=t.extractfile(member).read().decode(errors='replace')
                    for line in content.splitlines():
                        fields=line.split(None,6)
                        if len(fields)==7:warning_lines[fields[5]+' '+fields[6][:200]]+=1
            # Counters reset on boot; keep deltas within a single session only.
            session=str(archive.parent)
            old=previous_wakes.get(session,{})
            for key,value in wakes.items():
                if key in old and value>=old[key]:wake_totals[key[1]]+=value-old[key]
            previous_wakes[session]=wakes
            old_cpu=previous_cpu.get(session,{})
            for key,value in cpu.items():
                if key in old_cpu and value>=old_cpu[key]:
                    cpu_totals[key[1]+':'+key[2]]+=value-old_cpu[key]
            previous_cpu[session]=cpu
    with (args.output/'wake-sources.csv').open('w') as f:
        w=csv.writer(f);w.writerow(['source','observed_active_time_delta_ms'])
        w.writerows(wake_totals.most_common())
    finite_rates=[r for r in rows if math.isfinite(r['net_soc_pct_per_h'])]
    worst=sorted(finite_rates,key=lambda r:r['net_soc_pct_per_h'])[:10]
    best=sorted(finite_rates,key=lambda r:r['net_soc_pct_per_h'],reverse=True)[:10]
    summary={'samples':len(rows),'boots':len(boots),'driver_current_nonzero_seen':current_present,
             'first_utc':times[0].isoformat(),'last_utc':times[-1].isoformat(),
             'highest_net_discharge_windows':[{k:r[k] for k in ['epoch_s','net_soc_pct_per_h','status','wakefulness','temp_deci_c']} for r in worst],
             'highest_net_charge_windows':[{k:r[k] for k in ['epoch_s','net_soc_pct_per_h','status','charging_type']} for r in best],
             'top_wakeup_active_ms':wake_totals.most_common(20),
             'top_observed_process_cpu_seconds':cpu_totals.most_common(20),
             'repeated_warning_text_in_snapshots':warning_lines.most_common(30)}
    (args.output/'summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2,allow_nan=False))
    description='''<h1>Galaxy A51 — статистика батареи</h1>
<p>Голубой фон: внешний источник подключён. Это не доказывает, что батарея заряжается.</p>
<p>Темп SOC — среднее за фактический интервал от 5 до 30 минут, а не мгновенные пики мощности.
Драйвер вычисляет charge_counter из ёмкости и SOC. Нулевой ток не означает нулевой расход.
Пропуски и перезагрузки не соединяются выдуманными измерениями.</p>
<p>Wakelock/CPU/ошибки — кандидаты для проверки причин, а не точное распределение ватт по приложениям.
Снимки logcat перекрываются: частоты строк — повторяемость в снимках, не число уникальных событий.</p>'''
    (args.output/'report.html').write_text('<!doctype html><meta charset="utf-8"><title>A51 battery audit</title>'+description+
        '<img src="battery.svg" alt="Графики батареи" style="max-width:100%">'+
        '<h2>Сводка</h2><pre>'+html.escape(json.dumps(summary,ensure_ascii=False,indent=2))+'</pre>')
    print(args.output/'report.html')

if __name__=='__main__':
    main()
