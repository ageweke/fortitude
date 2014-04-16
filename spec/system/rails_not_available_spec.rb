describe "Fortitude spec environment" do
  # This may seem like a weird spec, but we REALLY don't want to be running Fortitude's built-in specs with Rails
  # available -- because we want to make really sure Fortitude doesn't end up with any kind of Rails dependency
  # in it. So we added this spec to make sure the specs fail if Rails somehow *is* available.
  #
  # Fortitude has lots and lots of Rails-specific tests, but those run in a separate process with a separate Gemfile,
  # and thus don't need Rails available at the overall Fortitude level.
  it "should not have Rails available" do
    expect { ::Rails }.to raise_error(NameError, /Rails/i)
  end
end
