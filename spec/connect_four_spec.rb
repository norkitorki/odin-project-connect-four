# frozen-string-literal: true

require_relative '../lib/connect_four'
require_relative '../lib/grid'

describe ConnectFour do
  subject(:connect_four) { described_class.new('Player1', 'Player2', connect_four_grid) }
  let(:connect_four_grid) { instance_double(Grid) }

  describe '#player_input' do
    before do
      allow(connect_four).to receive(:puts)
      allow(connect_four).to receive(:print)
      allow(connect_four_grid).to receive(:column_full?).and_return(false)
    end

    context 'when the player inputs a valid position' do
      before do
        valid_input = '6'
        allow(connect_four).to receive(:user_input).and_return(valid_input)
      end

      it 'should not print an error message' do
        error_message = 'Invalid input. Please input one of these positions: 0 1 2 3 4 5 6'
        expect(connect_four).not_to receive(:puts).with(error_message)
        connect_four.player_input
      end

      it 'should return the position converted to an integer' do
        valid_return = 6
        expect(connect_four.player_input).to eq(valid_return)
      end

      context 'when the column at the position is full' do
        before do
          input1 = '2'
          input2 = '5'
          allow(connect_four).to receive(:user_input).and_return(input1, input2)
          allow(connect_four_grid).to receive(:column_full?).and_return(
            false, false, false, false, false, false, false, true, false
          )
        end

        it 'should print an error message' do
          error_message = 'Invalid input. Please input one of these positions: 0 1 2 3 4 5 6'
          expect(connect_four).to receive(:puts).once.with(error_message)
          connect_four.player_input
        end

        it 'should not return the position converted to an integer' do
          input1_to_i = 2
          expect(connect_four.player_input).not_to eq(input1_to_i)
        end
      end
    end

    context 'when the player inputs one invalid and valid position' do
      before do
        invalid_position = '-2'
        valid_position = '2'
        allow(connect_four).to receive(:user_input).and_return(invalid_position, valid_position)
      end

      it 'should print an error message once' do
        error_message = 'Invalid input. Please input one of these positions: 0 1 2 3 4 5 6'
        expect(connect_four).to receive(:puts).once.with(error_message)
        connect_four.player_input
      end

      it 'should return the valid position converted to an integer' do
        valid_return = 2
        expect(connect_four.player_input).to eq(valid_return)
      end
    end

    context 'when the player inputs 3 invalid inputs and 1 valid position' do
      before do
        sym = ':sym'
        big_integer = '20442'
        string = 'seven'
        valid_position = '4'
        allow(connect_four).to receive(:user_input).and_return(sym, big_integer, string, valid_position)
      end

      it 'should print an error message 3 times' do
        error_message = 'Invalid input. Please input one of these positions: 0 1 2 3 4 5 6'
        expect(connect_four).to receive(:puts).exactly(3).times.with(error_message)
        connect_four.player_input
      end

      it 'should return the valid position converted to an integer' do
        valid_return = 4
        expect(connect_four.player_input).to eq(valid_return)
      end
    end
  end

  describe '#place' do
    it 'should place the current player\'s disk on the grid' do
      position = 2
      disk = connect_four.current_player[:disk]
      expect(connect_four.grid_board).to receive(:place).with(disk, position).once
      connect_four.place(position)
    end
  end

  describe '#swap_players' do
    context 'when the current player is player1' do
      before do
        player1 = connect_four.player1
        connect_four.instance_variable_set(:@current_player, player1)
      end

      it 'should assign current player to player2' do
        current_player = connect_four.current_player
        player2 = connect_four.player2
        expect { connect_four.swap_players }.to change { connect_four.current_player }.from(current_player).to(player2)
      end
    end

    context 'when the current player is player2' do
      before do
        player2 = connect_four.player2
        connect_four.instance_variable_set(:@current_player, player2)
      end

      it 'should assign current player to player1' do
        current_player = connect_four.current_player
        player1 = connect_four.player1
        expect { connect_four.swap_players }.to change { connect_four.current_player }.from(current_player).to(player1)
      end
    end
  end

  describe '#post_game' do
    before do
      allow(connect_four).to receive(:puts)
      allow(connect_four).to receive(:game_over?).once.and_return(true)
      allow(connect_four).to receive(:draw?).once.and_return(false)
      allow(connect_four).to receive(:user_input).and_return('n')
    end

    context 'when a player has won the game' do
      before do
        connect_four.instance_variable_set(:@current_player, connect_four.player2)
      end

      it 'should announce the winner of the game' do
        win_message = "\n#{connect_four.player2.name} has won the game!\n"
        expect(connect_four).to receive(:puts).with(win_message).once
        connect_four.post_game
      end

      it 'should not announce that the game ended in a draw' do
        draw_message = "\nThe game ended in a draw!\n"
        expect(connect_four).not_to receive(:puts).with(draw_message)
      end
    end

    context 'when the game ended in a draw' do
      before { allow(connect_four).to receive(:game_over?).once.and_return(false) }

      it 'should announce that the game ended in a draw' do
        draw_message = "\nThe game ended in a draw\n"
        expect(connect_four).to receive(:puts).with(draw_message).once
        connect_four.post_game
      end

      it 'should not announce a winner' do
        current_player = connect_four.current_player
        win_message = "\n#{current_player.name} has won the game!\n"
        expect(connect_four).not_to receive(:puts).with(win_message)
        connect_four.post_game
      end
    end

    context 'when the user decides to replay the game' do
      before do
        allow(connect_four).to receive(:user_input).and_return('y')
        allow(connect_four).to receive(:play)
        allow(connect_four_grid).to receive(:reset)
      end

      it 'should send a message to grid#reset' do
        expect(connect_four_grid).to receive(:reset).once
        connect_four.post_game
      end

      it 'should send a message to #play' do
        expect(connect_four).to receive(:play).once
        connect_four.post_game
      end
    end

    context 'when the user decides to quit the game' do
      before do
        allow(connect_four).to receive(:user_input).and_return('n')
      end

      it 'should not send a message to grid#reset' do
        expect(connect_four_grid).not_to receive(:reset)
        connect_four.post_game
      end

      it 'should not send a message to #play' do
        expect(connect_four).not_to receive(:play)
        connect_four.post_game
      end
    end
  end

  describe '#user_input' do
    before do
      allow(connect_four).to receive(:print)
      input = '6'
      allow(connect_four).to receive(:gets).and_return(input)
    end

    it 'should send a message to gets' do
      expect(connect_four).to receive(:gets).once
      connect_four.user_input
    end

    it 'should return the input' do
      expected_return = '6'
      expect(connect_four.user_input).to eq(expected_return)
    end
  end

  describe '#game_over?' do
    let(:game_over_grid) { Array.new(7) { Array.new(6, ' ') } }

    before do
      allow(connect_four_grid).to receive(:grid).and_return(game_over_grid)
      allow(connect_four_grid).to receive(:rows).and_return(7)
      allow(connect_four_grid).to receive(:columns).and_return(6)
    end

    context 'when a player has 4 disks vertically alligned' do
      before do
        disk = "\e[0;31;49m●\e[0m"
        4.times { |i| game_over_grid[0][i] = disk }
        allow(connect_four).to receive(:current_player).and_return(connect_four.player1)
      end

      it 'should return true' do
        expect(connect_four).to be_game_over
      end
    end

    context 'when a player does not have 4 disks vertically alligned' do
      before do
        disk = "\e[0;31;49m●\e[0m"
        2.times { |i| game_over_grid[1][i] = disk }
        allow(connect_four).to receive(:current_player).and_return(connect_four.player1)
      end

      it 'should return false' do
        expect(connect_four).to_not be_game_over
      end
    end

    context 'when a player has 4 disks horizontally alligned' do
      before do
        disk = "\e[0;31;49m●\e[0m"
        game_over_grid.each_with_index { |col, i| i < 4 ? col[0] = disk : break }
        allow(connect_four).to receive(:current_player).and_return(connect_four.player1)
      end

      it 'should return true' do
        expect(connect_four).to be_game_over
      end
    end

    context 'when a player does not have 4 disks horizontally alligned' do
      before do
        disk = "\e[0;31;49m●\e[0m"
        game_over_grid.each_with_index { |col, i| i < 3 ? col[0] = disk : break }
        allow(connect_four).to receive(:current_player).and_return(connect_four.player1)
      end

      it 'should return false' do
        expect(connect_four).to_not be_game_over
      end
    end

    context 'when a player has 4 disks diagonally alligned' do
      context 'when a match is found from upper left to lower right' do
        before do
          allow(connect_four).to receive(:current_player).and_return(connect_four.player1)
          disk = connect_four.player1.disk
          4.times { |i| game_over_grid[i][i] = disk }
        end

        it 'should return true' do
          expect(connect_four).to be_game_over
        end
      end

      context 'when a match is found from lower left to upper right' do
        before do
          disk = connect_four.player2.disk
          columns = connect_four_grid.columns
          4.times { |i| game_over_grid[i][columns - 1 - i] = disk }
          allow(connect_four).to receive(:current_player).and_return(connect_four.player2)
        end

        it 'should return true' do
          expect(connect_four).to be_game_over
        end
      end
    end

    context 'when 4 of the same disks are not diagonally alligned' do
      it 'should return false' do
        expect(connect_four).to_not be_game_over
      end
    end
  end

  describe '#draw?' do
    it 'should send a message to grid#row_full?' do
      allow(connect_four_grid).to receive(:column_full?)
      expect(connect_four_grid).to receive(:column_full?)
      connect_four.draw?
    end

    context 'when every column in the grid is full' do
      before { allow(connect_four_grid).to receive(:column_full?).exactly(7).times.and_return(true) }

      it 'should return true' do
        expect(connect_four).to be_draw
      end
    end

    context 'when every column in the grid is not full' do
      before { allow(connect_four_grid).to receive(:column_full?).once.and_return(false) }

      it 'should return false' do
        expect(connect_four).not_to be_draw
      end
    end
  end
end
