require 'spec_helper'

describe "sgykfjsm/play-scala-intro Images" do

  before(:all) do
    @image = Docker::Image.all.find { | image |
      @i = image.info["RepoTags"].find { | tag |
        tag == "sgykfjsm/play-scala-intro:latest"
      }
      @i
    }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=play-scala-intro")
  end

  it "should expose tcp port(play)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("9000/tcp")).to be true
  end

  it "should expose tcp port(monit)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("2812/tcp")).to be true
  end

  it "should have CMD" do
    expect(@image.json["Config"]["Cmd"]).to include("/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc")
  end

end

describe command("docker -H ':5432' ps -a --no-trunc --filter status=running") do

  its(:stdout) { should match /play/ }

end

describe command("docker -H ':5432' exec play-scala-intro test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/play-scala-intro/g' docker/etc/monit/conf.d/monit.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec play-scala-intro openssl sha1 /etc/monit/conf.d/monit.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^46aa5dab90ef96354c4970b6ac07f6a575a0392c$/ }

end

describe command("docker -H ':5432' exec play-scala-intro test -f /etc/monit/conf.d/application.conf") do

  its(:exit_status) { should eq 0 }

end

# sed -e 's/%CONTAINER_NAME%/play/g' docker/etc/monit/conf.d/application.conf | openssl sha1 | awk '{print $NF}'
describe command("docker -H ':5432' exec play-scala-intro openssl sha1 /etc/monit/conf.d/application.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^27119f9fdbb43c8d549c400544445e86bb32299a$/ }

end

describe command("curl --silent --head http://localhost:10080 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:10080") do

  its(:stdout) { should include 'Welcome to Play' }

end

describe command("curl --silent http://localhost:12812 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:12812") do

  its(:stdout) { should include 'Monit Service Manager' }

end
