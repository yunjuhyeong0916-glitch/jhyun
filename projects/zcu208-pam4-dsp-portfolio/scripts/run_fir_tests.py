"""Run the three original FIR equivalence testbenches with Vivado XSim.

Python standard library only. Run from any directory. All generated simulator
files are placed in the ignored work/ directory below this portfolio folder.
"""
from pathlib import Path
import argparse
import datetime
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
TESTS = [
    ('tb_tx_fir32_systolic_equiv', 'TX_FIR32_SYSTOLIC_EQUIV PASS'),
    ('tb_rx_eq21_segmented_transposed_equiv', 'RX_EQ21_SEGMENTED_TRANSPOSED_EQUIV PASS'),
    ('tb_rx_eq21_old_vs_segmented_equiv', 'RX_EQ21_OLD_VS_SEGMENTED_EQUIV PASS'),
]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--vivado-bin', type=Path, required=True,
                        help='Vivado bin directory containing xvlog, xelab and xsim')
    args = parser.parse_args()
    suffix = '.bat' if sys.platform == 'win32' else ''
    executables = {name: args.vivado_bin.resolve() / (name + suffix)
                   for name in ['xvlog', 'xelab', 'xsim']}
    for exe in executables.values():
        if not exe.is_file():
            parser.error(f'Tool not found: {exe}')

    run_dir = ROOT / 'work' / ('fir_' + datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f'))
    run_dir.mkdir(parents=True)
    results = []
    for top, marker in TESTS:
        current = run_dir / top
        current.mkdir()
        commands = [
            [str(executables['xvlog']), '-sv', str(ROOT / 'rtl' / 'pam4_fir_ffe_32lane_filters.sv'),
             str(ROOT / 'tb' / (top + '.sv'))],
            [str(executables['xelab']), top, '-s', 'snapshot', '-debug', 'typical'],
            [str(executables['xsim']), 'snapshot', '-runall'],
        ]
        output = ''
        passed = True
        for index, command in enumerate(commands):
            completed = subprocess.run(command, cwd=current, capture_output=True, text=True,
                                       encoding='utf-8', errors='replace')
            text = completed.stdout + completed.stderr
            (current / f'step_{index}.txt').write_text(text, encoding='utf-8')
            output += text
            if completed.returncode != 0:
                passed = False
                break
        found = re.search(re.escape(marker) + r'[^\r\n]*', output)
        passed = passed and found is not None and not re.search(r'\b(?:FAIL|FATAL|ERROR|MISMATCH)\b', output)
        result = {'test': top, 'status': 'PASS' if passed else 'FAIL',
                  'message': found.group(0) if found else 'Expected PASS marker missing; inspect work logs.'}
        results.append(result)
        print(json.dumps(result), flush=True)

    summary = {'executed_at': datetime.datetime.now().astimezone().isoformat(),
               'scope': 'FIR RTL equivalence simulations only; not MLSD or board implementation signoff',
               'results': results}
    (run_dir / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    print('Summary: ' + str(run_dir / 'summary.json'), flush=True)
    return 0 if all(x['status'] == 'PASS' for x in results) else 1

if __name__ == '__main__':
    raise SystemExit(main())
