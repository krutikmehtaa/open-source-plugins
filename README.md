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

These are two complementary utilities that create parallel rectangular surface features on 3D objects:

#### **Grooves Utility** (Subtractive)
* Creates parallel rectangular grooves/flutes using **boolean subtraction operations**
* Cuts grooves into the top face of selected objects
* Perfect for creating channels, flutes, or recessed details

#### **Ridges Utility** (Additive)
* Creates parallel rectangular ridges/ribs by **combining geometry**
* Adds raised elements to the top face of selected objects
* Ideal for ribbing, fins, or raised detail patterns

**Key Features (Both Utilities):**

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

## Usage

### 3ds Max — Grooves & Ridges Utilities

**Basic Workflow:**

1. **Select target object** — Choose any 3D object in your scene
2. **Open utility** — Go to Utilities Panel → MAXScript → select "Grooves" or "Ridges"
3. **Click "Use Current Selection"** — Loads the object and displays its dimensions
4. **Choose axis mode:**
   * Along X-Axis — grooves/ridges run parallel to X
   * Along Y-Axis — grooves/ridges run parallel to Y
   * Both Axes — creates a grid pattern
5. **Adjust parameters:**
   * Cuts/Ridges count
   * Width and Length
   * Depth (Grooves) or Height (Ridges)
   * Enable **Auto Center** for automatic spacing (recommended)
6. **Click "CREATE GROOVES" or "CREATE RIDGES"**
7. **Preview and adjust** — Use "Load From Selected" to tweak parameters
8. **Use "RESET TO ORIGINAL"** to undo (don't use Ctrl+Z with boolean operations)

**Pro Tips:**

* **Auto Center Mode:** Automatically distributes features evenly — best for most use cases
* **Manual Mode:** Disable Auto Center to manually set spacing and offsets
* **Load From Selected:** Edit existing grooved/ridged objects by loading their saved parameters
* **Both Axes Mode:** Creates grid patterns — each axis has independent controls
* **Safe Undo:** Always use the RESET button instead of Ctrl+Z to avoid boolean operation issues

---

### SketchUp Pro — GrooveTool

**Basic Workflow:**

1. **Select a rectangular face** in your model
2. **Right-click** on the face
3. **Choose "Create Groove"** from the context menu
4. **Enter parameters** in the dialog:
   * Groove Width (mm)
   * Groove Depth (mm)
   * Spacing Between Grooves (mm)
5. **Click OK** — grooves are created automatically

**Notes:**

* Tool validates face size before creating grooves
* If the face is too small for the specified parameters, you'll get a warning
* Parameters are remembered between uses
* Full undo support (Ctrl+Z or Edit → Undo)

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

Both tools are open and easily modifiable — ideal for learning, customization, and extending.

### 3ds Max

* **Written entirely in MaxScript** — no external dependencies
* **Utility-based architecture** with custom rollout UI for parameter control
* **Custom attributes system** for parameter persistence:
  * `grooveParamsCA` stores groove settings on modified objects
  * `ridgeParamsCA` stores ridge settings on modified objects
* **Boolean operations** (Grooves) vs. **Poly attachment** (Ridges) for different effects
* **Real-time calculation functions:**
  * `calcAutoSpacing()` — distributes features evenly with auto-centering
  * `getWorldBBox()` — accurate world-space bounding box calculation
  * `updateAutoSpacing()` — live feedback for both X and Y axes
* **Safe workflow management:**
  * Hides original object during preview
  * Custom RESET function to restore original (avoids undo stack corruption)
  * Progress bar and status updates for user feedback
* **Startup automation:** `utility_startup.ms` loads both utilities at launch
* **Extendable for:**
  * Additional pattern types (circular, hexagonal, etc.)
  * Variable spacing algorithms
  * Mesh cleanup and optimization routines
  * Support for curved surfaces

### SketchUp

* **Implemented in Ruby** using the native SketchUp API
* **Module-based design** (`GrooveTool`) — clean namespace, easy to integrate
* **Context menu integration** via `UI.add_context_menu_handler`
* **Input dialog** (`UI.inputbox`) for parameter configuration
* **Operation wrapper** for proper undo/redo support:
  * `start_operation` with commit ensures clean undo stack
  * Automatic rollback on errors
* **Geometry creation:**
  * Uses `entities.add_face` for groove faces
  * `pushpull` method for depth creation
* **Bounds-based calculation** for accurate placement
* **All logic in a single file** — easy to extend or convert to full extension
* **Developers can add:**
  * Toolbar buttons and icons
  * Preferences dialog for default settings
  * Ridge/rib creation (additive version)
  * Multiple groove pattern options
  * Curved or irregular face support

---

## License

Licensed under the **MIT License** — free for personal, commercial, and educational use.
See the included `LICENSE` file for details.

---

## Credits

Developed and maintained by **Krutik Mehta**. Pull requests are welcome!
