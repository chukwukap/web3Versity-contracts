/* Credentials (NFT Contract)
This contract manages the issuance, verification, and ownership of learning
 credentials represented as non-fungible
 tokens (NFTs). It allows authorized entities (e.g., course instructors, p
 latform admins) to issue credentials, and users to verify and share their earned credentials.
  */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract Credentials is ERC721, AccessControl {
	bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
	uint256 private _nextTokenId;

	error CallerNotIssuer(address issuer);

	struct Credential {
		uint256 courseId;
		string courseName;
		string description;
		string metadata;
	}

	mapping(uint256 => Credential) public credentials;
	mapping(address => mapping(uint256 => bool)) public issuedCredentials;

	constructor() ERC721("Web3Versity Credentials", "W3V") {
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
	}

	function issueCredential(
		address recipient,
		uint256 courseId,
		string memory courseName,
		string memory description,
		string memory metadata
	) public onlyRole(ISSUER_ROLE) {
		require(
			!issuedCredentials[recipient][courseId],
			"Credential already issued"
		);
		uint256 tokenId = _nextTokenId++;
		_safeMint(recipient, tokenId);
		Credential memory newCredential = Credential(
			courseId,
			courseName,
			description,
			metadata
		);
		credentials[tokenId] = newCredential;
		issuedCredentials[recipient][courseId] = true;
	}

	function verifyCredential(
		address user,
		uint256 courseId
	) public view returns (bool) {
		return issuedCredentials[user][courseId];
	}

	function grantIssuerRole(
		address account
	) public onlyRole(DEFAULT_ADMIN_ROLE) {
		_grantRole(ISSUER_ROLE, account);
	}

	function revokeIssuerRole(
		address account
	) public onlyRole(DEFAULT_ADMIN_ROLE) {
		_revokeRole(ISSUER_ROLE, account);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view virtual override(ERC721, AccessControl) returns (bool) {
		return
			super.supportsInterface(interfaceId) ||
			ERC165.supportsInterface(interfaceId);
	}
}
