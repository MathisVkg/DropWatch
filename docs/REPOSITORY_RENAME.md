# Optional GitHub repository rename

The existing local Git repository and its commit history are retained at:
C:/Users/zeyros/Documents/repository/loot-tracker

Current origin: https://github.com/MathisVkg/loot-tracker.git
No remote was changed, pushed or published by this task.

Recommended manual procedure, after reviewing the rebrand:
1. Open the GitHub repository, then Settings.
2. Under Repository name, enter dropwatch and choose Rename (requires admin permission).
3. Once the rename succeeds, update this local clone:
   git -C "C:/Users/zeyros/Documents/repository/loot-tracker" remote set-url origin https://github.com/MathisVkg/dropwatch.git
4. Check git remote -v, then fetch to confirm access.
5. Update README/website links, badges, clone URLs, package metadata, workflow references and any future project-site or CurseForge links to the new slug. Current source has no repository badges/workflows or publishing configuration. The historical local directory name may remain unchanged.

GitHub generally redirects old repository and Git transport URLs, but project-site URLs and action references need separate care. Avoid reusing the old repository name if you rely on redirects. See [GitHub's official rename instructions](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository).

Do not publish a GitHub release or CurseForge listing as part of this rename. None is performed here.
