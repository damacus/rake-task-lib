module Docker
  # Common Docker Tasks
  class RakeTask < Rake::TaskLib
    require_relative 'helpers'
    def initialize
      define
    end

    private

    def define
      namespace :docker do
        desc 'Docker Cleanup'
        task :system_cleanup do
          puts 'Starting Docker cleanup'
          sh 'docker system prune'
        end

        desc 'Remove all dangling images'
        task(:image_cleanup) { sh 'docker image prune' }

        desc 'build & tag Docker container'
        task :build, [:name] do |_t, args|
          Rake::Task['_build'].invoke(args[:name])
        end
      end
    end
  end
end
