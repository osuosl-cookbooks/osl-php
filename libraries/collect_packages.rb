#
# Cookbook Name:: osl-php
# Library:: collect_packages
#
# Copyright 2014, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def collect_packages(obj)
  arr = []
  if obj.class.ancestors.include?(Enumerable)
      obj.each do |iter|
      if iter.class.ancestors.include?(Enumerable)
        if iter.all? {|sub_iter| sub_iter.class.ancestors.include?(Enumerable)}
          iter.each {|sub_iter| arr += collect_packages(sub_iter)}
        elsif iter.any?{|sub_iter| sub_iter.class.ancestors.include?(Enumerable)}
          iter.each {|sub_iter| arr += collect_packages(sub_iter) if sub_iter.class.ancestors.include?(Enumerable)}
        else
          arr << iter
        end
      else
        arr << [iter]
      end
    end
    return arr
  else
    fail "Sorry, collect_packages only accepts Enumerable objects\
      that contains String objects, and #{obj} is not a String!" unless obj.class == String
    [[obj,true]]
  end
end
