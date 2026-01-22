/*
================================================================================
    GROOVES UTILITY v2.3
    --------------------
    Creates parallel rectangular grooves/flutes on top face of 3D objects.
    
    Access via: Utilities Panel > MAXScript > Utilities dropdown > "Grooves"
    
    NEW: Both Axes mode - create grooves on X and Y simultaneously
    
    Author: AI Assistant
    Version: 2.3
    Compatible: 3ds Max 2024+
================================================================================
*/

grooveParamsCA = attributes GrooveParams (
    parameters main (
        gp_axis type:#integer default:1
        gp_cuts type:#integer default:5
        gp_cutsY type:#integer default:5
        gp_width type:#float default:8.0
        gp_widthY type:#float default:8.0
        gp_depth type:#float default:4.0
        gp_length type:#float default:80.0
        gp_lengthY type:#float default:80.0
        gp_spacing type:#float default:12.0
        gp_spacingY type:#float default:12.0
        gp_startOffset type:#float default:8.0
        gp_startOffsetY type:#float default:8.0
        gp_originalName type:#string default:""
        gp_autoCenter type:#boolean default:true
    )
)

utility GroovesUtility "Grooves" (
    
    group "1. Target Object" (
        button btnUseSelection "Use Current Selection" width:150 height:24
        label lblTarget "Target: None" align:#left
        label lblSize "Size: --" align:#left
    )
    
    group "2. Axis Selection" (
        radiobuttons rbAxis labels:#("Along X-Axis", "Along Y-Axis", "Both Axes") default:1 columns:1
    )
    
    group "3. X-Axis Settings" (
        spinner spnCount "Cuts:" range:[1, 999, 5] type:#integer fieldWidth:70
        spinner spnWidth "Width:" range:[0.1, 99999, 8] type:#worldunits fieldWidth:70
        spinner spnLength "Length:" range:[0.1, 99999, 80] type:#worldunits fieldWidth:70
        label lblCalcX "" align:#left
    )
    
    group "4. Y-Axis Settings" (
        spinner spnCountY "Cuts:" range:[1, 999, 5] type:#integer fieldWidth:70
        spinner spnWidthY "Width:" range:[0.1, 99999, 8] type:#worldunits fieldWidth:70
        spinner spnLengthY "Length:" range:[0.1, 99999, 80] type:#worldunits fieldWidth:70
        label lblCalcY "" align:#left
    )
    
    group "5. Depth Space" (
        spinner spnDepth "Depth:" range:[0.1, 99999, 4] type:#worldunits fieldWidth:70
        checkbox chkAutoCenter "Auto Center" checked:true
        spinner spnSpacing "X Spacing:" range:[0.1, 99999, 12] type:#worldunits fieldWidth:70 enabled:false
        spinner spnStart "X Offset:" range:[0, 99999, 8] type:#worldunits fieldWidth:70 enabled:false
        spinner spnSpacingY "Y Spacing:" range:[0.1, 99999, 12] type:#worldunits fieldWidth:70 enabled:false
        spinner spnStartY "Y Offset:" range:[0, 99999, 8] type:#worldunits fieldWidth:70 enabled:false
    )
    
    group "6. Actions" (
        button btnCreate "CREATE GROOVES" width:150 height:32
        button btnLoadParams "Load From Selected" width:150 height:22
        progressbar pbProgress value:0 color:(color 80 200 80) height:6
        label lblStatus "" align:#left
    )
    
    group "7. Reset (Safe Undo)" (
        label lblWarn1 "*** WARNING ***" align:#center
        label lblWarn2 "Do NOT use Ctrl+Z!" align:#center
        label lblWarn3 "Use RESET button instead!" align:#center
        button btnReset "RESET TO ORIGINAL" width:150 height:26 enabled:false
    )
    
    local theOriginal = undefined
    local theResult = undefined
    local originalColor = undefined
    local originalName = ""
    local objectSizeX = 0.0
    local objectSizeY = 0.0
    
    fn getWorldBBox obj = (
        if obj == undefined or not isValidNode obj then return undefined
        local bb = nodeGetBoundingBox obj (matrix3 1)
        return #(bb[1], bb[2], bb[2] - bb[1], (bb[1] + bb[2]) / 2.0)
    )
    
    -- Calculate auto-center spacing
    fn calcAutoSpacing objLen numCuts cutWidth = (
        local totalCutWidth = numCuts * cutWidth
        local remainingSpace = objLen - totalCutWidth
        if remainingSpace <= 0 then return #(0, 0)
        local spacing = remainingSpace / (numCuts + 1)
        return #(spacing, spacing)
    )
    
    -- Update spacing display for both axes
    fn updateAutoSpacing = (
        if theOriginal == undefined or not isValidNode theOriginal then return()
        
        local bb = getWorldBBox theOriginal
        if bb == undefined then return()
        
        local sz = bb[3]
        objectSizeX = sz.x
        objectSizeY = sz.y
        
        if chkAutoCenter.checked then (
            -- Always calculate X-axis spacing
            local resultX = calcAutoSpacing objectSizeX spnCount.value spnWidth.value
            spnSpacing.value = resultX[1]
            spnStart.value = resultX[2]
            if resultX[1] > 0 then lblCalcX.text = "Gap: " + (formattedPrint resultX[1] format:".1f")
            else lblCalcX.text = "Warning: Exceeds object!"
            
            -- Always calculate Y-axis spacing
            local resultY = calcAutoSpacing objectSizeY spnCountY.value spnWidthY.value
            spnSpacingY.value = resultY[1]
            spnStartY.value = resultY[2]
            if resultY[1] > 0 then lblCalcY.text = "Gap: " + (formattedPrint resultY[1] format:".1f")
            else lblCalcY.text = "Warning: Exceeds object!"
        )
    )
    
    fn createCuttersForAxis targetObj axisX numCuts cutW cutD cutL startOff spacing = (
        local bb = getWorldBBox targetObj
        if bb == undefined then return #()
        
        local minP = bb[1], maxP = bb[2], centerP = bb[4]
        local cutters = #()
        local currentOffset = startOff
        
        for i = 1 to numCuts do (
            local c = Box()
            if axisX then (c.width = cutW; c.length = cutL) else (c.width = cutL; c.length = cutW)
            c.height = cutD
            
            local px = centerP.x, py = centerP.y
            local pz = maxP.z - (cutD / 2.0)
            if axisX then (px = minP.x + currentOffset + (cutW / 2.0)) else (py = minP.y + currentOffset + (cutW / 2.0))
            
            c.pos = [px, py, pz]
            c.name = "TempCutter_" + i as string
            c.wirecolor = color 255 255 0
            append cutters c
            currentOffset += cutW + spacing
        )
        return cutters
    )
    
    fn createCutters targetObj axisMode xCuts xW xD xL xStart xSpacing yCuts yW yL yStart ySpacing = (
        local allCutters = #()
        
        -- Create X-axis cutters (X-only or Both)
        if axisMode == 1 or axisMode == 3 then (
            local xCutters = createCuttersForAxis targetObj true xCuts xW xD xL xStart xSpacing
            join allCutters xCutters
        )
        
        -- Create Y-axis cutters (Y-only uses Y settings)
        if axisMode == 2 then (
            local yCutters = createCuttersForAxis targetObj false yCuts yW xD yL yStart ySpacing
            join allCutters yCutters
        )
        
        -- Create Y-axis cutters (Both mode)
        if axisMode == 3 then (
            local yCutters = createCuttersForAxis targetObj false yCuts yW xD yL yStart ySpacing
            join allCutters yCutters
        )
        
        -- Combine all cutters into one compound
        if allCutters.count > 0 then (
            local compound = allCutters[1]
            convertToPoly compound
            for i = 2 to allCutters.count do (
                convertToPoly allCutters[i]
                polyop.attach compound allCutters[i]
            )
            compound.name = "TempCutter"
            return compound
        )
        return undefined
    )
    
    fn applyParamsToResult result params = (
        custAttributes.add result grooveParamsCA
        result.GrooveParams.gp_axis = params[1]
        result.GrooveParams.gp_cuts = params[2]
        result.GrooveParams.gp_width = params[3]
        result.GrooveParams.gp_depth = params[4]
        result.GrooveParams.gp_length = params[5]
        result.GrooveParams.gp_spacing = params[6]
        result.GrooveParams.gp_startOffset = params[7]
        result.GrooveParams.gp_originalName = params[8]
        result.GrooveParams.gp_autoCenter = params[9]
        result.GrooveParams.gp_cutsY = params[10]
        result.GrooveParams.gp_widthY = params[11]
        result.GrooveParams.gp_lengthY = params[12]
        result.GrooveParams.gp_spacingY = params[13]
        result.GrooveParams.gp_startOffsetY = params[14]
    )
    
    fn doBoolean targetObj cutterObj originalCol params = (
        local success = false
        local result = undefined
        
        try (
            local workCopy = copy targetObj
            workCopy.name = targetObj.name
            workCopy.wirecolor = originalCol
            local cutCopy = copy cutterObj
            
            ProBoolean.CreateBooleanObjects workCopy cutCopy 2 0 0
            
            if isValidNode workCopy then (
                result = workCopy
                result.wirecolor = originalCol
                applyParamsToResult result params
                success = true
            )
        ) catch (
            format "Boolean failed: %\n" (getCurrentException())
        )
        
        if not success then (
            try (
                local workCopy = copy targetObj
                workCopy.name = targetObj.name
                workCopy.wirecolor = originalCol
                convertToPoly workCopy
                local cutCopy = copy cutterObj
                convertToPoly cutCopy
                select workCopy
                local pb = ProBoolean operandA:workCopy
                
                if isValidNode pb then (
                    try (pb.SetOperandB cutCopy 2) catch()
                    try (pb.SetOperandB cutCopy 1 2) catch()
                    result = pb
                    result.wirecolor = originalCol
                    applyParamsToResult result params
                    success = true
                )
            ) catch (
                format "Boolean fallback failed: %\n" (getCurrentException())
            )
        )
        
        return #(success, result)
    )
    
    fn hasGrooveParams obj = (
        if obj == undefined or not isValidNode obj then return false
        try (return (custAttributes.get obj grooveParamsCA) != undefined) catch (return false)
    )
    
    on chkAutoCenter changed state do (
        spnSpacing.enabled = not state
        spnStart.enabled = not state
        spnSpacingY.enabled = not state
        spnStartY.enabled = not state
        if state then updateAutoSpacing()
        else (lblCalcX.text = ""; lblCalcY.text = "")
    )
    
    on spnCount changed val do (updateAutoSpacing())
    on spnWidth changed val do (updateAutoSpacing())
    on spnCountY changed val do (updateAutoSpacing())
    on spnWidthY changed val do (updateAutoSpacing())
    on rbAxis changed state do (updateAutoSpacing())
    
    on btnUseSelection pressed do (
        if selection.count != 1 then (messageBox "Please select exactly ONE object" title:"Selection"; return())
        local sel = selection[1]
        if hasGrooveParams sel then (
            messageBox "This object already has grooves.\n\nUse 'Load From Selected' to edit." title:"Already Grooved"
            return()
        )
        theOriginal = sel
        originalName = theOriginal.name
        originalColor = theOriginal.wirecolor
        theResult = undefined
        lblTarget.text = "Target: " + originalName
        local bb = getWorldBBox theOriginal
        if bb != undefined then (
            local sz = bb[3]
            lblSize.text = "Size: " + (sz.x as integer) as string + "x" + (sz.y as integer) as string + "x" + (sz.z as integer) as string
            objectSizeX = sz.x
            objectSizeY = sz.y
        )
        btnReset.enabled = false
        lblStatus.text = ""
        updateAutoSpacing()
    )
    
    on btnLoadParams pressed do (
        if selection.count != 1 then (messageBox "Select a grooved object" title:"Load"; return())
        local sel = selection[1]
        if not hasGrooveParams sel then (messageBox "No groove parameters found" title:"Error"; return())
        rbAxis.state = sel.GrooveParams.gp_axis
        spnCount.value = sel.GrooveParams.gp_cuts
        spnWidth.value = sel.GrooveParams.gp_width
        spnDepth.value = sel.GrooveParams.gp_depth
        spnLength.value = sel.GrooveParams.gp_length
        spnSpacing.value = sel.GrooveParams.gp_spacing
        spnStart.value = sel.GrooveParams.gp_startOffset
        try (spnCountY.value = sel.GrooveParams.gp_cutsY) catch()
        try (spnWidthY.value = sel.GrooveParams.gp_widthY) catch()
        try (spnLengthY.value = sel.GrooveParams.gp_lengthY) catch()
        try (spnSpacingY.value = sel.GrooveParams.gp_spacingY) catch()
        try (spnStartY.value = sel.GrooveParams.gp_startOffsetY) catch()
        try (chkAutoCenter.checked = sel.GrooveParams.gp_autoCenter) catch (chkAutoCenter.checked = true)
        spnSpacing.enabled = not chkAutoCenter.checked
        spnStart.enabled = not chkAutoCenter.checked
        spnSpacingY.enabled = not chkAutoCenter.checked
        spnStartY.enabled = not chkAutoCenter.checked
        theResult = sel
        local origName = sel.GrooveParams.gp_originalName
        theOriginal = getNodeByName origName
        if theOriginal != undefined then (
            originalName = theOriginal.name
            originalColor = theOriginal.wirecolor
            lblTarget.text = "Target: " + originalName
            local bb = getWorldBBox theOriginal
            if bb != undefined then (objectSizeX = bb[3].x; objectSizeY = bb[3].y)
            btnReset.enabled = true
            updateAutoSpacing()
        ) else (
            lblTarget.text = "Original not found"
            btnReset.enabled = false
        )
        lblStatus.text = "Loaded!"
    )
    
    on btnCreate pressed do (
        if theOriginal == undefined or not isValidNode theOriginal then (messageBox "Select a target first!" title:"Error"; return())
        if theResult != undefined and isValidNode theResult then (
            if hasGrooveParams theResult and theResult.GrooveParams.gp_originalName == originalName then (delete theResult; theResult = undefined)
        )
        if theOriginal.isHidden then theOriginal.isHidden = false
        
        -- Update auto spacing before creating
        if chkAutoCenter.checked then updateAutoSpacing()
        
        pbProgress.value = 10; lblStatus.text = "Creating..."
        
        with undo off (
            local cutter = createCutters theOriginal rbAxis.state spnCount.value spnWidth.value spnDepth.value spnLength.value spnStart.value spnSpacing.value spnCountY.value spnWidthY.value spnLengthY.value spnStartY.value spnSpacingY.value
            if cutter == undefined then (lblStatus.text = "ERROR"; pbProgress.value = 0; return())
            pbProgress.value = 40; lblStatus.text = "Boolean..."
            local params = #(rbAxis.state, spnCount.value, spnWidth.value, spnDepth.value, spnLength.value, spnSpacing.value, spnStart.value, originalName, chkAutoCenter.checked, spnCountY.value, spnWidthY.value, spnLengthY.value, spnSpacingY.value, spnStartY.value)
            local boolResult = doBoolean theOriginal cutter originalColor params
            if isValidNode cutter then delete cutter
            pbProgress.value = 80
            if boolResult[1] then (theResult = boolResult[2]; theOriginal.isHidden = true; select theResult; pbProgress.value = 100; lblStatus.text = "Done!"; btnReset.enabled = true)
            else (pbProgress.value = 0; lblStatus.text = "Failed!"; messageBox "Boolean failed" title:"Error")
        )
    )
    
    on btnReset pressed do (
        if theResult != undefined and isValidNode theResult then (delete theResult; theResult = undefined)
        if theOriginal != undefined and isValidNode theOriginal then (theOriginal.isHidden = false; select theOriginal)
        for obj in objects where (matchPattern obj.name pattern:"TempCutter*") do delete obj
        btnReset.enabled = false; pbProgress.value = 0; lblStatus.text = "Reset!"
    )
    
    on GroovesUtility open do (
        if selection.count == 1 and not hasGrooveParams selection[1] then (
            theOriginal = selection[1]; originalName = theOriginal.name; originalColor = theOriginal.wirecolor
            lblTarget.text = "Target: " + originalName
            local bb = getWorldBBox theOriginal
            if bb != undefined then (
                local sz = bb[3]
                lblSize.text = "Size: " + (sz.x as integer) as string + "x" + (sz.y as integer) as string + "x" + (sz.z as integer) as string
                objectSizeX = sz.x
                objectSizeY = sz.y
                updateAutoSpacing()
            )
        )
    )
    
    on GroovesUtility close do (for obj in objects where (matchPattern obj.name pattern:"TempCutter*") do delete obj)
)
