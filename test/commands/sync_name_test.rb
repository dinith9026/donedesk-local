require 'test_helper'

class SyncNameTest < CommandTest
  describe 'call' do
    test 'when neither first or last name are out of sync' do
      newer = Minitest::Mock.new
      older = Minitest::Mock.new
      fname = 'Fname'
      lname = 'Lname'

      newer.expect(:first_name, fname)
      newer.expect(:last_name, lname)
      older.expect(:first_name, fname)
      older.expect(:last_name, lname)

      assert_broadcast(:ok) { SyncName.call(newer: newer, older: older) }
      assert_mock newer
      assert_mock older
    end

    test 'when only last name is out of sync' do
      newer = Minitest::Mock.new
      older = Minitest::Mock.new
      fname = 'Fname'
      new_lname = 'NewLname'
      old_lname = 'OldLname'

      newer.expect(:first_name, fname)
      newer.expect(:last_name, new_lname)
      older.expect(:first_name, fname)
      older.expect(:last_name, old_lname)
      older.expect(:update!, nil, [{last_name: new_lname }])

      assert_broadcast(:ok) { SyncName.call(newer: newer, older: older) }
      assert_mock newer
      assert_mock older
    end

    test 'when only first name is out of sync' do
      newer = Minitest::Mock.new
      older = Minitest::Mock.new
      lname = 'Lname'
      new_fname = 'NewFname'
      old_fname = 'OldFname'

      newer.expect(:first_name, new_fname)
      newer.expect(:last_name, lname)
      older.expect(:first_name, old_fname)
      older.expect(:last_name, lname)
      older.expect(:update!, nil, [{first_name: new_fname }])

      assert_broadcast(:ok) { SyncName.call(newer: newer, older: older) }
      assert_mock newer
      assert_mock older
    end

    test 'when both first and last name are out of sync' do
      newer = Minitest::Mock.new
      older = Minitest::Mock.new
      new_fname = 'NewFname'
      new_lname = 'NewLname'
      old_fname = 'OldFname'
      old_lname = 'OldLname'

      newer.expect(:first_name, new_fname)
      newer.expect(:last_name, new_lname)
      older.expect(:first_name, old_fname)
      older.expect(:last_name, old_lname)
      older.expect(:update!, nil, [{first_name: new_fname, last_name: new_lname }])

      assert_broadcast(:ok) { SyncName.call(newer: newer, older: older) }
      assert_mock newer
      assert_mock older
    end
  end
end
