require 'test_helper'

class PartRelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @pOne = parts(:pOne)
    @pTwo = parts(:pTwo)
    @pThree = parts(:pThree)
    @orgRel = organisation_relations(:orgRelOne)
  end
  
  def test_fixtures_access
    assert_not_nil part_rels(:pRelOne), "fixtures test"
  end
  
  def test_create_part_relation
    pRel = PartRel.create(:saleNo=>"saleNo_Test", :purchaseNo=>"purchaseNo_Test",
                                                          :client_part_id=>@pOne.id, :supplier_part_id=>@pTwo.id, :organisation_relation_id=>@orgRel.id)
    assert_not_nil pRel.reload
  end
  # def test_create_part_meta 
    # orgone = organisations(:orgone)
    # orgtwo = organisations(:orgtwo)
    # orgthree = organisations(:orgthree)
    # orgrel_one = OrganisationRelation.create(:clientNr=>orgtwo.name, :supplierNr=>"none")
    # orgone.clients<<orgrel_one
    # orgtwo.suppliers<<orgrel_one
    # orgtwo.suppliers<<OrganisationRelation.create(:clientNr=>orgthree.contact, :supplierNr=>orgthree.name)
    # puts "-"*10
    # puts orgone.clients.collect { |d|d.clientNr}
#     
    # part = ClientPart.create(:partNr=>"part_cli_001")
    # orgone.clients.first.client_parts<<part
    # orgone.clients.first.supplier_parts<<SupplierPart.create(:partNr=>"part_sup_001")
    # puts "-"*10
    # puts orgone.cli_req_parts.collect { |d|d.partNr}
    # puts "-"*10
    # puts orgtwo.sup_res_parts.collect { |d|d.partNr}
#     
    # meta = PartRelMeta.create(:saleNo=>"one_sale", :purchaseNo=>"two_purchase")
    # meta2 = PartRelMeta.create(:saleNo=>"meta_wrong_004", :purchaseNo=>"meta_wrong_d")
    # puts "-"*10
    # orgone.cli_req_parts.first.partRelMeta=meta
    # orgtwo.sup_res_parts.first.partRelMeta=meta2
    # puts orgone.cli_req_parts.collect {|d| d.partRelMeta.id }
    # puts "-"*10
    # puts orgtwo.sup_res_parts.collect {|d| d.partRelMeta.id }
    # puts "-"*10
    # puts orgone.cli_req_parts.first.partRelMeta.saleNo
    # puts orgone.cli_req_parts.first.partRelMeta.id
    # puts orgone.cli_req_parts.first.partRelMeta.client_part_id
    # puts orgone.cli_req_parts.first.type
    # puts orgone.cli_req_parts.first.partRelMeta.supplier_part_id
    # puts orgone.cli_req_parts.first.partRelMeta.supplier_part.type
    # puts orgone.cli_req_parts.first.partRelMeta.supplier_part.partNr
    # puts "-"*10
    # orgtwo.sup_res_parts.first.partRelMeta=meta2
    # puts orgtwo.sup_res_parts.first.partRelMeta.saleNo
    # puts orgtwo.sup_res_parts.first.partRelMeta.id
    # puts orgtwo.sup_res_parts.first.partRelMeta.client_part_id
    # # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part_id
    # # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    # # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.partNr
    # puts "-"*10
    # orgtwo.sup_res_parts.first.partRelMeta=meta
    # puts orgtwo.sup_res_parts.first.partRelMeta.saleNo
    # puts orgtwo.sup_res_parts.first.partRelMeta.id
    # puts orgtwo.sup_res_parts.first.partRelMeta.client_part_id
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part_id
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.partNr
#     
    # puts "-"*10
    # puts orgone.cli_req_parts.collect {|d| d.partRelMeta.id }
    # puts "-"*10
    # puts orgtwo.sup_res_parts.collect {|d| d.partRelMeta.id }
    # puts "-"*10
#     
    # assert_not_nil orgone.cli_req_parts.first.partRelMeta, "PartMeta one creation failed"
#     
  # end
end
