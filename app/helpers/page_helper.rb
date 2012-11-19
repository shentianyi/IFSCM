require  'action_view/helpers/tag_helper'

module PageHelper
  def bri_pager  *args
    page=''
    options = args.last.is_a?(Hash) ? args.pop : {}
    page.concat(tag("div", {:class=>options[:class]},true))
    page.concat(tag("ul",nil,true))
    target=options[:target]
    list=8
    pre=4
    after=list-pre
    total=options[:pages]
    current=options[:current]
    action=options[:action]
    page_concat page,0,1,current,action,target
    if total<=list
      page_concat page,1,total-1,current,action,target
    elsif current<pre+1
      page_concat page,1,list,current,action,target
    elsif after+current+1>=total
      page_concat page,total-list-1,total-1,current,action,target
    else
      page_concat page,current-pre+1,current+after,current,action,target
    end
    if total>1
      page_concat page,total-1,total,current,action,target,true
    end    

    page.concat('</ul>').html_safe
    page.concat('</div>').html_safe
  end

  # ws : get startIndex & endIndex of the page
  def self.generate_page_index index,size
       return  index*size,(index+1)*size-1
  end
  
  # ws : get total pages count
  def self.generate_page_count total,size
     total/size+(total%size==0?0:1)
  end
  
  private

  def page_concat page,pstart,pend,current,action,target=nil,last=nil
    for i in pstart...pend
      liso={}
      liso[:class]= i!=current ? 'disabled':'active'
      page.concat(tag("li",liso,true))
      so={}
      
      if i!=current
        if target.is_a?(String)
          so[:onclick]="return "+action+"('"+target+"',"+i.to_s+")"
        else
          so[:onclick]="return "+action+"(#{target.to_json},"+i.to_s+")"
        end
      end
        
      so[:href]="#"
      # text= pstart==0 ? 'FIRST' : i+1
      # text="LAST"  if !last.nil? 
      text=i+1
      page.concat(content_tag("a",text,so)) 
      page.concat('</li>').html_safe
    end
  end
end