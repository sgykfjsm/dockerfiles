require "spec_helper"

describe "sgykfjsm/jruby Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/jruby:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=jruby")
  end

  it "should have environmental SHELL" do
    expect(@image.json["Config"]["Env"]).to include("SHELL=/bin/bash")
  end

  it "should have environmental JRUBY_VERSION" do
    expect(@image.json["Config"]["Env"]).to include("JRUBY_VERSION=jruby-1.7.16")
  end

  it "should have environmental RBENV_ROOT" do
    expect(@image.json["Config"]["Env"]).to include("RBENV_ROOT=/usr/local/rbenv")
  end

  it "should have environmental PATH" do
    expect(@image.json["Config"]["Env"]).to include("PATH=/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")
  end

end

#------

describe command("docker -H ':5432' ps -a --no-trunc --filter status=running") do

  its(:stdout) { should match /jruby/ }

end

#------

# default ruby command should be pure ruby
describe command("docker -H ':5432' exec jruby ruby --version") do

  its(:stdout) { should match /jruby 1.7.16/ }

end

# i have other ruby.
describe command("docker -H ':5432' exec jruby rbenv versions") do

  its(:stdout) { is_expected.to include 'system', '* jruby-1.7.16' }

end

