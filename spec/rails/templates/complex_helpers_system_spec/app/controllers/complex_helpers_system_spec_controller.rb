class ComplexHelpersSystemSpecController < ApplicationController
  def form_for_test
    # nothing here
  end

  def fields_for_test
    # nothing here
  end

  def cache_test
    @a = params[:a]
    @b = params[:b]
  end

  def cache_tags_test
    @a = params[:a]
    @b = params[:b]
  end
end
