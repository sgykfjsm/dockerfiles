require "spec_helper"

#------

describe "sgykfjsm/openresty Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/openresty:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=openresty")
  end

  it "should have environmental OPENRESTY_VERSION" do
    expect(@image.json["Config"]["Env"]).to include("OPENRESTY_VERSION=1.7.4.1")
  end

  it "should have environmental OPENRESTY_DIR" do
    expect(@image.json["Config"]["Env"]).to include("OPENRESTY_DIR=/opt/openresty")
  end

  it "should expose http port(nginx with redis)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("80/tcp")).to be true
  end

  it "should expose http port(nginx with lua)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("27989/tcp")).to be true
  end

  it "should expose http port(monit)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("2812/tcp")).to be true
  end

  it "should have CMD" do
    expect(@image.json["Config"]["Cmd"]).to include("/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc")
  end

end

# ---------

describe command("docker -H ':5432' ps -a --no-trunc") do

  its(:stdout) { should match /openresty/ }

end

# ---------

describe command("docker -H ':5432' exec openresty test -f /etc/init.d/nginx") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec openresty openssl sha1 /etc/init.d/nginx | awk '{print $NF}'") do

  its(:stdout) { should match /^a8cbbc5c53ee609e0e1ebf2b3b564272bd1b7e32$/ }

end

describe command("docker -H ':5432' exec openresty stat --printf=%a /etc/init.d/nginx") do

  its(:stdout) { should match /755/ }

end

# ---------

describe command("docker -H ':5432' exec openresty test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec openresty openssl sha1 /etc/monit/conf.d/monit.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^a68b77f4a6a56c3a91735896aca9aa2d5cfd080e$/ }

end

describe command("docker -H ':5432' exec openresty test -f /etc/monit/conf.d/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec openresty openssl sha1 /etc/monit/conf.d/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^4c3e0bab8e3fdd37edd90720ae4c193e61204f22$/ }

end

describe command("docker -H ':5432' exec openresty test -f /etc/monit/conf.d/redis.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec openresty openssl sha1 /etc/monit/conf.d/redis.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^85b0d377141481dc1ad97e06b5a8f4c1303647e8$/ }

end

# ---------

describe command("docker -H ':5432' exec openresty test -f /etc/nginx/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec openresty openssl sha1 /etc/nginx/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^c144b712f51b8cfcb4d77e0a9a1fd9905997a633$/ }

end

# ---------

describe command("docker -H ':5432' exec openresty test -f /etc/nginx/conf.d/redict.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec openresty openssl sha1 /etc/nginx/conf.d/redirect.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^39fd62f9cd9caeceb545e0bb123266368e91bbdc$/ }

end

# ---------

describe command("docker -H ':5432' exec openresty /bin/bash -c 'echo set foo www.google.com | redis-cli -s /var/run/redis/redis.sock --pipe > /dev/null 2>&1'; curl --location --silent --header 'Host: foo' --head http://localhost:10080 --output /dev/null --write-out '%{http_code}'") do


  its(:stdout) { should eq '200' }

end

describe command("curl --location --silent --header 'Host: bar' --head http://localhost:10080 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '404' }

end

# ---------

describe command("curl --silent http://localhost:37989") do

  its(:stdout) { should include 'Lua Module works!' }

end

#------

describe command("curl --silent http://localhost:12812 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:12812") do

  its(:stdout) { should include 'Monit Service Manager' }

end
