#encoding: utf-8
require 'csv'
require 'zip/zip'

module DemanderHelper
  # ws : generate bar
  def self.generate_demand_bar demand
    img= thisLineWidth=lastLineWidth=nil
    if demand.oldamount.nil?
      img='dotchecked'
      title="新增需求"
    thisLineWidth=demand.amount>0 ? 100 : 0
    lastLineWidth=0
    elsif demand.rate.to_i>0
      img='arrup'
      title="需求增加"
    thisLineWidth=100
    lastLineWidth= demand.oldamount>0 ? 100/(1+demand.rate.to_f/100) : 0
    elsif demand.rate.to_i<0
      img='arrdown'
      title="需求减少"
    thisLineWidth=(100+demand.rate.to_f)
    lastLineWidth=100
    else
      img='equal'
      title="需求未变"
    thisLineWidth=demand.amount>0 ? 100 : 0
    lastLineWidth=demand.oldamount>0 ? 100 : 0
    end
    if demand.respond_to?(:accepted)
      img,title = 'dotunchecked',"需求未被确认"  unless demand.accepted
    end
    return img,thisLineWidth,lastLineWidth,title
  end
  
  def self.pre_work_on_params params
    c = params[:client]
    s = params[:supplier]
    p = params[:partNr]
    tstart = Time.parse(params[:start]) if params[:start].present?
    tend = Time.parse(params[:end]) if params[:end].present?
    
    return c, s, p, tstart, tend
  end

end
