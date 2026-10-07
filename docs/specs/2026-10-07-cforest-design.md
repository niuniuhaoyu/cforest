# cforest — Stata 版因果森林 / 广义随机森林（GRF）设计（Spec）

> 日期：2026-10-07
> 状态：待审阅（Draft）
> 作者：Haoyu Niu
> 定位：把 Generalized Random Forests（因果森林）带到 Stata，填补生态空白

---

## 1. 背景与目标

**方法**：
- **因果森林**（Causal Forest）：Wager & Athey (2018, JASA) *Estimation and Inference of Heterogeneous Treatment Effects using Random Forests*。
- **广义随机森林**（GRF）：Athey, Tibshirani & Wager (2019, Annals of Statistics) *Generalized Random Forests*。

**它解决什么**：普通 DiD/回归只给**平均效应**。因果森林估计**条件平均处理效应 CATE**：τ(x) = E[Y(1) − Y(0) | X = x]，即"效应**因人而异**长什么样"。

**缺口**：官方实现只有 **R `grf`**（C++ 内核 + Rcpp，GPL-3）和 Python（EconML / `skgrf`）。**Stata 至今没有可用实现**（Statalist 长期有人求）。

**目标**：实现一个**正确、可用、有文档、可复现**的 Stata 包 `cforest`，填补空白，作为作品集**旗舰项目**。

**对齐现有主线**：与 `contdid`/`qdid`/`didc` 同属"前沿因果推断 → Stata"，但难度最高。

---

## 2. 架构决策（关键）

真正的因果森林要长几千棵树 + honest splitting + 方差估计，**纯 Mata 性能不可接受**。三条路线：

| 方案 | 做法 | 优点 | 缺点 |
|---|---|---|---|
| **A. 纯 Mata** | 用 Mata 从零写森林 | 零依赖 | **太慢**，排除 |
| **B. 原生 C++ 插件链 grf 内核** | 写 Stata plugin（SPI）链接 `grf` 的 C++ 核心 | 快、无运行时依赖、正统 | 工程重；跨平台编译分发 |
| **C. Stata 内置 Python 集成 → 调 `skgrf`/`grf`** | `python:` 把数据交给 skgrf | **快速出货** | 用户需装 Python + 包，破坏"零依赖" |

**关键证据**：`skgrf`（PyPI）用 Cython 把 `grf` 的 C++ 内核包成了 Python 绑定 → **证明该内核能脱离 R 复用**。这让方案 B 从"未知"降为"已有人做到"。

**推荐：先 C 后 B（两阶段）**
- **Stage A（Python 桥，周级）**：`cforest` 命令，底层调 `skgrf`。快速把 API/输出/正确性/需求全部试出来，先立住。
- **Stage B（原生插件，月级）**：同样的命令接口，底层换成 C++ plugin 链 grf 内核 → 零依赖、可上 SSC。

---

## 3. v1 范围

### 做（v1）
- **二值处理** + **CATE 估计** τ̂(x)
- **ATE / CATT**、**honest splitting**、**有效方差** σ̂(x)、**OOB 预测**
- 可选：best linear projection（异质性检验）、CATE 图
- 数据：截面 / 观测数据（面板固定效应版留 v2）

### 不做（v2+）
- IV 森林、分位数森林、生存森林、多臂（multi-arm）
- 面板/固定效应因果森林
- 策略价值（policy learning / TOC/AUTOC）——可作 v1 可选加分项

---

## 4. 命令语法（设计）

```
cforest depvar indepvars [if] [in], treat(varname) [options]
```

| 选项 | 默认 | 说明 |
|---|---|---|
| `treat(varname)` | — | 二值处理变量（必填） |
| `numtrees(#)` | 2000 | 树数量 |
| `honesty` / `nohonesty` | honesty | 诚实切分 |
| `mtry(#)` | 自动 | 每次分裂考虑的变量数 |
| `minnodesize(#)` | 5 | 叶最小样本 |
| `sampleratio(#)` | 0.5 | 切分/估计样本比例 |
| `seed(#)` | 固定 | 随机种子（可复现） |
| `ovar(...)` / `predict` | — | CATE 预测新数据 |

- 返回：`e(tau_hat)`（训练样本 CATE）、`e(ate)`、`e(catt)`、`e(tau_se)` 等。
- 向后：与 R `grf::causal_forest` 参数语义对齐。

---

## 5. 验证方案

1. **对拍 R `grf`**：同一模拟数据，固定种子，比较 τ̂(x) 分布、ATE/CATT、方差（容差按实现阶段定）。
2. **已知 CATE 的 DGP**：τ(x) 已知（如 τ(x)=x₁），检验恢复。
3. **校准检验**：CATE 的分层校准 / best linear projection 系数≈1。

---

## 6. 包结构（扁平，支持 net install）

```
cforest/
├── README.md / LICENSE(AGPL-3.0) / CHANGELOG.md
├── cforest.pkg / stata.toc
├── cforest.ado / cforest.sthlp
├── cforest.mata        # Stage A 的桥接/工具
├── examples/           # 示例 + 测试 + R 对拍脚本
└── docs/specs|plans/
```

> Stage B 会新增 **plugin 源码**（C++）+ 各平台二进制。

---

## 7. 许可证与署名

- `grf` 为 **GPL-3**；链接其内核的 plugin 结果按 **GPL/AGPL** 分发（与作者既有包 AGPL-3.0 兼容）。
- **署名红线**：方法归 Athey–Tibshirani–Wager，必须正规引用；不得把方法据为己有。

---

## 8. 交付物与验收

- [ ] Stage A：`cforest`（Python 桥）可跑，对拍 R `grf` 通过
- [ ] Stage B：原生 plugin，`net install` 可用
- [ ] 英文 README / sthlp / 示例 / CHANGELOG
- [ ] 上传 `niuniuhaoyu/cforest`

---

## 9. 边界与未来

- ❌ v1 不做 IV/分位数/生存森林、面板 FE 版
- ✅ v2 候选：面板 FE 因果森林、policy learning、更多 GRF 变体
- ✅ 旗舰定位：**高方差、高上限**——skgrf 的存在已把最大风险降级

---

## 10. 实施顺序

1. 精读 grf / 因果森林识别与 honest splitting、方差估计
2. **决策并打通 Stage A**（Python 桥：Stata `python:` + skgrf）
3. 模拟 DGP + 对拍 R `grf`
4. Stage B：把 grf C++ 内核编译成 Stata plugin（先单平台跑通矩阵进出）
5. 跨平台编译 + `net install` 打包
6. 文档 + 发 SSC / Stata Journal
