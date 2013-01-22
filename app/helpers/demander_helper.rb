#coding:utf-8
require 'csv'
require 'zip/zip'

module DemanderHelper
  # ws : generate bar
  def self.generate_demand_bar demand
    img= thisLineWidth=lastLineWidth=nil
    if demand.oldamount.nil?
      img='dotchecked'
    thisLineWidth=demand.amount>0 ? 100 : 0
    lastLineWidth=0
    elsif demand.rate.to_i>0
      img='arrup'
    thisLineWidth=100
    lastLineWidth= demand.oldamount>0 ? 100/(1+demand.rate.to_f/100) : 0
    elsif demand.rate.to_i<0
      img='arrdown'
    thisLineWidth=(100+demand.rate.to_f)
    lastLineWidth=100
    else
      img='equal'
    thisLineWidth=demand.amount>0 ? 100 : 0
    lastLineWidth=demand.oldamount>0 ? 100 : 0
    end
    return img,thisLineWidth,lastLineWidth
  end

end
