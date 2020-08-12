package = "luaacd"
version = "1.0-1"
source = {
   url = ""
}
description = {
   homepage = "",
   license = ""
}
dependencies = {
   "lua >= 5.1, < 5.4",
   "dkjson >= 2.5",
   "redis-lua >= 2.0.4"
}
build = {
   type = "builtin",
   modules = {
      ["acd.abort"] = "acd/abort.lua",
      ["acd.adjust"] = "acd/adjust.lua",
      ["acd.alg.compare"] = "acd/alg/compare.lua",
      ["acd.alg.compare_client"] = "acd/alg/compare_client.lua",
      ["acd.alg.filter_list"] = "acd/alg/filter_list.lua",
      ["acd.alg.find_index"] = "acd/alg/find_index.lua",
      ["acd.alg.flatten_list"] = "acd/alg/flatten_list.lua",
      ["acd.alg.get_candidate_range"] = "acd/alg/get_candidate_range.lua",
      ["acd.alg.get_range_easy"] = "acd/alg/get_range_easy.lua",
      ["acd.alg.get_range_high"] = "acd/alg/get_range_high.lua",
      ["acd.alg.get_range_multi"] = "acd/alg/get_range_multi.lua",
      ["acd.alg.get_range_served"] = "acd/alg/get_range_served.lua",
      ["acd.alg.hit_staff"] = "acd/alg/hit_staff.lua",
      ["acd.alg.in_list"] = "acd/alg/in_list.lua",
      ["acd.alg.is_prior"] = "acd/alg/is_prior.lua",
      ["acd.alg.is_protocol_match"] = "acd/alg/is_protocol_match.lua",
      ["acd.alg.is_subset"] = "acd/alg/is_subset.lua",
      ["acd.alg.is_valid_exc_rule"] = "acd/alg/is_valid_exc_rule.lua",
      ["acd.alg.prior_list"] = "acd/alg/prior_list.lua",
      ["acd.alg.rate_client"] = "acd/alg/rate_client.lua",
      ["acd.alg.remove_member"] = "acd/alg/remove_member.lua",
      ["acd.alg.select_queue"] = "acd/alg/select_queue.lua",
      ["acd.alg.split_keystr"] = "acd/alg/split_keystr.lua",
      ["acd.alg.split_skillstr"] = "acd/alg/split_skillstr.lua",
      ["acd.dequeue"] = "acd/dequeue.lua",
      ["acd.enqueue"] = "acd/enqueue.lua",
      ["acd.message.acd_queue_response"] = "acd/message/acd_queue_response.lua",
      ["acd.message.acd_queue_result"] = "acd/message/acd_queue_result.lua",
      ["acd.model.acd_access_info"] = "acd/model/acd_access_info.lua",
      ["acd.model.acd_attribution"] = "acd/model/acd_attribution.lua",
      ["acd.model.acd_client"] = "acd/model/acd_client.lua",
      ["acd.model.acd_client_queue"] = "acd/model/acd_client_queue.lua",
      ["acd.model.acd_client_server_status"] = "acd/model/acd_client_server_status.lua",
      ["acd.model.acd_customer_type"] = "acd/model/acd_customer_type.lua",
      ["acd.model.acd_queue"] = "acd/model/acd_queue.lua",
      ["acd.model.acd_queue_distribution_rule"] = "acd/model/acd_queue_distribution_rule.lua",
      ["acd.model.acd_queue_exception_rule"] = "acd/model/acd_queue_exception_rule.lua",
      ["acd.model.acd_queue_sort_rule"] = "acd/model/acd_queue_sort_rule.lua"
   }
}
