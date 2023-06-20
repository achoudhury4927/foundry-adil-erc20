// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error MyToken_BalanceTooLow();
error MyToken_AllowanceTooLow();

/**
 * @title A sample ERC-20 Token contract
 * @author Adil Choudhury
 * @notice This contract is for creating an ERC-20 token
 * @dev This is an attempt to create an ERC-20 solely based on https://eips.ethereum.org/EIPS/eip-20 with no libraries
 * @custom:experimental This tag will be used to explain differences Ive found compared to OZ interface
 */
contract MyToken {
    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) s_allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /**
     * @custom:experimental This is a private variable set in the constructor of the contract.
     * The method then returns the value of that variable.
     * On Remix:
     * 706 gas when called by a contract returning string directly
     * 3397 gas when called by a contract returning a _name variable
     */
    function name() public pure returns (string memory) {
        return "My Token";
    }

    /**
     * @custom:experimental This is a private variable set in the constructor of the contract.
     * The method then returns the value of that variable.
     * On Remix:
     * 728 gas when called by a contract returning string directly
     * 3420 gas when called by a contract returning a _symbol variable
     */
    function symbol() public pure returns (string memory) {
        return "AMT";
    }

    function decimals() public pure returns (uint8) {
        return 3;
    }

    /**
     * @custom:experimental This is a private variable _totalSupply.
     * The method then returns the value of _totalSupply.
     * This is because the value of total supply can change with mints and burns.
     * My contract doesn't use total supply for any logic which makes it useless
     * I also cannot mint any tokens in this contract
     */
    function totalSupply() public pure returns (uint256) {
        return 1000;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    /**
     * @custom:experimental This method uses a hook to check the logic instead of repeating it for multiple methods
     * It also checks for the 0 address for to and from
     * It combines transferFrom into it and uses intermediary methods to add the required detail of "from"
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        if (_value > balanceOf(msg.sender)) revert MyToken_BalanceTooLow();
        uint256 previousBalanceOfFrom = balanceOf(msg.sender);
        uint256 previousBalanceOfTo = balanceOf(_to);
        s_balances[msg.sender] -= _value;
        s_balances[_to] += _value;
        require(s_balances[msg.sender] == (previousBalanceOfFrom - _value));
        require(s_balances[_to] == (previousBalanceOfTo + _value));
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        if (_value > balanceOf(_from)) revert MyToken_BalanceTooLow();
        if (_value > s_allowance[msg.sender][_from])
            revert MyToken_AllowanceTooLow();

        uint256 previousBalanceOfFrom = balanceOf(_from);
        uint256 previousBalanceOfTo = balanceOf(_to);
        uint256 previousBalanceOfApproval = s_allowance[msg.sender][_from];

        s_balances[_from] -= _value;
        s_balances[_to] += _value;
        s_allowance[msg.sender][_from] -= _value;

        require(s_balances[_from] == (previousBalanceOfFrom - _value));
        require(s_balances[_to] == (previousBalanceOfTo + _value));
        require(
            s_allowance[msg.sender][_from] ==
                (previousBalanceOfApproval - _value)
        );

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev There is currently an attack vector in this method where a spender could
     *      front-run an approver changing their spending value allowing them to "double spend their allowance"
     *
     * @custom:experimental Line 122 is not there as a contract which can send infinite (like Dex's)
     * will not be allowed to function at all if the user doesn't have a balance.
     */

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        if (_value > balanceOf(msg.sender)) revert MyToken_BalanceTooLow();
        s_allowance[_spender][msg.sender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        return s_allowance[_spender][_owner];
    }

    /**
     * @custom:experimental Missing the following:
     * Hooks to use to check logic of balances before and after a transfer
     * Ability to mint tokens
     * Ability to burn tokens
     * Decrease and Increase allowance methods that use the allowance function to update allowance meaning users cant double spend
     *
     */
}
