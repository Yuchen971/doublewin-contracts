// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract VRFConsumer is VRFConsumerBaseV2Plus {
    uint256 public s_subscriptionId;
    bytes32 public s_keyHash;
    uint32 public s_callbackGasLimit;
    uint16 public s_requestConfirmations;

    struct RandomResult {
        uint256 randomWord;
        uint256 requestId;
        uint256 fulfilledAt;
    }

    RandomResult public latestResult;
    mapping(uint256 => bool) public pendingRequests;

    event RandomRequested(uint256 indexed requestId);
    event RandomFulfilled(uint256 indexed requestId, uint256 randomWord);

    constructor(
        address vrfCoordinator,
        uint256 subscriptionId,
        bytes32 keyHash,
        uint32 callbackGasLimit,
        uint16 requestConfirmations
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_subscriptionId = subscriptionId;
        s_keyHash = keyHash;
        s_callbackGasLimit = callbackGasLimit;
        s_requestConfirmations = requestConfirmations;
    }

    function requestRandomWord() external onlyOwner returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: s_requestConfirmations,
                callbackGasLimit: s_callbackGasLimit,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        pendingRequests[requestId] = true;
        emit RandomRequested(requestId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        require(pendingRequests[requestId], "Unknown request");
        delete pendingRequests[requestId];
        latestResult = RandomResult({
            randomWord: randomWords[0],
            requestId: requestId,
            fulfilledAt: block.timestamp
        });
        emit RandomFulfilled(requestId, randomWords[0]);
    }

    function getLatestRandom()
        external
        view
        returns (uint256 randomWord, uint256 requestId, uint256 fulfilledAt)
    {
        return (
            latestResult.randomWord,
            latestResult.requestId,
            latestResult.fulfilledAt
        );
    }
}
