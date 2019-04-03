# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

def get_node_labels(rendered_kubelet_ctl)
  node_labels = rendered_kubelet_ctl.split("\n").select { |line| line[/--node-labels=/i] }
  expect(node_labels.length).to be(1)
  labels = node_labels[0].match(/--node-labels=(.*) `/).captures[0]
  labels.split(",")
end

describe 'kubelet_ctl' do
  let(:rendered_template) do
    compiled_template('kubelet-windows', 'bin/kubelet_ctl.ps1', {}, {}, {}, 'z1', 'fake-bosh-ip', 'fake-bosh-id')
  end

  it 'labels the kubelet with its own az' do
    expect(rendered_template).to include(',bosh.zone=z1')
  end

  it 'labels the kubelet with the spec ip' do
    expect(rendered_template).to include('spec.ip=fake-bosh-ip')
  end

  it 'labels the kubelet with the bosh id' do
    expect(rendered_template).to include(',bosh.id=fake-bosh-id')
  end

  it 'labels the kubelet with custom labels' do
    manifest_properties = {
      'k8s-args' => {
        'node-labels' => 'foo=bar,k8s.node=custom'
      }
    }
    rendered_kubelet_ctl = compiled_template('kubelet-windows', 'bin/kubelet_ctl.ps1', manifest_properties, {}, {}, 'z1', 'fake-bosh-ip', 'fake-bosh-id')
    labels = get_node_labels(rendered_kubelet_ctl)

    expect(labels).to include('bosh.zone=z1')
    expect(labels).to include('spec.ip=fake-bosh-ip')
    expect(labels).to include('bosh.id=fake-bosh-id')
    expect(labels).to include('k8s.node=custom')
    expect(labels).to include('foo=bar')
  end

  it 'labels the kubelet with default labels' do
    manifest_properties = {
      'k8s-args' => {
      }
    }
    rendered_kubelet_ctl = compiled_template('kubelet-windows', 'bin/kubelet_ctl.ps1', manifest_properties, {}, {}, 'z1', 'fake-bosh-ip', 'fake-bosh-id')
    labels = get_node_labels(rendered_kubelet_ctl)

    expect(labels).to include('bosh.zone=z1')
    expect(labels).to include('spec.ip=fake-bosh-ip')
    expect(labels).to include('bosh.id=fake-bosh-id')
  end
end
