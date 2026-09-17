#!/bin/sh
# Claude Code statusLine command
# Mirrors the Fish prompt style from ~/.config/fish/config.fish
# Colors from Catppuccin Mocha palette:
#   overlay  #7f849c  -> \033[38;2;127;132;156m
#   blue     #89b4fa  -> \033[38;2;137;180;250m
#   mauve    #cba6f7  -> \033[38;2;203;166;247m
#   green    #a6e3a1  -> \033[38;2;166;227;161m
#   peach    #fab387  -> \033[38;2;250;179;135m  (used for model/ctx info)
#   red      #f38ba8  -> \033[38;2;243;139;168m  (used for deletions)

input=$(cat)

user=$(whoami)
host=$(hostname -s)
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

# Shorten home directory to ~
home_escaped=$(echo "$HOME" | sed 's/[[\.*^$()+?{|]/\\&/g')
cwd=$(echo "$dir" | sed "s|^$home_escaped|~|")

model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_5h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rate_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Git branch
git_branch=""
gh_repo=""
git_diff=""
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)
  if [ -z "$git_branch" ]; then
    git_branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  fi

  # GitHub repo from remote
  remote_url=$(git -C "$dir" remote get-url origin 2>/dev/null)
  if echo "$remote_url" | grep -q "github\.com"; then
    gh_repo=$(echo "$remote_url" | sed 's|.*github\.com[:/]\(.*\)\.git|\1|' | sed 's|.*github\.com[:/]\(.*\)|\1|')
  fi

  # Diff stats (staged + unstaged vs HEAD)
  stats=$(git -C "$dir" diff --numstat HEAD 2>/dev/null)
  staged=$(git -C "$dir" diff --cached --numstat 2>/dev/null)
  add=$(printf '%s\n%s\n' "$stats" "$staged" | awk '{a+=$1} END {print a+0}')
  del=$(printf '%s\n%s\n' "$stats" "$staged" | awk '{a+=$2} END {print a+0}')
  if [ "$add" -gt 0 ] || [ "$del" -gt 0 ]; then
    git_diff="+${add}/-${del}"
  fi
fi

# [user@host] (cwd) (git:branch | owner/repo +N/-N) [model] ctx:XX% plan:5h:XX% 7d:XX%
printf "\033[38;2;127;132;156m[\033[0m"
printf "\033[38;2;137;180;250m%s@%s\033[0m" "$user" "$host"
printf "\033[38;2;127;132;156m] \033[0m"
printf "\033[38;2;203;166;247m(%s)\033[0m" "$cwd"

if [ -n "$git_branch" ]; then
  if [ -n "$gh_repo" ]; then
    printf "\033[38;2;166;227;161m (%s - %s)\033[0m" "$gh_repo" "$git_branch"
  else
    printf "\033[38;2;166;227;161m (git:%s)\033[0m" "$git_branch"
  fi
  if [ -n "$git_diff" ]; then
    add_part=$(echo "$git_diff" | cut -d/ -f1)
    del_part=$(echo "$git_diff" | cut -d/ -f2)
    printf " \033[38;2;127;132;156m[\033[0m\033[38;2;166;227;161m%s\033[0m\033[38;2;243;139;168m%s\033[0m\033[38;2;127;132;156m]\033[0m" "$add_part" "/$del_part"
  fi
fi

if [ -n "$model" ]; then
  printf " \033[38;2;250;179;135m[%s]\033[0m" "$model"
fi

if [ -n "$remaining" ]; then
  printf " \033[38;2;250;179;135mctx:%s%%\033[0m" "$(printf '%.0f' "$remaining")"
fi

if [ -n "$rate_5h" ] || [ -n "$rate_7d" ]; then
  # Pick color based on 5h usage: green < 70%, yellow < 90%, red >= 90%
  if [ -n "$rate_5h" ]; then
    if [ "$rate_5h" -ge 90 ]; then
      rate_color="\033[38;2;243;139;168m"
    elif [ "$rate_5h" -ge 70 ]; then
      rate_color="\033[38;2;249;226;175m"
    else
      rate_color="\033[38;2;166;227;161m"
    fi
  else
    rate_color="\033[38;2;166;227;161m"
  fi

  printf " ${rate_color}["
  if [ -n "$rate_5h" ]; then
    printf "5h:%s%%" "$rate_5h"
    # Show reset time if usage is high
    if [ "$rate_5h" -ge 70 ] && [ -n "$rate_5h_reset" ]; then
      reset_in=$(( rate_5h_reset - $(date +%s) ))
      if [ "$reset_in" -gt 0 ]; then
        reset_min=$(( reset_in / 60 ))
        printf " resets:%dm" "$reset_min"
      fi
    fi
  fi
  if [ -n "$rate_7d" ]; then
    [ -n "$rate_5h" ] && printf " "
    printf "7d:%s%%" "$rate_7d"
  fi
  printf "]\033[0m"
fi
