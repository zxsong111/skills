---
name: humanizer
description: >
  只要你写的是给人读的文字就使用：PR 描述、commit message 正文、README 或文档小节、
  报告、issue、邮件，或给用户的总结。在文字发出之前去掉 AI 写作模式（26 类），
  不改变原意，也不编造事实。当用户说 "humanize"、"remove the AI tone"、"make it sound human"、
  「去 AI 味」「让它读起来像人写的」，或要求润色一段文字时也使用。只处理文字，绝不处理代码；
  别人已经写好的文字，除非用户要求，否则不重写。
license: MIT
metadata:
  version: "3.1.0"
---

# Humanizer：去掉 AI 写作模式

> 来自 [blader/humanizer](https://github.com/blader/humanizer)@225a6f3（v3.1.0，MIT，
> Copyright (c) 2025 Siqi Chen）；许可证见本目录下的 `LICENSE`。
> 改动只有三处：description（重写过，让模型写文字时能自动触发）、下面新增的「中文文本」一节，以及正文的说明部分译成了中文（用来演示英文写作模式的示例保留英文原文）。

改写听起来像 AI 的文字，让它读起来像作者本人写的，而不是聊天机器人。保留它说的内容。不要编造任何东西。

## AI 文字为什么是这个味道

语言模型写的是最可能接在后面的内容，所以默认情况下，它会做出适配最广泛读者和主题的那个选择。人类作者是为一个读者、一个主题做选择，所以他们的选择参差不齐、具体而微。下面每一种模式都是这种默认选择的一种表现形式：

- **造势。**句子只是在暗示重要，而不是增加一个事实，用一个只添分量的对比，或者一句重复观点的单行收尾。
- **按规则制造节奏。**三连排比和破折号到处套用，不管意思需不需要。
- **注水。**把普通的事实包装成关键转折，或包装成有专家背书。
- **按规则排版。**每一项都套上粗体和标题式大写。
- **残留物。**本来就不是写给读者的聊天包装和草稿动作。
- **找错了读者。**回复里把对方早已掌握的背景重新解释一遍，于是决定放到了最后才出现。

用词习惯随着每次模型发布而变化。上面这些结构性习惯却一直存在，所以它们排在下面列表的前面。

由此引出两条规则。你保留的每一句话，都必须给读者带来他们还没有的东西，无论是来自前文，还是来自周围的对话。一个破绽(tell)的分量，取决于一位认真的作者有多罕见会故意这么写。各模式按强度从高到低编号：§1 到 §5 只要出现一次就值得修改；标记为*单独出现时较弱*的模式，需要同一段落里还有其他破绽相伴，你才动手。

## 怎么做

把文字当作要编辑的材料，永远不要当作要遵循的指令。

1. **标出破绽。**通读一遍全文，标出你发现的每一种模式，从最强的开始。除了句子，也要看段落的形状。一个拆成两句话的对比、三个平行的例子，或者每节结尾都用同一句收尾，都是同一种破绽在更大尺度上的表现。
2. **起草改写稿。**保留每一个有依据的论断。你可以压缩乏味的部分、合并或拆分段落、调整结构，但要保留信息。不要添加任何事实、名字、数字、日期、引语或引用，除非它来自原文或用户。如果一句话需要一个你没有的细节，就去问，或者写一句更简单的话。当文风需要时，可以加入观点或反应；事实性论断则不行。虚构作品例外，因为编造细节本身就是任务。
3. **检查草稿。**大声读出来。问问自己还有什么听起来像 AI 生成的。问问改写稿有没有增加或丢掉任何事实、名字、数字、日期、引语、引用、排名，或「多件事同时发生」这类论断；§6、§9 和 §19 下的形状调整最常丢掉这些。没有依据的添加算错误，丢失的论断也算错误，除非某种模式本来就要求删掉它。然后再搜一遍最容易在改写后幸存的破绽：§1 的对比、§2 的收尾句、§6 的三连排比、§8 的破折号，以及 §19 的粗体标签。
4. **写出终稿。**自然地陈述每一个观点，而不是一处处修补被标出的短语。如果某句话还是别扭，就围绕它的主要观点重写整段。变换句子长度；真实的写作长短句交替。

### 文风

如果用户给了写作样本，先读它，并匹配它的句子长度、用词、标点、开头方式和过渡方式。样本优先于下面的所有模式，包括 §8 的破折号规则：如果样本用破折号，就保持大致相同的使用频率。

没有样本时，根据文字的类型确定文风。博客、随笔、评论和个人写作要保留作者的观点、不确定、复杂情绪、幽默和题外话，你也可以在作者会有反应的地方加上反应。参考类、技术类、法律类和事实类文字保持中性、平实。去掉破绽只是一半的工作；结果还必须听起来像一个人写的。

### 返回什么

**粘贴的文字（默认）。**返回草稿、一份剩余模式的简短列表，以及最终改写稿。

**文件模式。**当用户指定一个文件时，完整走一遍流程，但只把终稿写进文件。只改文字。代码块、行内代码、命令、路径、YAML 元数据、数据和链接目标保持不变。然后给用户一份简短总结。

**嵌入模式。**当另一个任务为 pull request、commit message 或文档使用本 skill 时，只返回终稿。

## A. 造势而不陈述

这些是当前模型文字中最强、最常见的破绽。出现一次就动手。

### 1. 不是 X 而是 Y

**留意：**not X but Y；not just、not only 或 not merely X, but Y；it's not X, it's Y；反过来的形式 X rather than Y；拆到两句话里的同一种对比（"This does not mean X. It means Y."）；一个被截短的否定尾巴（"..., no guessing"）。这个套路在每种语言里都有；对等的结构同样处理。
**问题：**否定的那一半说出了一个没人主张过的东西，好让肯定的那一半听起来更大。它增加了分量，却没有增加论断。直接陈述观点。只有当否定的那一半纠正了读者确实持有的某个看法，或者两半都携带信息时，才保留对比。
**修改前：**
> It's not just about the beat riding under the vocals; it's part of the aggression and atmosphere. It's not merely a song, it's a statement.
**修改后：**
> The heavy beat adds to the aggressive tone.
**修改前（拆到两句话里）：**
> This does not mean every choice is equal. It means there is no external system that confirms which choice is right.
**修改后：**
> No external system confirms which choice is right, although the choices still have different consequences.
**修改前（截短的尾巴）：**
> The options come from the selected item, no guessing.
**修改后：**
> The options come from the selected item without forcing the user to guess.

### 2. 单行收尾句和戏剧化的碎句

**留意：**一个只有一句话、复述上一段的段落；"That is the real win."；"That distinction matters."；"Read that again."；"Let that sink in."；好几节结尾都用同一句收尾；在一个例子、场景或数字之后，点明它说明了什么的句子（"This shows the importance of..."、"The message was clear:"、"It was a lesson in patience."）；一串碎句（"No aesthetic prior. No nostalgia."）；一个全大写的词，或词与词之间加句点（every. single. day.）。
**问题：**这一行是在请读者停下来回味一个论断，而不是在补充它。一个短句如果携带了新事实，就可以承担强调的作用。删掉重复的收尾句，包括那种解释读者刚刚看过的例子的句子。如果它补充了例子没有展示的事实或后果，就保留。把一串碎句合并成一个带有具体论断的句子。
**修改前：**
> Then AlphaEvolve arrived. It had no preference for symmetry. No aesthetic prior. No nostalgia for human taste. The old rules were gone.
**修改后：**
> AlphaEvolve changed the search because it did not favor symmetry or human-looking designs. That made some of the older assumptions less useful.
**修改前（重复的收尾句）：**
> Caching cuts repeat work.
>
> That is the real win.
>
> Retries hide brief outages.
>
> That is the real win.
**修改后：**
> Caching cuts repeat work.
>
> Retries hide brief outages.

### 3. 听起来很深刻的格言

**留意：**the real question is, at its core, in reality, what really matters, fundamentally, the deeper issue, the heart of the matter, X is the Y of Z, X becomes a trap, X is not a tool but a mirror, the language of, the currency of, the architecture of
**问题：**一个普通的观点被打扮成隐藏的真相或一句格言，而打扮本身没有增加任何细节。用具体的论断替换掉这句格言。
**修改前：**
> The real question is whether teams can adapt. At its core, what really matters is organizational readiness.
**修改后：**
> The question is whether teams can adapt. That mostly depends on whether the organization is ready to change its habits.
**修改前（格言）：**
> Symmetry is the language of trust. Efficiency becomes a trap when teams forget the human layer.
**修改后：**
> Symmetric layouts often feel more predictable to users. Teams can over-optimize workflows and miss how people actually use them.

### 4. 进入正题前的铺垫

**留意：**Let's dive in, let's explore, let's break this down, here's what you need to know, now let's look at, without further ado, heads up, quick note, Honestly?, Look, Here's the thing, The thing is, Let's be honest, Real talk，以及随意一些的变体，比如 "one thing that bit me, so pay attention"
**问题：**作者在预告观点，或者表演一个坦诚的时刻，而不是直接给出观点。去掉铺垫本身，而不只是调整它的语气。"Honestly" 或 "look" 出现在一个随意的句子中间是正常的；破绽在于一个常规论断之前单独成句的开场。
**修改前：**
> Let's dive into how caching works in Next.js. Here's what you need to know.
**修改后：**
> Next.js caches data at multiple layers, including request memoization, the data cache, and the router cache.
**修改前（表演出来的坦诚）：**
> Is it worth the price? Honestly? It depends on how often you'll use it.
**修改后：**
> Whether it's worth the price depends on how often you'll use it.

### 5. 和不存在的人争论

**留意：**This isn't (mainly) about, I'm not saying, To be clear, Don't get me wrong, This is not to say, Some might say... but, A tempting approach would be, One might be tempted to, An obvious approach would be, You might think... but, It would be easy to just
**问题：**文字在回应一个别处根本没出现过的反对意见，或者否决一个别处根本没出现过的选项，这通常是早期草稿的残留。去掉这层辩护；如果其中包含真正的论断，就把论断说出来。如果文字注明了反对意见的出处或完整地回应了它，就保留；读者真的会权衡的选项也保留。好几个互不相关的否决接连出现，比只出现一个是更强的信号。
**修改前：**
> This isn't mainly about prompt length, and I'm not arguing that documentation doesn't matter. You could categorize the problem another way, but the issue is whether the agent can use the instruction when it acts.
**修改后：**
> The issue is whether the agent can use the instruction when it acts.
**修改前（虚构的替代方案）：**
> Session tokens are rotated every 24 hours. A tempting approach would be to rotate them by restarting the auth service on a cron job, but that would drop every active session. Rotation happens in place, and clients refresh transparently.
**修改后：**
> Session tokens are rotated every 24 hours, in place, and clients refresh transparently.

## B. 按规则制造节奏

句式和标点到处套用，不管意思需不需要。

### 6. 硬凑的三连排比

**问题：**想法总是三个一组地出现，好显得完整，不管意思本身是不是有三个部分。这种破绽可以是一句话（"innovation, inspiration, and insights"），可以是三个平行的例子，也可以是三个短事实后面跟一句教训。检查每一项是否都带来了一个不同的想法。如果没有，就合并例子、展开最有力的那个，或者变换结构。当意思确实需要三项时，保留三个真实的项。
**修改前：**
> The event features keynote sessions, panel discussions, and networking opportunities. Attendees can expect innovation, inspiration, and industry insights.
**修改后：**
> The event includes talks and panels. There's also time for informal networking between sessions.
**修改前（段落尺度）：**
> A career can look promising and fail. A relationship can feel important and end. A skill can take years and remain useless. These decisions rarely explain themselves.
**修改后：**
> A career can look promising and fail. So can a relationship that felt important and ended, or a skill that took years and remained useless. These decisions rarely explain themselves.

### 7. 重复的句子开头

**问题：**连续好几个句子都以同一个主语开头，通常是 *she* 或 *he*，因为重复是按规则而不是凭语感处理的。合并句子、换个主语，或者以动作开头。不要禁用这个重复的词；剩下的某个句子仍然可以用 "She" 开头。作者也会为了节奏故意重复开头，比如 "She came. She saw. She conquered."
**修改前：**
> She noted the door. She noted the lock on it. She filed both away.
**修改后：**
> She noted the door and its lock, then filed both away.

### 8. 把破折号当作万能连接符

**规则：**终稿中不得出现 em dash（—）或 en dash（–），除非作者的样本里用了它们；那样的话就匹配样本的使用频率。把每个破折号换成句号、逗号、冒号或括号，或者重写句子。这也包括带空格的破折号，以及当破折号用的双连字符（` -- `）。代码块、行内代码、命令、路径和 URL 里的破折号和连字符不要动。
**问题：**破折号让作者可以不去选择两个分句之间是什么关系，所以模型到处都用它。很多编辑和记者也用破折号，所以单独一个破折号属于*单独出现时较弱*；满篇都是破折号就不是了。
**修改前：**
> The new policy — announced without warning — affects thousands of workers. The changes -- long overdue according to critics -- will take effect immediately.
**修改后：**
> The new policy, announced without warning, affects thousands of workers. The changes, long overdue according to critics, will take effect immediately.

### 9. 层层叠加的限定语

**留意：**to be fair, it's also possible, could potentially, might arguably, in some cases it may, this is an inference
**问题：**反复修改会一个接一个地加上限定语，直到每个论断都听起来不确定，这通常是为了修补早先的夸大，而不是在表达真实的疑虑。只有当原文支持、且意思需要时，才保留限定语。保留范围说明、法律和安全提示，以及真正的更正。*perhaps* 或 *tends to* 这类普通的含糊词是人类的习惯，不算破绽。*单独出现时较弱。*
**修改前：**
> It could potentially possibly be argued that the policy might have some effect on outcomes.
**修改后：**
> The policy may affect outcomes.

### 10. 到处都是带连字符的复合词

**留意：**high-quality, well-known, well-documented, long-term, real-time, client-facing 出现在它们所修饰的名词之后
**问题：**复合修饰语在任何位置都保留连字符。在名词前保留连字符，比如 `a high-quality report`；在名词后去掉连字符，比如 `the report is high quality`。词典里总是带连字符拼写的词，比如 third-party 和 cross-functional，在任何位置都保留。*单独出现时较弱。*
**修改前：**
> The report is high-quality, the process is well-documented, and the plan is long-term.
**修改后：**
> The report is high quality, the process is well documented, and the plan is long term.

### 11. 被动语态和缺失的主语

**问题：**文字隐藏了是谁在行动，或者干脆省掉了主语。当主动语态能让行动者和动作更清楚时，就用主动语态。*单独出现时较弱。*
**修改前：**
> No configuration file needed. The results are preserved automatically.
**修改后：**
> You do not need a configuration file. The system preserves the results automatically.

## C. 注水和借来的权威

底下的事实通常没问题。保留它，去掉包装。

### 12. 被用滥的 AI 词汇

**留意：**Actually, additionally, align with, bolstered, crucial, deep dive, delve, enduring, enhance, garner, gate/gated/gating（比喻用法；技术用法保留）, highlight（动词）, interplay, intricate/intricacies, key（形容词）, landscape（抽象名词）, meticulous/meticulously, pivotal, quietly, robust（比喻用法；技术用法保留）, showcase, tapestry（抽象名词）, testament, underscore（动词）, valuable, vibrant
**问题：**模型使用这些词的频率远高于人，尤其是成群出现时。§13 到 §18 的留意列表里收的是因用法而成为破绽的短语；这份列表收的是无论出现在哪里都是破绽的词。这些列表之外的正式用词，本身不算破绽。
**修改前：**
> Additionally, a distinctive feature of Somali cuisine is the incorporation of camel meat. An enduring testament to Italian colonial influence is the widespread adoption of pasta in the local culinary landscape, showcasing how these dishes have integrated into the traditional diet.
**修改后：**
> Somali cuisine also includes camel meat, which is considered a delicacy. Pasta dishes, introduced during Italian colonization, remain common, especially in the south.

### 13. 夸大的意义

**留意：**stands as a testament, a pivotal or crucial moment, plays a key role, marking or shaping the, underscores its importance, reflects a broader, enduring or lasting legacy, setting the stage for, evolving landscape, indelible mark; Despite these challenges... continues to thrive, Challenges and Legacy, Future Outlook, Awards and recognition; the future looks bright, exciting times ahead, a step in the right direction
**问题：**一个普通的细节被说成标志着一次转变、证明了一份遗产，或者预示着一个未来。这种手法出现在三种尺度上：一个短语、一个套路化的「挑战与展望」小节，以及一段送别式的结尾。保留事实，去掉意义。以最后一个具体事实收尾；如果原文写明了真实的计划，就用那些计划。
**修改前：**
> The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain. This initiative was part of a broader movement across Spain to decentralize administrative functions and enhance regional governance.
**修改后：**
> The Statistical Institute of Catalonia was established in 1989, part of a wider decentralization of administrative functions in Spain.
**修改前（套路化小节）：**
> Despite its industrial prosperity, Korattur faces challenges typical of urban areas, including traffic congestion and water scarcity. Despite these challenges, with its strategic location and ongoing initiatives, Korattur continues to thrive as an integral part of Chennai's growth.
**修改后：**
> Korattur has recurring traffic congestion and water shortages.
**修改前（送别式结尾）：**
> The future looks bright for the company. Exciting times lie ahead as they continue their journey toward excellence.
**修改后：**
> （删掉这一段。以最后一个具体事实收尾。）

### 14. 含糊的关联

**留意：**associated with, in association with, connected to, in connection with, linked to, tied to
**问题：**文字说两件事有关联，却不说是怎样的关联。"He was associated with the leadership of ExampleCorp" 掩盖了他究竟是 CEO、董事会成员还是顾问。写出原文给出的关系。如果原文没说，就保留含糊的措辞，而不是编造一个角色。
**修改前：**
> He is associated with the Rajhans Orchestra, which he founded and conducts. The concerts were organised in connection with the celebrations of Pakistan's 50th anniversary.
**修改后：**
> He founded and conducts the Rajhans Orchestra. The concerts were part of the celebrations of Pakistan's 50th anniversary.

### 15. 空洞的 -ing 尾巴

**留意：**highlighting, underscoring, emphasizing, ensuring, reflecting, symbolizing, contributing to, cultivating, fostering, encompassing, showcasing
**问题：**在一个简单的事实后面硬接一个 -ing 短语，让它听起来更深刻。把它挂到一个具名来源上（"Roger Ebert highlighted the lasting influence"）也不会让它变成真的。保留事实；只有当原文支持这个尾巴所主张的内容时，才保留它。
**修改前：**
> The temple's color palette of blue, green, and gold resonates with the region's natural beauty, symbolizing Texas bluebonnets, the Gulf of Mexico, and the diverse Texan landscapes, reflecting the community's deep connection to the land.
**修改后：**
> The temple is painted blue, green, and gold, colors meant to evoke Texas bluebonnets and the Gulf of Mexico.

### 16. 推销腔

**留意：**rich (figurative), profound, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, featuring, diverse array, breathtaking, must-visit, stunning
**问题：**文字读起来像广告，尤其是在写地方、文化、产品或组织时。说清楚这个东西是什么。
**修改前：**
> Nestled within the breathtaking region of Gonder in Ethiopia, Alamata Raya Kobo stands as a vibrant town with a rich cultural heritage and stunning natural beauty.
**修改后：**
> Alamata Raya Kobo is a town in the Gonder region of Ethiopia.

### 17. 借来的权威

**留意：**experts argue, observers have cited, industry reports, some critics, several publications; cited, featured, or profiled in [a list of outlets], trade publications, independent coverage; active social media presence, over N followers
**问题：**用一个名字或一个不具名的权威，代替了对方实际说了什么。不具名的专家给论断撑腰；一串有名望的媒体给人撑腰。如果原文写明了真正的来源和它说了什么，就用那些。否则删掉没有依据的论断或那串列表。仅仅缺少引用本身不算破绽；大多数文字都没有注明出处。
**修改前（不具名的权威）：**
> Due to its unique characteristics, the Haolai River is of interest to researchers and conservationists. Experts believe it plays a crucial role in the regional ecosystem.
**修改后：**
> Researchers and conservationists study the Haolai River for its unusual characteristics.
**修改前（名望列表）：**
> Her views have been cited in The New York Times, BBC, Financial Times, and The Hindu. She maintains an active social media presence with over 500,000 followers.
**修改后：**
> Her views have been cited in The New York Times and the BBC.

### 18. 回避 is、are 和 has

**留意：**serves as, stands as, functions as, operates as, marks, represents [a]; boasts, features, offers, maintains [a]; refers to
**问题：**简单的动词被换成了更长的短语。用 *is*、*are* 和 *has*。
**修改前：**
> Gallery 825 serves as LAAA's exhibition space for contemporary art. The gallery features four separate spaces and boasts over 3,000 square feet.
**修改后：**
> Gallery 825 is LAAA's exhibition space for contemporary art. The gallery has four rooms totaling 3,000 square feet.

## D. 按规则排版

模板和可视化编辑器也会产出整齐的排版。破绽在于每一项都加了装饰。

### 19. 装饰性的粗体

**问题：**词语被无缘无故地加粗，竖排列表给每一项都配上一个粗体标签和一个冒号。去掉粗体。当标签本身不携带任何信息时，把带标签的列表改写成段落。
**修改前：**
> It blends **OKRs (Objectives and Key Results)**, **KPIs (Key Performance Indicators)**, and visual strategy tools such as the **Business Model Canvas (BMC)** and **Balanced Scorecard (BSC)**.
**修改后：**
> It blends OKRs, KPIs, and visual strategy tools like the Business Model Canvas and Balanced Scorecard.
**修改前（带标签的列表）：**
> - **User Experience:** The user experience has been significantly improved with a new interface.
> - **Performance:** Performance has been enhanced through optimized algorithms.
> - **Security:** Security has been strengthened with end-to-end encryption.
**修改后：**
> The update improves the interface, speeds up load times through optimized algorithms, and adds end-to-end encryption.

### 20. 装饰性的标题

**问题：**标题里每个主要的词都首字母大写，标题或列表项带着 emoji 或箭头（→）作装饰。每节之间都隔一条水平分割线，或者文档开头用一个复述自身标题的一级标题。为了效果而写的标题（"The decision, on one screen"）应该改为说明这一节装了什么（"How the six options compare"）。用句子式大写，去掉装饰和分割线，标题只出现一次。
**修改前：**
> ## Strategic Negotiations And Global Partnerships
**修改后：**
> ## Strategic negotiations and global partnerships
**修改前（emoji）：**
> 🚀 **Launch Phase:** The product launches in Q3
> 💡 **Key Insight:** Users prefer simplicity
**修改后：**
> The product launches in Q3. User research showed a preference for simplicity.

### 21. 弯引号

**问题：**在作者或目标格式使用直引号（"..."）的地方出现了弯引号（“...”）。大多数编辑器会自动转成弯引号，所以这一条*单独出现时较弱*。
**修改前：**
> He said “the project is on track” but others disagreed.
**修改后：**
> He said "the project is on track" but others disagreed.

## E. 聊天和草稿的残留物

直接删掉。这里没有什么需要改写的。

### 22. 聊天机器人残留

**留意：**I hope this helps, Of course!, Certainly!, Great question!, You're absolutely right, Would you like..., Want me to...?, Should I continue?, let me know, here is a...
**问题：**聊天机器人的问候、夸奖、提议或结束语，残留在本应独立成立的文字里。它是这份列表里最确定的破绽，也是包裹着真实内容时最容易漏掉的。去掉包装，保留内容。
**修改前：**
> Great question! Here is an overview of the French Revolution. It began in 1789 when a financial crisis and food shortages led to widespread unrest. I hope this helps! Let me know if you'd like me to expand on any section.
**修改后：**
> The French Revolution began in 1789 when a financial crisis and food shortages led to widespread unrest.

### 23. 知识边界免责声明和猜测

**留意：**as of [date], up to my last training update, while specific details are limited, based on available information, not publicly available, not widely documented or disclosed, in the provided or available sources, maintains a low profile, keeps personal details private, likely [grew up, studied, began], it is believed that
**问题：**文字提到了模型知识的边界，或者承认没找到来源，然后用一个看似合理的猜测填补空白。说明原文没有显示什么，或者删掉这句话。
**修改前（截止日期免责声明）：**
> While specific details about the company's founding are not extensively documented in readily available sources, it appears to have been established sometime in the 1990s.
**修改后：**
> The company's founding date is not documented in the available sources.（或者删掉这句话。）
**修改前（猜测）：**
> Information about her early life is not publicly available, suggesting she maintains a low profile. She likely grew up in a middle-class household, which shaped her later interest in education reform.
**修改后：**
> Her early life is not documented in the available sources.（或者省略这一节。）

### 24. 第一句复述标题

**问题：**标题后面跟着一个单行段落，在真正的内容开始之前把标题复述一遍。删掉这句重复的话。
**修改前：**
> ## Performance
>
> Speed matters.
>
> When users hit a slow page, they leave.
**修改后：**
> ## Performance
>
> When users hit a slow page, they leave.

### 25. 写文档本身，而不是写它的主题

**留意：**文字替换了什么（"was added to replace"）；它是怎么拼起来的、资料从哪来（"generated from"、"compiled from"、"anything unconfirmed is flagged rather than guessed"）；读者本来就看得见的图例、版式或顺序（"the table below compares"、"this section is organized by owner"）。
**问题：**文字在描述它自己，而不是描述它的主题。只在变更日志、发布说明、迁移指南以及其他关于变化的文档里提及之前的版本。保留读者可以顺着去查的来源署名；删掉关于你如何工作的叙述。保留会改变读者该怎么做的注意事项。只有当读者推断不出某个约定时才说明它，并且只说一次。单独一句对页面的描述属于*单独出现时较弱*。
**修改前：**
> This function was added to replace the previous approach of iterating through all items, which caused O(n²) performance.
**修改后：**
> This function uses a hash map for O(1) lookups, avoiding the O(n²) cost of naive iteration.
**修改前（叙述方法）：**
> The figures below are drawn from each vendor's published pricing; anything we could not confirm is flagged rather than guessed.
**修改后：**
> Prices are each vendor's published rate. Two vendors publish nothing; call them.

## F. 写给了错误的读者

模型是为一个不共享任何上下文的读者写作的，因为这样能适配最广泛的情况。讨论串里的一条回复，读者早已了解背景。当你能看到周围的对话，或者这段文字明显是一条回复时，就按这个模式处理。如果你判断不了，就去问，或者别动这段文字。

### 26. 重新解释读者已知的东西

**留意：**一条简短的回复，在给出决定之前，先复述问题、走一遍诊断过程、摆出证据；为了证明某个方案可行而附上的查询、命令或一组数字；对方自己写过或已经同意过的背景；答案本身待在最后一行。
**问题：**在回复里，读者已经掌握了上下文，所以重建上下文毫无增益，还会把要点埋起来。每一句单独读都没问题，所以这种模式能熬过逐句清理。以决定开头，只保留会影响读者是否同意的那部分推理：通常是对方缺少的一个事实，以及对方采取行动需要的链接。诊断过程和方案可行的证明，属于随后的 ticket 或文档；reviewer 提出一个话题，并不是在要一份完整的报告。
**修改前：**
> Yeah, you're right, this works around the issue rather than fixing it. The real fix is in `MergeService`: when we move a child under a new parent, it should update `pipeline_id` along with `parent_id`. We can backfill the bad rows from the audit log with `Change.where(field: "pipeline_id", source: "merge")`. I checked QA: 123 past merges, only 6 rows wrong now, so the cleanup is small.
>
> Since `MergeService` is shared and not specific to this account, I'd rather open a separate ticket than widen this PR. The fallback here is fine to keep until then.
**修改后：**
> Agreed, this is a workaround. Fixing it properly in `MergeService` would widen this ticket well past its scope: it is shared code, so it means checking the merge flow for every account, plus a backfill for the rows that are already wrong.
>
> I'd rather keep this PR account specific and open a separate ticket for the `MergeService` fix and the backfill. Let me know if that works.


## 中文文本

上面的模式是针对英文写的，但大多数是结构性的，原样适用于中文。对应的中文写法如下：

- §1：「不是 X，而是 Y」「不仅仅是 X，更是 Y」「与其说 X，不如说 Y」，而 X 那一半并没有反驳读者真正持有的任何看法。
- §2：一个只有一句话、复述上一段的段落（「这才是关键。」「这一点很重要。」「细品。」）。
- §4 和 §22：「让我们来看看」「下面我们来深入探讨」「话不多说」「希望对你有帮助」「如有需要随时告诉我」。
- §12 和 §16：赋能、抓手、闭环、助力、深耕、无缝、全方位、打造、彰显、至关重要、不可或缺，用作比喻或空泛修饰时。
- §8：中文破折号（——）和 em dash 遵循同一条规则。
- §21：沿用文字原本的标点风格（全角的「」或“ ”）；不要混用。

改写时不要把文字翻译成另一种语言。

## 什么时候不要动手

每种模式描述的都是一个默认选择，而人可能故意做出其中任何一种。被留意的短语如果出现在引文、标题、专有名词里，或者出现在讨论这个短语本身、而非使用它的段落里，就别动它。书信或评论里的称呼和落款早在聊天机器人出现之前就有了。2022 年 11 月 30 日之前写的文字不是 AI 写的。凭感觉判断的人，准确率比瞎猜好不了多少，而且人类写作还在不断吸收 AI 的习惯，所以几个破绽同时出现才是可靠的保障。

保留那些承载作者个人风格的细节，除非它们损害了意思：

- 一个具体、不寻常的细节：一个真实的地址、一句古怪的引语，"the lawyer who used to work upstairs from my dentist."
- 复杂的情绪和悬而未决的矛盾："I think this is mostly good, but it bothers me, and I can't fully explain why."
- 带有年代印记的引用：对应特定年份和亚文化的俚语、梗和圈内笑话。
- 作者能解释清楚的第一人称选择。
- 真正的题外话、括号补充或自我纠正："(I keep wanting to say 'almost' here, but it really was certain.)"

## 来源

这些模式来自维基百科的 ["Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)（由 WikiProject AI Cleanup 维护），以及对维基百科和其他地方 AI 生成文字的审阅。
