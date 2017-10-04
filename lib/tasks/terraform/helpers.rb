# @env: environment to plan against
# @target: terraform target
task :_plan, %i[env target] do |_t, args|
  Rake::Task['_init'].invoke

  Dir.chdir('terraform') do
    puts 'Planning environment: '.green + (args[:env]).to_s.light_red

    sh "terraform workspace select #{args[:env]}", verbose: false
    if args[:target]
      puts 'Planning with target: '.green + (args[:target]).to_s.white
      sh 'terraform plan ' \
         "-target #{args[:target]} " \
         "-var-file=\"workspaces/#{args[:env]}.tfvars\" " \
         "-var-file=\"'workspaces/default.tfvars\"", verbose: false
    else
      sh 'terraform plan ' \
          "-var-file=\"workspaces/#{args[:env]}.tfvars\" " \
          '-var-file="workspaces/default.tfvars"', verbose: false
    end
  end
end

# @env: environment to plan against
# @apply: Whether to force apply or not (Yes/No)
task :_apply, %i[env apply target] do |_t, args|
  Rake::Task['_init'].invoke
  Rake::Task['_plan'].invoke(args[:env], args[:target])

  Dir.chdir('terraform') do
    if args[:apply] == 'Yes'
      apply(args[:target], args[:env])
    else
      puts "Would you like to apply the changes to #{args[:env]}? (Yes/No)"
      user_response = $stdin.gets.chomp
      case user_response
      when 'Yes'
        apply(args[:target], args[:env])
      when 'No'
        puts 'Aborting apply: Nothing applied'
          .green
      else
        puts 'Aborting apply: please type either Yes or No. Case sensitive.'
          .light_red
      end
    end
  end
end
def apply(target, env)
  sh "terraform workspace select #{env}", verbose: false

  if target
    puts 'Applying with target: '.green + target.light_red
    sh 'terraform apply' \
       "-target #{target}" \
       "-var-file=\"workspaces/#{env}.tfvars\"" \
       '-var-file="workspaces/default.tfvars"', verbose: false
  else
    puts 'terraform apply'.green
    sh 'terraform apply ' \
       "-var-file=\"workspaces/#{env}.tfvars\" " \
       '-var-file="workspaces/default.tfvars"', verbose: false
  end
end
# rubocop:enable Metrics/MethodLength

task :_init do
  Dir.chdir('terraform') do
    puts 'Updating modules'.green
    sh 'terraform get --update', verbose: false
    puts 'Initializing terraform'.green
    sh 'terraform init -get=false -force-copy', verbose: false
  end
end
