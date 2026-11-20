#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v iverilog >/dev/null || { echo 'Install Icarus Verilog (iverilog and vvp) first.' >&2; exit 1; }
command -v vvp >/dev/null || { echo 'vvp is required.' >&2; exit 1; }
build_dir="$(mktemp -d "${TMPDIR:-/tmp}/cg3207-tests.XXXXXX")"
echo "Simulation outputs: $build_dir"
cd "$build_dir"
for test_name in tb_ALU tb_Decoder tb_PC_Logic tb_Branch_Prediction tb_MCycle_self_checking tb_RV; do
    echo "Running $test_name"
    top_module="$test_name"
    if [[ "$test_name" == tb_MCycle_self_checking ]]; then top_module=test_MCycle; fi
    iverilog -g2012 -s "$top_module" -o "$test_name.vvp" \
        "$repo_dir/Asst_04/Test_bench/$test_name.v" "$repo_dir"/Asst_04/Src/*.v
    vvp "$test_name.vvp" > "$test_name.log" 2>&1
    cat "$test_name.log"
    # Existing benches report errors with $display, so exit status alone is insufficient.
    if sed -E 's/(^|[^0-9])0 failed/\1/g' "$test_name.log" | grep -Eiq 'fail|timeout|unexpected store'; then
        echo "Failure reported by $test_name" >&2
        exit 1
    fi
done
echo 'All six simulation runs completed without reported failures.'
