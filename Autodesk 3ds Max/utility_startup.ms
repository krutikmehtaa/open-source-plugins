/*
================================================================================
    GROOVES & RIDGES - AUTO STARTUP LOADER
    ---------------------------------------
    Runs automatically when 3ds Max starts.
    Loads both utilities into: Utilities > MAXScript > dropdown
    
    Location: [3ds Max]\scripts\Startup\
================================================================================
*/

(
    local scriptsDir = getDir #scripts
    
    -- Load Grooves utility
    local groovesScript = scriptsDir + "\\utility_rectangular_grooves.ms"
    if doesFileExist groovesScript then (
        fileIn groovesScript quiet:true
        format "[Startup] Grooves utility loaded.\n"
    ) else (
        format "[Startup] Grooves not found: %\n" groovesScript
    )
    
    -- Load Ridges utility  
    local ridgesScript = scriptsDir + "\\utility_rectangular_ridges.ms"
    if doesFileExist ridgesScript then (
        fileIn ridgesScript quiet:true
        format "[Startup] Ridges utility loaded.\n"
    ) else (
        format "[Startup] Ridges not found: %\n" ridgesScript
    )
    
    format "[Startup] Grooves & Ridges ready.\n"
)
