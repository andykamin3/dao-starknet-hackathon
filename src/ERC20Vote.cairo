// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add


from openzeppelin.token.erc20.library import ERC20

struct Checkpoint{
    from_block: felt,
    votes: Uint256 
}

@storage_var
func _checkpoints(address:felt, index:felt) -> (res: Checkpoint) {
}

@storage_var
func _last_checkpoint(address:felt) -> (res: felt) {
}

@storage_var
func _delegates(sender:felt) -> (delegate: felt) {
} // Address to which a user has delegated their votes. 

// Events
@event
func DelegationChanged(amount: felt, from_delegate: felt, to_delegate: felt) {
}

// View functions

@view
func get_checkpoint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt, index: felt) -> (checkpoint: Checkpoint){
    let (checkpoint) = _checkpoints.read(address, index);
    return checkpoint;
}

@view
func get_last_checkpoint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) -> (last_checkpoint: Checkpoint){
    let (last_checkpoint_index) = _last_checkpoint.read(address);
    let (last_checkpoint) = _checkpoints.read(address, last_checkpoint_index);
    return last_checkpoint;
}



@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, symbol: felt, decimals: felt, initial_supply: Uint256, recipient: felt
) {
    ERC20.initializer(name, symbol, decimals);
    ERC20._mint(recipient, initial_supply);
    return ();
}


//
// Getters
//

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC20.name();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC20.symbol();
}

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    totalSupply: Uint256
) {
    let (totalSupply: Uint256) = ERC20.total_supply();
    return (totalSupply=totalSupply);
}

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    decimals: felt
) {
    return ERC20.decimals();
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    balance: Uint256
) {
    return ERC20.balance_of(account);
}

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, spender: felt
) -> (remaining: Uint256) {
    return ERC20.allowance(owner, spender);
}

//
// Externals
//

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer(recipient, amount);
}

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    sender: felt, recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer_from(sender, recipient, amount);
}

@external
func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.approve(spender, amount);
}

@external
func increaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, added_value: Uint256
) -> (success: felt) {
    return ERC20.increase_allowance(spender, added_value);
}

@external
func decreaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, subtracted_value: Uint256
) -> (success: felt) {
    return ERC20.decrease_allowance(spender, subtracted_value);
}

// Vote 

@external
func delegate{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(delegate: felt) -> (success: felt) {
    let (sender) = get_caller_address();
    let (sender_balance) = balanceOf(sender);
    return _delegate(sender, delegate);
}

func _delegate{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(sender: felt, delegate: felt) -> (success: felt) {
    let (sender_balance) = balanceOf(sender);
    let (sender_delegation) = _delegates.read(sender);
    with_attr error_message("ERC20: cannot delegate zero balance") {
            assert_not_zero(sender_balance);
    }
    with_attr error_message("ERC20: cannot delegate to zero address") {
            assert_not_zero(delegate);
    }
    let (prev_delegate) = _delegates.read(sender);
    let block_num= get_block_number();
    let (prev_delegate_checkpoint) = get_last_checkpoint(delegate);    
    let (curr_delegate_checkpoint) = get_last_checkpoint(delegate);
    let (curr_delegate_checkpoint_votes) = curr_delegate_checkpoint.votes;
    let (prev_delegate_checkpoint_votes) = curr_delegate_checkpoint.votes;

    let new_prev_votes = uint256_sub(prev_delegate_checkpoint_votes, sender_balance);
    let new_curr_votes = uint256_add(prev_delegate_checkpoint_votes, sender_balance);
    
    let curr_new_checkpoint = Checkpoint(from_block=block_num, votes=new_curr_votes);
    let prev_new_checkpoint = Checkpoint(from_block=block_num, votes=new_prev_votes);

    let curr_checkpoint_position = _last_checkpoint.read(delegate) + 1;
    let prev_checkpoint_position = _last_checkpoint.read(delegate) + 1;
    _delegates.write(sender = sender, delegate=delegate);
    _checkpoints.write(address=delegate, index=curr_checkpoint_position, checkpoint=curr_new_checkpoint);
    _checkpoints.write(address=prev_delegate, index=prev_checkpoint_position, checkpoint=prev_new_checkpoint);
    return 1;
}

