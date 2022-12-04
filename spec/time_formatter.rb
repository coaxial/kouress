# frozen_string_literal: true

# spec/time_formatter.rb
class TimeFormatter
  RSpec::Core::Formatters.register self, :example_started, :example_passed, :example_failed

  def initialize(output)
    @output = output
  end

  def example_started(_notification)
    @start_time = Time.zone.now
  end

  def example_passed(notification)
    time_taken = Time.zone.now - @start_time

    if time_taken > 1.0
      @output.print "\e[31m"
    elsif time_taken > 0.3
      @output.print "\e[33m"
    else
      @output.print "\e[32m"
    end

    @output.printf "%10.5f seconds\t%50s:%s\t%-30s\n", time_taken, notification.example.metadata[:file_path],
                   notification.example.metadata[:line_number], notification.example.description

    @output.print "\e[0m"
  end

  def example_failed(notification)
    time_taken = Time.zone.now - @start_time

    if time_taken > 1.0
      @output.print "\e[31m"
    elsif time_taken > 0.3
      @output.print "\e[33m"
    else
      @output.print "\e[32m"
    end

    @output.printf "%10.5f seconds\t%s:%s\t%s\n", time_taken, notification.example.metadata[:file_path],
                   notification.example.metadata[:line_number], notification.example.description

    @output.print "\e[0m"
  end
end
