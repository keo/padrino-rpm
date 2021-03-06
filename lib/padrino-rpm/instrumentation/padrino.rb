require 'new_relic/agent/instrumentation/controller_instrumentation'

DependencyDetection.defer do
  depends_on do
    defined?(::Padrino)
  end
  
  executes do
    Padrino::Application.class_eval do
      include PadrinoRpm::Instrumentation::Padrino
    end
  end
end

module PadrinoRpm
  module Instrumentation
    module Padrino
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation
      
      def route_eval(*args, &block)
        name = @route.as_options[:name]
        short_name = name.to_s.split(/_/).last

        perform_action_with_newrelic_trace(:category => :controller, :name => short_name, :params => request.params, :class_name => @route.controller)  do
          route_eval_without_newrelic(*args, &block) # RPM loads the sinatra plugin to eagerly
        end
      end

    end #PadrinoRpm::Instrumentation::Padrino
  end
end

DependencyDetection.detect!
