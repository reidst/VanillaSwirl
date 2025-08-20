#!/usr/bin/env bash
if ! ls -A /var/run/screen/S-$USER >/dev/null; then exit 1; fi
for session in /var/run/screen/S-$USER/*; do
    if [[ "$session" =~ \.vanillaswirl\. ]]; then exit 0; fi
done
exit 1
