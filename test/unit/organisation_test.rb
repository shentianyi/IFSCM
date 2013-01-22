require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @leoni=organisations(:leoni)
  end
  
  def test_clients
    @leoni = organisations(:ningbo)
    org2 = organisations(:leoni)
    assert_equal org.clients.first.origin_client.id, org2.id 
  end
  
  def test_suppliers
    org = organisations(:leoni)
    org2 = organisations(:ningbo)
    assert_equal org.suppliers.first.origin_supplier.id, org2.id 
  end
  
  def test_cli_req_parts
    org = organisations(:ningbo)
    assert_equal org.suppliers.first.origin_supplier.id, org2.id
  end
  
  def test_sup_res_parts
    
    
  end

  # def test_create_org
    # org = organisations(:orgone)
    # org.save
    # org.reload
    # assert_not_nil org, "Organisation one creation failed"
  # end
end
