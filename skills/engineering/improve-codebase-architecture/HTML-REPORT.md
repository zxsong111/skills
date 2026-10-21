# HTML 报告格式

架构评审渲染为操作系统临时目录中的一个自包含 HTML 文件。Tailwind 和 Mermaid 都从 CDN 引入。Mermaid 能可靠地处理图状的示意图；手搭的 div 和内联 SVG 负责更有编辑感的图示（体量图、剖面图）。两者混着用：不要什么都靠 Mermaid，否则看起来会千篇一律。

## 脚手架

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review for {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* 一小层自定义样式，用于 Tailwind 覆盖不干净的东西：
         虚线接缝、带手绘感的箭头等。 */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## 页头

仓库名、日期，以及一个紧凑的图例：实线框 = 模块（module），虚线 = 接缝（seam），红色箭头 = 泄漏，粗边深色框 = 深模块（deep module）。不要引言段落。直接进入候选。

## 候选卡片

图示扛大梁。文字要少而平实，直接使用（来自 `/codebase-design` skill 的）术语表术语，不必客套。

每个候选是一个 `<article>`：

- **标题**：简短，点明这次加深（例如「收拢 Order 接收流水线」）。
- **徽章行**：推荐强度（`Strong` = emerald，`Worth exploring` = amber，`Speculative` = slate），外加一个依赖类别标签（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **文件**：等宽字体列表，`font-mono text-sm`。
- **前后对比图**：核心部分。两栏，并排。模式见下文。
- **问题**：一句话。哪里疼。
- **方案**：一句话。改什么。
- **收获**：要点列表，每条 ≤6 个词。例如「测试只打一个接口」「定价逻辑不再泄漏」「删掉 4 个浅包装层」。
- **ADR 提示框**（如适用）：琥珀色底框里的一行字。

不要写成段的解释。如果图示需要一段话才能看懂，就重画图示。

## 图示模式

挑选适合该候选的模式。混着用。不要让每张图看起来都一样。多样性本身就是目的的一部分。

### Mermaid 图（依赖 / 调用流程的主力）

当要表达的是「X 调 Y，Y 调 Z，看看这一团乱」时，用 Mermaid 的 `flowchart` 或 `graph`。把它包在一张 Tailwind 样式的卡片里，免得显得是空降来的。用 classDef 把泄漏的边染成红色、把深模块染成深色。时序图很适合表达「之前：6 次往返；之后：1 次」。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### 手搭的方框加箭头（当 Mermaid 的布局跟你作对时）

模块用带边框和标签的 `<div>` 表示。箭头用内联 SVG 的 `<line>` 或 `<path>` 元素，绝对定位在一个相对定位的容器之上。当你想让「之后」的图看起来像一个粗边框的深模块、内部细节呈灰色时，就用这种方式，因为 Mermaid 渲染不出那种恰到好处的分量感。

### 剖面图（适合层层叠叠的浅）

堆叠水平色带（`h-12 border-l-4`），展示一次调用穿过的各层。之前：6 个薄层，每层什么都不做。之后：1 条粗色带，标注合并后的职责。

### 体量图（适合「接口和实现一样宽」）

每个模块两个矩形：一个代表接口表面积，一个代表实现。之前：接口矩形几乎和实现矩形一样高（浅）。之后：接口矩形很矮，实现矩形很高（深）。

### 调用图收拢

之前：一棵函数调用树，渲染成嵌套的方框。之后：同一棵树收拢成一个方框，现在已成为内部调用的部分以淡化的样式显示在框内。

## 样式指引

- 偏向编辑风格，而不是企业仪表盘风格。留白宽松。标题可选用衬线字体（`font-serif` 和 stone/slate 搭配效果很好）。
- 克制用色：一个强调色（emerald 或 indigo），外加红色表示泄漏、琥珀色表示警告。
- 图示高度保持在约 320px，让前后对比图舒服地并排，无需滚动。
- 图示里的模块标签用 `text-xs uppercase tracking-wider`，让它们读起来像示意图，而不是 UI。
- 仅有的脚本是 Tailwind CDN 和 Mermaid 的 ESM 导入。除此之外报告是静态的：没有应用代码，除了 Mermaid 自身的渲染之外没有交互。

## 首要推荐部分

一张更大的卡片。候选名称、一句话说明原因、一个指向其卡片的锚点链接。就这些。

## 语气

语言平实、简洁，但架构上的名词和动词直接取自 `/codebase-design` skill。简洁不是跑偏的借口。

**严格使用：** 模块（module）、接口（interface）、实现（implementation）、深度（depth）、深（deep）、浅（shallow）、接缝（seam）、适配器（adapter）、杠杆（leverage）、局部性（locality）。

**绝不替换成：** 组件、服务、单元（component、service、unit，用来指模块时）· API、签名（signature，用来指接口时）· 边界（boundary，用来指接缝时）· 层、包装层（layer、wrapper，用来指模块、而你的意思就是模块时）。

**符合这种风格的措辞：**

- 「Order 接收模块是浅的：接口几乎和实现一样。」
- 「定价逻辑跨接缝泄漏。」
- 「加深：一个接口，一个测试点。」
- 「两个适配器让这条接缝站得住：生产环境用 HTTP，测试中用内存实现。」

**收获要点**用术语表的术语点明收益：*「局部性：bug 集中在一个模块里」*、*「杠杆：一个接口，N 个调用点」*、*「接口缩小；实现吸收了那些包装层」*。不要写*「更易维护」*或*「代码更干净」*，因为这些说法不在术语表里，也不配占这个位置。

不要含糊其辞，不要清嗓子式的铺垫，不要「值得注意的是……」。一句话能变成要点，就把它变成要点。一个要点能删，就删掉。如果某个术语不在 `/codebase-design` 的术语表里，先去找一个在表里的，再考虑发明新词。
