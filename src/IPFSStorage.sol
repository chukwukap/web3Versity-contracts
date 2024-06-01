// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
*  IPFSStorage (Decentralized Storage)
This contract provides a simple interface for storing and retrieving data on the InterPlanetary File System (IPFS), a decentralized storage solution used in the Web3Versity platform for storing course materials, user data, and other relevant information.
@author
 */
contract IPFSStorage is AccessControl {
	bytes32 public constant UPLOADER_ROLE = keccak256("UPLOADER_ROLE");

	mapping(bytes32 => string) public ipfsData;

	constructor() {
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
	}

	function storeData(
		bytes32 hash,
		string memory data
	) public onlyRole(UPLOADER_ROLE) {
		ipfsData[hash] = data;
	}

	function retrieveData(bytes32 hash) public view returns (string memory) {
		return ipfsData[hash];
	}

	function grantUploaderRole(
		address account
	) public onlyRole(DEFAULT_ADMIN_ROLE) {
		_grantRole(UPLOADER_ROLE, account);
	}

	function revokeUploaderRole(
		address account
	) public onlyRole(DEFAULT_ADMIN_ROLE) {
		_revokeRole(UPLOADER_ROLE, account);
	}
}
