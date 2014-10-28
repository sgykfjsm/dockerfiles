require "spec_helper"
require 'json'

describe "sgykfjsm/nginx_ubuntu Images" do
  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/nginx_ubuntu:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

# ENV DEBIAN_FRONTEND noninteractive
# ENV CONTAINER_NAME app1
# ENV LC_ALL en_US.UTF-8
  it "should have environmental DEBIAN_FRONTEND" do
    expect(@image.json["Config"]["Env"]).to include("DEBIAN_FRONTEND=noninteractive")
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=app1")
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
