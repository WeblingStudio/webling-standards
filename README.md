# webling-standards

Shared development standards, conventions, and project scaffolding for [Webling Studio](https://github.com/WeblingStudio).

This repository is the single source of truth for how Webling Studio writes, reviews, and ships code. It is public and open source — we believe transparent engineering practices build trust.


## Contents

```
webling-standards/
├── CONVENTIONS.md                        # coding standards injected into every Claude session
│
├── configs/                              # shared tool configurations
│   ├── .editorconfig                     # cross-editor whitespace and encoding rules
│   ├── tsconfig.base.json                # TypeScript base config (projects extend this)
│   ├── eslint.config.base.mjs            # ESLint v9 flat config base
│   └── .prettierrc                       # Prettier formatting rules
│
├── templates/                            # scaffolding copied into new projects
│   ├── CLAUDE.md                         # project-level Claude context starter
│   ├── README.md                         # project README structure
│   ├── SECURITY.md                       # vulnerability disclosure policy
│   ├── .env.example                      # annotated environment variable template
│   └── .github/
│       ├── pull_request_template.md      # PR template with Jira and checklist
│       └── ISSUE_TEMPLATE/
│           ├── bug_report.md
│           ├── feature_request.md
│           └── task.md
│
└── scripts/
    └── onboard.sh                        # developer setup script
```


## Developer Onboarding

Run the onboarding script once on a new machine. It clones this repo to `~/.webling` and configures the `webling-claude` alias in your shell.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/WeblingStudio/webling-standards/main/scripts/onboard.sh)
```

Then reload your shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

From that point, use `webling-claude` instead of `claude` for all Webling Studio project work. The alias pulls the latest conventions on each invocation and injects them into the session:

```bash
alias webling-claude='git -C ~/.webling pull --quiet && claude --append-system-prompt-file ~/.webling/CONVENTIONS.md'
```

> Your personal `~/.claude/CLAUDE.md` is never modified. Conventions apply only when you invoke `webling-claude`.


## Using the Configs

Projects extend the shared configs rather than duplicating them. Reference the installed path directly.

**TypeScript** — in `tsconfig.json`:
```json
{
  "extends": "~/.webling/configs/tsconfig.base.json",
  "compilerOptions": {
    "baseUrl": ".",
    "outDir": "./dist"
  }
}
```

**ESLint** — in `eslint.config.mjs`:
```js
import weblingBase from '~/.webling/configs/eslint.config.base.mjs'
export default [...weblingBase, { /* project overrides */ }]
```

**Prettier** — in `package.json`:
```json
{
  "prettier": "~/.webling/configs/.prettierrc"
}
```

**EditorConfig** — copy `.editorconfig` into the project root (most editors read it automatically):
```bash
cp ~/.webling/configs/.editorconfig .
```


## Using the Templates

Copy templates into new projects and replace `[BRACKETED]` placeholders with project-specific values.

```bash
# Project context for Claude
cp ~/.webling/templates/CLAUDE.md ./CLAUDE.md

# Standard README
cp ~/.webling/templates/README.md ./README.md

# Security policy
cp ~/.webling/templates/SECURITY.md ./SECURITY.md

# Environment variable template
cp ~/.webling/templates/.env.example ./.env.example

# GitHub templates (PR and issue forms)
cp -r ~/.webling/templates/.github ./.github
```


## CONVENTIONS.md

`CONVENTIONS.md` is injected as a system prompt into every `webling-claude` session. It covers:

- Naming conventions (case, variables, functions)
- Type and constant patterns
- Error handling and async patterns
- Import and module organization
- Security (sensitive data, input validation, dependency policy)
- Testing conventions including contract tests
- Logging and observability
- Git conventions (branch naming, commits, PRs)
- Environment and configuration

It is not duplicated in project `CLAUDE.md` files. Project `CLAUDE.md` files cover only what is specific to that project: purpose, stack, architecture, commands, and links.


## Project CLAUDE.md

Each project carries its own `CLAUDE.md` (scaffolded from `templates/CLAUDE.md`) that gives Claude the context it needs to work effectively in that specific codebase. It does not repeat conventions — those arrive via the alias.

See `templates/CLAUDE.md` for the expected structure.


## Contributing

This repository reflects the current practices of Webling Studio. Changes are reviewed by the engineering team before merging. If you identify a gap or inconsistency, open an issue using the appropriate template.

All branches must follow the naming convention: `[type]/[JIRA-KEY]-[description]`


## License

Configuration files and scripts are licensed under the [Apache License 2.0](LICENSE).
Documentation and templates are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
