# frozen-string-literal: true

require_relative '../lib/grid'

describe Grid do
  subject(:grid) { described_class.new }

  describe '#to_s' do
    subject(:print_grid) { described_class.new(3, 2) }

    context 'when the grid is empty' do
      it 'should print the empty grid' do
        expect(print_grid.to_s).to eq(
          <<~GRID
            \n║───║───║───║
            ║ ◯ ║ ◯ ║ ◯ ║
            ╠═══╬═══╬═══╣
            ║ ◯ ║ ◯ ║ ◯ ║
            ╚═══╩═══╩═══╝
              0   1   2
          GRID
        )
      end
    end

    context 'when the grid is not empty' do
      before { 2.times { print_grid.place('X', 1) } }

      it 'should print the grid' do
        expect(print_grid.to_s).to eq(
          <<~GRID
            \n║───║───║───║
            ║ ◯ ║ X ║ ◯ ║
            ╠═══╬═══╬═══╣
            ║ ◯ ║ X ║ ◯ ║
            ╚═══╩═══╩═══╝
              0   1   2
          GRID
        )
      end
    end
  end

  describe '#place' do
    context 'when column is not in range' do
      before { allow(grid).to receive(:puts) }

      it 'should print out an error message' do
        disk = 'W'
        column = 11
        error_message = 'Column 11 is out of range'
        expect(grid).to receive(:puts).once.with(error_message)
        grid.place(disk, column)
      end
    end

    context 'when a column is not full' do
      it 'should place a disk in a column' do
        disk = 'O'
        column = 1
        grid.place(disk, column)
        expect(grid.grid[1]).to eq(['◯', '◯', '◯', '◯', '◯', disk])
      end
    end

    context 'when a column is full' do
      subject(:place_grid) { described_class.new(1, 1) }

      before do
        allow(place_grid).to receive(:puts)
        place_grid.grid[0][0] = 'X'
      end

      it 'should print out an error message' do
        disk = 'X'
        column = 0
        error_message = 'Column 0 is full.'
        expect(place_grid).to receive(:puts).once.with(error_message)
        place_grid.place(disk, column)
      end

      it 'should not place a disk in a column' do
        disk = 'O'
        column = 0
        expect { place_grid.place(disk, column) }.not_to change { place_grid.grid.first }
      end
    end
  end

  describe '#reset' do
    subject(:reset_grid) { described_class.new(3, 3) }

    before { 3.times { |i| reset_grid.place('X', i) } }

    it 'should reset/initialize the grid' do
      pre_reset_grid = reset_grid.grid
      expected_grid = [['◯', '◯', '◯']] * 3
      expect { reset_grid.reset }.to change { reset_grid.grid }.from(pre_reset_grid).to(expected_grid)
    end
  end

  describe '#column_full?' do
    context 'when the column is out of range' do
      context 'when the column is bigger than the total number of columns' do
        it 'should return false' do
          column = 1000
          result = grid.column_full?(column)
          expect(result).to eq(false)
        end
      end

      context 'when the column is negative' do
        it 'should return false' do
          column = -20
          result = grid.column_full?(column)
          expect(result).to eq(false)
        end
      end
    end

    context 'when a column is not full' do
      it 'should return false' do
        column = 5
        result = grid.column_full?(column)
        expect(result).to eq(false)
      end
    end

    context 'when a column is full' do
      subject(:full_column_grid) { described_class.new(1, 2) }

      before { 2.times { full_column_grid.place('M', 0) } }

      it 'should return true' do
        column = 0
        result = full_column_grid.column_full?(column)
        expect(result).to eq(true)
      end
    end
  end
end
