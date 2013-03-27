
include CalendarHelper
include Happening

use Rack::Cache

# set :static, true 

# before do
#   cache_control :public, :must_revalidate, :max_age => 600
# end

configure do
  set :protection, :except => :frame_options
  set :cal_url, "http://url.to/your/calendar_file.ics" # <-- Change this to your calendar online (ical format)
  set :cal_file, File.join('public', 'calendar.ics') # <-- Name and path where you want to save the calendar
  set :sweep_files, [settings.cal_file, File.join('public', 'json')]
  enable :logging
end


["/", "/index.html"].each do |path|
  get path do
    set :static, true
    cache_calendar(settings.cal_url, settings.cal_file)
    
    erb :index
    
  end
end

get '/list' do
  f = File.open(settings.cal_file)
  events = RiCal.parse(f).first.events.sort_by!{|e| e.dtstart}
  @current_events = events.find_all{ |e| e.dtend > DateTime.now }[0...5]
  erb :list
end

get "/json" do
  logger.info "json"
  
  file_cache('json') do
    ics = File.open(settings.cal_file)
    cal = RiCal.parse(ics).first
    Happening::CalWrapper.new(cal).to_json
  end
  
  cache_control :public, :must_revalidate, :max_age => 600
end

get "/css" do
  less :'less/style'
end

get '/fullcalendar.css' do
  content_type 'text/css'
  file_cache('fullcal.css') do
    less :'less/fullcalendar'
  end
  cache_control :public, :must_revalidate, :max_age => 600
end

get '/tooltip.css' do
  less :'less/tooltip'
end

helpers do
  def cache_calendar(url, filename)
    response = HTTParty.get(url)
    
    if File.exists?(filename)
      local_key = ''
      File.open(filename, 'r') do |f|
        local_key = digest(f.read)
      end
      logger.info "local: #{local_key}"
      remote_key = digest(response.body)
      logger.info "remote: #{remote_key}"
      if remote_key == local_key
        hit = true
      else
        hit = false
        cache_sweep
        write_file(filename, response.body)
      end
    else
      hit = false
      write_file(filename, response.body)
    end
    hit
  end
  
  def write_file(filename, contents)
    File.open(filename, 'w') do |f|
      f << contents
    end
  end

  def delete_file(filename)
    File.delete(filename)
    logger.info "deleted #{filename}"
  end
  
  def cache_sweep
    settings.sweep_files.each do |f|
      delete_file(f)
    end
  end
  
  def file_cache(filename)
    file = File.join('public', filename)
    unless File.exists?(file)
      File.open(file, 'w') do |f|
        f << yield
      end
    end
    etag digest(yield)
    # File.read(file)
    send_file file
  end
  
  def digest(text)
    Digest::MD5.hexdigest(text)
  end

end

