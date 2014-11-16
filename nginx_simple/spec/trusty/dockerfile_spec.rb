require "spec_helper"

#------

describe "sgykfjsm/nginx Images" do

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

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=nginx")
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

# ---------

describe command("docker -H ':5432' ps -a --no-trunc") do

  its(:stdout) { should match /nginx/ }

end

# ---------

describe command("docker -H ':5432' exec nginx test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/nginx/g' docker/nginx/etc_monit_conf.d_monit.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/monit/conf.d/monit.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^e4103eb613eecd4a39a38696a7155a8ac6641070$/}

end

describe command("docker -H ':5432' exec nginx test -f /etc/monit/conf.d/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/nginx/g' docker/nginx/etc_monit_conf.d_nginx.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/monit/conf.d/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^62e1bcbfb73b6cfcd0ce5cb965900ba43ba8eb21$/ }

end

# ---------

describe command("docker -H ':5432' exec nginx test -f /etc/nginx/nginx/nginx.conf") do

  its(:exit_status) { should eq 0 }

end

# openssl sha1 docker/nginx/etc_nginx_nginx.conf | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/nginx/nginx.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^d3eef5eeccf517f9fced271262ecded7c30d96a0$/ }

end

# ---------

describe command("docker -H ':5432' exec nginx test -f /etc/nginx/sites-available/default") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/nginx/g' docker/nginx/etc_nginx_sites-available_default  | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec nginx openssl sha1 /etc/nginx/sites-available/default | awk '{print $NF}'") do

  its(:stdout) { should match /^be5dc1c0d3eadef051b5d47c4fb79e25954bc274$/ }

end

#------

describe command("curl --silent --head http://localhost:10080 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:10080") do

  its(:stdout) { should include 'ok' }

end

#------

describe command("curl --silent http://localhost:12812 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:12812") do

  its(:stdout) { should include 'Monit Service Manager' }

end

#------
