class DevelopmentModeSystemSpecController < ApplicationController
  def reload_widget
    @datum = "one"
  end

  def reload_widget_with_html_extension
    @datum = "five"
  end

  def sample_output
    @name = "Jessica"
  end

  def namespace_reference
    # nothing here
  end

  def mailer_view_test
    DevelopmentModeMailer.mailer_view_test.deliver
  end

  def mailer_layout_test
    DevelopmentModeMailer.mailer_layout_test.deliver
  end

  def mailer_formatting_test
    DevelopmentModeMailer.mailer_formatting_test.deliver
  end
end
