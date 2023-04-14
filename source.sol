// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IConnext} from "@connext/interfaces/core/IConnext.sol";

interface IWstETH {
    function stEthPerToken() external view returns (uint256);
}

/**
 * @title WstethRateProvider
 * @notice Example source contract that sends a wstETH rate to a target contract.
 */
contract WstethRateProvider {

  address public constant wstETHAddress = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

  // The connext contract on the origin domain.
  IConnext public immutable connext;

  constructor(address _connext) {
    connext = IConnext(_connext);
  }

  // Get the stEthPerToken value from the wstETH contract
  function getStEthPerToken() public view returns (uint256) {
    IWstETH wstETH = IWstETH(wstETHAddress);
    return wstETH.stEthPerToken();
  }

  /** @notice Updates the wstETH rate on the target contract.
    * @param target Address of the target contract.
    * @param destinationDomain The destination domain ID.
    * @param relayerFee The fee offered to relayers.
    */
  function xUpdateRate (
    address target, 
    uint32 destinationDomain,
    uint256 relayerFee
  ) external payable {
      
    uint256 newRate = getStEthPerToken();
    // Encode the data needed for the target contract call.
    bytes memory callData = abi.encode(newRate);

    connext.xcall{value: relayerFee}(
      destinationDomain, // _destination: Domain ID of the destination chain
      target,            // _to: address of the target contract
      address(0),        // _asset: use address zero for 0-value transfers
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      0,                 // _amount: 0 because no funds are being transferred
      0,                 // _slippage: can be anything between 0-10000 because no funds are being transferred
      callData           // _callData: the encoded calldata to send
    );
  }
}
