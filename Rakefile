require 'spec/rake/spectask'
require 'rcov/rcovtask'

task :default => :spec

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.rcov = true
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = [ "-c" ]
end
