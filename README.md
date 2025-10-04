## open-source-plugins

> A cross-platform set of procedural groove-generation tools for **Autodesk 3ds Max** and **SketchUp Pro**, designed to streamline surface detailing and modeling automation for both 3D artists and plugin developers.

---

### 🗂️ Repository Structure

```
open-source-plugins/
│
├── Autodesk 3ds Max/
│   └── groove-ridge-modifier.ms
│
└── SketchUp Pro/
    └── groove-tool.rb
```

---

## Overview

### 🔹 Autodesk 3ds Max — **Groove Ridge Modifier (GR New Tool v21.0)**

**File:** `Autodesk 3ds Max/groove-ridge-modifier.ms`

* Adds a new **modifier** named **“GR New”** directly to the **Modifier List**.
* Enables creation of procedural **grooves** and **ridges** using boolean operations for direct modeling control.
* Supports both **equal** and **random** distribution with adjustable seed values.
* Non-destructive workflow within the modifier stack — no need to run scripts manually.
* All parameters are available directly within the modifier rollout for easy fine-tuning.
* Integrates cleanly into 3ds Max’s startup process for automatic availability.

**Key Features:**

* Procedural groove/ridge creation using compound boolean operations.
* Directional control: Along Length (Y), Width (X), or Both.
* Adjustable count, width, height, and spacing.
* Parameter persistence for iterative modeling.
* Modifier-based accessibility for faster iteration and scene management.

---

### 🔹 SketchUp Pro — **GrooveTool**

**File:** `SketchUp Pro/groove-tool.rb`

* Adds a **context menu tool** for generating grooves on rectangular faces.
* Built using the **SketchUp Ruby API** for seamless integration and lightweight operation.
* Prompts for customizable groove width, depth, and spacing.
* Automatically push-pulls groove faces to create physical geometry.
* Designed for quick face-based modeling tasks with full undo support.

**Key Features:**

* Simple right-click workflow.
* Configurable groove dimensions in millimeters.
* Automatic validation of face size before execution.
* Lightweight and Ruby Console–friendly for developers extending functionality.

---

## Installation

### Autodesk 3ds Max

**Installation path (typical):**

```
C:\Users\<username>\AppData\Local\Autodesk\3ds Max\<version>\Plugins\
```

**Steps:**

1. Copy `groove-ridge-modifier.ms` into your 3ds Max **Plugins** folder.
2. Restart 3ds Max.
3. Open any scene, select an object, and look for **“GR New”** in the **Modifier List**.
4. Apply the modifier to start generating grooves and ridges directly.

> 💡 The plugin loads automatically at startup — no manual script execution required.

---

### SketchUp Pro

**Installation path (Windows):**

```
C:\Users\<username>\AppData\Roaming\SketchUp\SketchUp <version>\SketchUp\Plugins\
```

**Installation path (macOS):**

```
~/Library/Application Support/SketchUp <version>/SketchUp/Plugins/
```

**Steps:**

1. Copy `groove-tool.rb` into the **Plugins** folder.
2. Restart SketchUp.
3. Right-click any rectangular face and choose **“Create Groove”** from the context menu.

> 💡 The tool automatically loads at startup and appears in the right-click context menu for faces.

---

## Developer Notes

Both tools are open and easily modifiable — ideal for learning, customization, and extending.

### 3ds Max

* Written entirely in **MaxScript**.
* Modifier-based architecture (registered through startup loading).
* Safe undo and parameter persistence.
* Extendable for additional pattern types, variable spacing, or mesh cleanup routines.

### SketchUp

* Implemented in **Ruby** using the native API.
* Uses `UI.add_context_menu_handler` for non-intrusive integration.
* All logic contained in a single module — easy to subclass or convert to a full extension.
* Developers can add toolbar integration, persistent settings, or geometry pattern variants.

---

## License

Licensed under the **MIT License** — free for personal, commercial, and educational use.
See the included `LICENSE` file for details.

---

## Credits

Developed and maintained by **Krutik Mehta**. Pull requests are welcome!
