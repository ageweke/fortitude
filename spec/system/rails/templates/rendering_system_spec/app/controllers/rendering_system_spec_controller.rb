class RenderingSystemSpecController < ApplicationController
  def render_with_colon_action
    render :action => 'trivial_widget'
  end

  def render_with_colon_template
    render :template => 'rendering_system_spec/trivial_widget'
  end

  def render_widget
    render :widget => Views::WidgetToRender.new(:name => 'Fred')
  end

  def render_widget_without_layout
    render :widget => Views::WidgetToRender.new(:name => 'Fred'), :layout => false
  end

  def render_widget_via_file_path
    @name = "Fred"
    render File.join(Rails.root, 'app', 'views', 'widget_to_render')
  end

  def render_widget_via_colon_file
    @name = "Fred"
    render :file => File.join(Rails.root, 'app', 'views', 'widget_to_render')
  end

  def render_widget_via_inline
    @name = "Fred"
    proc = lambda do
      p "this is an inline widget named #{shared_variables[:name]}"
    end
    render :inline => proc, :type => :fortitude
  end

  def render_partial_from_widget
    # nothing here
  end

  def render_text_from_widget
    # nothing here
  end

  def render_template_from_widget
    # nothing here
  end

  def render_file_from_widget
    # nothing here
  end

  def render_inline_from_widget
    # nothing here
  end

  def render_with_content_type
    render :action => 'trivial_widget', :content_type => 'boo/yeah'
  end

  def render_with_status
    render :action => 'trivial_widget', :status => 768
  end

  def render_with_location
    render :action => 'trivial_widget', :location => "http://somewhere/over/the/rainbow"
  end

  def render_collection
    # nothing here
  end

  def render_collection_as
    # nothing here
  end

  def render_partial_with_layout
    # nothing here
  end
end
