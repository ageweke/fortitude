class Views::RenderingSystemSpec::RenderHashSubclass < Fortitude::Widgets::Html5
  needs :the_hash, :other_hash

  def content
    text "the_hash class: #{the_hash.class.name}\n"
    # text "is_my_hash? #{the_hash.is_my_hash?.inspect}\n"
    text "the_hash[:foo] #{the_hash[:foo].inspect}\n"
    text "the_hash[\"foo\"] #{the_hash['foo'].inspect}\n"
    text "the_hash[:bar] #{the_hash[:bar].inspect}\n"
    text "the_hash[\"bar\"] #{the_hash['bar'].inspect}\n"

    text "other_hash class: #{other_hash.class.name}\n"
    text "other_hash[:quux] #{other_hash[:quux].inspect}\n"
    text "other_hash[\"quux\"] #{other_hash['quux'].inspect}\n"
    text "other_hash[:marph] #{other_hash[:marph].inspect}\n"
    text "other_hash[\"marph\"] #{other_hash['marph'].inspect}\n"
  end
end
