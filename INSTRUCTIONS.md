# Repository Instructions

These instructions apply to all development work in this repository.

## Documentation maintenance rules

1. **Keep `LOG.md` current.** Record every action made in this codebase, including file creation, edits, configuration changes, dependency changes, validation commands, and relevant outcomes. Add entries in chronological order with the date, action, affected paths, and result.
2. **Keep `CODEMAP.md` current.** Update it whenever the repository structure, module responsibilities, routes, dependencies, or important data flows change. It is the maintained index for developers and agents, so describe the current codebase rather than planned work.
3. **Keep `README.md` accurate.** Update project setup, scripts, architecture, and usage information when those details change. Do not retain template or placeholder claims that are not implemented.
4. **Cross-reference documentation.** When a change affects the project overview or code structure, update all related documentation in the same change.

## Development rules

- Inspect the relevant existing files before editing.
- Prefer small, focused changes that preserve existing behavior.
- Follow the conventions already used by the project.
- Run the narrowest applicable validation command after code changes.
- Report validation results and any known limitations in `LOG.md`.
- Do not document generated directories such as `node_modules` or `dist` in `CODEMAP.md` unless their build behavior is specifically relevant.
