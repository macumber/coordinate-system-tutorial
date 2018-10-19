# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class AdjustOrigins < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Adjust Origins'
  end

  # human readable description
  def description
    return 'Adjust all Surface Group origins for better rendering in preview mode'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Adjust all Surface Group origins for better rendering in preview mode'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new
    
    # make an argument for add_constructions
    move_z = OpenStudio::Measure::OSArgument.makeBoolArgument('move_z', true)
    move_z.setDisplayName('Move Z Origins')
    move_z.setDescription('Move the building to set minimum z value as 0')
    move_z.setDefaultValue(false)
    args << move_z

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
    
    move_z = runner.getBoolArgumentValue('move_z', user_arguments)
                            
    bb = OpenStudio::BoundingBox.new
    model.getPlanarSurfaceGroups.each do |g|
      bb.add(g.siteTransformation*g.boundingBox)
    end
    
    if bb.isEmpty
      runner.registerAsNotApplicable("Building does not have geometry.")
      return true
    end

    # report initial condition of model
    runner.registerInitialCondition("The building started with minimum geometry at [#{bb.minX.get}, #{bb.minY.get}, #{bb.minZ.get}].")
    
    moveT = nil
    if move_z
      # move to minimum X, Y, and Z
      moveT = OpenStudio::createTranslation(OpenStudio::Vector3d.new(-bb.minX.get, -bb.minY.get, -bb.minZ.get))    
    else
      # move to minimum X and Y, don't change Z
      moveT = OpenStudio::createTranslation(OpenStudio::Vector3d.new(-bb.minX.get, -bb.minY.get, 0))
    end
    
    model.getPlanarSurfaceGroups.each do |g|
      newT = moveT*g.transformation
      g.setTransformation(newT)
    end
    
    bb = OpenStudio::BoundingBox.new
    model.getPlanarSurfaceGroups.each do |g|
      bb.add(g.siteTransformation*g.boundingBox)
    end
    
    # report final condition of model
    runner.registerFinalCondition("The building ended with minimum geometry at [#{bb.minX.get}, #{bb.minY.get}, #{bb.minZ.get}].")

    return true
  end
end

# register the measure to be used by the application
AdjustOrigins.new.registerWithApplication
