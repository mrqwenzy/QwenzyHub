# How it works

- `Loader.lua` fetches `GetClosestMobs` and `Hitter` from GitHub, then loads WindUI and builds a small UI with a Fast Attack toggle.
- `MainHub/GetClosestMobs.lua` finds living player characters and/or mobs in range, sorts them by distance, and returns the nearest model or a list.
- `MainHub/Hitter.lua` rate-limits attack registration, then sends hit data for a target part or list of targets.

## Issues spotted
