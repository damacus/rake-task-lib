task :_build, :name do |_t, args|
  sh "docker build -t #{args[:name]} ."
end
