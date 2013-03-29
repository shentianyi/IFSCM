require 'test_helper'

class DemanderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @demand = Demander.new(:clientId=>2, :relpartId=>5, :supplierId=>6 , :type=>"R", :amount=>200, :oldamount=>400, :date=>"2014" , :rate=>1)
    @demand.save_to_redis
    @key=@demand.key
    @test = Demander.new(:clientId=>1, :relpartId=>2, :supplierId=>3 , :type=>"T", :amount=>100, :oldamount=>200, :date=>"2013" , :rate=>12)
  end
  
  def test_redis_save_to_redis
    @test.save_to_redis
    assert_not_nil  @demand.key
  end
  
  def test_redis_save_to_redis_no_twice
    flag = @demand.save_to_redis
    assert_equal  flag, false
  end
  
  def test_redis_rfind_not_nil
    de = Demander.rfind(@key)
    assert_not_nil  de
  end
  
  def test_redis_rfind_type
    de = Demander.rfind(@key)
    assert_equal  de.type, "R"
  end
  
  def test_redis_rupdate
    @demand.rupdate(:amount=>99.9)
    de = Demander.rfind(@key)
    assert_equal  de.amount, 99.9
  end
  
  def test_redis_rdestroy
    @demand.rdestroy
    de = Demander.rfind(@key)
    assert_nil  de
  end
  
end
