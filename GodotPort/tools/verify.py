"""Run Godot import, deterministic gameplay checks and optional two-process LAN test."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

parser = argparse.ArgumentParser()
parser.add_argument('--godot', default=r'C:\Users\HP\Documents\Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64_console.exe')
parser.add_argument('--network', action='store_true')
parser.add_argument('--network-only', action='store_true')
args = parser.parse_args()
project = Path(__file__).resolve().parents[1]
env = os.environ.copy()
env['APPDATA'] = str(Path(tempfile.gettempdir()) / 'GodotRTSPortTests')
env['LOCALAPPDATA'] = env['APPDATA']
Path(env['APPDATA']).mkdir(exist_ok=True)
engine = Path(args.godot)
# Invoke the engine directly on Windows instead of its console forwarding wrapper.
direct_engine = engine.with_name(engine.name.replace('_console.exe', '.exe'))
if direct_engine.exists():
    engine = direct_engine
base = [str(engine), '--headless', '--path', str(project)]

def report(result, label):
    output = result.stdout + result.stderr
    (project / 'docs' / (label + '.log')).write_text(output, encoding='utf-8')
    errors = [line for line in output.splitlines() if 'SCRIPT ERROR' in line or 'FAIL:' in line or ('ERROR:' in line and 'certificate store' not in line)]
    print(output if label != 'import' else '\n'.join(errors) or 'Import passed')
    if result.returncode or errors:
        sys.exit(1)

if not args.network_only:
    report(subprocess.run(base + ['--editor', '--import', '--quit'], env=env, capture_output=True, text=True, timeout=120), 'import')
    report(subprocess.run(base + ['--script', 'res://tests/smoke.gd', '--quit-after', '300'], env=env, capture_output=True, text=True, timeout=120), 'gameplay')
    report(subprocess.run(base + ['--script', 'res://tests/priority.gd', '--quit-after', '300'], env=env, capture_output=True, text=True, timeout=120), 'priority')
if args.network or args.network_only:
    ready_file = project / 'docs/network.ready'
    if ready_file.exists():
        ready_file.unlink()
    host_log = open(project / 'docs/network_host.log', 'w', encoding='utf-8')
    host = subprocess.Popen(base + ['--', '--host', '--network-test'], env=env, stdout=host_log, stderr=host_log, text=True)
    try:
        started = time.monotonic()
        while not ready_file.exists() and host.poll() is None and time.monotonic() - started < 120:
            time.sleep(0.1)
        if not ready_file.exists():
            host.terminate()
            host.wait(timeout=10)
            host_log.close()
            report(subprocess.CompletedProcess(base, 1, (project / 'docs/network_host.log').read_text(encoding='utf-8'), '\nHost did not become ready'), 'network_host')
        client = subprocess.run(base + ['--', '--join', '--network-test'], env=env, capture_output=True, text=True, timeout=120)
        host.wait(timeout=30)
        host_log.close()
        out = (project / 'docs/network_host.log').read_text(encoding='utf-8')
        (project / 'docs/network_client.log').write_text(client.stdout + client.stderr, encoding='utf-8')
        report(subprocess.CompletedProcess(base, host.returncode, out, ''), 'network_host')
        report(client, 'network_client')
    finally:
        if host.poll() is None:
            host.terminate()
        if not host_log.closed:
            host_log.close()
        if ready_file.exists():
            ready_file.unlink()
print('All requested checks passed')
