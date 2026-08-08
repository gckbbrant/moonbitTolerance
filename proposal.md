# moonbitTolerance｜MoonBit 机械公差分析引擎

## 项目目标

moonbitTolerance 面向机械设计、工艺和质量检测工具，提供可嵌入的尺寸链、公差叠加与装配间隙分析核心。项目不试图替代 CAD，而是把工程软件中经常重复实现、却适合独立复用的数值计算抽成清晰的 MoonBit API，让上层 CAD 插件、工艺脚本和检测服务可以共享同一套可复现结果。

## 首期交付

首期完成 `Dimension`、`Chain`、`AnalysisResult` 和方向模型；支持一维有向尺寸链、最坏情况法、RSS 统计法和确定性蒙特卡洛抽样。结果包含名义值、上下限、均值、标准差、合格率和敏感度数据，并提供可运行 CLI 示例。所有随机分析显式接受种子，测试可稳定复现；边界条件和非法输入有测试覆盖。

## 技术路线与扩展

MoonBit 的代数数据类型适合表达尺寸方向和后续 GD&T 约束，轻量包边界便于被其他 MoonBit 工具直接依赖。下一阶段加入二维投影/向量尺寸链、可配置分布、JSON/CSV 适配器与装配间隙约束；再向基准、位置度、同轴度和圆跳动扩展。扩展会保持计算核心与输入输出解耦，避免首期 API 被某一种 CAD 格式绑定。

## 生态价值与质量保证

当前 Mooncakes 中可见的相关项目主要是通用数学、几何或工程辅助库，未发现以机械尺寸链三类分析为核心的成熟同类包。本项目将以 Apache-2.0 发布，提供 README、示例、接口生成文件、问题记录和持续集成；CI 执行格式检查、`moon check --deny-warn`、`moon info` 与测试。代码按真实里程碑公开演进，保持单一作者身份和可审计提交历史。

## 计划与验收

第一阶段完成核心类型及极值/RSS；第二阶段完成确定性蒙特卡洛、敏感度和 CLI；第三阶段补充文档、CI、示例和 Mooncakes 发布准备。验收标准是新用户能按 README 在本地运行示例，核心测试在 wasm-gc 后端通过，结果对固定种子稳定，公共接口具备进一步接入二维链和 GD&T 的空间。

## 仓库

- GitHub: https://github.com/gckbbrant/moonbitTolerance
- GitLink: https://gitlink.org.cn/gckbbrant/moonbitTolerance
