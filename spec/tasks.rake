require 'pact/provider/proxy/tasks'

Pact::ProxyVerificationTask.new :monolith do | task |
 task.pact_url './spec/support/pact.json', :pact_helper => './spec/support/custom_pact_helper'
 task.provider_base_url 'http://localhost:9292'
end

Pact::ProxyVerificationTask.new :monolith_dynamic_pact_helper do | task |
 task.pact_url './spec/support/pact.json'
 task.provider_base_url 'http://localhost:9292'
end

Pact::ProxyVerificationTask.new :monolith_no_pact_helper do | task |
 task.pact_url './spec/support/pact-with-no-provider-states.json'
 task.provider_base_url 'http://localhost:9292'
end

namespace :pact do
  namespace :test do
    task :spawn_test_monolith do
      require 'pact/consumer/app_manager'
      Pact::Consumer::AppManager.instance.register lambda { | env | [200, {}, ["Monolith!"]] }, 9292
      Pact::Consumer::AppManager.instance.spawn_all
    end
  end
end

task 'delete_pact_helper' do
  FileUtils.rm_rf './spec/support/pact_helper.rb'
end

task 'create_pact_helper' do
  FileUtils.cp './spec/fixtures/template_pact_helper.rb', './spec/support/pact_helper.rb'
end

task 'create_custom_pact_helper' do
  FileUtils.cp './spec/fixtures/template_pact_helper.rb', './spec/support/custom_pact_helper.rb'
end

task 'pact:verify:monolith' => ['pact:test:spawn_test_monolith', 'create_custom_pact_helper']
task 'pact:verify:monolith_dynamic_pact_helper' => ['pact:test:spawn_test_monolith','create_pact_helper']
task 'pact:verify:monolith_no_pact_helper' => ['pact:test:spawn_test_monolith', 'delete_pact_helper']

task :spec => ['pact:verify:monolith_no_pact_helper','pact:verify:monolith','pact:verify:monolith_dynamic_pact_helper']
task :default => [:spec]