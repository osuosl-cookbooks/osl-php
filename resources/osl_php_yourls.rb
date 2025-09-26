resource_name :osl_php_yourls
provides :osl_php_yourls
unified_mode true

default_action :install

property :version, String
property :fqdn, String, name_property: true
property :db_username, String
property :db_password, String, sensitive: true
property :db_name, String
property :db_host, String
property :db_prefix, String
property :domain, String
property :language, String, default: ''
property :unique_urls, Boolean, default: true
property :private, Boolean, default: true
property :cookiekey, String
property :user_passwords, Array, default: []
property :url_convert, Integer, default: 36
property :reserved_urls, Array, default: []

action :install do
  package 'tar'

  yourls_version = osl_github_latest_version('yourls/yourls', new_resource.version)

  begin
    ark 'yourls' do
      url "https://github.com/YOURLS/YOURLS/archive/refs/tags/#{yourls_version}.tar.gz"
      path "/var/www/#{new_resource.name}/yourls"
      version yourls_version
      action :put
    end
  rescue
    Chef::Log.warn("Error downloading yourls-#{yourls_version}, skipping for now")
  end

  template "/var/www/#{new_resource.name}/yourls/user/config.php" do
    variables(
        db_username: new_resource.db_username,
        db_password: new_resource.db_password,
        db_name: new_resource.db_name,
        db_host: new_resource.db_host,
        db_prefix: new_resource.db_prefix,
        domain: new_resource.domain,
        language: new_resource.language,
        unique_urls: new_resource.unique_urls,
        private: new_resource.private,
        cookiekey: new_resource.cookiekey,
        user_passwords: new_resource.user_passwords,
        url_convert: new_resource.url_convert,
        reserved_urls: new_resource.reserved_urls
      )
    sensitive true
  end

  osl_php_install 'default'
end
