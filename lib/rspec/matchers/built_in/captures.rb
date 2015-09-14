module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the regex with captures matcher
      class Captures < BaseMatcher
        def initialize(expected)
          super(expected)
          @match_matcher = BuiltIn::Match.new(expected)
          @expected_captures = nil
        end

        # Used to specify the captures we match against
        # @return [self]
        def with_captures(*captures)
          @expected_captures = captures
          self
        end

        # @api private
        # @return [String]
        def description
          return @match_matcher.description unless @expected_captures
          "match with string #{@expected} have captures #{surface_descriptions_in(@expected_captures).inspect}"
        end

      private

        def match(expected, actual)
          return @match_matcher.matches?(actual) unless Regexp === actual
          return @match_matcher.matches?(actual) unless @expected_captures

          match = actual.match(expected)
          if match
            match = ReliableMatchData.new(match)
            if match.names.empty?
              values_match?(@expected_captures, match.captures)
            else
              expected_matcher = @expected_captures.last
              values_match?(expected_matcher, Hash[match.names.zip(match.captures)]) ||
                values_match?(expected_matcher, Hash[match.names.map(&:to_sym).zip(match.captures)])
            end
          else
            false
          end
        end
      end

      # @api private
      # Used to wrap match data and make it reliable for 1.8.7
      class ReliableMatchData
        def initialize(match_data)
          @match_data = match_data
        end

        # @api private
        # Returns match data names for named captures
        # @return Array
        def names
          match_data.names
        rescue NameError
          []
        end

        # @api private
        # returns an array of captures from the match data
        # @return Array
        def captures
          match_data.captures
        end

      protected

        attr_reader :match_data
      end
    end
  end
end
