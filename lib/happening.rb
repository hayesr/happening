require 'pry'

module Happening
  class CalWrapper
    def initialize(ri_calendar)
      
      @cal = ri_calendar
    end
    
    def to_json
      events = []
      @cal.events.each_with_index do |e,i|
        attributes = {
          title: e.summary,
          start: e.dtstart,
          :end => e.corrected_end,
          allday: e.allday?,
          desc: e.description
          }
        events << "#{i}," + attributes.to_json
      end
      
      "[ #{ events.join(",") } ]"
    end
    
    # def method_missing
    #   
    # end
  end
  
  module EventExtensions
    
    def allday?
      xprop = x_properties['X-MICROSOFT-CDO-ALLDAYEVENT']
      if xprop.any?
        xprop.first.ruby_value == "TRUE"
      end
    end
    
    def ends_at_midnight?
      true
    end
    
    def corrected_end
      if allday? && ends_at_midnight?
        dtend - 1
      else
        dtend
      end
    end
    
  end
end

class RiCal::Component::Event 
  include Happening::EventExtensions
end