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

def is_hashy(hash)
  return true if hash.class == Hash
  return true if hash.class.ancestors.include?(Hash)
  return true if hash.methods.include?(:keys) and hash.methods.include?(:values) and hash.methods.include?(:[])
  return false
end

def collect_packages(mash)
  return [[mash,true]] if mash.class == String
  package_tuples = []
  unless is_hashy(mash) or mash.class == Array
    fail "collect_packages was passed #{mash} which is not hash-like. Please make sure it supports .keys, .values, and .[]"
  end
  mash.each do |k,v|
    if is_hashy(v)
      package_tuples += collect_packages(v)
    elsif k.class == String and v.class == String
      package_tuples << [k,v]
    elsif v.class == Array
      v.each {|p| package_tuples += collect_packages(p) }
    else
      fail "#{mash} contains a value that is not a String, Hash-like, or Array."
    end
  end
  package_tuples
end
