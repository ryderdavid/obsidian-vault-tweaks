---
tags:
  - weekly_note
week: <% tp.file.title %>
week_start: <% moment(tp.file.title, "GGGG-[W]WW").startOf('isoWeek').format("YYYY-MM-DD") %>
week_end: <% moment(tp.file.title, "GGGG-[W]WW").endOf('isoWeek').format("YYYY-MM-DD") %>
prev_week_start: <% moment(tp.file.title, "GGGG-[W]WW").startOf('isoWeek').subtract(7, 'days').format("YYYY-MM-DD") %>
prev_week_end: <% moment(tp.file.title, "GGGG-[W]WW").startOf('isoWeek').subtract(1, 'days').format("YYYY-MM-DD") %>
---

[[Weekly/<% moment(tp.file.title, "GGGG-[W]WW").subtract(1, 'weeks').format("GGGG-[W]WW") %>|< Previous]] | Week of <% moment(tp.file.title, "GGGG-[W]WW").startOf('isoWeek').format("MMM DD") %> — <% moment(tp.file.title, "GGGG-[W]WW").endOf('isoWeek').format("MMM DD, YYYY") %> | [[Weekly/<% moment(tp.file.title, "GGGG-[W]WW").add(1, 'weeks').format("GGGG-[W]WW") %>|Next >]]

## Summary
[Refresh Summary](<obsidian://adv-uri?vault=Vault&commandid=templater-obsidian%3AResources%2FTemplates%2FRefresh%20Weekly%20Summary.md>)

%%SUMMARY_START%%
<%*
const weekStart = moment(tp.file.title, "GGGG-[W]WW").startOf('isoWeek');
const prevStart = weekStart.clone().subtract(7, 'days');
const prevEnd = weekStart.clone().subtract(1, 'days');

let content = "";
for (let d = prevStart.clone(); d.isSameOrBefore(prevEnd); d.add(1, 'days')) {
  const path = `Daily/${d.format("YYYY-MM-DD")}.md`;
  const file = app.vault.getAbstractFileByPath(path);
  if (file) {
    try {
      let text = await app.vault.read(file);
      text = text.replace(/^---\n[\s\S]*?\n---\n/, '')
        .replace(/\[(id|parent|completion|priority|uid)::.*?\]/g, '')
        .replace(/```dataviewjs[\s\S]*?```/g, '');
      content += `\n### ${d.format("dddd, MMM D")}\n${text}\n`;
    } catch(e) { /* skip unreadable files */ }
  }
}

if (content.length > 6500) {
  content = content.substring(content.length - 6500);
}

let summary = "";
if (content.trim()) {
  try {
    summary = await tp.ai.chat(
      `Summarize my week based on these daily notes. Write 3-5 short paragraphs covering what I accomplished, key events, and any patterns or themes. Be concise and conversational.\n\n${content}`,
      undefined,
      "You are a personal productivity assistant. Summarize the user's week from their daily notes. Focus on accomplishments, notable events, and themes. Be warm but concise. Use plain text, no markdown headers.",
      1024,
      8000
    );
  } catch(e) {
    summary = "*AI summary could not be generated. Click Refresh Summary above to try again, or check AI for Templater plugin settings.*";
  }
} else {
  summary = "*No daily notes found for the prior week.*";
}
tR += summary;
_%>
%%SUMMARY_END%%

## Unfinished Last Week

```dataviewjs
const ws = dv.current().week_start;
if (!ws) { dv.paragraph("*Missing week_start in frontmatter.*"); }
else {
  const weekStart = dv.date(ws);
  const prevStart = weekStart.minus({days: 7});
  const prevEnd = weekStart.minus({days: 1});

  const tasks = dv.pages('"Daily"').file.tasks
    .where(t => {
      const match = t.path?.match(/(\d{4}-\d{2}-\d{2})/);
      if (!match) return false;
      const d = dv.date(match[1]);
      return d >= prevStart && d <= prevEnd;
    })
    .where(t => !t.checked && !t.text.includes(">[["));

  if (tasks.length > 0) {
    dv.taskList(tasks, false);
  } else {
    dv.paragraph("*Nothing unfinished — clean slate!*");
  }
}
```

## Upcoming This Week

-

## Accomplishments

```dataviewjs
const ws = dv.current().week_start;
if (!ws) { dv.paragraph("*Missing week_start in frontmatter.*"); }
else {
  const weekStart = dv.date(ws);
  const prevStart = weekStart.minus({days: 7});
  const prevEnd = weekStart.minus({days: 1});

  const tasks = dv.pages('"Daily"').file.tasks
    .where(t => {
      const match = t.path?.match(/(\d{4}-\d{2}-\d{2})/);
      if (!match) return false;
      const d = dv.date(match[1]);
      return d >= prevStart && d <= prevEnd;
    })
    .where(t => t.completed);

  if (tasks.length > 0) {
    dv.taskList(tasks, false);
  } else {
    dv.paragraph("*No completed tasks found for last week.*");
  }
}
```

## Last Week's Notes

```dataviewjs
const ws = dv.current().week_start;
if (!ws) { dv.paragraph("*Missing week_start in frontmatter.*"); }
else {
  const weekStart = dv.date(ws);
  const prevStart = weekStart.minus({days: 7});
  const prevEnd = weekStart;

  const notes = dv.pages()
    .where(p => {
      return p.file.mtime >= prevStart
        && p.file.mtime < prevEnd
        && !p.file.path.startsWith("Daily/")
        && !p.file.path.startsWith("Templates/")
        && !p.file.path.startsWith("Weekly/")
        && !p.file.path.includes("Agent Chats")
        && !p.file.path.includes(".obsidian");
    })
    .sort(p => p.file.mtime, 'desc');

  if (notes.length > 0) {
    dv.list(notes.map(p => `[[${p.file.path}|${p.file.name}]] — _${p.file.folder}_`));
  } else {
    dv.paragraph("*No project or reference notes were edited last week.*");
  }
}
```

## Notes

