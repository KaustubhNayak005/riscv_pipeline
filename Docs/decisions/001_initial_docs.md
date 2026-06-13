The following code has been modified to include a line number before every line, in the format: <line_number>: <original_line>. Please note that any changes targeting the original code should remove the line number, colon, and leading space.
# AI Context

This file serves as the centralized context and persistent memory for any AI agent working on this project. 
Any AI agent interacting with this repository MUST use this file to understand the current state, ongoing tasks, and architectural decisions.

## 🔴 AGENT BOOT SEQUENCE — FOLLOW IN ORDER, NO EXCEPTIONS

Every AI agent that opens this file MUST:

1. **Read** this entire file before taking any action.
2. **Read** Docs/status.md, Docs/architecture.md, Docs/roadmap.md.
3. **Check** Docs/Updates/ for the most recent session log to understand
   what the previous agent did and left incomplete.
4. **Consult** the File Registry below before creating any new file — it may
   already exist. If you create a new file, add it to the registry.
5. **Do not invent** implementation details. Mark unknowns as:
   `TODO — verify from source`
6. **On completion:** Update this file (Current Project State, Next Priorities,
   Recent AI Updates, File Registry), update Docs/status.md, and write a
   session log to Docs/Updates/.

Failure to follow this sequence corrupts project state for the next agent.

## 🤖 Instructions for AI Agents
1. **Context Ingestion:** Start your task by reading this file completely. It contains the most up-to-date state of the project.
2. **Mandatory State Update:** Upon completing a task, making significant changes, resolving bugs, or advancing the roadmap, you MUST update the "Recent AI Updates", "Current Project State", and "Next Prio
<truncated 5318 bytes>
rdware setup and build guide. Board, pins, UART, build steps, test procedure. | ✅ Created | 2026-06-03 |
| `Docs/known_issues.md` | Living issue tracker. Bugs, limitations, technical debt, future investigations. | ✅ Created | 2026-06-03 |
| `Docs/DECISIONS/README.md` | ADR system index and format guide. Lists all ADRs with status. | ✅ Created | 2026-06-03 |
| `Docs/DECISIONS/001_initial_docs.md` | ADR: Decision to create this documentation system. | ✅ Accepted | 2026-06-03 |
| `Docs/DECISIONS/002_uart_mmio_layout.md` | ADR stub: UART MMIO address layout decision. | ⏳ Proposed | 2026-06-03 |
| `Docs/DECISIONS/003_hazard_strategy.md` | ADR stub: Pipeline hazard handling strategy. | ⏳ Proposed | 2026-06-03 |
| `Docs/DECISIONS/004_exception_handling.md` | ADR stub: Exception and trap handling approach. | ⏳ Proposed | 2026-06-03 |
| `Docs/DECISIONS/005_cache_decision.md` | ADR stub: Cache architecture or explicit no-cache decision. | ⏳ Proposed | 2026-06-03 |
| `Docs/Updates/README.md` | Index of all session logs. Append a link after every session. | ✅ Live | TODO |

## 📝 Recent AI Updates
- **2026-06-03**: Created documentation system: instruction_support.md, verification.md, performance.md, ownership.md, hardware_setup.md, known_issues.md, DECISIONS/ directory with 001 ADR and 4 stubs. Extended ai_context.md with File Registry and Agent Boot Sequence.
- **2026-06-03**: Implemented the Phase 3 debug/reliability slice: MMIO debug registers, a 4-entry trace buffer, and simulation checks that validate the debug window and trace history. Updated `Docs/status.md`, `Docs/architecture.md`, and the simulation testbench; Phase 4 is now the next major milestone.
- **2026-06-03**: Read the documentation folder, updated timestamps in `architecture.md` and `status.md`, and initialized this `ai_context.md` file to act as the primary brain for future AI agent interactions.
