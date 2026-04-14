# CONVENTIONS

## Acceptable AI Usage
AI assistance is recommended for most development, but all decisions and changes must be evaluated by human review.

No code from private repositories (including client repositories) must ever be entered into prompts subject to model training. Model training may be opted out by disabling the "Help Improve Claude" setting in the web interface.

## Naming Conventions
### Case
| Construct | Convention |
|-----------|------------|
| Variables | camelCase |
| Constants | UPPERCASE |
| Files | kebab-case |
| Components | PascalCase |
| Enums | PascalCase |
| Types | PascalCase |
| Classes | PascalCase |
| DB Tables | snake_case |
| DB Columns | snake_case |
| Labels | Title Case |

### Variable Names
Variable names must be as descriptive as possible, favoring _clarity_ over _compactness_ (e.g. `carsAtLocation` over `cars`).

| Type | Pattern | Examples |
|------|---------|---------|
| Boolean | `isNoun`, `hasNoun`, `doesNounExist` | `isActive`, `hasPermission`, `doesUserExist` |
| Number | `nounCount`, `nounLength`, `nounIndex` | `itemCount`, `arrayLength`, `pageIndex` |
| Array | pluralized noun, optionally prefixed | `orders`, `filteredOrders`, `sortedItems` |
| Object | `instanceName: InterfaceName` | `user: User`, `order: Order` |
| Temporary | `_varName` | `_result`, `_temp` |
| Borrowed Scope | `_outerName` — a locally-scoped copy of an outer variable | `let _config = config` |

> The `_` prefix signals intentional locality: the variable is either short-lived (temporary) or a local snapshot of an outer value that may be modified independently.

## Function Definitions
### Function Naming
All function names follow the `verbNoun()` pattern. Choose the most specific verb for the operation:

| Purpose | Pattern | Example |
|---------|---------|---------|
| Read / Compute | `getNoun()` | `getOrderTotal()` |
| Boolean check | `nounIsAdjective()`, `nounHasNoun()`, `nounExists()` | `userIsLoggedIn()`, `cartHasItems()` |
| Write | `setNoun()` | `setActiveUser()` |
| Reset to zero value | `clearNoun()` | `clearSelection()` |
| Get zero value | `getClearNoun()` | `getClearForm()` |
| Network GET | `fetchNoun()` | `fetchOrders()` |
| Network POST | `postNoun()` | `postOrder()` |
| Network PUT | `putNoun()` | `putOrderStatus()` |
| Network DELETE | `deleteNoun()` | `deleteOrder()` |
| Other | `verbNoun()` | `validateForm()`, `parseResponse()` |

### Function Arguments
- Prefer **named arguments** over **positional arguments**, unless the intent is immediately obvious:
	- ✅ `getUser({ userGuid: guid })`
	- ✅ `getUserByGuid(guid)`
	- ❌ `getUser(guid)` — ambiguous: what kind of identifier?
	- ❌ `userIsVerified(guid)` — ambiguous: user GUID or verification GUID?
- Place optional context at the end of positional argument lists: `fn(user: User, ctx?: ContextMetadata)`
- Prefer **specific interfaces** over general ones: `addNewEmployee(employee: Employee)` > `addNewEmployee(employee: BaseUser)`
- **Never use `any` types.** Use `unknown` and narrow explicitly if the type is genuinely unknown.

### Function Body
- **Scope**: confine scope to the current function. Pass values as arguments rather than closing over outer state.
- **Single-purpose**: each function should achieve one goal (e.g. compute a value, or post a value — not both).
- **Length**: no strict limit, but a function that follows the single-purpose rule will typically be under 20 lines.
- **Effects**: side effects must be obvious from the function name. If the single-purpose rule is followed, callers will know what effects to expect.
- **Nesting**: avoid more than 2 levels of nesting. Prefer early-return guard clauses to reduce indentation.
- **Comments**: behavior should be clear from the function name. Add comments when logic is non-obvious or when a deliberate trade-off has been made.

## Types
- Prefer `interface` for object shapes (supports extension); prefer `type` for unions, intersections, and aliases.
- Always export types used across more than one file.
- Prefer explicit type annotations at module boundaries; allow inference internally.
- Use `unknown` instead of `any` when the type is genuinely unknown, then narrow explicitly.
- Build specific types from base types via extension or intersection — never loosen a type to fit a reuse case.
- Use `Readonly<T>` for data that should not be mutated after creation.
- Generic parameter names: use single letters (`T`, `K`, `V`) for simple generics; use descriptive PascalCase (`TItem`, `TResponse`) when the generic's role needs clarification.

## Constants
- Avoid magic numbers and strings — always assign a named constant.
- Group related constants into a namespaced `const` object with `as const` for literal type inference:
	```ts
	const ORDER_STATUS = {
		Pending:   'pending',
		Fulfilled: 'fulfilled',
		Cancelled: 'cancelled',
	} as const
	```
- Co-locate constants with the code that uses them. Centralize only when a constant is shared across 3+ files.
- Use `enum` only when the set of values is closed and exhaustive; prefer `as const` objects otherwise.

## Utility
- Utility functions must be **pure**: no side effects, deterministic output given the same input.
- Organize utilities by domain in a `utils/` directory (e.g. `utils/date.ts`, `utils/string.ts`). Each file should address a single concern.
- Do not import application state, services, or UI logic into utility files — they must remain environment-agnostic.
- Prefer composing small, focused utilities over a single large helper.
- Name utilities using the same `verbNoun()` convention as all other functions.

## Reusability
- Apply the **rule of three**: abstract a pattern only after it appears in 3 or more distinct locations.
- Prefer **composition over inheritance**. Build complex behavior by combining small units rather than extending base classes.
- Functions and components should accept the **minimum data they need** — pass specific values, not entire objects, unless the full object is genuinely required. Use `Pick<T, K>` to derive a minimal argument type from an existing interface rather than accepting the full type or defining a redundant one:
	```ts
	// ❌ accepts more than needed
	function getDisplayName(user: User): string { ... }

	// ✅ declares exactly what is required
	function getDisplayName(user: Pick<User, 'firstName' | 'lastName'>): string { ... }
	```
	Prefer `Pick` for additive subsets and `Omit<T, K>` when excluding a small number of fields from a large type.
- Shared logic → utility function. Shared UI → component. Shared state → hook or store. Keep each layer in its own domain.
- Avoid **premature abstraction** — a concrete, readable duplicate is preferable to a forced abstraction that obscures intent.
- Use **generics** to unify logic that is structurally identical but differs only in type. Apply the rule of three: if the same shape appears for three or more types, introduce a generic rather than duplicating:
	```ts
	// ❌ duplicated for every entity
	function getPaginatedUsers(page: number): PaginatedResult<User> { ... }
	function getPaginatedOrders(page: number): PaginatedResult<Order> { ... }

	// ✅ one generic implementation
	function getPaginated<T>(endpoint: string, page: number): PaginatedResult<T> { ... }
	```
- **Constrain generics** with `extends` to communicate intent and preserve type safety. An unconstrained `T` is a deferred `any` — always bound it to the narrowest type that still allows reuse:
	```ts
	// ❌ unconstrained — no type safety inside the function
	function getId<T>(item: T): string { ... }

	// ✅ constrained — callers and the body both benefit
	function getId<T extends { id: string }>(item: T): string { return item.id }
	```

## Error Handling
- Define **typed error classes** by extending `Error` for each distinct failure category:
	```ts
	class NotFoundError extends Error {
		constructor(resource: string) {
			super(`${resource} not found`)
			this.name = 'NotFoundError'
		}
	}
	```
- **Recover** at the boundary where you have enough context to handle the failure meaningfully. **Rethrow** (or wrap with additional context) when you don't:
	```ts
	// ❌ swallowed — caller has no idea anything went wrong
	try { await saveOrder(order) } catch { }

	// ✅ rethrown with context
	try { await saveOrder(order) } catch (error) {
		throw new Error(`Failed to save order ${order.id}`, { cause: error })
	}
	```
- Never swallow errors silently — always log or rethrow.
- Surface errors at the correct layer: validation errors at the input boundary, network errors in the service layer, UI errors in the view layer. Do not let infrastructure errors leak into user-facing messages.
- Use `try/catch` for async operations. Reserve `.catch()` for intentional fire-and-forget Promises — ones where the caller does not need the result and failure is non-critical. Even then, the handler must log the error; it must not be empty.

## Async Patterns
- Prefer `async/await` over `.then()` chains — it reads sequentially and keeps error handling in one place.
- Use `Promise.all()` for independent concurrent operations; use sequential `await` only when one result depends on another:
	```ts
	// ❌ sequential when operations are independent — unnecessary latency
	const user  = await fetchUser(userId)
	const prefs = await fetchPreferences(userId)

	// ✅ concurrent
	const [user, prefs] = await Promise.all([fetchUser(userId), fetchPreferences(userId)])
	```
- Never leave a floating Promise — always `await` it or explicitly assign it when fire-and-forget is intentional.
- Do not **catch-and-ignore** — an empty `catch` block is never acceptable. Every caught error must be logged, rethrown, or converted into a typed result. A fire-and-forget `.catch()` that logs is not catch-and-ignore; an empty one is:
	```ts
	// ❌ catch-and-ignore — error disappears entirely
	sendAnalyticsEvent(event).catch(() => {})

	// ✅ fire-and-forget — non-critical, but failure is still recorded
	sendAnalyticsEvent(event).catch((error) => logger.warn('analytics.send.failed', { error }))
	```

## Imports & Modules
- Order imports in three groups, separated by blank lines: **external packages** → **internal aliases** → **relative paths**:
	```ts
	import { z }          from 'zod'
	import express        from 'express'

	import { config }     from '@/config'
	import { UserService} from '@/services/user-service'

	import { formatName } from './utils'
	```
- Use **barrel exports** (`index.ts`) only at intentional public API boundaries — never to shorten import paths within a module.
- Avoid **circular dependencies**. If one arises, it signals a layering or ownership problem that should be resolved structurally.
- Import only what is used. Avoid namespace imports (`import * as foo`) unless the module's own documentation recommends it.

## Security

## Sensitive Data
- Never log secrets, tokens, API keys, or PII — not even partially.
- Access all environment variables through a single `config` module. No direct `process.env` reads anywhere else in the codebase.
- No credentials, tokens, or secrets committed to source control under any circumstances — not in code, comments, or test fixtures.

## Input Validation
- Validate all data at system boundaries: user input, external API responses, and environment variables.
- Use a schema library (e.g. Zod) to parse and validate; use the parsed result as the typed value — never cast unvalidated data with `as`:
	```ts
	// ❌ cast without validation
	const body = req.body as CreateOrderRequest

	// ✅ parsed and validated
	const body = CreateOrderSchema.parse(req.body)
	```
- Reject and return early on invalid input. Do not attempt to coerce, default, or guess missing values.

## Dependency Policy
- Use **pnpm** as the package manager. Do not use `npm` or `yarn` — lockfile consistency depends on it.
- Before adding a package, evaluate: bundle size, maintenance activity (last commit, open issues), license compatibility, and known CVEs.
- Prefer established packages with active maintenance over niche or unmaintained alternatives.
- Run `pnpm audit` before each release to catch lockfile-level vulnerabilities. For deeper analysis, run `snyk test` via the **Snyk CLI** — it checks transitive dependencies and has a broader vulnerability database. Do not ship with unresolved high or critical findings from either tool.

## Testing
- Co-locate test files with the source they cover: `user-service.test.ts` sits beside `user-service.ts`.
- **Unit tests** for pure functions and utilities. **Integration tests** for service and API boundaries where real I/O is involved.
- Mock only what you do not own: external services, network calls, the filesystem, and the system clock. Do not mock your own modules.
- Each test asserts **one behavior**. The test name should read as a plain-English statement of that behavior:
	```ts
	it('returns null when the user is not found', async () => { ... })
	it('throws NotFoundError when the order id is invalid', async () => { ... })
	```
- Use a `test/` directory for **contract tests** — tests that validate an interface rather than a specific implementation. If multiple implementations must satisfy the same interface (e.g. `DatabaseParser` and `FilesystemParser` both implementing `Parser`), extract the shared assertions into a reusable suite factory and co-locate only implementation-specific tests:
	```ts
	// test/parsers/parser-contract.ts — owned by the interface, not any implementation
	export function testParserContract(getInstance: () => Parser) {
		it('returns null for unrecognised input', () => { ... })
		it('throws ParseError when the input is malformed', () => { ... })
	}

	// src/parsers/database-parser.test.ts
	import { testParserContract } from '@test/parsers/parser-contract'
	testParserContract(() => new DatabaseParser(mockDb))

	// src/parsers/filesystem-parser.test.ts
	import { testParserContract } from '@test/parsers/parser-contract'
	testParserContract(() => new FilesystemParser(mockFs))
	```
	This ensures implementations remain interchangeable: swapping one out requires passing the existing contract tests before any implementation-specific ones are written.

## Logging & Observability
- Use **structured logging** with JSON-compatible key-value pairs — not interpolated strings:
	```ts
	// ❌ unstructured — hard to query
	logger.info(`User ${userId} placed order ${orderId}`)

	// ✅ structured — queryable fields
	logger.info('order.placed', { userId, orderId })
	```
- Log levels: `error` for failures requiring immediate attention, `warn` for recoverable anomalies, `info` for significant state transitions, `debug` for developer context (disabled in production).
- Never log: passwords, tokens, full request bodies that may contain PII, or raw stack traces in user-facing responses.
- Include a **correlation ID** (request ID, trace ID) in every log entry so a full request flow can be reconstructed.

## Git Conventions
All branches (except `main`, `release`, and `feature/*`) must be associated with a Jira work item.

## Protected Branches
- **`main`** — latest state ready for integration testing. Never commit directly; all changes must arrive via approved pull request.
- **`feature/*`** — long-running branches for large, complex work. Follow the same PR and approval rules as `main`. Must be kept up to date with `main` daily.
- **`release/[env]/[version]`** — deployment files organized by environment and version (e.g. `release/uat/v2.5.1`).

## Branch Naming
`[type]/[JIRA-ticket]-[lowercase-short-description]`
- `fix/PROJ-123-table-alignment`
- `task/PROJ-124-submit-form`
- `docs/PROJ-125-remove-legacy-section`
- `feature/PROJ-126-refund-requests`

## Commits
`[JIRA-ticket]: [lowercase purposeful commit message]`
- `PROJ-123: left align currency column`

Commit messages must describe the **purposeful outcome** of the change, not the mechanical action (e.g. `PROJ-99: allow guests to check out without an account` not `PROJ-99: update checkout flow`). Commits are never pushed directly to `main` or `feature/*`.

## Pull Requests
- Target `main` or the relevant `feature/*` branch.
- Require at least **one peer-reviewed approval** before merging.
- PRs should be small and focused. If a PR exceeds ~400 lines of meaningful change, consider splitting it.

## Environment & Configuration
- All environment-specific values live in `.env` files. Never hardcode environment values in source.
- A single `config.ts` module reads, types, and exports all environment variables. All other files import from it — never from `process.env` directly:
	```ts
	// config.ts
	export const config = {
		databaseUrl: requireEnv('DATABASE_URL'),
		jwtSecret:   requireEnv('JWT_SECRET'),
		port:        parseInt(process.env.PORT ?? '3000', 10),
	} as const
	```
- Provide a `.env.example` file that documents every variable the application requires. No variable may exist in `.env` without a corresponding entry in `.env.example`.
- Validate required environment variables **at startup**. Fail fast with a clear, specific error if any are missing — do not allow the application to start in a broken state.