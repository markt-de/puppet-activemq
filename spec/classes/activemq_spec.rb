require 'spec_helper'
describe 'activemq' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:activemq_checksum) { '84b5a65d8eb2fc8cf3f17df524d586b0c6a2acfa9a09089d5ffdfc1323ff99dfdc775b2e95eec264cfeddc4742839ba9b0f3269351a5c955dd4bbf6d5ec5dfa9' }
      let(:activemq_password) { 'seCReT' }
      let(:activemq_user) { 'admin' }
      let(:activemq_version) { '2.14.0' }

      context 'with default parameters' do
        let :params do
          {
            admin_password: activemq_password.to_s,
            admin_user: activemq_user.to_s,
            checksum: activemq_checksum.to_s,
            cluster: false,
            version: activemq_version.to_s,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('activemq') }
        it { is_expected.to contain_class('activemq::install') }
        it { is_expected.to contain_class('activemq::service') }
      end

      context 'with multiple instances' do
        let :params do
          {
            admin_password: activemq_password.to_s,
            admin_user: activemq_user.to_s,
            checksum: activemq_checksum.to_s,
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
            version: activemq_version.to_s,
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
