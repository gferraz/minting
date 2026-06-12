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
      def step(step_size = nil, &)
        return super unless step_size.is_a?(Mint::Money)

        raise TypeError, "can't iterate from NilClass" unless self.begin
        raise ArgumentError, "step can't be 0" if step_size.zero?

        if block_given?
          each_money_step(step_size, &)
          self
        else
          Enumerator.new do |yielder|
            each_money_step(step_size) { |v| yielder << v }
          end
        end
      end

      private

      def each_money_step(step_amount)
        current = self.begin
        last = self.end

        unless last
          loop do
            yield current
            current += step_amount
          end
          return
        end

        ascending = step_amount.positive?
        loop do
          break if ascending ? current > last : current < last
          break if exclude_end? && current == last

          yield current
          current += step_amount
        end
      end
    end
    Range.prepend(Mint::RangeStepPatch)
  end
end
