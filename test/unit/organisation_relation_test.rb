require 'test_helper'

class OrganisationRelationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @leoni=organisations(:leoni)
    @ningbo = organisations(:ningbo)
  end
  
  def test_create_org_relation
    orgrel_one = OrganisationRelation.create(:clientNr=>@leoni.name, :supplierNr=>"none", :origin_supplier_id=>@ningbo.id, :origin_client_id=>@leoni.id)
    # puts @leoni.suppliers.each {|e|"--#{e.id}--#{e.supplierNr}--"}
    assert_not_nil orgrel_one.reload
  end
  
  def test_find_org_relation
    orgrel = OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", @leoni.id, @ningbo.id).first
    assert_not_nil  orgrel
  end
  # def test_create_org_rela
    # orgone = organisations(:orgone)
    # orgtwo = organisations(:orgtwo)
    # orgthree = organisations(:orgthree)
    # orgrel_one = OrganisationRelation.create(:clientNr=>orgtwo.name)
    # orgone.clients<<orgrel_one
    # orgone.suppliers<<OrganisationRelation.create(:supplierNr=>orgthree.name)
    # puts "-"*20
    # puts orgone.clients.collect { |d|d.clientNr}
    # puts "-"*20
    # puts orgone.clients.first.origin_supplier.instance_variables.collect {|d|d}
    # puts "-"*20
    # assert_not_nil orgone.clients, "Organisation one creation failed"
  # end
end
