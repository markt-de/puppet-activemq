require 'spec_helper'

ACTIVEMQ_VERSION = '2.23.1'.freeze
ACTIVEMQ_VERSION_CHKSUM = 'a73331cb959bb0ba9667414682c279bc9ce2aec4c8fecbcdee4670bf9d63bf66010c8c55a6b727b1ad6d51bbccadd663b96a70b867721d9388d54a9391c6af85'.freeze
# ACTIVEMQ_VERSION = '2.29.0'.freeze
# ACTIVEMQ_VERSION_CHKSUM = 'b78ed2541a2dd4d3fb8c73032e8526d954bca1089e9c7795815f1321901a1ca97358721acde61bebe11fd057377668691e3d3eaf414d32a72501f97ab6f7facd'.freeze

describe 'activemq' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:activemq_instance_name) { 'activemq' }
      let(:activemq_password) { 'seCReT' }
      let(:activemq_user) { 'admin' }

      context 'a standalone instance with default parameters' do
        let(:params) do
          {
            admin_password: activemq_password.to_s,
            admin_user: activemq_user.to_s,
            checksum: ACTIVEMQ_VERSION_CHKSUM.to_s,
            cluster: false,
            instances: {
              'activemq': {},
            },
            version: ACTIVEMQ_VERSION.to_s,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('activemq') }
        it { is_expected.to contain_class('activemq::install') }
        it { is_expected.to contain_class('activemq::service') }

        it { is_expected.to contain_activemq__instance(activemq_instance_name.to_s) }
        it {
          is_expected.to contain_service("activemq@#{activemq_instance_name}").with(
            enable: true,
            ensure: 'running',
          )
        }

        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to('Class[activemq::install]') }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File[instance #{activemq_instance_name} broker.xml]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File[instance #{activemq_instance_name} management.xml]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File[instance #{activemq_instance_name} bootstrap.xml]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File[instance #{activemq_instance_name} login.config]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File_line[instance #{activemq_instance_name} set HAWTIO_ROLE]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File_line[instance #{activemq_instance_name} set JAVA_ARGS]") }

        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires('Class[activemq::install]') }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File[instance #{activemq_instance_name} broker.xml]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File[instance #{activemq_instance_name} management.xml]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File[instance #{activemq_instance_name} bootstrap.xml]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File[instance #{activemq_instance_name} login.config]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File_line[instance #{activemq_instance_name} set HAWTIO_ROLE]") }
        it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File_line[instance #{activemq_instance_name} set JAVA_ARGS]") }

        if Gem::Version.new(ACTIVEMQ_VERSION.to_s) >= Gem::Version.new('2.27.0')
          it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File[instance #{activemq_instance_name} log4j2.properties]") }
          it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File[instance #{activemq_instance_name} log4j2.properties]") }
        else
          it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_subscribes_to("File[instance #{activemq_instance_name} logging.properties]") }
          it { is_expected.to contain_service("activemq@#{activemq_instance_name}").that_requires("File[instance #{activemq_instance_name} logging.properties]") }
        end
      end

      context 'with multiple instances' do
        let(:params) do
          {
            admin_password: activemq_password.to_s,
            admin_user: activemq_user.to_s,
            checksum: ACTIVEMQ_VERSION_CHKSUM.to_s,
            cluster: false,
            instances: {
              instance1: {
                bind: 'localhost',
                port: 61_616,
                web_port: 8161,
                acceptors: {
                  artemis: {
                    port: 61_616,
                  },
                  amqp: {
                    port: 5672,
                  },
                },
              },
              instance2: {
                bind: 'localhost',
                port: 62_616,
                web_port: 8261,
                acceptors: {
                  artemis: {
                    port: 62_616,
                  },
                  amqp: {
                    port: 5772,
                  },
                },
              },
              instance3: {
                bind: 'localhost',
                port: 63_616,
                web_port: 8361,
                acceptors: {
                  artemis: {
                    port: 63_616,
                  },
                  amqp: {
                    port: 5872,
                  },
                },
              },
            },
            version: ACTIVEMQ_VERSION.to_s,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_activemq__instance('instance1') }
        it { is_expected.to contain_activemq__instance('instance2') }
        it { is_expected.to contain_activemq__instance('instance3') }
      end
    end
  end
end
