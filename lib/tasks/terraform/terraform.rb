module Terraform
  # Common Terraform Rake Tasks
  class RakeTask < Rake::TaskLib
    require_relative 'helpers'

    def initialize
      @workspaces = []
      define
    end

    private

    def define
      Dir.chdir('terraform/workspaces') do
        Dir.glob('*.tfvars').each do |w|
          w.slice! '.tfvars'
          @workspaces << w
        end
      end

      namespace 'plan' do
        @workspaces.each do |w|
          desc "Terraform plan for workspace: #{w}"
          task(w) { Rake::Task['_plan'].invoke(w) }
        end
      end

      namespace 'apply' do
        @workspaces.each do |w|
          desc "Terraform apply workspace: #{w}"
          task(w) { Rake::Task['_apply'].invoke(w, 'No') }
        end
      end

      namespace 'ci_apply' do
        @workspaces.each do |w|
          desc "Terraform apply workspace: #{w} for CI Environments"
          task(w) { Rake::Task['_apply'].invoke(w, 'Yes') }
        end
      end
    end
  end
end
