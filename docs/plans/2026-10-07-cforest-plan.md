# cforest — Stata 版因果森林 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 Stata 包 `cforest`，估计二值处理下的条件平均处理效应 CATE，填 Stata 生态空白。

**Architecture:** 两阶段——Stage A 用 Stata 内置 Python 集成调 `skgrf`/`grf` 内核（快速出货）；Stage B 把 `grf` 的 C++ 内核编译成 Stata plugin（SPI），实现零依赖。命令接口两阶段一致。

**Tech Stack:** Stata 19 MP（`D:\Stata\StataMP-64.exe`）+ Python 集成；`skgrf`/`grf`（对拍基准）；后续 C++17 + Stata Plugin Interface；Git/GitHub（`gh` 已装）。

**Spec:** `cforest/docs/specs/2026-10-07-cforest-design.md`

## Global Constraints

- Stata 16+；命令 `cforest`；许可证 AGPL-3.0（链接 GPL-3 的 grf 内核）
- 估计量/参数语义以 R `grf` 为准；**方法署名归 Athey–Tibshirani–Wager**
- 固定默认随机种子，保证可复现
- 遵守 `SOP/SOP_AI辅助编程核验.md`、`SOP/SOP_环境与工具链.md`

## Review Focus

1. **Python 集成可用性**——Stata 是否配好 Python；`skgrf` 是否装得上；不行就换 EconML 或直接 grf。
2. **CATE 的排列/单位对齐**——从 Python 回传 τ̂(x) 时行顺序必须与 Stata 数据一致。（Task 3）
3. **honest splitting 与方差**——最容易写错；必须靠对拍 R `grf` 兜底。（Task 4）
4. **复现**——固定种子后结果可复现。（Task 3）
5. **插件工具链**——Stage B 的 C++ 编译/链接 grf 内核（剥离 Rcpp、vendor Eigen）能否跑通最小矩阵进出。（Task 5）
6. **跨平台二进制**——Stage B 分发要 Windows/mac/Linux 分别编译。（Task 6）

---

### Task 1: 研究 + 骨架

**Files:** `docs/research-notes.md`；包骨架文件（LICENSE/CHANGELOG/.gitignore/cforest.pkg/stata.toc/cforest.ado/sthlp 占位）

- [ ] **Step 1**: 精读 Wager–Athey (2018) 与 Athey–Tibshirani–Wager (2019)，写清：因果森林分裂准则、honest splitting、τ̂(x) 与方差估计、ATE/CATT 定义。写入 notes。
- [ ] **Step 2**: 读 R `grf::causal_forest` 的参数默认与返回；记录对齐目标。
- [ ] **Step 3**: 建目录 + 骨架文件（`write`）；LICENSE 用 contdid 同款 AGPL-3.0。
- [ ] **Step 4**: `which cforest` 冒烟（Stata 批处理）。
- [ ] **Step 5**: Commit。

### Task 2: 模拟 DGP + R grf 参考值

**Files:** `examples/cforest_simdata.do`、`examples/reference/run_grf_check.R`

- [x] **Step 1**: DGP：τ(x) 已知（如 τ(x)=x₁），含混杂；生成 `data/cforest_sim.dta` 并导出 csv。
- [x] **Step 2**: R 装/确认 `grf`，`causal_forest` 跑出 τ̂(x)、ATE/CATT 参考值。
- [x] **Step 3**: Commit。

### Task 3: Stage A — `cforest`（Python 桥）

**Files:** `cforest.ado`、`cforest.mata`（工具）、`examples/_test_cforest.do`

- [x] **Step 1**: 装 Python 侧依赖（`skgrf` 或 EconML；见 Review Focus #1），确认 Stata 能 `python: import`。
- [x] **Step 2**: 写失败测试：已知 τ(x)=x₁ 的 DGP 下，`cforest` 的 CATE 相关性与真值高、ATE 接近真值。
- [x] **Step 3**: 实现 `cforest`：把 X/W/Y 传 Python，跑因果森林，回传 τ̂(x)/ATE/CATT，**保证行对齐**（Review Focus #2）。
- [x] **Step 4**: 实现 `predict`（对新数据出 CATE）+ 固定种子可复现（#4）。
- [x] **Step 5**: 运行测试，预期通过。
- [x] **Step 6**: Commit。

### Task 4: 对拍 R grf

**Files:** `examples/_test_cforest_grf.do`、参考脚本

- [x] **Step 1**: 同一数据、同参数，比较 Stata cforest 与 R grf 的 ATE/CATT、τ̂(x)（容差按实现定）。
- [x] **Step 2**: 记录差异与原因（honest splitting/默认参数/draw 差异）。
- [x] **Step 3**: Commit。

### Task 5: Stage B — 原生 plugin 最小 PoC

**Files:** `plugin/`（C++ 源码 + 构建脚本）

- [ ] **Step 1**: 取 `grf` C++ 内核，剥离 R 依赖、vendor Eigen（参考 `skgrf` 做法）。
- [ ] **Step 2**: 写最小 Stata plugin（SPI）：接收矩阵、调用内核、返回矩阵；本机单平台编出 `.plugin`。
- [ ] **Step 3**: 与 Stage A / R grf 对拍（数值一致）。
- [ ] **Step 4**: Commit。

### Task 6: 文档 + 跨平台 + 发布

- [x] **Step 1**: 英文 README / sthlp / 示例 / CHANGELOG。
- [ ] **Step 2**: 跨平台编译（Win/mac/Linux）+ `net install` 打包（Review Focus #6；见 `docs/stage-b.md`）。
- [x] **Step 3**: push 到 `niuniuhaoyu/cforest`；（可选）发 SSC / Stata Journal。

---

## Self-Review

- **Spec 覆盖**：§2 架构 → Task 3/5；§3 范围 → Task 3/4；§4 语法 → Task 3；§5 验证 → Task 2/4；§6 结构 → Task 1；§8 交付 → Task 6。
- **占位符**：无 TBD；精确方程通过 Task 1 research-notes 落定。
- **Review Focus**：6 条分别落到 Task 3（#2/#4）、Task 4（#3）、Task 5（#5）、Task 6（#6）、Task 3 Step1（#1）。
