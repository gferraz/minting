# frozen_string_literal: true

# Mint Range patch
# @api private
module Mint
  if RUBY_VERSION < '4.0'
    # Ruby < 4.0's Range#step calls rb_to_int on non-Numeric step arguments,
    # which raises TypeError for Money objects. Ruby 4.0+ uses arithmetic
    # iteration (+ / <=>) for non-numeric steps natively, so this patch is
    # only needed on older Rubies.
    module RangeStepPatch
      def step(step_size = nil, &block)
        return super unless step_size.is_a?(Mint::Money)

        raise TypeError, "can't iterate from NilClass" unless self.begin
        raise ArgumentError, "step can't be 0" if step_size.zero?

        if block
          each_money_step(step_size, &block)
          self
        else
          Enumerator.new { |yielder| each_money_step(step_size) { |value| yielder << value } }
        end
      end

      private

      def each_money_step(step, &)
        self.end ? bounded_step(step, &) : unbounded_step(step, &)
      end

      def unbounded_step(step)
        current = self.begin
        loop do
          yield current
          current += step
        end
      end

      def bounded_step(step)
        current = self.begin
        last    = self.end
        asc     = step.positive?

        loop do
          break if asc ? current > last : current < last
          break if exclude_end? && current == last

          yield current
          current += step
        end
      end
    end
    Range.prepend(Mint::RangeStepPatch)
  end
end
