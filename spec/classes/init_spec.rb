require 'spec_helper'
describe 'pam' do

  describe 'packages' do

    context 'with class defaults on osfamily redhat with lsbmajdistrelease 5' do
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end

      it do
        should contain_package('pam_package').with({
          'ensure' => 'installed',
          'name'   => ['pam', 'util-linux'],
        })
      end
    end

    context 'with class defaults on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end

      it do
        should contain_package('pam_package').with({
          'ensure' => 'installed',
          'name'   => 'pam',
        })
      end
    end

    context 'with class defaults on osfamily suse with lsbmajdistrelease 11' do
      let :facts do
        {
          :osfamily          => 'Suse',
          :lsbmajdistrelease => '11',
        }
      end

      it do
        should contain_package('pam_package').with({
          'ensure' => 'installed',
          'name'   => 'pam',
        })
      end
    end

    context 'with class defaults on osfamily suse with lsbmajdistrelease 9' do
      let :facts do
        {
          :osfamily          => 'Suse',
          :lsbmajdistrelease => '9',
        }
      end

      it do
        should contain_package('pam_package').with({
          'ensure' => 'installed',
          'name'   => ["pam", "pam-modules"],
        })
      end
    end

    context 'with class defaults on osfamily suse with lsbmajdistrelease 10' do
      let :facts do
        {
          :osfamily          => 'Suse',
          :lsbmajdistrelease => '10',
        }
      end

      it do
        should contain_package('pam_package').with({
          'ensure' => 'installed',
          'name'   => 'pam',
        })
      end
    end

    context 'with specifying package_name on valid platform' do
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end

      let(:params) { {:package_name => 'foo'} }

      it do
        should contain_package('pam_package').with({
          'ensure' => 'installed',
          'name'   => 'foo',
        })
      end
    end
  end

  describe 'config files' do

    context 'with specifying services' do
      let (:params) { {:services => { 'testservice' => { 'content' => 'foo' } } } }
      let :facts do
        {
          :osfamily          => 'Suse',
          :lsbmajdistrelease => '9',
        }
      end
      it do
        should contain_file('pam.d-service-testservice').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/testservice',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam.d-service-testservice').with_content('foo')
      end
    end

    context 'defaults on osfamily redhat with lsbmajdistrelease 5' do
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end

      it do
        should contain_file('pam_system_auth_ac').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/system-auth-ac',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_system_auth_ac').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
# Auth
auth        required      pam_env.so
auth        sufficient    pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 500 quiet
auth        required      pam_deny.so

# Account
account     required      pam_unix.so
account     sufficient    pam_succeed_if.so uid < 500 quiet
account     required      pam_permit.so

# Password
password    requisite     pam_cracklib.so try_first_pass retry=3
password    sufficient    pam_unix.so md5 shadow nullok try_first_pass use_authtok
password    required      pam_deny.so

# Session
session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
")

      should contain_file('pam_system_auth').with({
        'ensure' => 'symlink',
        'path'   => '/etc/pam.d/system-auth',
        'owner'  => 'root',
        'group'  => 'root',
      })

      should contain_file('pam_d_login').with({
        'ensure' => 'file',
        'path'   => '/etc/pam.d/login',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('pam_d_login').with_content("#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
account    required     pam_access.so
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    optional     pam_keyinit.so force revoke
session    required     pam_loginuid.so
session    include      system-auth
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
")

      should contain_file('pam_d_sshd').with({
        'ensure' => 'file',
        'path'   => '/etc/pam.d/sshd',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('pam_d_sshd').with_content("#%PAM-1.0
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
account    required     pam_access.so
password   include      system-auth
session    optional     pam_keyinit.so force revoke
session    include      system-auth
session    required     pam_loginuid.so
")
      end
    end

    context 'defaults on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end

      it do
        should contain_file('pam_system_auth_ac').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/system-auth-ac',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      should contain_file('pam_system_auth_ac').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
# Auth
auth        required      pam_env.so
auth        sufficient    pam_fprintd.so
auth        sufficient    pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 500 quiet
auth        required      pam_deny.so

# Account
account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 500 quiet
account     required      pam_permit.so

# Password
password    requisite     pam_cracklib.so try_first_pass retry=3 type=
password    sufficient    pam_unix.so md5 shadow nullok try_first_pass use_authtok
password    required      pam_deny.so

# Session
session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
")

        should contain_file('pam_system_auth').with({
         'ensure' => 'symlink',
         'path'   => '/etc/pam.d/system-auth',
         'owner'  => 'root',
         'group'  => 'root',
       })

       should contain_file('pam_d_login').with({
         'ensure' => 'file',
         'path'   => '/etc/pam.d/login',
         'owner'  => 'root',
         'group'  => 'root',
         'mode'   => '0644',
       })
      should contain_file('pam_d_login').with_content("#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
account    required     pam_access.so
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
-session   optional     pam_ck_connector.so
")

        should contain_file('pam_d_sshd').with({
         'ensure' => 'file',
         'path'   => '/etc/pam.d/sshd',
         'owner'  => 'root',
         'group'  => 'root',
         'mode'   => '0644',
       })
      should contain_file('pam_d_sshd').with_content("#%PAM-1.0
auth       required     pam_sepermit.so
auth       include      password-auth
account    required     pam_access.so
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    optional     pam_keyinit.so force revoke
session    include      password-auth
")
      end
    end

    context 'with class defaults on Ubuntu 12.04 LTS' do
      let :facts do
        {
          :operatingsystem   => 'Ubuntu',
          :osfamily          => 'Debian',
          :lsbmajdistrelease => '12',
        }
      end

      it do
        should contain_package('pam_package').with({
          'ensure' => 'installed',
          'name'   => 'libpam0g',
        })
      end

      it do
        should contain_file('pam_common_auth').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-auth',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      should contain_file('pam_common_auth').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
auth  [success=1 default=ignore]  pam_unix.so nullok_secure
auth  requisite     pam_deny.so
auth  required      pam_permit.so
")

      should contain_file('pam_common_account').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-account',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      should contain_file('pam_common_account').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
account [success=1 new_authtok_reqd=done default=ignore]  pam_unix.so
account requisite     pam_deny.so
account required      pam_permit.so
")

      should contain_file('pam_common_password').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-password',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      should contain_file('pam_common_password').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
password  [success=1 default=ignore]  pam_unix.so obscure sha512
password  requisite     pam_deny.so
password  required      pam_permit.so
")

      should contain_file('pam_common_session').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-session',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      should contain_file('pam_common_session').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
session [default=1]   pam_permit.so
session requisite     pam_deny.so
session required      pam_permit.so
session optional      pam_umask.so
session required      pam_unix.so
")

      should contain_file('pam_d_login').with({
        'ensure' => 'file',
        'path'   => '/etc/pam.d/login',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('pam_d_login').with_content("auth     optional   pam_faildelay.so  delay=3000000
auth     [success=ok new_authtok_reqd=ok ignore=ignore user_unknown=bad default=die] pam_securetty.so
auth     requisite  pam_nologin.so
session  [success=ok ignore=ignore module_unknown=ignore default=bad] pam_selinux.so close
session  required   pam_env.so readenv=1
session  required   pam_env.so readenv=1 envfile=/etc/default/locale
@include common-auth
auth     optional   pam_group.so
session  required   pam_limits.so
session  optional   pam_lastlog.so
session  optional   pam_motd.so
session  optional   pam_mail.so standard
@include common-account
@include common-session
@include common-password
session  [success=ok ignore=ignore module_unknown=ignore default=bad] pam_selinux.so open
")

      should contain_file('pam_d_sshd').with({
        'ensure' => 'file',
        'path'   => '/etc/pam.d/sshd',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('pam_d_sshd').with_content("auth       required     pam_env.so # [1]
auth       required     pam_env.so envfile=/etc/default/locale
@include common-auth
account    required     pam_nologin.so
@include common-account
@include common-session
session    optional     pam_motd.so # [1]
session    optional     pam_mail.so standard noenv # [1]
session    required     pam_limits.so
@include common-password
")
      end
    end

    context 'defaults on osfamily suse with lsbmajdistrelease 9' do
      let :facts do
        {
          :osfamily          => 'Suse',
          :lsbmajdistrelease => '9',
        }
      end

      it do
        should contain_file('pam_other').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/other',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_other').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
# Auth
auth     required pam_warn.so
auth     required pam_unix2.so  #nullok set_setrpc

# Account
account  required pam_warn.so
account  required pam_unix2.so

# Password
password required pam_warn.so
password required pam_pwcheck.so  use_cracklib

# Session
session  required pam_warn.so
session  required pam_unix2.so  debug # none or trace
")
      end
    end

    context 'defaults on osfamily suse with lsbmajdistrelease 10' do
      let :facts do
        {
          :osfamily          => 'Suse',
          :lsbmajdistrelease => '10',
        }
      end

      it do
        should contain_file('pam_common_auth').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-auth',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_common_auth').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
auth    required    pam_env.so
auth    required    pam_unix2.so
")

        should contain_file('pam_common_account').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-account',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_common_account').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
account    required    pam_unix2.so
")

        should contain_file('pam_common_password').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-password',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
         })
        should contain_file('pam_common_password').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
password    required    pam_pwcheck.so  nullok
password    required    pam_unix2.so  nullok use_authtok
")

        should contain_file('pam_common_session').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-session',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
         })
        should contain_file('pam_common_session').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
session    required    pam_limits.so
session    required    pam_unix2.so
")

        should contain_file('pam_d_login').with({
          'ensure' => 'file',
          'path'   => '/etc/pam.d/login',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
        should contain_file('pam_d_login').with_content("#%PAM-1.0
auth      required  pam_securetty.so
auth      include   common-auth
auth      required  pam_nologin.so
account   include   common-account
password  include   common-password
session   include   common-session
session   required  pam_lastlog.so nowtmp
session   required  pam_resmgr.so
session   optional  pam_mail.so standard
")

        should contain_file('pam_d_sshd').with({
          'ensure' => 'file',
          'path'   => '/etc/pam.d/sshd',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
        should contain_file('pam_d_sshd').with_content("#%PAM-1.0
auth     include        common-auth
auth     required       pam_nologin.so
account  include        common-account
password include        common-password
session  include        common-session
")
      end
    end

    context 'defaults on osfamily suse with lsbmajdistrelease 11' do
      let :facts do
        {
          :osfamily          => 'Suse',
          :lsbmajdistrelease => '11',
        }
      end

      it do
        should contain_file('pam_common_auth_pc').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-auth-pc',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_common_auth_pc').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
auth    required    pam_env.so
auth    required    pam_unix2.so
")

        should contain_file('pam_common_auth').with({
          'ensure' => 'symlink',
          'path'   => '/etc/pam.d/common-auth',
          'owner'  => 'root',
          'group'  => 'root',
        })

        should contain_file('pam_common_account_pc').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-account-pc',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_common_account_pc').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
account    required    pam_unix2.so
")

        should contain_file('pam_common_account').with({
          'ensure' => 'symlink',
          'path'   => '/etc/pam.d/common-account',
          'owner'  => 'root',
          'group'  => 'root',
        })

        should contain_file('pam_common_password_pc').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-password-pc',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_common_password_pc').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
password    required    pam_pwcheck.so  nullok cracklib
password   required    pam_unix2.so  nullok use_authtok
")

        should contain_file('pam_common_password').with({
          'ensure' => 'symlink',
          'path'   => '/etc/pam.d/common-password',
          'owner'  => 'root',
          'group'  => 'root',
        })

        should contain_file('pam_common_session_pc').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/common-session-pc',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_common_session_pc').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
session    required    pam_limits.so
session    required    pam_unix2.so
session    optional    pam_umask.so
")

        should contain_file('pam_common_session').with({
          'ensure' => 'symlink',
          'path'   => '/etc/pam.d/common-session',
          'owner'  => 'root',
          'group'  => 'root',
        })

        should contain_file('pam_d_login').with({
          'ensure' => 'file',
          'path'   => '/etc/pam.d/login',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
        should contain_file('pam_d_login').with_content("#%PAM-1.0
auth     requisite      pam_nologin.so
auth     [user_unknown=ignore success=ok ignore=ignore auth_err=die default=bad]        pam_securetty.so
auth     include        common-auth
account  include        common-account
account  required       pam_access.so
password include        common-password
session  required       pam_loginuid.so
session  include        common-session
session  required       pam_lastlog.so  nowtmp
session  optional       pam_mail.so standard
session  optional       pam_ck_connector.so
")

        should contain_file('pam_d_sshd').with({
          'ensure' => 'file',
          'path'   => '/etc/pam.d/sshd',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
        should contain_file('pam_d_sshd').with_content("#%PAM-1.0
auth     requisite      pam_nologin.so
auth     include        common-auth
account  required       pam_access.so
account  requisite      pam_nologin.so
account  include        common-account
password include        common-password
session  required       pam_loginuid.so
session  include        common-session
")
      end
    end

    context 'defaults on osfamily solaris with kernelrelease 5.10' do
      let :facts do
        {
          :osfamily      => 'Solaris',
          :kernelrelease => '5.10',
        }
      end

      it do
        should contain_file('pam_conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.conf',
          'owner'   => 'root',
          'group'   => 'sys',
          'mode'    => '0644',
        })
        should contain_file('pam_conf').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
# Auth
login   auth requisite          pam_authtok_get.so.1
login   auth required           pam_dhkeys.so.1
login   auth required           pam_unix_cred.so.1
login   auth required           pam_unix_auth.so.1
login   auth required           pam_dial_auth.so.1
passwd  auth required           pam_passwd_auth.so.1
other   auth requisite          pam_authtok_get.so.1
other   auth required           pam_dhkeys.so.1
other   auth required           pam_unix_cred.so.1
other   auth required           pam_unix_auth.so.1

# Account
other   account requisite       pam_roles.so.1
other   account required        pam_unix_account.so.1

# Password
other   password required       pam_dhkeys.so.1
other   password requisite      pam_authtok_get.so.1
other   password requisite      pam_authtok_check.so.1
other   password required       pam_authtok_store.so.1

# Session
other   session required        pam_unix_session.so.1
")
      end
    end
    context 'defaults on osfamily solaris with kernelrelease 5.11' do
      let :facts do
        {
          :osfamily      => 'Solaris',
          :kernelrelease => '5.11',
        }
      end

      it do
        should contain_file('pam_other').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/other',
          'owner'   => 'root',
          'group'   => 'sys',
          'mode'    => '0644',
        })
        should contain_file('pam_other').with_content("# This file is being maintained by Puppet.
# DO NOT EDIT
# Auth
auth definitive         pam_user_policy.so.1
auth requisite          pam_authtok_get.so.1
auth required           pam_dhkeys.so.1
auth required           pam_unix_auth.so.1
auth required           pam_unix_cred.so.1

# Account
account requisite       pam_roles.so.1
account definitive      pam_user_policy.so.1
account required        pam_unix_account.so.1
account required        pam_tsol_account.so.1

# Password
password definitive     pam_user_policy.so.1
password include        pam_authtok_common
password required       pam_authtok_store.so.1

# Session
session definitive      pam_user_policy.so.1
session required        pam_unix_session.so.1
")
      end
    end
    context 'with ensure_vas=present and default vas_major_version (4) on osfamily redhat with lsbmajdistrelease 5' do
      let (:params) do
        {
          :ensure_vas => 'present',
        }
      end
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end
      it do
        should contain_file('pam_system_auth_ac').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/system-auth-ac',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_system_auth_ac') \
          .with_content(/auth[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/account[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/password[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/session[\s]+required[\s]+pam_vas3.so/)
        should_not contain_file('pam_system_auth_ac').with_content(/auth[\s]+sufficient[\s]+pam_vas3.so.*store_creds/)
      end
    end
    context 'with ensure_vas=present and default vas_major_version (4) on osfamily redhat with lsbmajdistrelease 6' do
      let (:params) do
        {
          :ensure_vas => 'present',
        }
      end
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end
      it do
        should contain_file('pam_system_auth_ac').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/system-auth-ac',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_system_auth_ac') \
          .with_content(/auth[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/account[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/password[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/session[\s]+required[\s]+pam_vas3.so/)
        should_not contain_file('pam_system_auth_ac').with_content(/auth[\s]+sufficient[\s]+pam_vas3.so.*store_creds/)
      end
    end

    context 'with ensure_vas=present and vas_major_version=3 on osfamily redhat with lsbmajdistrelease 5' do
      let (:params) do
        {
          :ensure_vas        => 'present',
          :vas_major_version => '3',
        }
      end
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end
      it do
        should contain_file('pam_system_auth_ac').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/system-auth-ac',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_system_auth_ac') \
          .with_content(/auth[\s]+sufficient[\s]+pam_vas3.so.*store_creds/) \
          .with_content(/account[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/password[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/session[\s]+required[\s]+pam_vas3.so/)
      end
    end

    context 'with ensure_vas=present and vas_major_version=3 on osfamily redhat with lsbmajdistrelease 6' do
      let (:params) do
        {
          :ensure_vas        => 'present',
          :vas_major_version => '3',
        }
      end
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end
      it do
        should contain_file('pam_system_auth_ac').with({
          'ensure'  => 'file',
          'path'    => '/etc/pam.d/system-auth-ac',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('pam_system_auth_ac') \
          .with_content(/auth[\s]+sufficient[\s]+pam_vas3.so.*store_creds/) \
          .with_content(/account[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/password[\s]+sufficient[\s]+pam_vas3.so/) \
          .with_content(/session[\s]+required[\s]+pam_vas3.so/)
      end
    end
    context 'with ensure_vas=present and unsupported vas_major_version on osfamily redhat with lsbmajdistrelease 5' do
      let (:params) do
        {
          :ensure_vas        => 'present',
          :vas_major_version => '5',
        }
      end
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end
      it 'should fail' do
        expect {
          should include_class('pam')
        }.to raise_error(Puppet::Error,/Pam is only supported with vas_major_version 3 or 4/)
      end
    end
    context 'with ensure_vas=present and unsupported vas_major_version on osfamily redhat with lsbmajdistrelease 6' do
      let (:params) do
        {
          :ensure_vas        => 'present',
          :vas_major_version => '5',
        }
      end
      let :facts do
        {
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end
      it 'should fail' do
        expect {
          should include_class('pam')
        }.to raise_error(Puppet::Error,/Pam is only supported with vas_major_version 3 or 4/)
      end
    end
  end
end