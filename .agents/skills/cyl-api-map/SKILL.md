---
name: cyl-api-map
description: Map the placeholder and refresh APIs to their headers, example, tests, and documentation.
---

# API map

Inspect the headers and implementation before changing behavior. Code is the
source of truth; update the README and issue tracker if they become stale.

| Area | Source |
| --- | --- |
| Public umbrella | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h` |
| Placeholder reload | `CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h` |
| Placeholder provider and frame | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h` |
| Refresh public API | `CYLTableViewPlaceHolder/CYLRefresh/CYLRefresh.h` |
| Refresh categories | `CYLTableViewPlaceHolder/CYLRefresh/UIScrollView+CYLRefresh.h` |
| Example | `Example/ViewController.m` |
| Regression tests | `Tests/PlaceholderTests.m` |
| Integration and usage | `README.md` |
| Issue history | `docs/issue-progress.md` |

Preserve API compatibility and keep this map current when a mapped file or
public API changes.
