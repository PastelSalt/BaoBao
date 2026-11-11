# Legacy reference docs

These four files are the only survivors of the 75 generated Markdown reports that used to sit in the repository root. They are kept because the Flutter migration (`PLAN-A-00-111126.md`) needs the content, not because they are maintained.

**They may be stale. The Kotlin source is the source of truth.** Known drift is noted below.

| File | Why it is kept | Known drift |
|------|----------------|-------------|
| `AUDIO_FILE_NAMING_GUIDE.md` | Maps every voice clip name to the line BaoBao speaks. | Says `.wav`; the shipped clips are `.aac` in `app/src/main/res/raw/`. |
| `CONVERSATION_LOGIC_EXPLANATION.md` | Explains the mood → node tree → loop point → intervention flow. | Refers to a `MoodSelectionActivity` and 88 nodes; mood selection is now a dialog and there are 79 nodes. |
| `DIALOG_DESIGN_STANDARD.md` | Dialog sizing, colours, and spacing used by the bamboo UI. | None found. |
| `OUTFIT_SYSTEM_GUIDE.md` | Naming scheme for outfit × emotion character art. | None found. |

Delete each file once its content has been ported into the Flutter app's assets or docs.
