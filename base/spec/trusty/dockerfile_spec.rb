require "spec_helper"
require 'json'

describe "sgykfjsm/ubuntu Images" do

  before(:all) do
      @image = Docker::Image.all.find {|image|
        @i = image.info["RepoTags"].find { |tag|
          tag == "sgykfjsm/base_ubuntu:latest"
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

  it "should have environmental CONTAINER_NAME" do
    expect(@image.json["Config"]["Env"]).to include("CONTAINER_NAME=base")
  end

  it "should have environmental LANG" do
    expect(@image.json["Config"]["Env"]).to include("LANG=en_US.UTF-8")
  end

  it "should have environmental LC_ALL" do
    expect(@image.json["Config"]["Env"]).to include("LC_ALL=en_US.UTF-8")
  end

end

#------

describe command("docker -H ':5432' exec base_ubuntu test -f /etc/security/limits.d/fd.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec base_ubuntu cat /etc/security/limits.d/fd.conf") do

  its(:stdout) {
    is_expected.to include 'root soft nofile 65536',
      'root hard nofile 65536',
      '* soft nofile 65536',
      '* hard nofile 65536'
  }

end

#------

describe command("docker -H ':5432' exec base_ubuntu test -f /etc/sysctl.d/params.conf") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec base_ubuntu cat /etc/sysctl.d/params.conf") do

  its(:stdout) {
    is_expected.to include 'net.ipv4.tcp_tw_recycle = 1',
      'net.ipv4.tcp_tw_reuse = 1',
      'net.ipv4.ip_local_port_range = 10240    65535'
  }

end

#------

describe command("docker -H ':5432' exec base_ubuntu test -f /etc/initscript") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec base_ubuntu cat /etc/initscript") do

  its(:stdout) { is_expected.to include 'ulimit -n 65536', 'eval exec "$4"' }

end

#------

describe command("docker -H ':5432' exec base_ubuntu /bin/bash -c 'ulimit -n'") do

  its(:stdout) { is_expected.not_to match /1024/ }

end

#------

describe command("docker -H ':5432' exec base_ubuntu test -f /etc/resolvconf/resolv.conf.d/base") do

  its(:exit_status) { should eq 0 }

end

describe command("docker -H ':5432' exec base_ubuntu cat /etc/resolvconf/resolv.conf.d/base") do

  its(:stdout) { is_expected.to include 'nameserver 8.8.8.8' }

end


