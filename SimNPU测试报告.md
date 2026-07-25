<!--
Copyright (c) 2026 Southeast University.
This program is free software, you can redistribute it and/or modify it under the terms and conditions of
CANN Open Software License Agreement Version 2.0 (the "License").
Please refer to the License for details. You may not use this file except in compliance with the License.
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.
See LICENSE in the root of the software repository for the full text of the License.
-->
# SimNPU 测试报告

## 1. 测试基本信息

| 项目 | 内容 |
|---|---|
| 项目名称 | SimNPU |
| 代码来源 | `its-matrix-computation-master.zip` |
| 测试日期 | 2026年7月6日 |
| 测试类型 | 功能测试 |
| 测试结论 | 通过 |

SimNPU 是面向昇腾 NPU 矩阵计算的性能仿真程序，支持 `fast`、`bayes` 和 `exhaustive` 三种矩阵分块搜索模式。本次测试主要验证代码安装、基础编译以及三种模式能否正常运行并输出仿真结果。

## 2. 测试环境

| 项目 | 配置 |
|---|---|
| 操作系统 | Debian GNU/Linux 13 |
| 系统架构 | x86_64 |
| Python | 3.13.5 |
| NumPy | 2.5.1 |
| Pandas | 3.0.3 |
| scikit-optimize | 0.10.2 |
| 仿真目标硬件 | 昇腾 910B1 |
| 硬件配置文件 | `data/npu_910B1.json` |

依赖根据仓库 `requirements.txt` 安装，包含 `numpy`、`pandas` 和 `scikit-optimize`。

## 3. 测试内容及结果

| 编号 | 测试内容 | 测试方法 | 测试结果 | 结论 |
|---|---|---|---|---|
| 1 | 代码编译检查 | 执行 `python -m py_compile src/*.py` | 所有 Python 文件编译通过 | 通过 |
| 2 | Fast 模式 | 执行 `python src/test_new_matmul_threemode.py --mode fast` | 默认矩阵仿真时延为 `15.432770 μs`，程序正常结束 | 通过 |
| 3 | Bayes 模式 | 执行 `python src/test_new_matmul_threemode.py --mode bayes --n_calls 15` | 完成 15 次搜索，最优分块为 `(592, 288, 64)`，循环顺序为 `nmk`，仿真时延为 `14.696216 μs` | 通过 |
| 4 | Exhaustive 模式 | 对 `256×256` 与 `256×256` 矩阵执行 exhaustive 搜索 | 完成 24,576 个候选组合的搜索，仿真时延为 `2.159570 μs` | 通过 |

测试使用的默认矩阵为：

```text
[1096, 1600] × [1600, 1096]
```

## 4. 测试结果汇总

| 测试用例数 | 通过 | 失败 | 通过率 |
|---:|---:|---:|---:|
| 4 | 4 | 0 | 100% |

三种搜索模式均能够正常执行，硬件配置和带宽效率数据能够被程序正常读取，测试过程中未出现异常退出。

## 5. 测试结论

SimNPU 代码包能够在测试环境中完成依赖安装和 Python 编译检查，`fast`、`bayes`、`exhaustive` 三种矩阵分块搜索模式均可正常运行并输出仿真时延结果。本次功能测试通过。
