// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Credentials.sol";

/**
 * This contract manages quests and missions that learners can embark on. It allows authorized entities to create and manage quests, and learners to track their progress and earn rewards upon completion.
 * @title Quests
 * @author Chukwuka Uba <promiseuba67@gmail.com>
 * @notice
 */

contract Quests is AccessControl {
	bytes32 public constant QUEST_CREATOR_ROLE =
		keccak256("QUEST_CREATOR_ROLE");
	uint256 private _nextQuestId;

	struct Quest {
		uint256 id;
		string name;
		string description;
		uint256[] courseIds;
		uint256 tokenReward;
	}

	mapping(uint256 => Quest) public quests;
	mapping(address => mapping(uint256 => bool)) public completedQuests;

	IERC20 public tokenContract;
	Credentials public credentialsContract;

	constructor(address _tokenContract, address _credentialsContract) {
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		tokenContract = IERC20(_tokenContract);
		credentialsContract = Credentials(_credentialsContract);
	}

	function createQuest(
		string memory name,
		string memory description,
		uint256[] memory courseIds,
		uint256 tokenReward
	) public onlyRole(QUEST_CREATOR_ROLE) {
		uint256 questId = _nextQuestId++;
		Quest memory newQuest = Quest(
			questId,
			name,
			description,
			courseIds,
			tokenReward
		);
		quests[questId] = newQuest;
	}

	function completeQuest(uint256 questId) public {
		Quest storage quest = quests[questId];
		require(quest.id != 0, "Invalid quest ID");

		bool allCoursesCompleted = true;
		for (uint256 i = 0; i < quest.courseIds.length; i++) {
			if (
				!credentialsContract.verifyCredential(
					msg.sender,
					quest.courseIds[i]
				)
			) {
				allCoursesCompleted = false;
				break;
			}
		}

		require(allCoursesCompleted, "Not all courses completed");
		require(
			!completedQuests[msg.sender][questId],
			"Quest already completed"
		);

		completedQuests[msg.sender][questId] = true;
		tokenContract.transfer(msg.sender, quest.tokenReward);
	}

	function grantQuestCreatorRole(
		address account
	) public onlyRole(DEFAULT_ADMIN_ROLE) {
		_grantRole(QUEST_CREATOR_ROLE, account);
	}

	function revokeQuestCreatorRole(
		address account
	) public onlyRole(DEFAULT_ADMIN_ROLE) {
		_revokeRole(QUEST_CREATOR_ROLE, account);
	}
}
