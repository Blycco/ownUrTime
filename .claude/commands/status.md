# /status
> Print current project state.

Output format:
```
[OwnUrTime Status]
Branch    : {git branch --show-current}
Last commit: {git log --oneline -1}
Memory    : {top entry from .claude/memory.md}
Phase     : {current MVP phase}
Open tasks: {list of incomplete work}
```

Run:
```bash
echo "Branch: $(git branch --show-current)"
echo "Last:   $(git log --oneline -1)"
echo "---"
head -20 .claude/memory.md
```
