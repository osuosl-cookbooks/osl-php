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

def enum?(e)
  return e.class.included_modules.include?(Enumerable)
end

def hashy?(h)
  return h.class.ancestors.include?(Hash)
end

def iterate(iter)
  return enum?(iter) ? collect_packages(iter) : iter
end

def collect_packages(en)
  return en unless enum?(en)
  # values contains all values from hashes +  each entry from non-hashy enums
  values = []
  # Partition enums into hashy and non-hashy (potentially non-)enums
  parted_ens = hashy?(en) ? [[en],[]] : en.partition { |iter| hashy?(iter) }
  # We only want to include hash keys if they have a true value and the values are not enumerable
  parted_ens[0].each { |iter| iter.each_pair { |k,v| values << (enum?(v) ? collect_packages(v) : iterate(k) if v) }}
  # Iterate over non-hashy enums and non-enums
  parted_ens[1].each { |iter| values << iterate(iter) }
  return values.flatten.compact
end
