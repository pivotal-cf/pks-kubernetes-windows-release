# frozen_string_literal: true

require 'rspec'
require 'spec_helper'


describe 'docker pre-start' do
  let(:link_spec) do {
      'docker' => {
          'instances' => [],
          'properties' => {
              'env' => {
                  'http_proxy'  => "http://user:pa$word@127.0.0.1:1234",
                  'https_proxy' => "https://user:pa$word@127.0.0.1:1234",
                  'no_proxy' => "https://user:noproxy:1234",
              }
          },
      }
  }
  end

  let(:rendered_template) do
    # compiled_template(job_name, template_name, manifest_properties = {}, links = {},
    # network_properties = [], az = '', ip = '', id = '', instance_name: '')
    compiled_template('docker-windows', 'pre-start.ps1', {}, link_spec, {}, 'z1', 'fake-bosh-ip', 'fake-bosh-id')
  end

  it 'sets proxy env values' do
    expect(rendered_template).to include('[System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://user:pa$word@127.0.0.1:1234", "User")')
    expect(rendered_template).to include('[System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "https://user:pa$word@127.0.0.1:1234", "User")')
    expect(rendered_template).to include('[System.Environment]::SetEnvironmentVariable("NO_PROXY", "https://user:noproxy:1234", "User")')
  end
end
