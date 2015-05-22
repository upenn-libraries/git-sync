# git-sync
Git plugin for version-aware synchronization of client-side edits to server-side evaluation and full git workflow.

## Motivation and Design
For a workflow where web developers are working on personal workstations (some running Windows), and need to
sync their files to a server to evaluate their changes. 

There is a desire to confine the full git workflow to the server in order to allow more effective monitoring 
and troubleshooting (e.g., in case of merge conflicts and users with limited Git experience), but also of course 
a desire to avoid the potential dangers (e.g., accidental overwriting of changes) inherent in a version-unaware 
workstation/server synchronization workflow. 

Git is used on the workstation essentially as a version-aware runtime environment for syncing changes to the server, 
and for wrapping calls to run a handful of the simplest git commands on the server. This standardizes the toolset 
needed for deploying synchronization solutions, and provides convenient workflow hooks (e.g., a post-update git hook 
for re-bundling javascript files on pushing incremental changes to the server for evaluation).
