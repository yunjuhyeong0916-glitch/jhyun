"""Plot saved RTL-metric recovery CSV (optional matplotlib dependency)."""
import argparse
import csv
from pathlib import Path


def main():
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--g0-q8", type=int, default=192)
    parser.add_argument("--g1-q8", type=int, default=128)
    args = parser.parse_args()
    with args.trace.open(newline="", encoding="utf-8") as f:
        rows = [{k: int(v) for k, v in r.items()} for r in csv.DictReader(f)]
    x = [r["index"] for r in rows]
    levels = [-96, -32, 32, 96]
    slicer = [min(levels, key=lambda level: abs(r["sample"] - ((args.g0_q8*level) >> 8))) for r in rows]
    slicer_errors = [int(a != r["expected"]) for a, r in zip(slicer, rows)]
    rtl_errors = [int(r["recovered_from_rtl_metrics"] != r["expected"]) for r in rows]
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10})
    fig, axes = plt.subplots(3, 1, figsize=(11, 8), constrained_layout=True)
    shown = rows[:64]
    xs = x[:64]
    axes[0].plot(xs, [r["sample"] for r in shown], "o-", color="#246080", markersize=3, linewidth=1)
    axes[0].set(title=f"Synthetic input: g0={args.g0_q8/256:.2f}, g1={args.g1_q8/256:.2f}; noise in [-3, 3]",
                ylabel="Received sample", xlim=(-1, 64))
    axes[1].step(xs, [r["expected"] for r in shown], where="mid", color="#246080", label="Transmitted / expected level")
    axes[1].plot(xs, [r["recovered_from_rtl_metrics"] for r in shown], "x", color="#c35420",
                 markersize=5, label="Recovered from RTL matrices (Python traceback)")
    axes[1].set(ylabel="PAM4 level", xlabel="Symbol index (first 64 of 512)",
                yticks=levels, ylim=(-116, 180), xlim=(-1, 64))
    axes[1].legend(loc="upper right", fontsize=8)
    axes[2].vlines([i for i, error in zip(x, slicer_errors) if error], 0, 1, color="#b4562b", alpha=.7,
                  label=f"Memoryless slicer: {sum(slicer_errors)} / {len(rows)} errors")
    axes[2].plot(x, rtl_errors, color="#246080", linewidth=2,
                 label=f"RTL metrics + Python traceback: {sum(rtl_errors)} / {len(rows)} errors")
    axes[2].set(xlabel="Symbol index (all 512)", ylabel="Symbol error", yticks=[0, 1], ylim=(-.15, 1.45))
    axes[2].legend(loc="upper right", fontsize=9)
    for ax in axes:
        ax.grid(True, alpha=.18)
        ax.spines[["top", "right"]].set_visible(False)
    fig.suptitle("MLSD metric-tile example | actual XSim output matrices | synthetic data", fontsize=13)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.output, dpi=180)
    plt.close(fig)


if __name__ == "__main__":
    main()
