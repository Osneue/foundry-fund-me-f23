// SPDX-Indirect-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithrawFundMe} from "script/Interaction.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;
    address immutable i_user = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_VALUE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(i_user, INITIAL_VALUE);
    }

    function test_UserCanFundAndOwnerCanWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(fundMe);

        WithrawFundMe withdrawFundMe = new WithrawFundMe();
        withdrawFundMe.withdrawFundMe(fundMe);

        assertEq(0, address(fundMe).balance);
    }
}
