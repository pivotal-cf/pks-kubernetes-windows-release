# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

describe 'docker_pre-start' do
  let(:link_spec) do {
      'docker' => {
          'instances' => [],
          'properties' => {
              'env' => {
                  'http_proxy'  => "http://user:pa$word@127.0.0.1:1234",
                  'https_proxy' => "https://user:pa$word@127.0.0.1:1234",
              }
          }
      },
  }
  end

  let(:rendered_template) do
    compiled_template('docker-windows', 'bin/pre-start.ps1', {}, link_spec, {}, 'z1', 'fake-bosh-ip', 'fake-bosh-id')
  end

  it 'configures the proxy' do
    expect(rendered_template).to include('SetX HTTP_PROXY "http://user:pa$word@127.0.0.1:1234" /m')
  end

end
