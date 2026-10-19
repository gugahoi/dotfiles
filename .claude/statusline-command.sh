#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
dir=$(echo "$input" | jq -r '.workspace.current_dir' | xargs basename)
style=$(echo "$input" | jq -r '.output_style.name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Build the base label
if [ "$style" != "default" ]; then
  label="$model | $dir | $style"
else
  label="$model | $dir"
fi

# Append context usage if available
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  label="$label | ctx: ${used_int}%"
fi

# Append 5-hour session usage (and reset time if available)
if [ -n "$five_hour" ]; then
  five_int=$(printf "%.0f" "$five_hour")
  if [ -n "$five_hour_resets" ]; then
    current_time=$(date +%s)
    time_left=$((five_hour_resets - current_time))
    if [ "$time_left" -gt 0 ]; then
      if [ "$time_left" -ge 3600 ]; then
        hours=$((time_left / 3600))
        reset_label="resets in ${hours}h"
      else
        minutes=$(((time_left + 59) / 60))
        reset_label="resets in ${minutes}m"
      fi
      label="$label | session: ${five_int}% (${reset_label})"
    else
      label="$label | session: ${five_int}%"
    fi
  else
    label="$label | session: ${five_int}%"
  fi
fi

# Append 7-day weekly usage (and reset time if available)
if [ -n "$seven_day" ]; then
  week_int=$(printf "%.0f" "$seven_day")
  if [ -n "$seven_day_resets" ]; then
    current_time=$(date +%s)
    time_left=$((seven_day_resets - current_time))
    if [ "$time_left" -gt 0 ]; then
      if [ "$time_left" -lt 3600 ]; then
        minutes=$(((time_left + 59) / 60))
        reset_label="resets in ${minutes}m"
      elif [ "$time_left" -lt 86400 ]; then
        hours=$((time_left / 3600))
        reset_label="resets in ${hours}h"
      else
        reset_label="ends $(date -r "$seven_day_resets" "+%a %H:%M" 2>/dev/null)"
      fi
      label="$label | weekly: ${week_int}% (${reset_label})"
    else
      label="$label | weekly: ${week_int}%"
    fi
  else
    label="$label | weekly: ${week_int}%"
  fi
fi

printf "\033[2m%s\033[0m" "$label"
