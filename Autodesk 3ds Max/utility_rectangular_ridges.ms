/*
================================================================================
    RIDGES UTILITY v2.3
    -------------------
    Creates parallel rectangular ridges/ribs on top face of 3D objects.
    
    Access via: Utilities Panel > MAXScript > Utilities dropdown > "Ridges"
    
    NEW: Both Axes mode - create ridges on X and Y simultaneously
    
    Author: AI Assistant
    Version: 2.3
    Compatible: 3ds Max 2024+
================================================================================
*/

ridgeParamsCA = attributes RidgeParams (
    parameters main (
        rp_axis type:#integer default:1
        rp_count type:#integer default:5
        rp_countY type:#integer default:5
        rp_width type:#float default:8.0
        rp_widthY type:#float default:8.0
        rp_height type:#float default:4.0
        rp_length type:#float default:80.0
        rp_lengthY type:#float default:80.0
        rp_spacing type:#float default:12.0
        rp_spacingY type:#float default:12.0
        rp_startOffset type:#float default:8.0
        rp_startOffsetY type:#float default:8.0
        rp_originalName type:#string default:""
        rp_autoCenter type:#boolean default:true
    )
)

utility RidgesUtility "Ridges" (
    
    group "1. Target Object" (
        button btnUseSelection "Use Current Selection" width:150 height:24
        label lblTarget "Target: None" align:#left
        label lblSize "Size: --" align:#left
    )
    
    group "2. Axis Selection" (
        radiobuttons rbAxis labels:#("Along X-Axis", "Along Y-Axis", "Both Axes") default:1 columns:1
    )
    
    group "3. X-Axis Settings" (
        spinner spnCount "Ridges:" range:[1, 999, 5] type:#integer fieldWidth:70
        spinner spnWidth "Width:" range:[0.1, 99999, 8] type:#worldunits fieldWidth:70
        spinner spnLength "Length:" range:[0.1, 99999, 80] type:#worldunits fieldWidth:70
        label lblCalcX "" align:#left
    )
    
    group "4. Y-Axis Settings" (
        spinner spnCountY "Ridges:" range:[1, 999, 5] type:#integer fieldWidth:70
        spinner spnWidthY "Width:" range:[0.1, 99999, 8] type:#worldunits fieldWidth:70
        spinner spnLengthY "Length:" range:[0.1, 99999, 80] type:#worldunits fieldWidth:70
        label lblCalcY "" align:#left
    )
    
    group "5. Height Space" (
        spinner spnHeight "Height:" range:[0.1, 99999, 4] type:#worldunits fieldWidth:70
        checkbox chkAutoCenter "Auto Center" checked:true
        spinner spnSpacing "X Spacing:" range:[0.1, 99999, 12] type:#worldunits fieldWidth:70 enabled:false
        spinner spnStart "X Offset:" range:[0, 99999, 8] type:#worldunits fieldWidth:70 enabled:false
        spinner spnSpacingY "Y Spacing:" range:[0.1, 99999, 12] type:#worldunits fieldWidth:70 enabled:false
        spinner spnStartY "Y Offset:" range:[0, 99999, 8] type:#worldunits fieldWidth:70 enabled:false
    )
    
    group "6. Actions" (
        button btnCreate "CREATE RIDGES" width:150 height:32
        button btnLoadParams "Load From Selected" width:150 height:22
        progressbar pbProgress value:0 color:(color 80 180 255) height:6
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
    fn calcAutoSpacing objLen numRidges ridgeWidth = (
        local totalRidgeWidth = numRidges * ridgeWidth
        local remainingSpace = objLen - totalRidgeWidth
        if remainingSpace <= 0 then return #(0, 0)
        local spacing = remainingSpace / (numRidges + 1)
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
    
    fn createRidgesForAxis targetObj axisX numRidges ridgeW ridgeH ridgeL startOff spacing = (
        local bb = getWorldBBox targetObj
        if bb == undefined then return #()
        
        local minP = bb[1], maxP = bb[2], centerP = bb[4]
        local ridges = #()
        local currentOffset = startOff
        
        for i = 1 to numRidges do (
            local r = Box()
            if axisX then (r.width = ridgeW; r.length = ridgeL) else (r.width = ridgeL; r.length = ridgeW)
            r.height = ridgeH
            
            local px = centerP.x, py = centerP.y
            local pz = maxP.z
            if axisX then (px = minP.x + currentOffset + (ridgeW / 2.0)) else (py = minP.y + currentOffset + (ridgeW / 2.0))
            
            r.pos = [px, py, pz]
            r.wirecolor = color 100 180 255
            append ridges r
            currentOffset += ridgeW + spacing
        )
        return ridges
    )
    
    fn createRidges targetObj axisMode xCount xW xH xL xStart xSpacing yCount yW yL yStart ySpacing = (
        local allRidges = #()
        
        -- Create X-axis ridges (X-only or Both)
        if axisMode == 1 or axisMode == 3 then (
            local xRidges = createRidgesForAxis targetObj true xCount xW xH xL xStart xSpacing
            join allRidges xRidges
        )
        
        -- Create Y-axis ridges (Y-only uses Y settings)
        if axisMode == 2 then (
            local yRidges = createRidgesForAxis targetObj false yCount yW xH yL yStart ySpacing
            join allRidges yRidges
        )
        
        -- Create Y-axis ridges (Both mode)
        if axisMode == 3 then (
            local yRidges = createRidgesForAxis targetObj false yCount yW xH yL yStart ySpacing
            join allRidges yRidges
        )
        
        return allRidges
    )
    
    fn combineWithBase targetObj ridges originalCol params = (
        local workCopy = copy targetObj
        workCopy.name = targetObj.name
        workCopy.wirecolor = originalCol
        convertToPoly workCopy
        
        for r in ridges do (
            convertToPoly r
            polyop.attach workCopy r
        )
        
        custAttributes.add workCopy ridgeParamsCA
        workCopy.RidgeParams.rp_axis = params[1]
        workCopy.RidgeParams.rp_count = params[2]
        workCopy.RidgeParams.rp_width = params[3]
        workCopy.RidgeParams.rp_height = params[4]
        workCopy.RidgeParams.rp_length = params[5]
        workCopy.RidgeParams.rp_spacing = params[6]
        workCopy.RidgeParams.rp_startOffset = params[7]
        workCopy.RidgeParams.rp_originalName = params[8]
        workCopy.RidgeParams.rp_autoCenter = params[9]
        workCopy.RidgeParams.rp_countY = params[10]
        workCopy.RidgeParams.rp_widthY = params[11]
        workCopy.RidgeParams.rp_lengthY = params[12]
        workCopy.RidgeParams.rp_spacingY = params[13]
        workCopy.RidgeParams.rp_startOffsetY = params[14]
        
        return workCopy
    )
    
    fn hasRidgeParams obj = (
        if obj == undefined or not isValidNode obj then return false
        try (return (custAttributes.get obj ridgeParamsCA) != undefined) catch (return false)
    )
    
    on chkAutoCenter changed state do (
        local disabled = state
        spnSpacing.enabled = not disabled
        spnStart.enabled = not disabled
        spnSpacingY.enabled = not disabled
        spnStartY.enabled = not disabled
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
        if hasRidgeParams sel then (
            messageBox "This object already has ridges.\n\nUse 'Load From Selected' to edit." title:"Already Ridged"
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
        if selection.count != 1 then (messageBox "Select a ridged object" title:"Load"; return())
        local sel = selection[1]
        if not hasRidgeParams sel then (messageBox "No ridge parameters found" title:"Error"; return())
        rbAxis.state = sel.RidgeParams.rp_axis
        spnCount.value = sel.RidgeParams.rp_count
        spnWidth.value = sel.RidgeParams.rp_width
        spnHeight.value = sel.RidgeParams.rp_height
        spnLength.value = sel.RidgeParams.rp_length
        spnSpacing.value = sel.RidgeParams.rp_spacing
        spnStart.value = sel.RidgeParams.rp_startOffset
        try (spnCountY.value = sel.RidgeParams.rp_countY) catch()
        try (spnWidthY.value = sel.RidgeParams.rp_widthY) catch()
        try (spnLengthY.value = sel.RidgeParams.rp_lengthY) catch()
        try (spnSpacingY.value = sel.RidgeParams.rp_spacingY) catch()
        try (spnStartY.value = sel.RidgeParams.rp_startOffsetY) catch()
        try (chkAutoCenter.checked = sel.RidgeParams.rp_autoCenter) catch (chkAutoCenter.checked = true)
        spnSpacing.enabled = not chkAutoCenter.checked
        spnStart.enabled = not chkAutoCenter.checked
        spnSpacingY.enabled = not chkAutoCenter.checked
        spnStartY.enabled = not chkAutoCenter.checked
        theResult = sel
        local origName = sel.RidgeParams.rp_originalName
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
            if hasRidgeParams theResult and theResult.RidgeParams.rp_originalName == originalName then (delete theResult; theResult = undefined)
        )
        if theOriginal.isHidden then theOriginal.isHidden = false
        
        -- Update auto spacing before creating
        if chkAutoCenter.checked then updateAutoSpacing()
        
        pbProgress.value = 10; lblStatus.text = "Creating..."
        
        local ridges = createRidges theOriginal rbAxis.state spnCount.value spnWidth.value spnHeight.value spnLength.value spnStart.value spnSpacing.value spnCountY.value spnWidthY.value spnLengthY.value spnStartY.value spnSpacingY.value
        if ridges.count == 0 then (lblStatus.text = "ERROR"; pbProgress.value = 0; return())
        pbProgress.value = 50; lblStatus.text = "Combining..."
        local params = #(rbAxis.state, spnCount.value, spnWidth.value, spnHeight.value, spnLength.value, spnSpacing.value, spnStart.value, originalName, chkAutoCenter.checked, spnCountY.value, spnWidthY.value, spnLengthY.value, spnSpacingY.value, spnStartY.value)
        theResult = combineWithBase theOriginal ridges originalColor params
        theOriginal.isHidden = true
        select theResult
        pbProgress.value = 100; lblStatus.text = "Done!"; btnReset.enabled = true
    )
    
    on btnReset pressed do (
        if theResult != undefined and isValidNode theResult then (delete theResult; theResult = undefined)
        if theOriginal != undefined and isValidNode theOriginal then (theOriginal.isHidden = false; select theOriginal)
        btnReset.enabled = false; pbProgress.value = 0; lblStatus.text = "Reset!"
    )
    
    on RidgesUtility open do (
        if selection.count == 1 and not hasRidgeParams selection[1] then (
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
)
