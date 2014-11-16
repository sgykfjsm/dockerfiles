require "spec_helper"

describe "sgykfjsm/ruby Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/ruby:latest"
        }
        @i
      }
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=ruby")
  end

  it "should have environmental SHELL" do
    expect(@image.json["Config"]["Env"]).to include("SHELL=/bin/bash")
  end

  it "should have environmental RUBY_VERSION" do
    expect(@image.json["Config"]["Env"]).to include("RUBY_VERSION=2.1.4")
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

  its(:stdout) { should match /ruby/ }

end

#------

# default ruby command should be pure ruby
describe command("docker -H ':5432' exec ruby ruby --version") do

  its(:stdout) { should match /ruby 2.1.4/ }

end

# i have other ruby.
describe command("docker -H ':5432' exec ruby rbenv versions") do

  its(:stdout) { is_expected.to include 'system', '2.1.4' }

end

