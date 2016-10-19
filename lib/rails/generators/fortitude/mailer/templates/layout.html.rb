class Views::Layouts::Mailer < Views::Base
  def contents
    html {
      body {
        yield
      }
    }
  end
end
