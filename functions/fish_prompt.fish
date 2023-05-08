# <default customization />
## :: symbols ::
set -l __mayfish_default_symbol_git_hash ":"
## :: colors ::
### main
set -l __mayfish_default_color_tag (set_color normal)
set -l __mayfish_default_color_dir (set_color cyan)
set -l __mayfish_default_color_user (set_color yellow)
### root
set -l __mayfish_default_color_root (set_color -o red)
set -l __mayfish_default_color_root_tag (set_color -o red)
### git
set -l __mayfish_default_color_git_branch (set_color green)
set -l __mayfish_default_color_git_state (set_color magenta)

# <set customization />
## :: utility ::
function __mayfish_default_fallback -d "return if not set"
	set -l arg0 $argv[1]
	set -l arg1 $argv[2]

	if test -n $arg0
		echo $arg0
	else
		echo $arg1
	end
end

## :: symbols ::
set __mayfish_local_symbol_git_hash (__mayfish_default_fallback $__mayfish_symbol_git_hash $__mayfish_default_symbol_git_hash)
## :: colors ::
### main
set __mayfish_local_color_tag (__mayfish_default_fallback $__mayfish_color_tag $__mayfish_default_color_tag)
set __mayfish_local_color_dir (__mayfish_default_fallback $__mayfish_color_dir $__mayfish_default_color_dir)
set __mayfish_local_color_user (__mayfish_default_fallback $__mayfish_color_user $__mayfish_default_color_user)
### root
set __mayfish_local_color_root (__mayfish_default_fallback $__mayfish_color_root $__mayfish_default_color_root)
set __mayfish_local_color_root_tag (__mayfish_default_fallback $__mayfish_color_root_tag $__mayfish_default_color_root_tag)
### git
set __mayfish_local_color_git_branch (__mayfish_default_fallback $__mayfish_color_git_branch $__mayfish_default_color_git_branch)
set __mayfish_local_color_git_state (__mayfish_default_fallback $__mayfish_color_git_state $__mayfish_default_color_git_state)

# <git integration />
function __mayfish_git_path -d "get path of git directory"
	echo (git rev-parse --git-dir 2> /dev/null)
end

function __mayfish_git_hash -d "format git hash"
	set -l hash_long $argv[1]
	set -l hash_short (git rev-parse --short $hash_long)
	set -l hash_rel (git name-rev --no-undefined --always --exclude="tags/*" --exclude="remotes/*" --exclude="bisect/*" "$hash_short" 2> /dev/null)

	set -l spl (string split " " $hash_rel)
	if test "$spl[1]" = "$spl[2]"
		set hash_rel (git name-rev --no-undefined --always --exclude="tags/*" "$hash_short" 2> /dev/null)
		set spl (string split " " $hash_rel)

		if test "$spl[1]" = "$spl[2]"
			set --erase hash_rel
		end
	end

	if [ $hash_rel ]
		echo $__mayfish_local_symbol_git_hash$hash_rel
	else
		echo $__mayfish_local_symbol_git_hash$hash_short
	end
end

## thx https://github.com/Byron/gitoxide/blob/31801420e1bef1ebf32e14caf73ba29ddbc36443/gix/src/repository/state.rs#L3
## thx https://github.com/Byron/gitoxide/blob/31801420e1bef1ebf32e14caf73ba29ddbc36443/gix/src/state.rs#L3
function __mayfish_git_state -d "get info for current git operation"
	set -l git_path $(__mayfish_git_path)

	if test -f "$git_path/rebase-apply/applying"
		echo "am"
	else if test -f "$git_path/rebase-apply/rebasing"
		# todo rebase steps / extra info ?
		# idk how to get into this mode lol
		echo "rbs"
	else if test -d "$git_path/rebase-apply"
		echo "am/rbs"
	else if test -d "$git_path/rebase-merge"
		set -l branch
		set -l proc

		if test -f "$git_path/rebase-merge/head-name"
			set -l branch_str (cat "$git_path/rebase-merge/head-name" | sed -e 's/^refs\/heads\///')
			[ $branch_str ] && set branch " $branch_str"
		end

		if test -f "$git_path/rebase-merge/msgnum"
			set -l step (cat "$git_path/rebase-merge/msgnum")
			set -l total (cat "$git_path/rebase-merge/end")
			set proc " $step/$total"
		end

		echo "rbs$branch$proc"
	else if test -f "$git_path/BISECT_LOG"
		set -l branch
		if test -f "$git_path/BISECT_START"
			set -l branch_str (cat "$git_path/BISECT_START")
			set branch " $branch_str"
		end

		echo "bsc$branch"
	else if test -f "$git_path/MERGE_HEAD"
		set -l hash_long (cat "$git_path/MERGE_HEAD")
		set -l hash (__mayfish_git_hash $hash_long)

		echo "mrg $hash"
	else if test -f "$git_path/CHERRY_PICK_HEAD"
		set -l hash_long (cat "$git_path/CHERRY_PICK_HEAD")
		set -l hash (__mayfish_git_hash $hash_long)

		echo "chp $hash"
	else if test -f "$git_path/REVERT_HEAD"
		set -l hash_long (cat "$git_path/REVERT_HEAD")
		set -l hash (__mayfish_git_hash $hash_long)

		echo "rvt $hash"
	end 
end

function __mayfish_git_branch -d "get name of current branch / hash"
	set -l ref (git symbolic-ref --quiet HEAD 2> /dev/null)
	set -l ret $status
	set -l git_branch ""

	if [ $ret = 0 ]
		echo $ref | sed -e 's/^refs\/heads\///'
	else
		[ $ret = 128 ] && return
		set ref (git rev-parse --short HEAD 2> /dev/null) || return
		set -l hash (__mayfish_git_hash $ref)
		echo $hash
	end
end

function __mayfish_git -d "get git info"
	set -l git_branch (__mayfish_git_branch)
	[ $git_branch ] || return

	set -l git_state (__mayfish_git_state)

	if [ $git_state ]
		echo -ns $__mayfish_local_color_git_branch'('$__mayfish_local_color_git_state$git_state$__mayfish_local_color_git_branch' '$git_branch')'
	else
		echo -ns $__mayfish_local_color_git_branch'('$git_branch')'
	end
end

# <prompt info />
function __mayfish_tag -d "start character of shell, \$ usually, # for root"
	set -l normal (set_color normal)

	if [ (whoami) = "root" ]
		echo "$__mayfish_local_color_root_tag#$normal"
	else
		echo "$__mayfish_local_color_tag\$$normal"
	end
end

function __mayfish_usr -d "get whomai"
	set -l normal (set_color normal)

	set -l usr (whoami)
	if [ $usr = "root" ]
		echo "$__mayfish_local_color_root$usr$normal"
	else
		echo "$__mayfish_local_color_user$usr$normal"
	end
end

function __mayfish_dir -d "get dir"
	set -l normal (set_color normal)

	set -l pwd (prompt_pwd)
	set -l dir (basename $pwd)

	echo "$__mayfish_local_color_dir$dir$normal"
end

# <prompt />
function fish_prompt -d "generate prompt"
	set -l normal (set_color normal)

	set -l tag (__mayfish_tag)
	set -l usr (__mayfish_usr)
	set -l dir (__mayfish_dir)
	set -l git (__mayfish_git)

	if test $git
		echo -ns $tag' '$usr' '$dir' '$git$normal' >> ' 
	else
		echo -ns $tag' '$usr' '$dir$normal' >> ' 
	end
end
