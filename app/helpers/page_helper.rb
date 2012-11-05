require  'action_view/helpers/tag_helper'

module PageHelper
  def bri_pager  *args
    page=''
    options = args.last.is_a?(Hash) ? args.pop : {}
    page.concat(tag("div", {:class=>options[:class]},true))
    page.concat(tag("ul",nil,true))
    targetId=options[:targetid]
    list=8
    pre=4
    after=list-pre
    total=options[:pages]
    current=options[:current]
    action=options[:action]
    page_concat page,0,1,current,action,targetId
    if total<=list
      page_concat page,1,total-1,current,action,targetId
    elsif current<pre+1
      page_concat page,1,list,current,action,targetId
    elsif after+current+1>=total
      page_concat page,total-list-1,total-1,current,action,targetId
    else
      page_concat page,current-pre+1,current+after,current,action,targetId
    end
    if total>1
      page_concat page,total-1,total,current,action,targetId,true
    end
    page.concat('</ul>').html_safe
    page.concat('</div>').html_safe
  end

  private

  def page_concat page,pstart,pend,current,action,targetId=nil,last=nil
    for i in pstart...pend
      liso={}
      liso[:class]= i!=current ? 'disabled':'active'
      page.concat(tag("li",liso,true))
      so={}

      so[:onclick]="return "+action+"('"+"#{targetId}"+"',"+i.to_s+")" if i!=current and targetId!=nil and targetId.class==String
      so[:onclick]="return "+action+"("+"#{targetId.to_json}"+","+i.to_s+")" if i!=current and targetId!=nil 
      
      so[:href]="#"
      # text= pstart==0 ? 'FIRST' : i+1
      # text="LAST"  if !last.nil? 
      text=i+1
      page.concat(content_tag("a",text,so)) 
      page.concat('</li>').html_safe
    end
  end
end