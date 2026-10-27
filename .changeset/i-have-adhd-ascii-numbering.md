---
"zxs-skills": patch
---

`i-have-adhd` rule 2 now restricts numbering to ASCII (`1.`, `2.`, sub-items `(a)`): circled numbers (`①`, `②a`), emoji digits (`1️⃣`) and decorative checkmarks and arrows in lists are banned, because East Asian Ambiguous width characters overlap themselves in several terminals (iTerm2 among them) when the renderer and the cursor math disagree on their width.
