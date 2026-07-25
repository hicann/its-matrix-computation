<!--
Copyright (c) 2026 Southeast University.
This program is free software, you can redistribute it and/or modify it under the terms and conditions of
CANN Open Software License Agreement Version 2.0 (the "License").
Please refer to the License for details. You may not use this file except in compliance with the License.
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.
See LICENSE in the root of the software repository for the full text of the License.
-->
# its-matrix-computation（SimNPU）

> 面向昇腾 NPU 矩阵计算的性能仿真与分块策略搜索工具。

SimNPU 是 CANN 社区 Intelligent Transportation System SIG 维护的矩阵计算仿真项目。项目围绕昇腾 NPU 的 AI Core、多级存储、数据搬运和矩阵分块机制建立性能模型，在不依赖实际 NPU 设备的情况下，估算不同矩阵形状和分块配置下的执行周期与时延，并提供 `fast`、`bayes` 和 `exhaustive` 三种搜索模式。

## 项目概述

矩阵乘法是大模型训练、推理和高性能计算中的核心计算内核。实际执行效率不仅取决于理论峰值算力，还受到矩阵形状、分块策略、数据复用、多级存储容量、数据搬运带宽和调度方式等因素影响。

SimNPU 通过软件仿真方式对上述因素进行建模，主要用于：

- 分析不同矩阵形状下的计算与数据搬运开销；
- 搜索满足存储和对齐约束的矩阵分块方案；
- 比较不同循环顺序和调度策略的预计性能；
- 为昇腾 NPU 上的 GEMM/GEMV 算子调优提供候选配置；
- 在真实硬件测试前缩小配置搜索空间。

> SimNPU 输出的是基于硬件配置和效率曲线得到的仿真估计结果，不能替代真实硬件测试、性能验收或硬件厂商正式结论。

## 核心能力

| 能力 | 说明 |
|---|---|
| NPU 多层硬件建模 | 对 AI Core、L0A/L0B/L0C、L1、L2 和外部存储等关键层级进行参数化描述 |
| 分层矩阵分块 | 根据原始矩阵形状、缓存容量和对齐要求生成合法的 L1/L0 分块配置 |
| 分批调度 | 将矩阵块映射到多个 AI Core，并估算完整批次和尾批次的执行过程 |
| 双缓冲建模 | 模拟计算、预取和结果写回之间的重叠关系 |
| 动态带宽效率 | 根据实际传输数据量查询效率曲线，计算不同存储路径上的有效带宽 |
| 延迟估算 | 综合计算周期、数据读取、片上搬运和结果写回开销估算执行时延 |
| Roofline 估算 | 针对矩阵向量等特殊场景提供 Roofline 参考结果 |
| 三种搜索模式 | 支持快速候选搜索、贝叶斯优化搜索和合法配置穷举搜索 |

## 工作流程

```text
矩阵形状（M、N、K）
        +
硬件配置与带宽效率曲线
        │
        ▼
生成满足容量、边界和对齐约束的候选分块
        │
        ▼
选择 fast / bayes / exhaustive 搜索模式
        │
        ▼
执行分批调度、计算与传输时延仿真
        │
        ▼
输出最优分块、循环顺序、周期和仿真时延
```

## 搜索模式

| 模式 | 搜索方式 | 适用场景 | 注意事项 |
|---|---|---|---|
| `fast` | 在预设的少量候选分块中快速搜索 | 快速验证、初步估算和调试 | 搜索速度快，但不保证覆盖全部合法配置 |
| `bayes` | 在合法分块范围内进行贝叶斯优化 | 在搜索成本和结果质量之间取得平衡 | 依赖 `scikit-optimize`，结果受 `n_calls` 等参数影响 |
| `exhaustive` | 穷举满足边界、容量和对齐要求的候选配置 | 小规模矩阵的最优性核对 | 搜索空间可能很大，不建议直接用于大矩阵全量搜索 |

候选分块需满足代码中定义的缓存容量和数据对齐约束。L1 分块维度通常按 16 对齐，且不会超过原始矩阵对应的 M、N、K 维度上限。

## 版本与环境配套

SimNPU 是 Python 仿真程序，正常运行不要求安装 CANN Toolkit，也不要求连接实际 NPU 设备。仓库当前提供的默认硬件配置面向昇腾 910B1。

| 项目 | 要求或说明 |
|---|---|
| 源码分支 | `master` |
| Python | 3.9 及以上 |
| 默认仿真目标 | 昇腾 910B1 |
| 默认硬件配置 | `data/npu_910B1.json` |
| CANN Toolkit | 非运行必需；本项目不直接调用 CANN Runtime |
| 实际 NPU | 非运行必需 |
| Python 依赖 | 以 `requirements.txt` 为准 |

已验证环境：

| 环境项 | 已验证配置 |
|---|---|
| 操作系统 | Debian GNU/Linux 13 |
| 系统架构 | x86_64 |
| Python | 3.13.5 |
| NumPy | 2.5.1 |
| Pandas | 3.0.3 |
| scikit-optimize | 0.10.2 |

如新增其他昇腾硬件配置，应同步提供硬件参数来源、字段说明、效率曲线及相应验证结果。

## 环境准备

建议在 Python 虚拟环境中安装依赖：

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Windows PowerShell 可使用：

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

## ⬇ 源码下载

```bash
git clone https://gitcode.com/cann/its-matrix-computation.git
cd its-matrix-computation
```

如需复现实验或测试结果，请记录所使用的分支和 Commit ID。

## 快速入门

### 1. 代码语法检查

```bash
python -m py_compile src/*.py
```

### 2. Fast 模式

```bash
python src/test_new_matmul_threemode.py --mode fast
```

### 3. Bayes 模式

```bash
python src/test_new_matmul_threemode.py --mode bayes --n_calls 100
```

`n_calls` 用于设置贝叶斯搜索调用次数。增加调用次数通常会扩大搜索过程，但也会增加运行时间。

### 4. Exhaustive 模式

```bash
python src/test_new_matmul_threemode.py --mode exhaustive
```

穷举模式的运行时间随矩阵规模和合法分块数量快速增长，建议先使用小规模矩阵验证。

### 5. 查看参数说明

```bash
python src/test_new_matmul_threemode.py --help
```

## 输入与输出

### 默认示例输入

当前测试入口的默认矩阵为：

```text
A: [1096, 1600]
B: [1600, 1096]
```

对应矩阵乘法：

```text
[1096, 1600] × [1600, 1096]
```

### 主要输出

程序根据运行模式输出以下信息：

- 矩阵形状；
- 搜索模式；
- 候选或最优 L1 分块；
- 循环顺序；
- Roofline 参考结果；
- 仿真执行周期；
- 仿真时延。

仓库同时提供典型 GEMM 和 GEMV 矩阵维度文件，可用于扩展批量测试。当前测试入口默认执行单个示例矩阵；使用批量矩阵时，应根据脚本中的批量测试逻辑启用相应入口，并确认每个输入均产生独立结果。

## 已验证结果

以下结果来自 2026 年 7 月 6 日的功能测试。不同代码版本、输入矩阵、搜索次数和硬件参数可能产生不同结果。

| 测试项 | 输入或配置 | 结果 |
|---|---|---|
| Python 语法检查 | `python -m py_compile src/*.py` | 所有 Python 文件编译通过 |
| Fast 模式 | 默认矩阵 | 仿真时延 `15.432770 μs` |
| Bayes 模式 | 默认矩阵，`n_calls=15` | 最优分块 `(592, 288, 64)`，循环顺序 `nmk`，仿真时延 `14.696216 μs` |
| Exhaustive 模式 | `256×256` 与 `256×256` | 搜索 24,576 个候选组合，仿真时延 `2.159570 μs` |

上述结果用于说明程序能够正常执行，不代表所有矩阵形状下的性能或精度结论。

## 仿真模型

### 多层硬件结构

仿真模型以 AI Core 和多级存储层次为核心，包括：

- AI Core 与 Cube 矩阵计算单元；
- L0A、L0B 和 L0C 片上缓冲区；
- L1 缓存；
- L2 相关带宽影响；
- 外部存储与结果写回路径。

硬件核心数量、频率、存储容量、访问粒度和理论带宽等参数由配置文件加载。

### 矩阵分块与调度

矩阵乘法会按照硬件容量和对齐约束生成分块方案。仿真过程综合考虑：

- L1 和 L0 分块；
- M、N、K 边界；
- 16×16 等基础计算粒度；
- 输入数据复用；
- 不同循环顺序；
- 多核并行批次；
- 尾批次中的空闲核心。

### 双缓冲与传输

模型可描述计算、下一批数据预取和上一批结果写回之间的重叠。只有无法被计算过程掩盖的传输时间才会作为额外开销计入总时延。

### 动态带宽效率

DRAM→L1、L1→L0A 和 L1→L0B 等路径不直接使用固定峰值带宽，而是根据传输数据量查询对应的效率曲线，再计算有效带宽和传输时延。

### 总时延

总时延主要由以下部分构成：

- 矩阵计算开销；
- 输入读取开销；
- 片上数据搬运开销；
- 结果写回开销；
- 批次调度和边界处理开销。

FixPipe 写回路径在当前模型中采用简化处理，仅保留主要成本。

## 目录结构

```text
its-matrix-computation/
├── src/
│   ├── new_matmul_threemode.py       # Matmul 仿真与三种分块搜索逻辑
│   ├── test_new_matmul_threemode.py  # 测试和性能评估入口
│   ├── hardware.py                   # NPU 硬件结构与参数加载
│   ├── modules.py                    # 计算、IO 与缓存等仿真模块
│   ├── operators.py                  # Operator 基类与基础张量算子
│   └── utils.py                      # Tensor、DataType 和辅助函数
├── data/
│   ├── npu_910B1.json                # 昇腾 910B1 硬件配置
│   ├── OUT2L1_efficiency.csv         # DRAM/OUT 到 L1 的带宽效率曲线
│   ├── OUT2L1_efficiency - roofline.csv
│   │                                  # Roofline 使用的带宽效率数据
│   ├── l12L0A_efficiency.csv         # L1 到 L0A 的带宽效率曲线
│   ├── l12L0B_efficiency.csv         # L1 到 L0B 的带宽效率曲线
│   ├── 101 个矩阵_Input_Shapes.csv   # 典型 GEMM 矩阵形状
│   └── 矩阵向量乘维度.csv             # GEMV 测试矩阵形状
├── image/                             # 结果图和说明图片
├── requirements.txt                   # Python 依赖
├── CONTRIBUTING.md                    # 贡献指南
├── SECURITY.md                        # 安全声明
├── CHANGELOG.md                       # 版本变更记录
├── LICENSE                            # 开源许可证
└── README.md                          # 项目说明
```

> 文件名区分大小写。Linux 环境下请使用仓库中的实际文件名，例如 `l12L0A_efficiency.csv`，避免将小写字母 `l` 误写为大写字母 `I`。

## 核心文件说明

### `src/new_matmul_threemode.py`

实现 `Matmul` 仿真模型、Roofline 估算以及 `fast`、`bayes`、`exhaustive` 三种分块搜索逻辑。

### `src/test_new_matmul_threemode.py`

项目测试和性能评估入口。默认执行一个矩阵乘法示例，并可根据脚本中的任务定义扩展为典型矩阵或 GEMV 批量测试。

### `src/hardware.py`

加载和描述 AI Core 数量、时钟频率、多级存储容量、访问粒度、理论带宽和效率曲线等硬件参数。

### `src/modules.py`

实现计算模块、IO 传输模块和缓存管理等底层仿真组件。

### `src/operators.py`

定义算子通用基类，并提供 `Reshape`、`Concat` 和 `Transpose` 等基础张量操作。

### `src/utils.py`

定义 `Tensor`、`DataType` 等数据结构，以及张量大小计算、约数查找等辅助方法。

## 数据与配置

### 硬件配置

`data/npu_910B1.json` 保存默认仿真目标的硬件参数。修改配置前应确认字段单位、参数来源和合理范围。

### 带宽效率曲线

以下文件用于根据数据传输规模计算有效带宽：

- `data/OUT2L1_efficiency.csv`
- `data/OUT2L1_efficiency - roofline.csv`
- `data/l12L0A_efficiency.csv`
- `data/l12L0B_efficiency.csv`

修改效率数据时，应保留原始测量依据，并重新验证仿真结果。

### 测试矩阵

- `data/101 个矩阵_Input_Shapes.csv`：典型 GEMM 矩阵形状；
- `data/矩阵向量乘维度.csv`：GEMV 场景矩阵形状。

## 已知限制

- 当前仓库默认提供昇腾 910B1 硬件配置，其他硬件需要补充配置和效率数据；
- 仿真精度依赖硬件参数和效率曲线的准确性；
- `exhaustive` 模式在大矩阵上可能产生较高的时间和内存开销；
- Bayes 搜索结果受调用次数和搜索过程影响；
- 当前测试入口默认执行单个矩阵示例，批量数据文件不会在默认命令中自动全部执行；
- README 中的示例结果不能替代逐样本日志、误差统计和真实硬件对比。

## 参与贡献

欢迎提交 Bug 修复、搜索策略、硬件配置、效率曲线、测试用例和文档改进。

提交贡献前，请阅读：

- [贡献指南](CONTRIBUTING.md)
- [安全声明](SECURITY.md)
- [变更记录](CHANGELOG.md)
- [开源许可证](LICENSE)

基本流程：

1. 创建或关联 Issue；
2. Fork 仓库并创建独立分支；
3. 完成代码、测试和文档修改；
4. 提交可复现的测试命令与结果；
5. 发起 Pull Request；
6. 根据检视意见完成闭环。

涉及性能或精度结论的 PR，应同时提供测试环境、Commit ID、输入矩阵、对照方法、原始结果和统计口径。

## 所属 SIG

本项目属于 CANN 社区 [Intelligent Transportation System SIG](https://gitcode.com/cann/community/blob/master/CANN/sigs/intelligent-transportation-system/README.md)。

该 SIG 聚焦交通大数据分析、交通网络优化计算和交通大模型智能决策等场景，推动交通行业相关算子、工具链和示例应用在 CANN 生态中建设与落地。

## 问题反馈与社区交流

- [提交 Issue](https://gitcode.com/cann/its-matrix-computation/issues)
- [查看 Pull Requests](https://gitcode.com/cann/its-matrix-computation/pulls)
- [CANN 社区](https://gitcode.com/cann/community)
- [Intelligent Transportation System SIG](https://gitcode.com/cann/community/blob/master/CANN/sigs/intelligent-transportation-system/README.md)

提交问题时，请提供代码版本、运行环境、执行命令、输入矩阵、完整错误信息和最小复现步骤。

## 许可证

本项目采用仓库根目录 [`LICENSE`](LICENSE) 中声明的开源许可证。使用、修改和分发本项目代码前，请阅读并遵守相应许可条款。
