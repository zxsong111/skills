---
name: implement
description: >
  根据 spec 或一组 ticket 实现一项工作。
disable-model-invocation: true
---

实现用户在 spec 或 ticket 中描述的工作。

如果用户给了 ticket 引用，先从 issue tracker 拉取它，开始前说出它的标题。如果引用有歧义，就问。

在事先约定好的接缝(seam)处，尽可能调用 Skill 工具，参数为 "tdd"。

定期运行类型检查，定期运行单个测试文件，最后跑一次完整测试套件。

完成后，调用 Skill 工具，参数为 "code-review"，审查这项工作。

把你的工作 commit 到当前 branch。
