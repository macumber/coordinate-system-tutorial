# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class CoordinateSystemTutorial < OpenStudio::Ruleset::ModelUserScript

  # human readable name
  def name
    return "Coordinate System Tutorial"
  end

  # human readable description
  def description
    return "This measure does not do any useful work, it is a tutorial for how to use the coordinate transformations in OpenStudio."
  end

  # human readable description of modeling approach
  def modeler_description
    return ""
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    return args
  end

  def print_vertex(v)
    return "#{'% 5.2f' % v.x}, #{'% 5.2f' % v.y}, #{'% 5.2f' % v.z}"
  end
  
  def print_vertices(vertices)
    a = []
    vertices.each do |v|
      a << print_vertex(v)
    end
    result = "[#{a.join('; ')}]"
    return result.gsub(' ', '&nbsp;')
  end
  
  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    model.getSurfaces.each do |surface|
      # vertices are in space coordinates
      vertices = surface.vertices
      
      # site vertices are the vertices in site coordinates
      site_transformation = surface.space.get.siteTransformation
      site_vertices = site_transformation*vertices
      
      # face vertices are the vertices in face coordinates
      face_transformation = OpenStudio::Transformation.alignFace(vertices)
      face_vertices = face_transformation.inverse*vertices
      
      # put the point 0,0,0 in face coordiantes back into space coordinates
      face_origin = face_transformation*OpenStudio::Point3d.new(0,0,0)
      
      runner.registerInfo("Surface #{surface.name}<br/><span style='font-family:courier new;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;vertices = #{print_vertices(vertices)}<br/>&nbsp;site_vertices = #{print_vertices(site_vertices)}<br/>&nbsp;face_vertices = #{print_vertices(face_vertices)}<br/>&nbsp;&nbsp;&nbsp;face_origin = [#{print_vertex(face_origin)}]</span>")
    end

    return true

  end
  
end

# register the measure to be used by the application
CoordinateSystemTutorial.new.registerWithApplication
