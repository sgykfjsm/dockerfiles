require "spec_helper"

describe "sgykfjsm/td-agent Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/td-agent:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=td")
  end

  it "should have environmental NORIKRA_DIR" do
    expect(@image.json["Config"]["Env"]).to include("NORIKRA_DIR=/opt/norikra")
  end

  it "should have environmental PATH" do
    expect(@image.json["Config"]["Env"]).to include("PATH=/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/td-agent/embedded/bin:/opt/td-agent/bin")
  end

  it "should expose http port(monit)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("2812/tcp")).to be true
  end

  it "should expose http port(norikra)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("26578/tcp")).to be true
  end

end

#------

describe command("docker -H ':5432' ps -a --no-trunc --filter status=running") do

  its(:stdout) { should match /td-agent/ }

end

#------

describe command("docker -H ':5432' exec td-agent test -d /var/log/monit") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec td-agent test -f /etc/monit/conf.d/monit.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec td-agent openssl sha1 /etc/monit/conf.d/monit.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^bb0bc9ad6f00aa0b9ab9f16ef103979b009243e6$/ }

end

#------

describe command("docker -H ':5432' exec td-agent test -f /etc/monit/conf.d/td.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec td-agent openssl sha1 /etc/monit/conf.d/td.conf | awk '{print $NF}'") do

  its(:stdout) { should match /^883f59e5a52bef32510427645e5857bc84ffd917$/ }

end

#------

describe command("docker -H ':5432' exec td-agent pidof td-agent") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec td-agent fluent-gem list") do

  its(:stdout) { should include 'norikra-client' }

end

#------

describe command("curl --silent http://localhost:12812 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:12812") do

  its(:stdout) { should include 'Monit Service Manager' }

end

#------

describe command("curl --silent --head http://localhost:46578 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:46578") do

  its(:stdout) { should include 'Norikra' }

end

