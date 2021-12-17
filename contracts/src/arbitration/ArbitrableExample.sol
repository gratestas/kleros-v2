// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "../api/AbstractArbitrable.sol";

/**
 *  @title ArbitrableExample
 *  An example of the arbitrable contract which connects to the arbitator that implements IArbitrator interface.
 */
contract ArbitrableExample is AbstractArbitrable {
    struct DisputeStruct {
        bool isRuled; // Whether the dispute has been ruled or not.
        uint256 ruling; // Ruling given by the arbitrator.
        uint256 numberOfRulingOptions; // The number of choices the arbitrator can give.
    }

    IArbitrator public immutable arbitrator; // Arbitrator is set in constructor and never changed.

    mapping(uint256 => uint256) public externalIDtoLocalID; // Maps external (arbitrator side) dispute IDs to local dispute IDs.

    DisputeStruct[] public disputes; // Stores the disputes' info. disputes[disputeID].

    /** @dev Constructor
     *  @param _arbitrator The arbitrator to rule on created disputes.
     */
    constructor(IArbitrator _arbitrator) {
        arbitrator = _arbitrator;
    }

    /** @dev TRUSTED. Calls createDispute function of the specified arbitrator to create a dispute.
        Note that we don’t need to check that msg.value is enough to pay arbitration fees as it’s the responsibility of the arbitrator contract.
     *  @param _numberOfRulingOptions Number of ruling options. Must be greater than 1, otherwise there is nothing to choose from.
     *  @param _arbitratorExtraData Extra data for the arbitrator.
     *  @return disputeID Dispute id (on arbitrator side) of the dispute created.
     */
    function createDispute(uint256 _numberOfRulingOptions, bytes calldata _arbitratorExtraData)
        external
        payable
        returns (uint256 disputeID)
    {
        require(_numberOfRulingOptions > 1, "Incorrect number of choices");

        uint256 localDisputeID = disputes.length;
        disputes.push(DisputeStruct({isRuled: false, ruling: 0, numberOfRulingOptions: _numberOfRulingOptions}));

        disputeID = arbitrator.createDispute{value: msg.value}(_numberOfRulingOptions, _arbitratorExtraData);

        externalIDtoLocalID[disputeID] = localDisputeID;
    }

    /** @dev To be called by the arbitrator of the dispute, to declare the winning ruling.
     *  @param _externalDisputeID ID of the dispute in arbitrator contract.
     *  @param _ruling The ruling choice of the arbitration.
     */
    function rule(uint256 _externalDisputeID, uint256 _ruling) external override {
        uint256 localDisputeID = externalIDtoLocalID[_externalDisputeID];
        DisputeStruct storage dispute = disputes[localDisputeID];
        require(msg.sender == address(arbitrator), "Only the arbitrator can execute this.");
        require(_ruling <= dispute.numberOfRulingOptions, "Invalid ruling.");
        require(dispute.isRuled == false, "This dispute has been ruled already.");

        dispute.isRuled = true;
        dispute.ruling = _ruling;

        emit Ruling(IArbitrator(msg.sender), _externalDisputeID, dispute.ruling);
    }
}
