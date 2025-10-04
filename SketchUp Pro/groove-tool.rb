module GrooveTool
  extend self

  @groove_width = 100.mm
  @groove_depth = 200.mm
  @groove_spacing = 500.mm

  # Add context menu handler
  UI.add_context_menu_handler do |menu|
    selection = Sketchup.active_model.selection
    if selection.grep(Sketchup::Face).any?
      menu.add_item('Create Groove') { configure_and_create_grooves }
    end
  end

  # Prompt for groove parameters and create grooves
  def configure_and_create_grooves
    prompts = ["Groove Width (mm):", "Groove Depth (mm):", "Spacing Between Grooves (mm):"]
    defaults = [@groove_width / 1.mm, @groove_depth / 1.mm, @groove_spacing / 1.mm]
    input = UI.inputbox(prompts, defaults, "Set Groove Parameters")

    if input
      @groove_width = input[0].to_f.mm
      @groove_depth = input[1].to_f.mm
      @groove_spacing = input[2].to_f.mm

      selection = Sketchup.active_model.selection
      face = selection.grep(Sketchup::Face).first
      if face
        create_grooves(face)
      else
        UI.messagebox("No valid face selected. Please select a rectangle face.")
      end
    end
  end

  # Create grooves on the selected face
  def create_grooves(rectangle_face)
    model = Sketchup.active_model
    entities = model.active_entities

    # Get the bounds of the rectangle
    bounds = rectangle_face.bounds
    width = bounds.corner(1).x - bounds.corner(0).x
    height = bounds.corner(2).y - bounds.corner(0).y

    # Validate dimensions
    if width <= @groove_spacing + @groove_width || height <= @groove_width
      UI.messagebox("Rectangle is too small for the specified grooves.")
      return
    end

    model.start_operation('Create Grooves', true)

    begin
      x_start = bounds.corner(0).x
      y_start = bounds.corner(0).y
      z_start = bounds.corner(0).z
      x_position = x_start + @groove_spacing

      # Create grooves along the width
      while x_position + @groove_width <= bounds.corner(1).x
        # Draw a groove rectangle
        points = [
          [x_position, y_start, z_start],
          [x_position + @groove_width, y_start, z_start],
          [x_position + @groove_width, bounds.corner(2).y, z_start],
          [x_position, bounds.corner(2).y, z_start]
        ]

        groove_face = entities.add_face(points)
        if groove_face
          groove_face.pushpull(-@groove_depth)
        end
        x_position += @groove_width + @groove_spacing
      end

      UI.messagebox("Grooves created successfully!")
    rescue StandardError => e
      UI.messagebox("Error creating grooves: #{e.message}")
    ensure
      model.commit_operation
    end
  end
end