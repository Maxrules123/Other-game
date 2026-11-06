# Implementation checklist

- [x] Milestone 1: fresh Rojo architecture and complete starter-loop implementation.
  - Present: target claims, server timing, loot, banking, upgrades, objective onboarding.
  - Verified: domain assertions for transactions and timing; source compilation and Rojo build.
  - Pending: Roblox Studio end-to-end playtest and first-success timing.
- [x] Milestone 2: Starter Street geometry, UI, input, Heat, suspicion, and security.
  - Present: stylized city primitives, props, guard perception/patrol/chase/search/capture, menus, touch/gamepad controls.
  - Verified: compile/build, capture/Heat/suspicion transaction assertions, code review.
  - Pending: actual pathfinding, collision, camera, visual polish, device focus and layout tests.
- [x] Milestone 3: saving, index, starter/daily missions.
  - Present: versioned profiles, lease-based UpdateAsync, retries, autosave/shutdown, nonpersistent Studio mode, collection variants/milestones, seven starter jobs, daily claims.
  - Verified: mocked load/rejoin/lease/failure tests; collection and mission reward tests.
  - Pending: private published Roblox persistence, real throttling/concurrency and UTC-boundary tests.
- [x] Milestone 4: five connected districts and configured progression.
  - Present: distinct district geometry, colors/landmarks, targets, security levels, unlock prices/requirements.
  - Verified: obtainable catalog entries and district transaction assertions; build.
  - Pending: traverse all districts in Studio and assess economy pacing and sightlines.
- [x] Milestone 5: Vault Run, prestige, presentation, bounded update loops.
  - Present: spatially isolated rooms, hazards/card/exit/timer, cleanup/replay, prestige confirmation and capped bonus, reveals, particles, configurable audio slots.
  - Verified: prestige reset/preserve assertions, compilation/build, code review.
  - Pending: actual Vault Run playtest, performance profiling, permitted audio assets.

**Status:** implemented source and build artifacts delivered; runtime acceptance is pending Studio validation. Checklist ticks mean implementation exists, not that unperformed Roblox tests passed.
