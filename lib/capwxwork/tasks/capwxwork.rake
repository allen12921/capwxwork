namespace :wxwork do
  def post_to_wxwork(message, full_format: false)
    require 'net/http'
    require 'openssl'
    require 'json'

    stage = fetch(:stage)
    branch = fetch(:branch)
    app_name = fetch(:application)
    deployer = fetch(:local_user)
    wxwork_config = fetch(:wxwork_config)
    time = Time.now.to_s
    $global_stime = Time.now unless defined? $global_stime
    duration = Time.at(Time.now - $global_stime).utc.strftime("%H:%M:%S")
    uri = URI(wxwork_config[:web_hook])
    current_version = fetch(:current_revision,'default')
    repo_url = fetch(:repo_url)
    base_url = 'https://'+repo_url[4..-5].gsub(':','/')
        
    unless defined? $global_old_version
     on primary(:app) do
         within current_path do
           $global_old_version = capture :cat, 'REVISION'
         end
     end
    end

    content_start = <<-MARKDOWN
    <font color="comment">#{message}</font>
    >App Name: <font color="info">#{app_name}</font>
    >Environment: <font color="info">#{stage}</font>
    >Branch: <font color="info">#{branch}</font>
    >Deployer: <font color="info">#{deployer}</font>
    >Time At: <font color="info">#{time}</font>
    MARKDOWN

    content_end = <<-MARKDOWN
    <font color="comment">#{message}</font>
    >App Name: <font color="info">#{app_name}</font>
    >Environment: <font color="info">#{stage}</font>
    >Branch: <font color="info">#{branch}</font>
    >Deployer: <font color="info">#{deployer}</font>
    >Diff: <font color="info">[#{base_url}/compare/#{$global_old_version}...#{current_version}](#{base_url}/compare/#{$global_old_version}...#{current_version})</font>
    >Duration: <font color="info">#{duration}</font>
    >Time At: <font color="info">#{time}</font>
    MARKDOWN

    content = message.include?('finished') ? content_end : content_start

    payload = {
      'msgtype' => 'markdown',
      'markdown' =>
        {
          'content' => content.strip
        }
    }

    # Net::HTTP.post(uri, JSON.generate(payload), "Content-Type" => "application/json")

    Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Post.new uri.request_uri
      request.add_field('Content-Type', 'application/json')
      request.add_field('Accept', 'application/json')
      request.body = JSON.generate payload
      http.request request
    end
  end

  desc 'Send message to wxwork'
  task :notify, [:message, :full_format] do |_t, args|
    message = args[:message]
    full_format = args[:full_format]

    run_locally do
      with rails_env: fetch(:rails_env) do
        post_to_wxwork message, full_format: full_format
      end
    end

    Rake::Task['wxwork:notify'].reenable
  end
end
