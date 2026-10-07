"""Run deterministic PAM4 examples with the published MLSD metric tile.

Python standard library only. The reference uses all four transitions per state
for memory-0/1 L1 Viterbi decoding. RTL exports sparse branch matrices; Python
checks their arithmetic and min-plus composition, then reconstructs the path.
--audit-adapter separately exercises the full published board adapter and exits
nonzero on a mismatch. Tile PASS does not establish RTL traceback correctness.
"""
from pathlib import Path
import argparse
import csv
import datetime
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LEVELS = [-96, -32, 32, 96]
CASES = {"memoryless": (256, 0), "residual_isi": (192, 128)}
RTL = ["ds_sbmm_rs4_row_min.sv", "ds_sbmm_rs4_apply_xform_rowpipe.sv",
       "ds_sbmm_rs4_metric_tile8_dual_survivor.sv", "ds_sbmm_rs4_xform_export32.sv",
       "ds_sbmm_rs4_trace_shell32_rowpipe.sv", "pam4_fir_ffe_32lane_filters.sv",
       "ds_sbmm_rs4_trace32_board_adapter.sv"]
TB = ROOT / "tb" / "tb_mlsd_adapter_regression.sv"
TILE_TB = ROOT / "tb" / "tb_mlsd_metric_example.sv"
INF = 4095


def reference_decode(samples, g0, g1):
    costs, paths = [0, 10**12, 10**12, 10**12], [[], [], [], []]
    for sample in samples:
        next_costs, next_paths = [], []
        for dest, level in enumerate(LEVELS):
            candidates = [costs[src] + abs(sample - ((g0*level + g1*prev) >> 8))
                          for src, prev in enumerate(LEVELS)]
            src = min(range(4), key=lambda k: candidates[k])
            next_costs.append(candidates[src])
            next_paths.append(paths[src] + [dest])
        costs, paths = next_costs, next_paths
    return paths[min(range(4), key=lambda k: costs[k])]


def load_case(name, g0, g1):
    path = ROOT / "examples" / "mlsd_minimal" / (name + ".csv")
    with path.open(encoding="utf-8", newline="") as f:
        rows = [{k: int(v) for k, v in row.items()} for row in csv.DictReader(f)]
    if len(rows) != 512 or [r["index"] for r in rows] != list(range(512)):
        raise ValueError(f"{name}: expected 512 ordered samples")
    prev = LEVELS[0]
    for row in rows:
        if row["level"] != LEVELS[row["state"]] or abs(row["noise"]) > 3:
            raise ValueError(f"{name}: invalid state, level or noise")
        if row["sample"] != ((g0*row["level"] + g1*prev) >> 8) + row["noise"]:
            raise ValueError(f"{name}: channel arithmetic mismatch")
        if not -128 <= row["sample"] <= 127:
            raise ValueError(f"{name}: sample outside signed 8-bit range")
        prev = row["level"]
    decoded = reference_decode([r["sample"] for r in rows], g0, g1)
    if decoded != [r["state"] for r in rows]:
        raise ValueError(f"{name}: full memory-1 reference does not recover transmitted states")
    slicer = [min(range(4), key=lambda k: abs(r["sample"] - ((g0*LEVELS[k]) >> 8)))
              for r in rows]
    return path, rows, sum(a != r["state"] for a, r in zip(slicer, rows))


def write_hex(name, rows, directory):
    sample_words, expected_words = [], []
    for start in range(0, len(rows), 32):
        packed_samples = packed_expected = 0
        for lane, row in enumerate(rows[start:start+32]):
            # Adapter FIFO order: group 0 occupies bits [511:384].
            bit = (3 - lane//8)*128 + (lane % 8)*16
            packed_samples |= ((row["sample"]*128) & 0xffff) << bit
            packed_expected |= (row["level"] & 0xff) << (lane*8)
        sample_words.append(f"{packed_samples:0128x}")
        expected_words.append(f"{packed_expected:064x}")
    (directory / (name + "_samples.hex")).write_text("\n".join(sample_words)+"\n", encoding="ascii")
    (directory / (name + "_expected.hex")).write_text("\n".join(expected_words)+"\n", encoding="ascii")
    tile_words = [sum(((r["sample"] & 255) << (8*k)) for k, r in enumerate(rows[i:i+8]))
                  for i in range(0, len(rows), 8)]
    (directory / (name + "_tile_samples.hex")).write_text(
        "".join(f"{word:016x}\n" for word in tile_words), encoding="ascii")


def compose(later, earlier):
    product = [[min(min(INF, later[r][k] + earlier[k][c])
                    for k in range(4)) for c in range(4)] for r in range(4)]
    minimum = min(min(row) for row in product)
    return [[v-minimum if v != INF else INF for v in row] for row in product]


def verify_metrics(name, rows, g0, g1, directory, corrupt_expected=False):
    """Check actual RTL CSV, not a second software implementation of pruning."""
    with (directory / (name + "_lane_metrics.csv")).open(newline="", encoding="utf-8") as f:
        entries = [{k: int(v) for k, v in r.items()} for r in csv.DictReader(f)]
    if len(entries) != len(rows)*16:
        raise ValueError("Missing lane matrix entries")
    mats = [[[None]*4 for _ in range(4)] for _ in rows]
    cycles = []
    for e in entries:
        index = e["word"]*8 + e["lane"]
        r, c = e["destination"], e["previous"]
        if not (0 <= e["lane"] < 8 and 0 <= index < len(rows) and 0 <= r < 4 and 0 <= c < 4):
            raise ValueError("Invalid lane matrix coordinate")
        if mats[index][r][c] is not None:
            raise ValueError("Duplicate lane matrix entry")
        mats[index][r][c] = e["metric"]
        metric = abs(rows[index]["sample"] - ((g0*LEVELS[r] + g1*LEVELS[c]) >> 8))
        if e["metric"] != INF and e["metric"] != metric:
            raise ValueError(f"Branch arithmetic mismatch at symbol {index}, row {r}, col {c}")
        cycles.append((e["input_cycle"], e["output_cycle"]))
    for i, mat in enumerate(mats):
        if any(v is None for row in mat for v in row):
            raise ValueError("Incomplete lane matrix")
        if any(all(v == INF for v in row) for row in mat):
            raise ValueError("Destination rescue did not cover every destination")
        for c in range(4):
            distances = [abs(rows[i]["sample"] - ((g0*x + g1*LEVELS[c]) >> 8)) for x in LEVELS]
            threshold = sorted(distances)[1]
            kept = [r for r in range(4) if mat[r][c] != INF]
            if (sum(distances[r] <= threshold for r in kept) < 2
                    or any(mat[r][c] == INF for r in range(4) if distances[r] < threshold)):
                raise ValueError("Nearest-two branch coverage mismatch")
    with (directory / (name + "_block_metrics.csv")).open(newline="", encoding="utf-8") as f:
        blocks = [{k: int(v) for k, v in r.items()} for r in csv.DictReader(f)]
    if len(blocks) != len(rows)//8*16:
        raise ValueError("Missing block matrix entries")
    expected_blocks = []
    for start in range(0, len(rows), 8):
        product = mats[start]
        for mat in mats[start+1:start+8]:
            product = compose(mat, product)
        expected_blocks.append(product)
    seen = set()
    for e in blocks:
        key = e["word"], e["destination"], e["previous"]
        if key in seen or e["metric"] != expected_blocks[key[0]][key[1]][key[2]]:
            raise ValueError("Eight-symbol min-plus composition mismatch")
        seen.add(key)
    # Decode the RTL-exported sparse matrices with a software traceback. The
    # independent full-state reference was checked before simulation in load_case.
    costs, paths = [0, 10**12, 10**12, 10**12], [[], [], [], []]
    for mat in mats:
        choices = [[costs[c] + mat[r][c] if mat[r][c] != INF else 10**12 for c in range(4)]
                   for r in range(4)]
        predecessors = [min(range(4), key=lambda c: choices[r][c]) for r in range(4)]
        costs = [choices[r][predecessors[r]] for r in range(4)]
        paths = [paths[predecessors[r]] + [r] for r in range(4)]
    decoded = paths[min(range(4), key=lambda r: costs[r])]
    expected = [r["state"] for r in rows]
    if corrupt_expected:
        expected[0] = (expected[0]+1) % 4
    errors = sum(a != b for a, b in zip(decoded, expected))
    if errors:
        raise ValueError(f"MLSD_MISMATCH: {errors} recovered level(s) differ")
    trace = directory / (name + "_recovery.csv")
    with trace.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f, lineterminator="\n")
        writer.writerow(["index", "sample", "expected", "recovered_from_rtl_metrics", "input_cycle", "output_cycle"])
        for i, (row, state) in enumerate(zip(rows, decoded)):
            writer.writerow([i, row["sample"], row["level"], LEVELS[state], *cycles[i*16]])
    return {"symbols": len(rows), "lane_metric_entries": len(entries), "block_metric_entries": len(blocks),
            "level_errors": errors, "latency_cycles": sorted(set(b-a for a, b in cycles))}


def execute(command, directory, log):
    proc = subprocess.run(command, cwd=directory, capture_output=True, text=True,
                          encoding="utf-8", errors="replace", timeout=300)
    output = proc.stdout + proc.stderr
    (directory / log).write_text(output, encoding="utf-8")
    return proc.returncode, output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vivado-bin", type=Path)
    parser.add_argument("--check-vectors-only", action="store_true")
    parser.add_argument("--check-failure-path", action="store_true",
                        help="Also require a deliberately corrupted expectation to fail")
    parser.add_argument("--audit-adapter", action="store_true",
                        help="Run full board-adapter regression instead of the bounded tile example")
    args = parser.parse_args()
    cases = {name: load_case(name, *taps) for name, taps in CASES.items()}
    if args.check_vectors_only:
        print(json.dumps({name: {"symbols": len(rows), "reference": "PASS",
                                 "memoryless_slicer_errors": errors}
                          for name, (_, rows, errors) in cases.items()}, indent=2))
        return 0
    if args.vivado_bin is None:
        parser.error("--vivado-bin is required unless --check-vectors-only is used")
    suffix = ".bat" if sys.platform == "win32" else ""
    exe = {n: args.vivado_bin.resolve() / (n+suffix) for n in ["xvlog", "xelab", "xsim"]}
    for path in exe.values():
        if not path.is_file():
            parser.error(f"Tool not found: {path}")
    run_dir = ROOT / "work" / ("mlsd_minimal_" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S_%f"))
    run_dir.mkdir(parents=True)
    for name, (_, rows, _) in cases.items():
        write_hex(name, rows, run_dir)
    top = "tb_mlsd_adapter_regression" if args.audit_adapter else "tb_mlsd_metric_example"
    selected_tb = TB if args.audit_adapter else TILE_TB
    commands = [[str(exe["xvlog"]), "-sv", *[str(ROOT/"rtl"/n) for n in RTL], str(selected_tb)],
                [str(exe["xelab"]), top, "-s", "snapshot", "-debug", "typical"]]
    for i, command in enumerate(commands):
        rc, output = execute(command, run_dir, f"build_{i}.log")
        if rc or re.search(r"\b(?:ERROR|FATAL)\b", output):
            print(f"Build failed; inspect {run_dir / f'build_{i}.log'}", file=sys.stderr)
            return 1
    results = []
    for name, (g0, g1) in CASES.items():
        # Avoid '=' in plusargs: Windows Vivado batch wrappers split those tokens.
        command = [str(exe["xsim"]), "snapshot", "-runall", "-testplusarg", f"CASE_{name}",
                   "-testplusarg", f"G0_{g0}", "-testplusarg", f"G1_{g1}"]
        rc, output = execute(command, run_dir, name + ".log")
        marker = "MLSD_MINIMAL" if args.audit_adapter else "MLSD_TILE"
        match = re.search(marker+r" PASS case=(\w+) words=(\d+) symbols=(\d+) latency_cycles=(\d+)", output)
        passed = rc == 0 and match is not None and not re.search(r"\b(?:ERROR|FATAL|FAIL|MLSD_MISMATCH)\b", output)
        result = {"case": name, "status": "PASS" if passed else "FAIL", "g_q8": [g0,g1,0],
                  "reference": "full four-state memory-1 L1 Viterbi",
                  "memoryless_slicer_errors": cases[name][2]}
        if match:
            result.update(words=int(match[2]), symbols=int(match[3]), latency_cycles=int(match[4]))
        if passed and not args.audit_adapter:
            try:
                result["checks"] = verify_metrics(name, cases[name][1], g0, g1, run_dir)
            except ValueError as error:
                result["status"], result["failure"] = "FAIL", str(error)
        if not passed:
            fatal = re.search(r"Fatal:.*", output)
            result["failure"] = fatal[0] if fatal else "Simulator error or missing PASS marker"
        results.append(result)
        print(json.dumps(result), flush=True)
    negative = None
    if args.check_failure_path and not args.audit_adapter and all(r["status"] == "PASS" for r in results):
        try:
            verify_metrics("memoryless", cases["memoryless"][1], *CASES["memoryless"], run_dir, corrupt_expected=True)
            negative = "FAIL"
        except ValueError as error:
            negative = "PASS" if "MLSD_MISMATCH" in str(error) else "FAIL"
            (run_dir/"negative_control.log").write_text(str(error)+"\n", encoding="utf-8")
        print("Mismatch detection: " + negative, flush=True)
    paths = [ROOT/"rtl"/n for n in RTL] + [selected_tb, Path(__file__).resolve()] + [case[0] for case in cases.values()]
    summary = {"executed_at": datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=9))).isoformat(),
               "scope": ("Full published board adapter; g2=0, EQ bypass, TB=40, two warmup words"
                         if args.audit_adapter else "Published 8-lane RTL metric tile plus Python traceback; synthetic memory-0/1 channels, g2=0"),
               "simulator": "Vivado XSim 2022.2", "clock_period_ns": 8,
               "results": results, "negative_control": negative,
               "sha256": {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}}
    (run_dir/"summary.json").write_text(json.dumps(summary,indent=2)+"\n",encoding="utf-8")
    print("Summary: " + str(run_dir/"summary.json"), flush=True)
    return 0 if all(r["status"] == "PASS" for r in results) and negative != "FAIL" else 1


if __name__ == "__main__":
    raise SystemExit(main())
