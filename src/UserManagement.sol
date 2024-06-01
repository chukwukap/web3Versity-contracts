// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserManagement {
	// Struct to store user data
	struct User {
		string did; // Decentralized Identifier (DID)
		string role; // User role (e.g., admin, user)
		bool isActive; // Is the user account active?
		mapping(bytes32 => string) metadata; // User metadata
	}

	// Mapping to store user data
	mapping(address => User) private users;

	// Role identifiers
	bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
	bytes32 public constant USER_ROLE = keccak256("USER");

	// Events
	event UserRegistered(address indexed userAddress, string did, bytes32 role);
	event UserDeactivated(address indexed userAddress, string did);
	event MetadataUpdated(address indexed userAddress, bytes32 key);

	// Modifiers for access control
	modifier onlyAdmin() {
		require(hasRole(msg.sender, ADMIN_ROLE), "Caller must be an admin");
		_;
	}

	modifier onlyActiveUser() {
		require(users[msg.sender].isActive, "User account is not active");
		_;
	}

	// Register a new user
	function registerUser(string memory _did, bytes32 _role) public onlyAdmin {
		require(
			bytes(users[msg.sender].did).length == 0,
			"User already registered"
		);
		require(_role == ADMIN_ROLE || _role == USER_ROLE, "Invalid role");

		users[msg.sender] = User(_did, getRoleString(_role), true);
		emit UserRegistered(msg.sender, _did, _role);
	}

	// Deactivate a user account
	function deactivateUser(address _userAddress) public onlyAdmin {
		require(
			bytes(users[_userAddress].did).length != 0,
			"User not registered"
		);

		users[_userAddress].isActive = false;
		emit UserDeactivated(_userAddress, users[_userAddress].did);
	}

	// Get user data
	function getUserData(
		address _userAddress
	) public view returns (string memory, string memory, bool) {
		require(
			bytes(users[_userAddress].did).length != 0,
			"User not registered"
		);

		User memory user = users[_userAddress];
		return (user.did, user.role, user.isActive);
	}

	// Update user metadata
	function updateMetadata(
		bytes32 _key,
		string memory _value
	) public onlyActiveUser {
		users[msg.sender].metadata[_key] = _value;
		emit MetadataUpdated(msg.sender, _key);
	}

	// Check if a user has a specific role
	function hasRole(
		address _userAddress,
		bytes32 _role
	) public view returns (bool) {
		require(
			bytes(users[_userAddress].did).length != 0,
			"User not registered"
		);
		return
			bytes(users[_userAddress].role).length > 0 &&
			keccak256(bytes(users[_userAddress].role)) == _role;
	}

	// Helper function to get the string representation of a role
	function getRoleString(bytes32 _role) private pure returns (string memory) {
		if (_role == ADMIN_ROLE) {
			return "admin";
		} else if (_role == USER_ROLE) {
			return "user";
		} else {
			return "";
		}
	}
}
