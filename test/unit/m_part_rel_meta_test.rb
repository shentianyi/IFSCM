require 'test_helper'

class MPartRelMetaTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def test_fixtures_access
    assert_not_nil m_part_rel_meta(:partMetaone), "fixtures test"
  end
  
  def test_create_part_meta 
    orgone = m_organisations(:orgone)
    orgtwo = m_organisations(:orgtwo)
    orgthree = m_organisations(:orgthree)
    orgrel_one = MOrganisationRelation.create(:clientNr=>orgtwo.name, :supplierNr=>"none")
    orgone.clients<<orgrel_one
    orgtwo.suppliers<<orgrel_one
    orgtwo.suppliers<<MOrganisationRelation.create(:clientNr=>orgthree.contact, :supplierNr=>orgthree.name)
    puts "-"*10
    puts orgone.clients.collect { |d|d.clientNr}
    
    part = ClientPart.create(:partNr=>"part_cli_001")
    orgone.clients.first.client_parts<<part
    orgone.clients.first.supplier_parts<<SupplierPart.create(:partNr=>"part_sup_001")
    puts "-"*10
    puts orgone.cli_req_parts.collect { |d|d.partNr}
    puts "-"*10
    puts orgtwo.sup_res_parts.collect { |d|d.partNr}
    
    meta = MPartRelMeta.create(:saleNo=>"one_sale", :purchaseNo=>"two_purchase")
    meta2 = MPartRelMeta.create(:saleNo=>"meta_wrong_004", :purchaseNo=>"meta_wrong_d")
    puts "-"*10
    orgone.cli_req_parts.first.partRelMeta=meta
    orgtwo.sup_res_parts.first.partRelMeta=meta2
    puts orgone.cli_req_parts.collect {|d| d.partRelMeta.id }
    puts "-"*10
    puts orgtwo.sup_res_parts.collect {|d| d.partRelMeta.id }
    puts "-"*10
    puts orgone.cli_req_parts.first.partRelMeta.saleNo
    puts orgone.cli_req_parts.first.partRelMeta.id
    puts orgone.cli_req_parts.first.partRelMeta.client_part_id
    puts orgone.cli_req_parts.first.type
    puts orgone.cli_req_parts.first.partRelMeta.supplier_part_id
    puts orgone.cli_req_parts.first.partRelMeta.supplier_part.type
    puts orgone.cli_req_parts.first.partRelMeta.supplier_part.partNr
    puts "-"*10
    orgtwo.sup_res_parts.first.partRelMeta=meta2
    puts orgtwo.sup_res_parts.first.partRelMeta.saleNo
    puts orgtwo.sup_res_parts.first.partRelMeta.id
    puts orgtwo.sup_res_parts.first.partRelMeta.client_part_id
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part_id
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    # puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.partNr
    puts "-"*10
    orgtwo.sup_res_parts.first.partRelMeta=meta
    puts orgtwo.sup_res_parts.first.partRelMeta.saleNo
    puts orgtwo.sup_res_parts.first.partRelMeta.id
    puts orgtwo.sup_res_parts.first.partRelMeta.client_part_id
    puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part_id
    puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.type
    puts orgtwo.sup_res_parts.first.partRelMeta.supplier_part.partNr
    
    puts "-"*10
    puts orgone.cli_req_parts.collect {|d| d.partRelMeta.id }
    puts "-"*10
    puts orgtwo.sup_res_parts.collect {|d| d.partRelMeta.id }
    puts "-"*10
    
    assert_not_nil orgone.cli_req_parts.first.partRelMeta, "PartMeta one creation failed"
    
  end
end
