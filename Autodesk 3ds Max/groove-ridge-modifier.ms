-- GR New Tool v21.0 - UTILITY PANEL APPROACH
-- Scripted utility instead of modifier for direct Boolean operations
-- Access from Utilities tab > GR New

utility GRNewTool "GR New"
(
    group "Create"
    (
        dropdownlist ddlCreateType "Type:" items:#("Groove","Ridge") selection:1 width:140
    )
    
    group "Parameters"
    (
        spinner spnCount "Count:" range:[1,50,3] type:#integer
        spinner spnWidth "Width:" range:[0.1,1000,10] type:#float
        spinner spnHeight "Height:" range:[0.1,1000,5] type:#float
    )
    
    group "Distribution"
    (
        dropdownlist ddlDistribution "" items:#("Equal Spacing","Random Spacing") selection:1 width:140
        spinner spnSeed "Random Seed:" range:[1,99999,12345] type:#integer enabled:false
    )
    
    group "Direction"
    (
        dropdownlist ddlDirection "" items:#("Along Length (Y)","Along Width (X)","Both") selection:1 width:190
    )
    
    group "Actions"
    (
        button btnApply "Create Grooves/Ridges" width:140 height:30
        button btnLoadStored "Load from Selected" width:140
        button btnReset "Reset Parameters" width:140
    )
    
    on ddlDistribution selected val do
    (
        spnSeed.enabled = (val == 2)
    )
    
    on btnLoadStored pressed do
    (
        if selection.count == 0 then
        (
            messageBox "Select an object first!" title:"GR New"
            return false
        )
        
        local obj = selection[1]
        if getUserProp obj "GR_CreateType" != undefined then
        (
            ddlCreateType.selection = getUserProp obj "GR_CreateType"
            spnCount.value = getUserProp obj "GR_FeatureCount"
            spnWidth.value = getUserProp obj "GR_FeatureWidth"
            spnHeight.value = getUserProp obj "GR_FeatureHeight"
            ddlDistribution.selection = getUserProp obj "GR_Distribution"
            ddlDirection.selection = getUserProp obj "GR_Direction"
            spnSeed.value = getUserProp obj "GR_RandomSeed"
            spnSeed.enabled = (getUserProp obj "GR_Distribution" == 2)
            
            messageBox "Parameters loaded!" title:"GR New"
        )
        else
        (
            messageBox "No stored parameters found on this object." title:"GR New"
        )
    )
    
    on btnReset pressed do
    (
        ddlCreateType.selection = 1
        spnCount.value = 3
        spnWidth.value = 10.0
        spnHeight.value = 5.0
        ddlDistribution.selection = 1
        spnSeed.value = 12345
        spnSeed.enabled = false
        ddlDirection.selection = 1
    )
    
    on btnApply pressed do
    (
        format "\n========================================\n"
        format "GR NEW v21 - UTILITY TOOL\n"
        format "========================================\n"
        
        if selection.count == 0 then
        (
            messageBox "Select an object first!" title:"GR New"
            return false
        )
        
        local obj = selection[1]
        
        -- Check for existing grooves
        if getUserProp obj "GR_CreateType" != undefined then
        (
            local result = queryBox "This object already has grooves.\n\nReplace them?" title:"GR New"
            if not result then return false
            
            -- Suggest undo
            messageBox "Please Undo (Ctrl+Z) to original state first,\nthen run this tool again." title:"GR New"
            return false
        )
        
        try
        (
            undo "GR New Grooves" on
            (
                -- Store position
                local origPos = obj.pos
                local origPivot = obj.pivot
                
                format "Processing: %\n" obj.name
                
                -- Convert to mesh if needed
                if classOf obj != Editable_Mesh then
                    convertTo obj Editable_Mesh
                
                -- Get bounds
                local bbox = nodeLocalBoundingBox obj
                local bbMin = bbox[1]
                local bbMax = bbox[2]
                local topZ = bbMax.z
                
                format "Bounds: % to %\n" bbMin bbMax
                
                -- Calculate positions
                local grooveData = #()
                
                if ddlDirection.selection == 1 or ddlDirection.selection == 3 then
                (
                    local range = bbMax.y - bbMin.y
                    if ddlDistribution.selection == 1 then
                    (
                        local spacing = range / (spnCount.value + 1.0)
                        for i = 1 to spnCount.value do
                            append grooveData #('Y', bbMin.y + spacing * i)
                    )
                    else
                    (
                        seed spnSeed.value
                        local margin = range * 0.1
                        for i = 1 to spnCount.value do
                            append grooveData #('Y', bbMin.y + margin + random 0.0 (range - 2*margin))
                    )
                )
                
                if ddlDirection.selection == 2 or ddlDirection.selection == 3 then
                (
                    local range = bbMax.x - bbMin.x
                    if ddlDistribution.selection == 1 then
                    (
                        local spacing = range / (spnCount.value + 1.0)
                        for i = 1 to spnCount.value do
                            append grooveData #('X', bbMin.x + spacing * i)
                    )
                    else
                    (
                        seed spnSeed.value
                        local margin = range * 0.1
                        for i = 1 to spnCount.value do
                            append grooveData #('X', bbMin.x + margin + random 0.0 (range - 2*margin))
                    )
                )
                
                format "Creating % grooves...\n" grooveData.count
                
                -- Create grooves using Boolean compound objects
                for grv in grooveData do
                (
                    local cutter
                    
                    if grv[1] == 'Y' then
                    (
                        cutter = Box length:(bbMax.x - bbMin.x + 10) \
                                     width:spnWidth.value \
                                     height:spnHeight.value \
                                     pos:[(bbMax.x + bbMin.x)/2, grv[2], topZ - spnHeight.value/2]
                    )
                    else
                    (
                        cutter = Box length:spnWidth.value \
                                     width:(bbMax.y - bbMin.y + 10) \
                                     height:spnHeight.value \
                                     pos:[grv[2], (bbMax.y + bbMin.y)/2, topZ - spnHeight.value/2]
                    )
                    
                    -- Use standard Boolean compound object
                    local boolObj = compound_objects Boolean
                    obj.baseobject = boolObj
                    boolObj.OperandA = obj
                    boolObj.OperandB = cutter
                    
                    if ddlCreateType.selection == 1 then
                        boolObj.operation = 2  -- Subtraction
                    else
                        boolObj.operation = 1  -- Union
                    
                    -- Collapse
                    convertTo obj Editable_Mesh
                    
                    format "."
                )
                
                format "\n"
                
                -- Restore position
                obj.pos = origPos
                obj.pivot = origPivot
                
                -- Store parameters
                setUserProp obj "GR_CreateType" ddlCreateType.selection
                setUserProp obj "GR_FeatureCount" spnCount.value
                setUserProp obj "GR_FeatureWidth" spnWidth.value
                setUserProp obj "GR_FeatureHeight" spnHeight.value
                setUserProp obj "GR_Distribution" ddlDistribution.selection
                setUserProp obj "GR_Direction" ddlDirection.selection
                setUserProp obj "GR_RandomSeed" spnSeed.value
                
                format "SUCCESS!\n========================================\n\n"
                
                messageBox ("Grooves created successfully!\n\n" + grooveData.count as string + " grooves applied.\n\nTo edit: Undo (Ctrl+Z), adjust parameters, Apply again.") title:"GR New - Success"
            )
        )
        catch
        (
            local err = getCurrentException()
            format "ERROR: %\n========================================\n\n" err
            messageBox ("Error: " + err) title:"GR New - Error"
        )
    )
)

format "\n========================================\n"
format "GR New v21.0 - UTILITY TOOL\n"
format "========================================\n"
format "NEW APPROACH: Utility panel!\n"
format "Access: Utilities tab > GR New\n"
format "Uses Boolean compound objects directly\n"
format "No modifier execution issues\n"
format "========================================\n\n"