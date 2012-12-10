$(document).ready(function() {
     $('#client-search-text').autocomplete({
          source : "/organisation_manager/redis_search"
     });
});

// ws
// 功能 ： 根据parterNr搜索关系零件
// 参数 ： 
//  - string : partnerNr
// 返回 ： 
// - partial : 零件列表
function get_parts_by_parterNr () {
  
}
