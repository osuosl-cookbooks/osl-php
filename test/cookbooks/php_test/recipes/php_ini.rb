#
# Cookbook:: php_test
# Recipe:: default
# Copyright:: 2019-2024, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License"); # you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

with_sections = {
  'allow_call_time_pass_reference' => 'Off',
  'allow_url_fopen' => 'On',
  'asp_tags' => 'Off',
  'browscap' => {
    'dbx.colnames_case' => '"lowercase"',
    'default_mimetype' => '"text/html"',
    'display_errors' => 'Off',
    'display_startup_errors' => 'Off',
  },
  'Informix' => {
    'ingres.allow_persistent' => 'On',
  },
  'Ingres II' => {
    'ingres.max_links' => '-1',
    'ingres.max_persistent' => '-1',
    'log_errors_max_len' => '1024',
    'log_errors' => 'On',
  },
  'MSSQL' => {
    'mssql.allow_persistent' => 'On',
    'mssql.compatability_mode' => 'Off',
    'mssql.secure_connection' => 'Off',
  },
  'MySQL' => {
    'mysql.allow_persistent' => 'On',
    'mysql.connect_timeout' => '60',
  },
  'MySQLI' => {
    'mysqli.reconnect' => 'Off',
    'mysql.max_links' => '-1',
    'mysql.max_persistent' => '-1',
    'mysql.trace_mode' => 'Off',
  },
  'ODBC' => {
    'odbc.defaultbinmode' => '1',
    'odbc.defaultlrl' => '4096',
    'odbc.max_links' => '-1',
    'odbc.max_persistent' => '-1',
  },
  'PostgresSQL' => {
    'post_max_size' => '8M',
    'precision' => '14',
    'register_argc_argv' => 'On',
  },
  'Session' => {
    'session.auto_start' => '0',
    'session.bug_compat_42' => '0',
    'session.bug_compat_warn' => '1',
    'session.cache_expire' => '180',
  },
}

no_sections = {
  'allow_call_time_pass_reference' => 'Off',
  'allow_url_fopen' => 'On',
  'asp_tags' => 'Off',
  'dbx.colnames_case' => '"lowercase"',
  'default_mimetype' => '"text/html"',
  'display_errors' => 'Off',
  'display_startup_errors' => 'Off',
  'ingres.allow_persistent' => 'On',
  'ingres.max_links' => '-1',
  'ingres.max_persistent' => '-1',
  'log_errors_max_len' => '1024',
  'log_errors' => 'On',
  'mssql.allow_persistent' => 'On',
  'mssql.compatability_mode' => 'Off',
  'mssql.secure_connection' => 'Off',
  'mysql.allow_persistent' => 'On',
  'mysql.connect_timeout' => '60',
  'mysqli.reconnect' => 'Off',
  'mysql.max_links' => '-1',
  'mysql.max_persistent' => '-1',
  'mysql.trace_mode' => 'Off',
  'odbc.defaultbinmode' => '1',
  'odbc.defaultlrl' => '4096',
  'odbc.max_links' => '-1',
  'odbc.max_persistent' => '-1',
  'post_max_size' => '8M',
  'precision' => '14',
  'register_argc_argv' => 'On',
  'session.auto_start' => '0',
  'session.bug_compat_42' => '0',
  'session.bug_compat_warn' => '1',
  'session.cache_expire' => '180',
}

osl_php_ini 'with_sections_rendered' do
  options with_sections
end

osl_php_ini 'no_sections_rendered' do
  options no_sections
end

osl_php_ini 'no_sections_rendered_added' do
  options no_sections
end

osl_php_ini 'no_sections_rendered_removed' do
  action :remove
end

# These cookbook_files are the ini files that the two hashes above are based on.
# They are copied to the server to be compared with the rendered versions of themselves
cookbook_file '/tmp/with_sections_static' do
  source 'with_sections_static'
end
cookbook_file '/tmp/no_sections_static' do
  source 'no_sections_static'
end
