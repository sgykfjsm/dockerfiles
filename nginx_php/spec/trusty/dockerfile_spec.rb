require "spec_helper"
require 'json'

describe "sgykfjsm/nginx_php5fpm Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/nginx_php5fpm:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=nginx_php5fpm")
  end

  it "should expose http port(nginx)" do
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

describe command("docker -H ':5432' ps -a --no-trunc --filter status=running") do

  its(:stdout) { should match /nginx_php5fpm/ }

end

#------

describe command("docker -H ':5432' exec nginx_php5fpm test -f /etc/monit/conf.d/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_monit_conf.d_nginx.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx_php5fpm openssl sha1 /etc/monit/conf.d/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^a8c276381973f43961530712131755f953f610e8$/}

end

#------

describe command("docker -H ':5432' exec nginx_php5fpm test -f /etc/nginx/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_nginx_nginx.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx_php5fpm openssl sha1 /etc/nginx/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^d28abca32be0dc6033be9f815720e34c80e3e805$/}

end

#------

describe command("docker -H ':5432' exec nginx_php5fpm test -f /etc/nginx/sites-available/default") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/nginx_php5fpm/g' docker/etc_nginx_sites-available_default | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx_php5fpm openssl sha1 /etc/nginx/sites-available/default | awk '{print $NF}'") do

  its(:stdout) { should match /^be4c82f31ea32ac5124a6653e44bd3a8702a6288$/}

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
