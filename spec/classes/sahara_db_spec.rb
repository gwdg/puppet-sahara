require 'spec_helper'

describe 'sahara::db' do

  shared_examples 'sahara::db' do
    context 'with default parameters' do
      it { is_expected.to contain_sahara_config('database/db_max_retries').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_sahara_config('database/connection').with_value('mysql+pymysql://sahara:secrete@localhost:3306/sahara').with_secret(true) }
      it { is_expected.to contain_sahara_config('database/idle_timeout').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_sahara_config('database/min_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_sahara_config('database/max_retries').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_sahara_config('database/retry_interval').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_sahara_config('database/max_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_sahara_config('database/max_overflow').with_value('<SERVICE DEFAULT>') }
    end

    context 'with specific parameters' do
      let :params do
        { :database_db_max_retries => '-1',
          :database_connection     => 'mysql+pymysql://sahara:sahara@localhost/sahara',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_max_pool_size  => '11',
          :database_max_overflow   => '21',
        }
      end

      it { is_expected.to contain_sahara_config('database/db_max_retries').with_value('-1') }
      it { is_expected.to contain_sahara_config('database/connection').with_value('mysql+pymysql://sahara:sahara@localhost/sahara').with_secret(true) }
      it { is_expected.to contain_sahara_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_sahara_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_sahara_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_sahara_config('database/retry_interval').with_value('11') }
      it { is_expected.to contain_sahara_config('database/max_pool_size').with_value('11') }
      it { is_expected.to contain_sahara_config('database/max_overflow').with_value('21') }
    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection => 'mysql://sahara:sahara@localhost/sahara' }
      end

      it { is_expected.to contain_sahara_config('database/connection').with_value('mysql://sahara:sahara@localhost/sahara').with_secret(true) }
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://sahara:sahara@localhost/sahara', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'sqlite://sahara:sahara@localhost/sahara', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'foo+pymysql://sahara:sahara@localhost/sahara', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => 'jessie',
      })
    end

    it_configures 'sahara::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://sahara:sahara@localhost/sahara' }
      end

      it { is_expected.to contain_package('db_backend_package').with({ :ensure => 'present', :name => 'python-pymysql' }) }
    end

  end

  context 'on Redhat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat',
        :operatingsystemrelease => '7.1',
      })
    end

    it_configures 'sahara::db'

    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://sahara:sahara@localhost/sahara' }
      end

      it { is_expected.not_to contain_package('db_backend_package') }
    end
  end

end
