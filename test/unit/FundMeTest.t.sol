// SPDX-Indirect-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address immutable i_user = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_VALUE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(i_user, INITIAL_VALUE);
    }

    function test_MinumUsdIsFive() public {
        assertEq(5e18, fundMe.getMinumumUsd());
    }

    function test_OwnerIsMsgSender() public {
        assertEq(address(msg.sender), fundMe.getOwner());
    }

    function test_PriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log("Price Feed Version: %s", version);
        assertNotEq(0, version);
    }

    function test_FundMeFailWithoutEnoughtETH() public {
        vm.expectRevert();
        fundMe.fund{value: 0}();
    }

    modifier funded() {
        vm.prank(i_user);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function test_FundMeCanUpdateAddressToAmountFunded() public funded {
        assertEq(SEND_VALUE, fundMe.getAddressToAmountFunded(address(i_user)));
    }

    function test_FundMeCanUpdateFunders() public funded {
        assertEq(address(i_user), fundMe.getFunders(0));
    }

    function test_RevertIf_WithdrawNotOwner() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function test_WithdrawFromSingleFunder() public funded {
        // set up
        address owner = fundMe.getOwner();
        uint256 startOnwerBalance = address(owner).balance;
        uint256 startContractBalance = address(fundMe).balance;

        // act
        vm.prank(owner);
        fundMe.withdraw();

        // assert
        uint256 endOnwerBalance = address(owner).balance;
        uint256 endContractBalance = address(fundMe).balance;
        assertEq(0, endContractBalance);
        assertEq(endOnwerBalance, startOnwerBalance + startContractBalance);
    }

    function withdrawFromMultiFunders(bool cheaper) private {
        // set up
        uint256 startIndex = 1;
        uint256 numOfFunders = 10;
        for (uint256 i = startIndex; i < numOfFunders; i++) {
            hoax(address(uint160(i)), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        address owner = fundMe.getOwner();
        uint256 startOnwerBalance = address(owner).balance;
        uint256 startContractBalance = address(fundMe).balance;

        // act
        vm.startPrank(owner);
        if (!cheaper) {
            fundMe.withdraw();
        } else {
            fundMe.withdrawCheaper();
        }

        vm.stopPrank();

        // assert
        uint256 endOnwerBalance = address(owner).balance;
        uint256 endContractBalance = address(fundMe).balance;
        assertEq(0, endContractBalance);
        assertEq(endOnwerBalance, startOnwerBalance + startContractBalance);
    }

    function test_WithdrawFromMultiFunders() public funded {
        withdrawFromMultiFunders(false);
    }

    function test_WithdrawCheaperFromMultiFunders() public funded {
        withdrawFromMultiFunders(true);
    }
}
