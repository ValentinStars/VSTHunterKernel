# Manual builds and releases

Only `workflow_dispatch` triggers the A51 build. Pushes, pull requests and a
schedule do not run it. There is no hidden periodic job or build on every commit.

Open **Actions → Build A51 kernel and release → Run workflow**. Select main or a
reviewed branch. `publish_release` defaults to true: a successful build becomes
a prerelease. Turn it off for an artifact-only build. Leave `release_tag` blank
for a unique `ci-alpha5-RUN-SHA` tag, or enter a new tag. Existing tags are rejected;
the workflow does not overwrite the manually validated Alpha5 release.

Builds use a pinned Neutron Clang 18 archive with SHA256 checking, Ubuntu 24.04,
and the normal checked-in build scripts. Actions are pinned to commit hashes.
A repeated launch for the same branch cancels the older run. Build step limit:
65 minutes; total job limit: 80 minutes. Artifacts/logs expire after 3 days.
No multi-device matrix, schedule or extra compilation job is used.

Outputs: AnyKernel kernel ZIP, raw Image, matching slcan/br_netfilter modules,
effective config, nine-module Magisk bundle, public helper sources, build
provenance and checksums. Phone backups, ROM services.jar and libttmod.so are
never inputs or outputs of CI. Their local overlays require the owner's files.

CI proves compilation/packaging, not that a new kernel boots or fixes a phone.
Automated releases remain prereleases pending device testing. The historical
Alpha5 session results do not certify later CI binaries.
