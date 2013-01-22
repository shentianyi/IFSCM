require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @leoni=organisations(:leoni)
    @ningbo = organisations(:ningbo)
  end
  
  def test_clients
    assert_equal @ningbo.clients.first.origin_client.id, @leoni.id 
  end
  
  def test_suppliers
    assert_equal @leoni.suppliers.first.origin_supplier.id, @ningbo.id 
  end
  
  def test_pOne_not_in_cli_req_parts
    assert_include  parts(:pOne), @ningbo.cli_req_parts
  end
  
  def test_pTwo_in_cli_req_parts
    assert_include  parts(:pTwo), @ningbo.cli_req_parts
  end
  
  def test_pOne_in_sup_res_parts
    assert_include  parts(:pOne), @leoni.sup_res_parts
  end

  # def test_create_org
    # org = organisations(:orgone)
    # org.save
    # org.reload
    # assert_not_nil org, "Organisation one creation failed"
  # end
end
