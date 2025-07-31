require 'spec_helper_acceptance'

RSpec::Matchers.define_negated_matcher :not_match, :match

describe 'activemq' do
  let(:activemq_checksum) { 'a73331cb959bb0ba9667414682c279bc9ce2aec4c8fecbcdee4670bf9d63bf66010c8c55a6b727b1ad6d51bbccadd663b96a70b867721d9388d54a9391c6af85' }
  let(:activemq_group) { 'activemq' }
  let(:activemq_instance_base) { '/var/lib/activemq-brokers' }
  let(:activemq_instance_name) { 'instance1' }
  let(:activemq_instance_password) { 'seCReT' }
  let(:activemq_instance_user) { 'admin' }
  let(:activemq_user) { 'activemq' }
  let(:activemq_version) { '2.23.1' }

  before(:all) do
    apply_manifest(%(
      if ($facts['os']['family'] == 'Debian') {
        $target_path = '/usr/lib/jvm'
      } else {
        $target_path = '/usr/java'
      }

      package { 'bzip2':
        ensure => 'present',
      }

      java::adopt { 'jdk11':
        ensure        => 'present',
        java          => 'jdk',
        version_major => '11.0.6',
        version_minor => '10',
      }
      -> file { '/usr/bin/java':
        ensure => link,
        target => "${target_path}/jdk-11.0.6+10/bin/java",
      }
    ), catch_failures: true)
  end

  context 'when installing one instance' do
    let(:pp) do
      %(class { 'activemq':
        admin_password => '#{activemq_instance_password}',
        admin_user => '#{activemq_instance_user}',
        checksum => '#{activemq_checksum}',
        cluster => true,
        cluster_password => '#{activemq_instance_password}',
        cluster_user => '#{activemq_instance_user}',
        cluster_name => 'activemq-cluster',
        cluster_topology => {
          '#{activemq_instance_name}' => {
            target_host => 'localhost',
            bind => '127.0.0.1',
          },
          'instance2' => {
            target_host => 'localhost',
            bind => '127.0.0.2',
          }
        },
        server_discovery => 'static',
        download_url => 'http://archive.apache.org/dist/activemq/activemq-artemis/#{activemq_version}/%s',
        instances => {
          '#{activemq_instance_name}' => {
            bind => '127.0.0.1',
            port => 61616,
            web_port => 8161,
            ha_policy => 'live-only',
            acceptors => {
              artemis => { port => 61616 },
              amqp => { port => 5672 },
            },
          },
        },
        version => '#{activemq_version}',
      })
    end

    it { apply_manifest(pp, catch_failures: true) }

    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}")).to be_directory }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}")).to be_owned_by activemq_user }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}")).to be_grouped_into activemq_group }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}")).to be_mode 755 }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc")).to be_directory }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc/broker.xml")).to be_mode 640 }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc/management.xml")).to be_mode 640 }

    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc/artemis.profile").content).to match(%r{^HAWTIO_ROLE}) }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc/artemis.profile").content).to match(%r{^ARTEMIS_HOME}) }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc/artemis.profile").content).to match(%r{^JAVA_ARGS}) }

    # Test that 'artemis-instance1' is not in the static-connectors list
    it {
      expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc/broker.xml").content.gsub(%r{.*<static-connectors[^>]*>(.*)</static-connectors>.*}ms, '\1'))
        .to match(%r{instance2})
        .and not_match(%r{:activemq_instance_name})
    }
    it { expect(file("#{activemq_instance_base}/#{activemq_instance_name}/etc/broker.xml").content).to match(%r{allow-direct-connections-only="false"}) }

    it 'sets up the service' do
      expect(service("activemq@#{activemq_instance_name}")).to be_running
      expect(service("activemq@#{activemq_instance_name}")).to be_enabled
    end
  end
end
