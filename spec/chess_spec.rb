# frozen_string_literal: true

require_relative '../lib/moves'

describe Moves do
  subject(:game) { described_class.new }

  describe '#knight_check' do
    it 'returns true if the knight puts the king in check'
  end
end
