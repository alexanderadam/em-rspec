begin
  require 'fiber'
rescue LoadError
  raise LoadError.new "em-rspec requires the Fiber class. (Available in core Ruby 1.9)"
end

require 'eventmachine'

RSpec::Core::Example.class_eval do
  alias ignorant_run run

  def run(example_group_instance, reporter)

    if metadata[:eventmachine]

      EM.run do
        Fiber.new do
          df = EM::DefaultDeferrable.new
          df.callback { |x| EM.stop }
  
          ignorant_run example_group_instance, reporter
          
          df.succeed
        end.resume
      end

    else
      ignorant_run example_group_instance, reporter
    end
  end

end
