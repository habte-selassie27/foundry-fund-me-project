// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script, console } from "forge-std/Script.sol";
import { FundMe } from "../src/FundMe.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployFundMe is Script{

    function run() external returns(FundMe){
      // before startBroadcast --> Not a Txn
      HelperConfig helperConfig = new HelperConfig();
      address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
      

       // after startBroadcast --> Real Txn
       vm.startBroadcast();
       FundMe fundMe = new FundMe(ethUsdPriceFeed);
       vm.stopBroadcast(); 
       return fundMe;
    }

}
