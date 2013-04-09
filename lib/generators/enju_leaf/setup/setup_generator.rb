#class EnjuLeaf::SetupGenerator < Rails::Generators::NamedBase
class EnjuLeaf::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  desc "Create a setup file for Next-L Enju"

  def copy_setup_files
    say_status("copying setup files", :green)
    directory("fixtures", "db/fixtures")
  end
end
