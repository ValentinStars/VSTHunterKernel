# Network traffic indicator layout loop

Observed on SM-A515F, EvolutionX-16.0-20260221-a51-11.6.1-Vanilla-Unofficial.
Installed SystemUI APK SHA-256:
`20e48f894c1a6d3905abf047f45d1962c8da1b6ec35c7b7865eaa79472ef726b`.

While the phone was Dozing, NetworkTraffic and StatusIconContainer repeatedly
requested layout during layout. The widget alternated between widths 78 and 0.
The installed classes2.dex confirms that setVisibleState calls updateVisibility,
and setFixedWidth depends on mVisible. Container overflow therefore changes the
space needed by the same child it is positioning.

A controlled configuration test produced:

| Configuration | Observation |
| --- | --- |
| Arrows visible, 12 seconds | 1278 improper requestLayout warnings |
| Arrows hidden, 12 seconds | 0 warnings |
| Arrows restored, 8 seconds | 448 warnings |

The workaround now applied is `settings put system network_traffic_hidearrow 1`.
The speed indicator stays enabled; only its arrows are hidden. To restore them:
`settings put system network_traffic_hidearrow 0`. This does not change LiveBoot,
log levels or collection. It may avoid overflow in this layout; different font,
icon or display settings can still trigger the underlying bug. Battery savings
have not yet been measured.

A separate 20-second comparison kept the same SystemUI PID and Dozing state:
arrows hidden used 1.65 CPU seconds (8.2% of one core); arrows visible used 9.31
CPU seconds (46.3%). Arrows were hidden again afterward. This supports a CPU
cost from the loop; these short, sequential windows do not establish battery
runtime or precise energy savings.

`tools/rom/NetworkTraffic-width.patch` proposes a source fix: retain an active
indicator's width when the container hides it for overflow, and use INVISIBLE
instead of GONE in that state. Inactive traffic can still use GONE. Width updates
keep their existing equality guard.

The patch targets [Evolution-X frameworks_base bka source](https://github.com/Evolution-X/frameworks_base/blob/bka/packages/SystemUI/src/com/android/systemui/statusbar/NetworkTraffic.java).
It has not been compiled or installed. Apply it to the matching ROM source and
build SystemUI with that ROM's signing setup. Check icon overflow, active/idle
traffic, auto-hide, arrows, font scaling, RTL and AOD transitions. The kernel
workflow does not build SystemUI. The local APK used for inspection was removed;
no proprietary ROM APK is included in this repository.
