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
    expect(@image.json["Config"]["Env"]).to include("APP_CONTAINER_NAME=app1")
  end

  it "should have environmental DATA_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("DATA_CONTAINER_NAME=data1")
  end

  it "should have environmental LANG" do
    expect(@image.json["Config"]["Env"]).to include("LANG=en_US.UTF-8")
  end

  it "should have environmental LC_ALL" do
    expect(@image.json["Config"]["Env"]).to include("LC_ALL=en_US.UTF-8")
  end

end

#------

describe "sgykfjsm/app1 Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/app1:latest"
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
    expect(@image.json["Config"]["Env"]).to include("APP_CONTAINER_NAME=app1")
  end

  it "should have environmental DATA_CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("DATA_CONTAINER_NAME=data1")
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

describe command("docker -H ':5432' ps -a --no-trunc") do

  its(:stdout) { should match /app1/ }
  its(:stdout) { should match /data1/ }

end

describe command("docker -H ':5432' exec app1 test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/app1/g' docker/nginx/etc_monit_conf.d_monit.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec app1 cat /etc/monit/conf.d/monit.conf | openssl sha1 | awk '{print $NF}'") do

  its(:stdout) { should match /^299d873ba0991f0fd24862dd0c9990479f42b593$/}

end

describe command("docker -H ':5432' exec app1 test -f /etc/monit/conf.d/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/app1/g' docker/nginx/etc_monit_conf.d_nginx.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec app1 cat /etc/monit/conf.d/nginx.conf | openssl sha1 | awk '{print $NF}'") do

  its(:stdout) { should match /^62e1bcbfb73b6cfcd0ce5cb965900ba43ba8eb21$/}

end

describe command("docker -H ':5432' exec app1 test -f /etc/nginx/nginx/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# cat docker/nginx/etc_nginx_nginx.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec app1 cat /etc/nginx/nginx.conf | openssl sha1 | awk '{print $NF}'") do

  its(:stdout) { should match /^d28abca32be0dc6033be9f815720e34c80e3e805$/}

end

describe command("docker -H ':5432' exec app1 test -f /etc/nginx/sites-available/app1") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/app1/g' docker/nginx/etc_nginx_sites-available_app1  | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec app1 cat  /etc/nginx/sites-available/app1 | openssl sha1 | awk '{print $NF}'") do

  its(:stdout) { should match /^6dc3ca9a2a03d86fbc8253557eadaf7e920ede44$/}

end

describe command("docker -H ':5432' exec app1 test -f /etc/php5/fpm/pool.d/www.conf ") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_php5_fpm_pool.d_www.conf| awk '{print $NF}'
describe command("docker -H ':5432' exec app1 openssl sha1 /etc/php5/fpm/pool.d/www.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^1ce1afce4f71281637dfe8b42dc4920e29ef5aa9$/}

end
