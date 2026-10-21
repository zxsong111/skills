# GLOSSARY.md 格式

## 结构

```md
# {上下文名称}

{用一两句话描述这个上下文是什么、为什么存在。}

## Language

**Order**:
{用一两句话描述这个术语}
_Avoid_: Purchase, transaction

**Invoice**:
交付后发给客户的付款请求。
_Avoid_: Bill, payment request

**Customer**:
下订单的个人或组织。
_Avoid_: Client, buyer, account
```

## 规则

- **要有主见。** 当同一个概念有多个说法时，选出最好的那个，把其余的列在 `_Avoid_` 下面。
- **定义要紧凑。** 最多一两句话。定义它*是*什么，而不是它*做*什么。
- **只收录这个项目的上下文所特有的术语。** 通用的编程概念（超时、错误类型、工具类模式）即使项目大量使用也不属于这里。加术语之前先问：这是这个上下文独有的概念，还是一个通用的编程概念？只有前者属于这里。
- **在自然形成的聚类出现时，用子标题给术语分组。** 如果所有术语都属于同一个内聚的领域，用平铺的列表就行。

## 单上下文与多上下文仓库

**单上下文（大多数仓库）：** 仓库根目录下一个 `GLOSSARY.md`。

**多上下文：** 仓库根目录下一个 `GLOSSARY-MAP.md`，列出各个上下文、它们所在的位置，以及它们之间的关系：

```md
# Glossary Map

## Contexts

- [Ordering](./src/ordering/GLOSSARY.md)：接收并跟踪客户订单
- [Billing](./src/billing/GLOSSARY.md)：生成发票并处理付款
- [Fulfillment](./src/fulfillment/GLOSSARY.md)：管理仓库拣货和发货

## Relationships

- **Ordering → Fulfillment**：Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费这些事件以开始拣货
- **Fulfillment → Billing**：Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费这些事件以生成发票
- **Ordering ↔ Billing**：共享 `CustomerId` 和 `Money` 类型
```

这个 skill 会推断适用哪种结构：

- 如果存在 `GLOSSARY-MAP.md`，读取它来找到各个上下文
- 如果只有根目录下的 `GLOSSARY.md`，就是单上下文
- 如果两者都不存在，在第一个术语确定下来时，再在根目录创建 `GLOSSARY.md`

存在多个上下文时，推断当前话题与哪一个相关。如果不清楚，就问。
