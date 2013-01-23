require 'test_helper'

class PartTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @leoni = organisations(:leoni)
    @pOne = parts(:pOne)
    @pTwo = parts(:pTwo)
    @pThree = parts(:pThree)
    @orgRel = organisation_relations(:orgRelOne)
  end
  
  def test_create_part
    part = Part.new(:partNr=>"part__Test")
    @leoni.parts<<part
    assert_equal  @leoni.id, part.organisation_id
  end
  
  def test_find_part
    part = Part.where("organisation_id = ? and partNr = ?", @leoni.id, @pOne.partNr).first
    assert_not_nil  part
  end
  
  def test_part_in_collections
    parts = Part.where("organisation_id = ?", @leoni.id).all
    assert (parts.include? @pOne)
  end
end
