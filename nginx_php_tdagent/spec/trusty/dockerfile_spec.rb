require "spec_helper"
require 'json'

describe "sgykfjsm/data1 Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/data1:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental DEBIAN_FRONTEND" do
    expect(@image.json["Config"]["Env"]).to include("DEBIAN_FRONTEND=noninteractive")
  end

  it "should have environmental APP_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("APP_CONTAINER_NAME=nginx")
  end

  it "should have environmental DATA_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("DATA_CONTAINER_NAME=data")
  end

  it "should have environmental LOG_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("LOG_CONTAINER_NAME=td")
  end

  it "should have environmental LANG" do
    expect(@image.json["Config"]["Env"]).to include("LANG=en_US.UTF-8")
  end

  it "should have environmental LC_ALL" do
    expect(@image.json["Config"]["Env"]).to include("LC_ALL=en_US.UTF-8")
  end

end

#------

describe "sgykfjsm/app Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/nginx:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental DEBIAN_FRONTEND" do
    expect(@image.json["Config"]["Env"]).to include("DEBIAN_FRONTEND=noninteractive")
  end

  it "should have environmental APP_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("APP_CONTAINER_NAME=nginx")
  end

  it "should have environmental DATA_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("DATA_CONTAINER_NAME=data")
  end

  it "should have environmental LOG_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("LOG_CONTAINER_NAME=td")
  end

  it "should have environmental LANG" do
    expect(@image.json["Config"]["Env"]).to include("LANG=en_US.UTF-8")
  end

  it "should have environmental LC_ALL" do
    expect(@image.json["Config"]["Env"]).to include("LC_ALL=en_US.UTF-8")
  end

  it "should expose http port(nginx)" do
    # puts JSON.pretty_generate(@image.json)
    expect(@image.json["Config"]["ExposedPorts"].has_key?("80/tcp")).to be true
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

  its(:stdout) { should match /nginx/ }
  its(:stdout) { should match /data/ }
  its(:stdout) { should match /td/ }

end

#------

describe command("docker -H ':5432' exec nginx test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/app1/g' docker/nginx/etc_monit_conf.d_monit.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx cat /etc/monit/conf.d/monit.conf | openssl sha1 | awk '{print $NF}'") do

  its(:stdout) { should match /^299d873ba0991f0fd24862dd0c9990479f42b593$/}

end

#------

describe command("docker -H ':5432' exec nginx test -f /etc/monit/conf.d/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_monit_conf.d_nginx.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/monit/conf.d/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^a8c276381973f43961530712131755f953f610e8$/}

end

#------

describe command("docker -H ':5432' exec nginx test -f /etc/nginx/nginx/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_nginx_nginx.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/nginx/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^d28abca32be0dc6033be9f815720e34c80e3e805$/}

end

#------

describe command("docker -H ':5432' exec nginx test -f /etc/nginx/sites-available/app1") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/app1/g' docker/nginx/etc_nginx_sites-available_app1  | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/nginx/sites-available/app1 | awk '{print $NF}'") do

  its(:stdout) { should match /^39b49eb74ce5746395711976e84ecf0923c80016$/}

end

#------

describe command("docker -H ':5432' exec nginx test -f /etc/monit/conf.d/php5fpm.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_monit_conf.d_php5fpm.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/monit/conf.d/php5fpm.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^dc5ce6fb79d851e454765e476e0aebaf1a499060$/ }

end

#------

describe command("docker -H ':5432' exec nginx test -f /etc/php5/fpm/php.ini") do

  its(:exit_status) { should eq 0 }

end

#------

describe command("docker -H ':5432' exec nginx test -f /etc/php5/fpm/pool.d/www.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_php5_fpm_pool.d_www.conf| awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/php5/fpm/pool.d/www.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^1ce1afce4f71281637dfe8b42dc4920e29ef5aa9$/ }

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

describe command("docker -H ':5432' exec nginx php5-fpm -m") do

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

#------

describe command("docker -H ':5432' exec nginx php5-fpm -i") do

  its(:stdout) {
    is_expected.to include 'expose_php => Off => Off',
      'html_errors => Off => Off',
      'variables_order => EGPCS => EGPCS',
      'session.save_path => /tmp => /tmp',
      'default_socket_timeout => 90 => 90',
      'short_open_tag => On => On',
      'date.timezone => UTC => UTC'
  }

end
