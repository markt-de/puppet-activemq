require 'spec_helper'
describe 'activemq' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:activemq_checksum) { 'a73331cb959bb0ba9667414682c279bc9ce2aec4c8fecbcdee4670bf9d63bf66010c8c55a6b727b1ad6d51bbccadd663b96a70b867721d9388d54a9391c6af85' }
      let(:activemq_password) { 'seCReT' }
      let(:activemq_user) { 'admin' }
      let(:activemq_version) { '2.23.1' }

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
