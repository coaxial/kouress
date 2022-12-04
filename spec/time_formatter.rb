# frozen_string_literal: true

# This code was written by ChatGPT, I refactored it some.
class TimeFormatter
  RSpec::Core::Formatters.register self, :example_started, :example_passed, :example_failed

  def initialize(output)
    @output = output
  end

  def example_started(_notification)
    @start_time = Time.zone.now
  end

  def example_passed(notification)
    handle_example(notification)
  end

  def example_failed(notification)
    handle_example(notification)
  end

  private

  def handle_example(notification)
    time_taken = Time.zone.now - @start_time
    colorize_output(time_taken:, notification:)
  end

  # rubocop:disable Metrics/MethodLength
  def colorize_output(time_taken:, notification:)
    if time_taken > 1.0
      @output.print "\e[31m"
    elsif time_taken > 0.3
      @output.print "\e[33m"
    else
      @output.print "\e[32m"
    end

    @output.printf "%10.5<time_taken>f seconds\t%50<file_path>s:%<line_number>s\t%-30<description>s\n",
                   time_taken:, file_path: notification.example.metadata[:file_path],
                   line_number: notification.example.metadata[:line_number],
                   description: notification.example.description

    @output.print "\e[0m"
  end
  # rubocop:enable Metrics/MethodLength
end
