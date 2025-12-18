# Fugitive Merge Conflict Resolution Guide

## Key Mappings for Merge Conflicts

### Global Keymaps (available anywhere):
- `<leader>gs` - Open Git status
- `<leader>gd` - Open 3-way diff for merge conflicts (`Gvdiffsplit!`)
- `<leader>gh` - Get from HEAD/current branch (left side in diff)
- `<leader>gm` - Get from merge branch (right side in diff)
- `<leader>gc` - Add all changes and commit

### Inside Fugitive Buffer:
- `<leader>p` - Git push
- `<leader>P` - Git pull with rebase
- `<leader>t` - Git push with upstream tracking
- `<leader>gj` - Get from target branch (right side)
- `<leader>gf` - Get from current branch (left side)
- `<leader>gs` - Stage current file (Gwrite)

## Typical Merge Conflict Workflow

1. When you encounter a merge conflict:
   ```
   <leader>gs    # Open Git status to see conflicted files
   ```

2. Navigate to a conflicted file and press `Enter` to open it

3. Open 3-way diff view:
   ```
   <leader>gd    # Opens Gvdiffsplit! (3-way diff)
   ```

4. In the diff view:
   - Left window: Your current branch (HEAD)
   - Middle window: The working copy (what you're editing)
   - Right window: The branch you're merging

5. Resolve conflicts by choosing which changes to keep:
   ```
   <leader>gh    # Accept change from HEAD (left)
   <leader>gm    # Accept change from merge branch (right)
   ```

6. After resolving conflicts:
   ```
   :Gwrite       # Stage the resolved file
   <leader>gc    # Add all and commit
   ```

## Fugitive Commands Reference

- `:Git` or `:G` - Run any git command
- `:Gwrite` - Stage current file
- `:Gread` - Checkout current file (discard changes)
- `:Gvdiffsplit` - Vertical diff split
- `:Gvdiffsplit!` - 3-way diff (for merge conflicts)
- `:Gdiffsplit` - Horizontal diff split
- `:Gblame` - Git blame
- `:Gbrowse` - Open in browser (if remote is GitHub/GitLab)
- `:Glog` - Load previous revisions into quickfix
- `:Gedit` - Edit a git object

## Tips

1. Use `]c` and `[c` to jump between conflicts in diff mode
2. Use `:diffupdate` if the diff highlighting gets out of sync
3. Use `:diffget` with buffer numbers for more precise control
4. Use `:windo diffthis` to create a diff between any two windows
