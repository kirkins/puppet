# encoding: UTF-8

test_name "puppet module install (with modulepath)"
require 'puppet/acceptance/module_utils'
extend Puppet::Acceptance::ModuleUtils

module_author = "pmtacceptance"
module_name   = "nginx"
module_dependencies = []

orig_installed_modules = get_installed_modules_for_hosts hosts

teardown do
  installed_modules = get_installed_modules_for_hosts hosts
  rm_installed_modules_from_hosts orig_installed_modules, installed_modules
  # TODO: make helper take modulepath
  on master, "rm -rf #{master['puppetpath']}/modules2"
end

step 'Setup'

stub_forge_on(master)

on master, "mkdir -p #{master['puppetpath']}/modules2"

step "Install a module with relative modulepath"
on master, "cd #{master['puppetpath']}/modules2 && puppet module install #{module_author}-#{module_name} --modulepath=." do
  assert_match(/Installing -- do not interrupt/, stdout,
        "Notice that module was installing was not displayed")
  assert_match(/#{module_author}-#{module_name}/, stdout,
        "Notice that module '#{module_author}-#{module_name}' was installed was not displayed")
  assert_match(/#{master['puppetpath']}\/modules2/, stdout,
        "Notice of non default install path was not displayed")
end
on master, "[ -d #{master['puppetpath']}/modules2/#{module_name} ]"

step "Install a module with absolute modulepath"
on master, "test -d #{master['puppetpath']}/modules2/#{module_name} && rm -rf #{master['puppetpath']}/modules2/#{module_name}"
on master, puppet("module install #{module_author}-#{module_name} --modulepath=#{master['puppetpath']}/modules2") do
  assert_match(/Installing -- do not interrupt/, stdout,
        "Notice that module was installing was not displayed")
  assert_match(/#{module_author}-#{module_name}/, stdout,
        "Notice that module '#{module_author}-#{module_name}' was installed was not displayed")
  assert_match(/#{master['puppetpath']}\/modules2/, stdout,
        "Notice of non default install path was not displayed")
end
on master, "[ -d #{master['puppetpath']}/modules2/#{module_name} ]"
