require 'test_helper'

class MOrganisationRelationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def test_create_org_rela
    orgone = m_organisations(:orgone)
    orgtwo = m_organisations(:orgtwo)
    orgthree = m_organisations(:orgthree)
    orgrel_one = MOrganisationRelation.create(:clientNr=>orgtwo.name)
    orgone.clients<<orgrel_one
    orgone.suppliers<<MOrganisationRelation.create(:supplierNr=>orgthree.name)
    puts "-"*20
    puts orgone.clients.collect { |d|d.clientNr}
    puts "-"*20
    puts orgone.clients.first.origin_supplier.instance_variables.collect {|d|d}
    puts "-"*20
    assert_not_nil orgone.clients, "Organisation one creation failed"
  end
end
