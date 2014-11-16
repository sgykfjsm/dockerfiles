require "spec_helper"
require "json"

describe "sgykfjsm/norikra Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/norikra:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=norikra")
  end

  it "should have environmental NORIKRA_DIR" do
    expect(@image.json["Config"]["Env"]).to include("NORIKRA_DIR=/opt/norikra")
  end

  it "should have environmental PATH" do
    expect(@image.json["Config"]["Env"]).to include("PATH=/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")
  end

  it "should expose http port(norikra)" do
    expect(@image.json["Config"]["ExposedPorts"].has_key?("26578/tcp")).to be true
  end

end

#------

describe command("docker -H ':5432' ps -a --no-trunc --filter status=running") do

  its(:stdout) { should match /norikra/ }

end

#------

describe command("docker -H ':5432' exec norikra pidof norikra") do

  its(:exit_status) { should eq 0 }

end

#------

describe command("curl --silent --head http://localhost:46578 --output /dev/null --write-out '%{http_code}'") do

  its(:stdout) { should eq '200' }

end

describe command("curl --silent http://localhost:46578") do

  its(:stdout) { should include 'Norikra' }

end

