require 'test_helper'

class MOrganisationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  # def test_fixtures_access
    # assert m_part_rel_meta(:partMetaone)!=nil
  # end
  def test_my_clients
    
  end

  def test_create_org
    org = m_organisations(:orgone)
    org.save
    org.reload
    assert_not_nil org, "Organisation one creation failed"
  end
end
