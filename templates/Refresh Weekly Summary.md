<%*
// Refresh Weekly Summary — regenerates the AI summary in-place
// Triggered via the [Refresh Summary] link in weekly notes

const fm = app.metadataCache.getFileCache(tp.config.target_file)?.frontmatter;
if (!fm?.prev_week_start || !fm?.prev_week_end) {
  new Notice("Missing prev_week_start/prev_week_end in frontmatter");
  return;
}

const prevStart = moment(fm.prev_week_start, "YYYY-MM-DD");
const prevEnd = moment(fm.prev_week_end, "YYYY-MM-DD");

// Read and condense daily notes
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
    } catch(e) {}
  }
}

if (content.length > 6500) {
  content = content.substring(content.length - 6500);
}

let summary = "*No daily notes found for the prior week.*";
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
    summary = "*AI summary failed. Try again or check AI for Templater settings.*";
  }
}

// Replace content between markers in the active file
const activeFile = tp.config.target_file;
let fileContent = await app.vault.read(activeFile);
const startMarker = "%%SUMMARY_START%%";
const endMarker = "%%SUMMARY_END%%";
const startIdx = fileContent.indexOf(startMarker);
const endIdx = fileContent.indexOf(endMarker);

if (startIdx !== -1 && endIdx !== -1) {
  const before = fileContent.substring(0, startIdx + startMarker.length);
  const after = fileContent.substring(endIdx);
  fileContent = before + "\n" + summary + "\n" + after;
  await app.vault.modify(activeFile, fileContent);
  new Notice("Weekly summary refreshed!");
} else {
  new Notice("Could not find summary markers in this note.");
}
_%>
