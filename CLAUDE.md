# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.6 2D game project focused on learning Finite State Machine (FSM) patterns. The project uses CharacterBody2D for the player entity with an AnimationTree-based state machine.

## Running the Project

- Open the project in Godot 4.6 editor, or run from command line:
  ```bash
  godot --headless # headless server mode
  godot          # with display
  ```

## Controls

- **WASD / Arrow Keys**: Movement
- **Left Mouse Click**: Attack (direction based on mouse position)

## Architecture

### Player Entity (`scenes/entity/player/palyer.gd`)

The player implements a manual FSM with these states:
- `IDLE` - No movement
- `RUN` - Moving
- `ATTACK` - Attacking (locks movement during attack)
- `DEAD` - Dead (defined but not implemented)

State transitions are handled in `movement_loop()` and `attack()` methods.

### Animation System

Uses `AnimationTree` with `AnimationNodeStateMachine`:
- State machine transitions: idle ↔ run ↔ attack
- Attack state uses `BlendSpace2D` for 4-directional attack animations (up, down, left, right)
- Sprite flip is managed based on movement/attack direction

### Scene Structure

```
scenes/
├── entity/
│   └── player/
│       ├── palyer.gd        # Player script
│       └── palyer.tscn      # Player scene with AnimationTree
└── test/
    └── test_scene_tilemap.tscn  # Test level with tilemap
```

## Key Files

- `project.godot` - Godot project config, input bindings (up/down/left/right)
- `scenes/entity/player/palyer.gd` - Main player FSM implementation
- `scenes/entity/player/palyer.tscn` - Player scene with AnimationTree setup
