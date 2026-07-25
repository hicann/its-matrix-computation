<!--
Copyright (c) 2026 Southeast University.
This program is free software, you can redistribute it and/or modify it under the terms and conditions of
CANN Open Software License Agreement Version 2.0 (the "License").
Please refer to the License for details. You may not use this file except in compliance with the License.
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.
See LICENSE in the root of the software repository for the full text of the License.
-->
# SimNPU Test Report

## 1. Basic Test Information

| Item | Details |
|---|---|
| Project Name | SimNPU |
| Source Package | `its-matrix-computation-master.zip` |
| Test Date | July 6, 2026 |
| Test Type | Functional Testing |
| Test Conclusion | Passed |

SimNPU is a performance simulation program for matrix computation on Ascend NPUs. It supports three matrix tiling search modes: `fast`, `bayes`, and `exhaustive`. This test mainly verifies dependency installation, basic Python compilation, and whether the three search modes can run correctly and produce simulation results.

## 2. Test Environment

| Item | Configuration |
|---|---|
| Operating System | Debian GNU/Linux 13 |
| System Architecture | x86_64 |
| Python | 3.13.5 |
| NumPy | 2.5.1 |
| Pandas | 3.0.3 |
| scikit-optimize | 0.10.2 |
| Simulated Target Hardware | Ascend 910B1 |
| Hardware Configuration File | `data/npu_910B1.json` |

The dependencies were installed according to the repository's `requirements.txt`, including `numpy`, `pandas`, and `scikit-optimize`.

## 3. Test Items and Results

| No. | Test Item | Test Method | Test Result | Conclusion |
|---:|---|---|---|---|
| 1 | Python compilation check | Run `python -m py_compile src/*.py` | All Python files compiled successfully | Passed |
| 2 | Fast mode | Run `python src/test_new_matmul_threemode.py --mode fast` | The simulated latency for the default matrix was `15.432770 μs`, and the program exited normally | Passed |
| 3 | Bayes mode | Run `python src/test_new_matmul_threemode.py --mode bayes --n_calls 15` | Completed 15 search iterations. The best tiling configuration was `(592, 288, 64)`, the loop order was `nmk`, and the simulated latency was `14.696216 μs` | Passed |
| 4 | Exhaustive mode | Run an exhaustive search for a `256×256` matrix multiplied by a `256×256` matrix | Completed the search over 24,576 candidate combinations, with a simulated latency of `2.159570 μs` | Passed |

The default matrix multiplication used in the test was:

```text
[1096, 1600] × [1600, 1096]
```

## 4. Test Result Summary

| Total Test Cases | Passed | Failed | Pass Rate |
|---:|---:|---:|---:|
| 4 | 4 | 0 | 100% |

All three search modes executed successfully. The hardware configuration and bandwidth-efficiency data were loaded correctly, and no abnormal program termination occurred during testing.

## 5. Test Conclusion

The SimNPU code package successfully completed dependency installation and Python compilation checks in the specified test environment. The `fast`, `bayes`, and `exhaustive` matrix tiling search modes all ran correctly and produced simulated latency results. The functional test passed.
