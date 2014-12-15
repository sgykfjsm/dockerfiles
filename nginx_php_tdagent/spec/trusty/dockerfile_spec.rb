require "spec_helper"
require 'json'

describe "sgykfjsm/nginx_php_tdagent Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/nginx_php_tdagent:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=nginx_php_tdagent")
  end

  it "should expose http port(nginx)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("80/tcp")).to be true
  end

  it "should expose http port(monit)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("2812/tcp")).to be true
  end

  it "should expose http port(24220)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("24220/tcp")).to be true
  end

  it "should expose http port(8888)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("8888/tcp")).to be true
  end

  it "should expose http port(24224)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("24224/tcp")).to be true
  end

  it "should expose http port(24230)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("24230/tcp")).to be true
  end

  it "should have environmental PATH" do
    expect(@image.json["Config"]["Env"]).to include("PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/td-agent/embedded/bin:/opt/td-agent/bin")
  end

  it "should have CMD" do
    expect(@image.json["Config"]["Cmd"]).to include("/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc")
  end

end

#------

describe command("docker -H ':5432' ps -a --no-trunc --filter status=running") do

  its(:stdout) { should match /nginx_php_tdagent/ }

end

#------

describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/monit/conf.d/php5fpm.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec nginx_php_tdagent openssl sha1 /etc/monit/conf.d/php5fpm.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^dc5ce6fb79d851e454765e476e0aebaf1a499060$/ }

end


describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/monit/conf.d/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec nginx_php_tdagent openssl sha1 /etc/monit/conf.d/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^a8c276381973f43961530712131755f953f610e8$/}

end

describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec nginx_php_tdagent openssl sha1 /etc/monit/conf.d/monit.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^e042aa561ff8f448ac7e041f6644c1bd95a30302$/}

end

describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/monit/conf.d/td.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec nginx_php_tdagent openssl sha1 /etc/monit/conf.d/td.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^883f59e5a52bef32510427645e5857bc84ffd917$/}

end

#------

describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/nginx/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_nginx_nginx.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx_php_tdagent openssl sha1 /etc/nginx/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^d28abca32be0dc6033be9f815720e34c80e3e805$/}

end

#------

describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/nginx/sites-available/default") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec nginx_php_tdagent openssl sha1 /etc/nginx/sites-available/default | awk '{print $NF}'") do

  its(:stdout) { should match /^e7f617bedf0df4ec6820a54dc87349c0d0d15e13$/ }

end

describe command("docker -H ':5432' exec nginx_php_tdagent test -d /var/log/monit") do

  its(:exit_status) { should eq 0 }

end

#------

describe port(10080) do

  it { should be_listening }

end

describe port(12812) do

  it { should be_listening }

end

#------

describe command("curl --silent http://localhost:10080/index.html") do

  its(:stdout) { should match 'ok' }

end

#------

describe command("curl --silent --head http://localhost:10080 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:10080") do

  its(:stdout) { should include 'FPM/FastCGI' }

end

#------

describe command("curl --silent http://localhost:12812 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:12812") do

  its(:stdout) { should include 'Monit Service Manager' }

end

#------

describe command("docker -H ':5432' exec nginx_php_tdagent pidof td-agent") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec nginx_php_tdagent fluent-gem list") do

  its(:stdout) { should include 'norikra-client' }

end

#------

describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/php5/fpm/php.ini") do

  its(:exit_status) { should eq 0 }

end

#------

describe command("docker -H ':5432' exec nginx_php_tdagent test -f /etc/php5/fpm/pool.d/www.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_php5_fpm_pool.d_www.conf| awk '{print $NF}'
describe command("docker -H ':5432' exec nginx_php_tdagent openssl sha1 /etc/php5/fpm/pool.d/www.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^1ce1afce4f71281637dfe8b42dc4920e29ef5aa9$/ }

end

#------

describe command("docker -H ':5432' exec nginx_php_tdagent php5-fpm -m") do

  its(:stdout) {
    is_expected.to include 'apc',
      'apcu',
      'bcmath',
      'bz2',
      'calendar',
      'cgi-fcgi',
      'Core',
      'ctype',
      'curl',
      'date',
      'dba',
      'dom',
      'ereg',
      'exif',
      'fileinfo',
      'filter',
      'ftp',
      'gd',
      'gettext',
      'hash',
      'iconv',
      'imagick',
      'intl',
      'json',
      'libxml',
      'mbstring',
      'memcache',
      'memcached',
      'mhash',
      'mysql',
      'mysqli',
      'mysqlnd',
      'OAuth',
      'odbc',
      'openssl',
      'pcre',
      'PDO',
      'pdo_mysql',
      'PDO_ODBC',
      'pdo_pgsql',
      'pdo_sqlite',
      'pgsql',
      'Phar',
      'posix',
      'readline',
      'Reflection',
      'session',
      'shmop',
      'SimpleXML',
      'soap',
      'sockets',
      'SPL',
      'sqlite3',
      'ssh2',
      'standard',
      'sysvmsg',
      'sysvsem',
      'sysvshm',
      'tokenizer',
      'wddx',
      'xml',
      'xmlreader',
      'xmlrpc',
      'xmlwriter',
      'xsl',
      'Zend OPcache',
      'zip',
      'zlib'
  }

end

describe command("docker -H ':5432' exec nginx_php_tdagent php5-fpm -i") do

  its(:stdout) {
    is_expected.to include 'expose_php => Off => Off',
      'html_errors => Off => Off',
      'variables_order => EGPCS => EGPCS',
      'session.save_path => /tmp => /tmp',
      'default_socket_timeout => 90 => 90',
      'short_open_tag => On => On',
      'date.timezone => UTC => UTC',
      'error_log => /var/log/php5-fpm-error.log => /var/log/php5-fpm-error.log'
  }

end
#------
