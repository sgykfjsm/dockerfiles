require "spec_helper"
require 'json'

describe "sgykfjsm/php5fpm Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        puts image
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/php5fpm:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=php5fpm")
  end

  it "should expose http port(monit)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("2812/tcp")).to be true
  end

  it "should have CMD" do
    expect(@image.json["Config"]["Cmd"]).to include("/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc")
  end

end

#------

describe command("docker -H ':5432' ps -a --no-trunc") do

  its(:stdout) { should match /php5fpm/ }
  its(:stdout) { should match /base_ubuntu/ }

end

#------

describe command("docker -H ':5432' exec php5fpm test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/php5fpm/g' docker/php5fpm/etc_monit_conf.d_monit.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec php5fpm cat /etc/monit/conf.d/monit.conf | openssl sha1 | awk '{print $NF}'") do

  its(:stdout) { should match /^b56268ee615f6ad4d48ad399f95d7196557f2a59$/}

end

#------

describe command("docker -H ':5432' exec php5fpm test -f /etc/monit/conf.d/php5fpm.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/php5fpm/etc_monit_conf.d_php5fpm.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec php5fpm openssl sha1 /etc/monit/conf.d/php5fpm.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^dc5ce6fb79d851e454765e476e0aebaf1a499060$/ }

end

#------

describe command("docker -H ':5432' exec php5fpm test -f /etc/php5/fpm/php.ini") do

  its(:exit_status) { should eq 0 }

end

#------

describe command("docker -H ':5432' exec php5fpm test -f /etc/php5/fpm/pool.d/www.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_php5_fpm_pool.d_www.conf| awk '{print $NF}'
describe command("docker -H ':5432' exec php5fpm openssl sha1 /etc/php5/fpm/pool.d/www.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^1ce1afce4f71281637dfe8b42dc4920e29ef5aa9$/ }

end

#------

describe port(12812) do

  it { should be_listening }

end

#------

describe command("curl --silent http://localhost:12812 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:12812") do

  its(:stdout) { should include 'Monit Service Manager' }

end

#------

describe command("docker -H ':5432' exec php5fpm php5-fpm -m") do

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

describe command("docker -H ':5432' exec php5fpm php5-fpm -i") do

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
