// Diode Contracts
// Copyright 2020 IoT Blockchain Technology Corporation LLC (IBTC)
// Licensed under the Diode License, Version 1.0
pragma solidity ^0.6.5;

contract CallForwarder {
    address immutable target;

    constructor(address _target) public {
        target = _target; 
    } 

    fallback() external payable {
        address t = target;
        assembly {
            calldatacopy(0x0, 0x0, calldatasize())
            let result := call(gas(), t, 0, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }
}
