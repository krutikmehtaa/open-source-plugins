## open-source-plugins

> A cross-platform set of procedural groove-ridge generation tools for **Autodesk 3ds Max** and **SketchUp Pro**, designed to streamline surface detailing and modeling automation for both 3D artists and plugin developers.

---

### 🗂️ Repository Structure

```
open-source-plugins/
│
├── Autodesk 3ds Max/
│   ├── utility_rectangular_grooves.ms
│   ├── utility_rectangular_ridges.ms
│   └── utility_startup.ms
│
└── SketchUp Pro/
    └── groove-tool.rb
```

---

## Overview

### 🔹 Autodesk 3ds Max — **Grooves & Ridges Utilities**

**Files:** 
* `utility_rectangular_grooves.ms` — Grooves Utility v2.3
* `utility_rectangular_ridges.ms` — Ridges Utility v2.3
* `utility_startup.ms` — Auto-loader for startup

**Access:** Utilities Panel > MAXScript > Utilities dropdown > "Grooves" or "Ridges"

**Key Features:**

* **Three-axis control:** Along X-Axis, Y-Axis, or Both Axes simultaneously
* **Auto-center mode:** Automatically calculates optimal spacing and offsets
* **Real-time calculation:** Live preview of spacing gaps and warnings
* **Parameter persistence:** Settings are stored with the object via custom attributes
* **Load From Selected:** Reload previous settings from grooved/ridged objects
* **Safe undo system:** Built-in RESET button (avoids Ctrl+Z issues with boolean operations)
* **Separate X/Y controls:** Independent settings for count, width, length, spacing, and offset per axis
* **Automatic startup loading:** Both utilities load automatically when 3ds Max starts

---

### 🔹 SketchUp Pro — **GrooveTool**

**File:** `SketchUp Pro/groove-tool.rb`

* Adds a **context menu tool** for generating grooves on rectangular faces
* Built using the **SketchUp Ruby API** for seamless integration and lightweight operation
* Prompts for customizable groove width, depth, and spacing
* Automatically creates groove geometry with push-pull operations
* Designed for quick face-based modeling tasks with full undo support

**Key Features:**

* **Right-click workflow:** Appears in context menu when a face is selected
* **Three configurable parameters:**
  * Groove Width (mm) — default: 100mm
  * Groove Depth (mm) — default: 200mm
  * Spacing Between Grooves (mm) — default: 500mm
* **Automatic validation:** Checks if face is large enough for specified grooves
* **Persistent settings:** Remembers last-used parameters between sessions
* **Full undo support:** Uses `start_operation` with commit for proper undo stack integration
* **Lightweight module:** Single-file implementation, easy to extend or modify

---

## Demo

### Autodesk 3ds Max Demo

<video src="https://github.com/krutikmehtaa/open-source-plugins/assets/3ds_max_plugin_demo.mp4" controls></video>

*Alternatively, [download the demo video](https://github.com/krutikmehtaa/open-source-plugins/raw/main/Autodesk%203ds%20Max/3ds_max_plugin_demo.mp4)*

---

## Installation

### Autodesk 3ds Max

**Installation paths:**

For utilities (main scripts):
```
C:\Users\<username>\AppData\Local\Autodesk\3ds Max\<version>\scripts\
```

For startup script (auto-loader):
```
C:\Users\<username>\AppData\Local\Autodesk\3ds Max\<version>\scripts\Startup\
```

**Steps:**

1. Copy `utility_rectangular_grooves.ms` and `utility_rectangular_ridges.ms` to the **scripts** folder
2. Copy `utility_startup.ms` to the **scripts\Startup** folder
3. Restart 3ds Max
4. Access the utilities via: **Utilities Panel** → **MAXScript** → **Utilities dropdown** → select **"Grooves"** or **"Ridges"**

**Alternative (Manual Loading):**

If you don't want auto-startup, skip step 2 and manually run the utility scripts from the **MAXScript** menu → **Run Script**.

> 💡 The startup script automatically loads both utilities when 3ds Max starts, making them instantly available in the Utilities panel.

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

### 3ds Max

* Written entirely in **MaxScript** with no external dependencies
* Custom attributes system (`grooveParamsCA`, `ridgeParamsCA`) for parameter persistence
* Boolean operations for grooves, poly attachment for ridges
* Auto-spacing calculations with real-time feedback
* Startup automation via `utility_startup.ms`

### SketchUp

* Implemented in **Ruby** using native SketchUp API
* Context menu integration for face-based workflow
* Operation wrapper for proper undo/redo support
* Single-file module design for easy extension

---

## License

**Copyright © 2026 Krutik Mehta. All Rights Reserved.**

This software and associated documentation are proprietary and confidential. Unauthorized copying, distribution, modification, or use of this software, via any medium, is strictly prohibited without prior written permission from the copyright holder.

---

## Credits

Developed and maintained by **Krutik Mehta**.
