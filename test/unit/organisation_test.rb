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
  
  def test_pOne_not_in_cli_parts
    p = @ningbo.parts.where("partNr = 'nl001'").first
    assert_not_equal  parts(:pOne).id, p.id
  end
  
  def test_pOne_in_cli_parts
    p = @leoni.parts.where("partNr = 'leoni001'").first
    assert_equal  parts(:pOne).id, p.id
  end

  # def test_create_org
    # org = organisations(:orgone)
    # org.save
    # org.reload
    # assert_not_nil org, "Organisation one creation failed"
  # end
end
