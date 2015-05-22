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

## Installation
### Server
Clone the git-sync project into ./.git/sync (the .git directory of your project) on the server. 

Run `./.git/sync/init.sh server`

### Client
Clone your project from your server repository (see above) to the client machine.

Run `./.git/sync/init.sh client`

## Commands
### Server
`git sync [lock | unlock]`: locks or unlocks sync functionality from client; enables safe manual git workflow on server

`git sync working-on`: you always have the `work` branch checked out; this command tells you what the corresponding 
branch is

`git sync checkout [-b] <branchname>`: a wrapper around `git checkout [-b] <branchname>` that takes as it's base 
the current sync `working-on` branch, as opposed to the checked out branch (which is always the sync work branch).
Running this command changes the target of the sync work branch to the specified branch (creating a new branch with 
`git checkout -b` if necessary).

### Client
`git sync`: with no args, wraps `git commit -am` with a dummy commit message, and `git push origin`, to sync current work
tree to the server

`git sync update [meaningful commit message]`: remote call to the server pulls in recent changes from the `working-on` 
branch into the sync work branch, squash-merging the current contents of the sync work branch if necessary, and syncs 
the new work branch back to the client. Effectively the same as svn up, from the client's perspective. If the optional 
commit message argument is supplied, the squash-merged contents of the sync work branch are ff-merged into the 
`working-on` branch, effectively making related changes "permanent"

`git sync checkout [-b] <branchname>`: remote call to server checkout command, allows simple branch workflow to be acheived
directly from the client

`git sync working-on`: tells you the branch you're working on.
