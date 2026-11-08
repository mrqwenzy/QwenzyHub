# How it works

- `Loader.lua` loads utilities, shared modules, and WindUI from public raw GitHub URLs. Add a source and one `FeatureRegistry` entry when inserting a feature; each feature receives a shared `App` table.
- `Features/Combat.lua` owns combat controls and registers their defaults with the config module.
- `Features/Settings.lua` owns the config and appearance UI. The selected WindUI theme is saved with every config.
- `Modules/ConfigManager.lua` creates, saves, loads, lists, and deletes named JSON files in `QwenzyRecode_Configs`. Missing values use the registered control default, including numeric slider defaults.
- The remote loader uses public raw URLs. A private GitHub repository requires a server-side proxy or another public delivery location; placing a GitHub token in client code exposes it.
- `MainHub/GetClosestMobs.lua` finds living player characters and/or mobs in range, sorts them by distance, and returns the nearest model or a list.
- `MainHub/Hitter.lua` rate-limits attack registration, then sends hit data for a target part or list of targets.

## Issues spotted
