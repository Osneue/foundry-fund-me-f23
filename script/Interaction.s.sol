// SPDX-Indirect-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(FundMe fundMeContract) public {
        vm.startBroadcast();
        fundMeContract.fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        console.log("mostRecentlyDeployedContract: %s", mostRecentlyDeployedContract);
        fundFundMe(FundMe(payable(mostRecentlyDeployedContract)));
    }
}

contract WithrawFundMe is Script {
    function withdrawFundMe(FundMe fundMeContract) public {
        vm.startBroadcast();
        fundMeContract.withdrawCheaper();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        console.log("mostRecentlyDeployedContract: %s", mostRecentlyDeployedContract);
        withdrawFundMe(FundMe(payable(mostRecentlyDeployedContract)));
    }
}
