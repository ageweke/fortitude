class ViewPathsSystemSpecController < ApplicationController
  def added_view_path
  end

  def autoloading_from_added_view_path
  end

  def added_view_path_from_controller
    append_view_path(File.join(File.expand_path(::Rails.root), 'view_path_two'))
  end

  def added_view_path_from_controller_with_impossible_to_guess_name
    append_view_path(File.join(File.expand_path(::Rails.root), 'view_path_two'))
  end
end
