<!--
Copyright (c) 2026 Southeast University.
This program is free software, you can redistribute it and/or modify it under the terms and conditions of
CANN Open Software License Agreement Version 2.0 (the "License").
Please refer to the License for details. You may not use this file except in compliance with the License.
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.
See LICENSE in the root of the software repository for the full text of the License.
-->

# Contributing to SimNPU

感谢你对 SimNPU 的关注与贡献。SimNPU 是面向 NPU 矩阵计算的性能仿真工具，支持硬件配置加载、矩阵分块与调度建模，以及 `fast`、`bayes`、`exhaustive` 三种矩阵乘搜索模式。

## 1. 社区贡献流程

SimNPU 作为 CANN 社区相关项目，贡献流程遵循 CANN community 仓中的统一规范。

在参与贡献前，请先阅读并遵守 CANN community 仓中的以下内容：

* 社区行为准则；
* CLA 签署要求；
* Issue 提交流程；
* GitCode 工作流；
* Pull Request 提交流程；
* 代码检视与门禁要求；
* 许可证和安全合规要求。

请参考 CANN community 仓：

```text
https://gitcode.com/cann/community
```

其中，GitCode 工作流可参考：

```text
https://gitcode.com/cann/community/blob/master/contributor/gitcode-workflow.md
```

Issue 操作指南可参考：

```text
https://gitcode.com/cann/community/blob/master/contributor/issue-operation.md
```

## 2. SimNPU 可接受的贡献类型

欢迎以下类型的贡献：

* Bug 修复；
* 新功能或新搜索策略；
* 性能优化；
* 仿真模型、硬件参数或带宽效率模型改进；
* 新增硬件配置文件；
* 测试用例、测试数据与测试报告补充；
* 文档、示例和使用说明改进；
* 安全问题修复；
* 代码重构和工程质量提升。

对于影响仿真公式、时延模型、分块策略、搜索空间或结果精度的改动，请在 PR 中说明理论依据、实现逻辑和验证方法。

## 3. 提交 PR 前的项目检查

除 CANN community 仓统一要求外，向 SimNPU 提交 PR 前，请至少完成与改动相关的本地验证。

### 3.1 安装依赖

```bash
python -m pip install -r requirements.txt
```

### 3.2 Python 语法检查

```bash
python -m py_compile src/*.py
```

### 3.3 基础功能测试

根据改动范围执行对应模式：

```bash
python src/test_new_matmul_threemode.py --mode fast
python src/test_new_matmul_threemode.py --mode bayes
python src/test_new_matmul_threemode.py --mode exhaustive
```

如命令行参数与当前代码实现不一致，请以仓库最新 `README.md` 和脚本帮助信息为准，并同步更新文档。

## 4. 配置、数据和结果要求

涉及 `data/` 目录中的硬件配置、效率曲线或矩阵维度文件时，请在 PR 中说明：

* 修改的配置或数据文件；
* 配置项或数据字段的含义；
* 数据来源；
* 对仿真结果的预期影响；
* 修改前后的关键结果对比。

涉及算法、模型或性能结果的修改时，请提供：

* 测试环境；
* Commit ID；
* 执行命令；
* 输入矩阵或数据集；
* 关键输出结果；
* 修改前后对比；
* 精度或误差统计；
* 必要的日志或结果文件。

不得仅以截图代替可复现的测试命令和原始结果。

## 5. 文档同步要求

出现以下变化时，请同步更新 `README.md` 或相关文档：

* 安装方式变化；
* Python 或依赖版本变化；
* 命令行参数变化；
* 目录结构变化；
* 配置字段变化；
* 搜索模式或默认参数变化；
* 输入输出格式变化；
* 新增硬件配置；
* 已知限制变化。

## 6. 安全与合规

请勿在 Issue、PR、代码、配置、日志或测试数据中提交以下内容：

* 密码、Token、私钥；
* 内部地址或敏感路径；
* 个人隐私数据；
* 未授权的第三方代码或数据；
* 与许可证不兼容的内容。

如发现安全问题，请按照 CANN community 仓中的安全问题处理流程进行反馈。

感谢你为 SimNPU 做出的贡献。
