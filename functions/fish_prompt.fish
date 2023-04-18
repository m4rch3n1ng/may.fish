function __mayfish_git_path -d "get path of git directory"
	echo (git rev-parse --git-dir 2> /dev/null)
end

function __mayfish_git_hash -d "format git hash"
	set -l hash_long $argv[1]
	set -l hash_short (git rev-parse --short $hash_long)
	set -l hash_rel (git name-rev --no-undefined --always --exclude="tags/*" --exclude="remotes/*" "$hash_short" 2> /dev/null)

	set -l spl (string split " " $hash_rel)
	if test "$spl[1]" = "$spl[2]"
		set hash_rel (git name-rev --no-undefined --always --exclude="tags/*" "$hash_short" 2> /dev/null)
		set spl (string split " " $hash_rel)

		if test "$spl[1]" = "$spl[2]"
			set --erase hash_rel
		end
	end

	if [ $hash_rel ]
		echo $hash_rel
	else
		echo $hash_short
	end
end

# thx https://github.com/ohmyzsh/ohmyzsh/blob/d47e1d65f66f9bb2e7a96ba58797b33f0e91a623/themes/peepcode.zsh-theme#L14
# thx https://github.com/zthxxx/jovial/blob/bd705f1b74ecb1dfc5a3637193498191a016bb09/jovial.zsh-theme#L749
function __mayfish_git_mode -d "get info for current git operation"
	set -l git_path $(__mayfish_git_path)
	set -l green (set_color green)

	if test -e "$git_path/rebase"; or test -e "$git_path/rebase-apply"; or test -e "$git_path/rebase-merge"
		set -l branch
		set -l proc

		if test -f "$git_path/rebase-merge/msgnum"
			set -l step (cat "$git_path/rebase-merge/msgnum")
			set -l total (cat "$git_path/rebase-merge/end")
			set proc " $step/$total"
		end

		if test -f "$git_path/rebase-merge/head-name"
			set -l branch_str (cat "$git_path/rebase-merge/head-name" | sed -e 's/^refs\/heads\///')
			[ $branch_str ] && set branch " $green$branch_str"
		end

		echo "rbs$proc$branch"
	else if test -e "$git_path/BISECT_LOG"
		set -l branch
		if test -f "$git_path/BISECT_START"
			set -l branch_str (cat "$git_path/BISECT_START")
			set branch " $branch_str"
		end

		echo "bsc$branch"
	else if test -e "$git_path/MERGE_HEAD"
		set -l hash_long (cat "$git_path/MERGE_HEAD")
		set -l hash (__mayfish_git_hash $hash_long)

		echo "mrg :$hash"
	else if test -f "$git_path/CHERRY_PICK_HEAD"
		set -l hash_long (cat "$git_path/CHERRY_PICK_HEAD")
		set -l hash (__mayfish_git_hash $hash_long)

		echo "chp :$hash"
	else if test -f "$git_path/REVERT_HEAD"
		set -l hash_long (cat "$git_path/REVERT_HEAD")
		set -l hash (__mayfish_git_hash $hash_long)

		echo "rvt :$hash"
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
		echo ':'$hash
	end
end

function __mayfish_git -d "get git info"
	set -l red (set_color red)
	set -l green (set_color green)

	set -l git_branch (__mayfish_git_branch)
	[ $git_branch ] || return

	set -l git_mode (__mayfish_git_mode)

	if [ $git_mode ]
		echo -ns $green'('$red$git_mode$green' '$git_branch')'
	else
		echo -ns $green'('$git_branch')'
	end
end

function __mayfish_start -d "start character of shell, \$ normally, # for root"
	if [ (whoami) = "root" ]
		echo "#"
	else
		echo "\$"
	end
end

function fish_prompt -d "generate prompt"
	set -l normal (set_color normal)
	set -l magenta (set_color magenta)
	set -l yellow (set_color yellow)

	set -l start (__mayfish_start)
	set -l usr $yellow(whoami)$normal
	set -l dir $magenta(basename (prompt_pwd))$normal
	set -l git (__mayfish_git)

	if test $git
		echo -ns $start' '$usr' '$dir' '$git$normal' >> ' 
	else
		echo -ns $start' '$usr' '$dir$normal' >> ' 
	end
end
